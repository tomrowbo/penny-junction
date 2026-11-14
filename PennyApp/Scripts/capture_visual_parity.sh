#!/bin/bash
set -euo pipefail

script_dir=$(cd "$(dirname "$0")" && pwd)
app_dir=$(cd "$script_dir/.." && pwd)
workspace_dir=$(cd "$app_dir/.." && pwd)
reference_dir="$app_dir/VisualReferences/SMobiili-2.43.0"
review_dir="$workspace_dir/.impeccable/review"
raw_dir="$review_dir/raw"
build_dir="$review_dir/build"
pair_dir="$review_dir/pairs"
derived_dir="${TMPDIR:-/tmp}/PennyVisualParityDerived"
device_name="Penny Visual Reference"

command -v jq >/dev/null
command -v magick >/dev/null
"$script_dir/build_reference_crops.sh"
mkdir -p "$raw_dir" "$build_dir" "$pair_dir"

device_id=$(xcrun simctl list devices available -j | jq -r --arg name "$device_name" '.devices[][] | select(.name == $name) | .udid' | head -1)
[[ -n "$device_id" ]] || { echo "Missing simulator named '$device_name'." >&2; exit 1; }
runtime=$(xcrun simctl list devices available -j | jq -r --arg id "$device_id" '.devices | to_entries[] | select(any(.value[]; .udid == $id)) | .key')
[[ "$runtime" == *"iOS-26-2"* ]] || { echo "Simulator must use iOS 26.2, got $runtime" >&2; exit 1; }

xcrun simctl boot "$device_id" 2>/dev/null || true
xcrun simctl bootstatus "$device_id" -b
model_identifier=$(xcrun simctl getenv "$device_id" SIMULATOR_MODEL_IDENTIFIER)
[[ "$model_identifier" == "iPhone18,1" ]] || { echo "Simulator must be iPhone 17 Pro, got $model_identifier" >&2; exit 1; }
xcrun simctl ui "$device_id" appearance light
xcrun simctl ui "$device_id" content_size large
[[ "$(xcrun simctl ui "$device_id" appearance)" == "light" ]] || { echo "Unable to set light appearance" >&2; exit 1; }
[[ "$(xcrun simctl ui "$device_id" content_size)" == "large" ]] || { echo "Unable to set default Dynamic Type" >&2; exit 1; }
xcrun simctl status_bar "$device_id" override --time 9:41 --batteryState charged --batteryLevel 100

xcodebuild build -project "$app_dir/PennyApp.xcodeproj" -scheme PennyApp -sdk iphonesimulator \
    -destination "platform=iOS Simulator,id=$device_id" -derivedDataPath "$derived_dir" >/dev/null
xcrun simctl install "$device_id" "$derived_dir/Build/Products/Debug-iphonesimulator/PennyApp.app"

wait_for_render() {
    local output_path=$1
    local attempts=0
    local dominant_pixels=0
    local dominant_hex=""
    local dominant_line=""
    local sampled_pixels=$((64 * 128))
    local previous_signature=""
    local current_signature=""
    local stable_frames=0

    while (( attempts < 80 )); do
        xcrun simctl io "$device_id" screenshot "$output_path" >/dev/null
        dominant_line=$(magick "$output_path" -resize '64x128!' -colors 32 -format '%c' histogram:info:- | sort -nr | head -1)
        dominant_pixels=$(printf '%s' "$dominant_line" | awk -F: '{gsub(/ /, "", $1); print $1}')
        dominant_hex=$(printf '%s' "$dominant_line" | sed -E 's/.*#([0-9A-Fa-f]{6}).*/\1/' | tr '[:lower:]' '[:upper:]')
        if [[ "$dominant_hex" != "007A36" ]] || (( dominant_pixels * 100 / sampled_pixels < 50 )); then
            current_signature=$(magick "$output_path" -resize '32x64!' -colorspace Gray -format '%#' info:)
            if [[ "$current_signature" == "$previous_signature" ]]; then
                stable_frames=$((stable_frames + 1))
                if (( stable_frames >= 2 )); then
                    return 0
                fi
            else
                stable_frames=0
                previous_signature=$current_signature
            fi
        fi
        attempts=$((attempts + 1))
        sleep 0.25
    done

    echo "App did not leave its launch screen for $output_path" >&2
    return 1
}

while IFS=$'\t' read -r state launch_state crop build_offset_y; do
    xcrun simctl terminate "$device_id" com.tomrowbotham.junction.penny 2>/dev/null || true
    SIMCTL_CHILD_PENNY_DEMO_STATE="$launch_state" xcrun simctl launch "$device_id" com.tomrowbotham.junction.penny -AppleLanguages '(en)' -AppleLocale en_FI >/dev/null
    wait_for_render "$raw_dir/$state.png"
    dimensions=$(magick identify -format '%wx%h' "$raw_dir/$state.png")
    [[ "$dimensions" == "1206x2622" ]] || { echo "Unexpected simulator screenshot size: $dimensions" >&2; exit 1; }
    target_width=${crop%%x*}
    crop_tail=${crop#*x}
    target_height=${crop_tail%%+*}
    magick "$raw_dir/$state.png" -resize "${target_width}x" -gravity north -crop "${target_width}x${target_height}+0+${build_offset_y}" +repage "$build_dir/$state.png"
    magick "$review_dir/reference/$state.png" "$build_dir/$state.png" +append "$pair_dir/$state-pair.png"
done < <(jq -r '.comparisons[] | [.state, .launchState, .crop, (.buildOffsetY // 0)] | @tsv' "$reference_dir/crops.json")

echo "Visual parity pairs written to $pair_dir"
