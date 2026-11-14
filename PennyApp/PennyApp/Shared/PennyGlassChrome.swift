import SwiftUI

struct PennyGlassTabBar: View {
    @Binding var selection: AppTab
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: 2) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Button {
                    if reduceMotion {
                        selection = tab
                    } else {
                        withAnimation(.snappy(duration: 0.28)) {
                            selection = tab
                        }
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
                    .foregroundStyle(selection == tab ? PennyTheme.obsidian : PennyTheme.textSecondary)
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
                .fill(reduceTransparency ? Color.white : Color.white.opacity(0.74))
                .background(.ultraThinMaterial, in: Capsule(style: .continuous))
                .overlay {
                    Capsule(style: .continuous)
                        .strokeBorder(Color.black.opacity(0.10), lineWidth: 0.7)
                }
        }
        .shadow(color: PennyTheme.obsidian.opacity(0.14), radius: 20, y: 10)
        .padding(.horizontal, 12)
        .padding(.top, 6)
        .padding(.bottom, 4)
    }

    @ViewBuilder
    private func icon(for tab: AppTab) -> some View {
        switch tab {
        case .askPenny:
            PennyMark(size: selection == tab ? 30 : 25)
                .padding(2)
                .background(Color.white.opacity(selection == tab ? 0.96 : 0.72), in: Circle())
        case .spend:
            artworkIcon("SpendNavIcon", size: 30, for: tab)
        case .plan:
            artworkIcon("PlanNavIcon", size: 36, for: tab)
        case .incoming:
            artworkIcon("IncomingNavIcon", size: 32, for: tab)
        }
    }

    private func artworkIcon(_ name: String, size: CGFloat, for tab: AppTab) -> some View {
        Image(name)
            .renderingMode(.original)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .scaleEffect(selection == tab ? 1.05 : 1)
            .frame(width: 36, height: 28)
            .accessibilityHidden(true)
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
                    .foregroundStyle(PennyTheme.textPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(PennyTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer(minLength: 12)
            Button {
                showsProfile = true
            } label: {
                ProfileAvatar(size: 38)
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

struct ProfileAvatar: View {
    var size: CGFloat

    var body: some View {
        Image("ProfileAvatar")
            .renderingMode(.original)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .padding(4)
            .background(Color.white.opacity(0.94), in: Circle())
            .overlay { Circle().strokeBorder(Color.black.opacity(0.08), lineWidth: 0.75) }
            .accessibilityHidden(true)
    }
}
