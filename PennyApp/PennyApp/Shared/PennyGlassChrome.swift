import SwiftUI

struct PennyGlassTabBar: View {
    @Binding var selection: AppTab
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        HStack(spacing: 2) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.snappy(duration: 0.28)) {
                        selection = tab
                    }
                } label: {
                    VStack(spacing: 5) {
                        icon(for: tab)
                            .frame(height: 28)
                        Text(tab.title)
                            .font(.caption2.weight(selection == tab ? .bold : .medium))
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                    }
                    .foregroundStyle(selection == tab ? Color.white : Color.white.opacity(0.66))
                    .frame(maxWidth: .infinity, minHeight: 58)
                    .contentShape(Rectangle())
                    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.title)
                .accessibilityAddTraits(selection == tab ? .isSelected : [])
            }
        }
        .padding(5)
        .background {
            Capsule(style: .continuous)
                .fill(reduceTransparency ? Color(red: 0.035, green: 0.075, blue: 0.065) : Color.black.opacity(0.34))
                .background(.ultraThinMaterial, in: Capsule(style: .continuous))
                .overlay {
                    Capsule(style: .continuous)
                        .strokeBorder(Color.white.opacity(0.16), lineWidth: 0.7)
                }
        }
        .shadow(color: .black.opacity(0.28), radius: 20, y: 10)
        .padding(.horizontal, 12)
        .padding(.top, 6)
        .padding(.bottom, 4)
    }

    @ViewBuilder
    private func icon(for tab: AppTab) -> some View {
        if tab == .askPenny {
            PennyMark(size: selection == tab ? 30 : 25)
                .padding(2)
                .background(Color.white.opacity(selection == tab ? 0.96 : 0.72), in: Circle())
        } else {
            Image(systemName: tab.symbol)
                .font(.system(size: 19, weight: selection == tab ? .bold : .medium))
                .symbolVariant(selection == tab ? .fill : .none)
                .frame(width: 32, height: 28)
        }
    }
}

struct PennyRootHeader: View {
    let title: String
    var subtitle: String? = nil
    @State private var showsProfile = false

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.white)
                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(Color.white.opacity(0.62))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer(minLength: 12)
            Button {
                showsProfile = true
            } label: {
                PennyMark(size: 34)
                    .padding(4)
                    .background(Color.white.opacity(0.92), in: Circle())
                    .frame(width: 48, height: 48)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open profile")
        }
        .sheet(isPresented: $showsProfile) {
            MeView()
        }
    }
}
