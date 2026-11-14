#!/bin/bash
set -euo pipefail

script_dir=$(cd "$(dirname "$0")" && pwd)
app_dir=$(cd "$script_dir/.." && pwd)
workspace_dir=$(cd "$app_dir/.." && pwd)
reference_dir="$app_dir/VisualReferences/SMobiili-2.43.0"
review_dir="$workspace_dir/.impeccable/review/reference"
metadata="$reference_dir/metadata.json"
crops="$reference_dir/crops.json"

command -v jq >/dev/null
command -v magick >/dev/null
mkdir -p "$review_dir"

expected_width=$(jq -r '.width' "$metadata")
expected_height=$(jq -r '.height' "$metadata")

while IFS=$'\t' read -r file expected; do
    actual=$(shasum -a 256 "$reference_dir/$file" | awk '{print $1}')
    [[ "$actual" == "$expected" ]] || { echo "Reference hash mismatch: $file" >&2; exit 1; }
    dimensions=$(magick identify -format '%wx%h' "$reference_dir/$file")
    [[ "$dimensions" == "${expected_width}x${expected_height}" ]] || {
        echo "Reference dimensions mismatch: $file ($dimensions)" >&2
        exit 1
    }
done < <(jq -r '.images[] | [.file, .sha256] | @tsv' "$metadata")

while IFS=$'\t' read -r state source crop; do
    magick "$reference_dir/$source" -crop "$crop" +repage "$review_dir/$state.png"
done < <(jq -r '.comparisons[] | [.state, .source, .crop] | @tsv' "$crops")

echo "Reference crops written to $review_dir"
