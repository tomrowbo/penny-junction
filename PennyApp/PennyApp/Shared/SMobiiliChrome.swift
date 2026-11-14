import SwiftUI

struct SMobiiliHeader: View {
    let title: String
    var leading: AnyView?
    var showsMessages = true

    var body: some View {
        ZStack {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.primary)

            HStack {
                if let leading {
                    leading
                }
                Spacer()
                if showsMessages {
                    SMobiiliMessageButton()
                }
            }
        }
        .padding(.horizontal, SMobiiliMetrics.contentInset)
        .frame(height: SMobiiliMetrics.navigationHeight)
        .background(SMobiiliPalette.surface)
    }
}

struct SMobiiliMessageButton: View {
    var body: some View {
        Button(action: {}) {
            Image(systemName: "bubble.left")
                .font(.body)
                .frame(width: SMobiiliMetrics.minimumTapTarget, height: SMobiiliMetrics.minimumTapTarget)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.primary)
        .accessibilityLabel("Messages")
    }
}

struct SMobiiliServiceRow: View {
    let title: String
    let detail: String
    let symbol: String
    var value: String?

    var body: some View {
        HStack(spacing: 13) {
            SMobiiliServiceGlyph(symbol: symbol)
                .frame(width: SMobiiliMetrics.serviceIconSize, height: SMobiiliMetrics.serviceIconSize)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.smobiiliRowTitle)
                    .foregroundStyle(SMobiiliPalette.green)
                    .fixedSize(horizontal: false, vertical: true)
                if title == "Accounts" {
                    HStack(alignment: .top, spacing: 18) {
                        accountDetail("S-Tili", amount: "80,34 €")
                        accountDetail("Taloustili", amount: "800,00 €")
                    }
                } else {
                    Text(detail)
                        .font(.smobiiliRowDetail)
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer(minLength: 6)

            if let value {
                Text(value)
                    .font(.system(size: 12))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.trailing)
            }

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(SMobiiliPalette.secondaryLabel)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, minHeight: SMobiiliMetrics.serviceRowMinimumHeight, alignment: .leading)
        .background(SMobiiliPalette.surface, in: RoundedRectangle(cornerRadius: SMobiiliMetrics.serviceRowRadius, style: .continuous))
        .contentShape(Rectangle())
        .dynamicTypeSize(...DynamicTypeSize.accessibility2)
    }

    private func accountDetail(_ name: String, amount: String) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(name)
            Text(amount)
        }
        .font(.smobiiliRowDetail)
        .foregroundStyle(.primary)
    }
}

struct SMobiiliActionRow: View {
    let title: String
    var detail: String?
    let symbol: String
    var trailingSymbol = "chevron.right"
    var minimumHeight: CGFloat = 66

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: symbol)
                .foregroundStyle(SMobiiliPalette.green)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                if let detail {
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(SMobiiliPalette.secondaryLabel)
                }
            }
            Spacer()
            Image(systemName: trailingSymbol)
                .font(.caption)
                .foregroundStyle(SMobiiliPalette.secondaryLabel)
        }
        .padding(.horizontal, 16)
        .frame(minHeight: minimumHeight)
        .contentShape(Rectangle())
    }
}

struct SMobiiliTabBar: View {
    @Binding var selection: AppTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Button {
                    selection = tab
                } label: {
                    VStack(spacing: 3) {
                        tabIcon(tab)
                            .frame(height: 24)
                        Text(tab.title)
                            .font(.system(size: 11, weight: selection == tab ? .semibold : .regular))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .foregroundStyle(selection == tab ? SMobiiliPalette.green : Color(.label))
                    .frame(maxWidth: .infinity, minHeight: SMobiiliMetrics.tabBarHeight)
                    .contentShape(Rectangle())
                    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.title)
                .accessibilityAddTraits(selection == tab ? .isSelected : [])
            }
        }
        .background(SMobiiliPalette.surface)
        .overlay(alignment: .top) { Divider() }
    }

    @ViewBuilder
    private func tabIcon(_ tab: AppTab) -> some View {
        Image(systemName: tab.symbol)
            .font(.system(size: 19, weight: selection == tab ? .semibold : .regular))
    }
}

private struct SMobiiliServiceGlyph: View {
    let symbol: String

    var body: some View {
        Group {
            if symbol == "creditcard" {
                RoundedRectangle(cornerRadius: 2)
                    .stroke(SMobiiliPalette.green, lineWidth: 1.5)
                    .frame(width: 25, height: 36)
                    .overlay { SMark(size: 17) }
            } else if symbol == "eurosign.square" {
                RoundedRectangle(cornerRadius: 2)
                    .stroke(SMobiiliPalette.green, lineWidth: 1.5)
                    .frame(width: 25, height: 36)
                    .overlay {
                        Text("€")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(SMobiiliPalette.green)
                    }
            } else if symbol == "trophy" {
                Image(systemName: "trophy")
                    .font(.title3.weight(.regular))
                    .foregroundStyle(SMobiiliPalette.green)
                    .overlay {
                        Text("€")
                            .font(.system(size: 7, weight: .bold))
                            .foregroundStyle(SMobiiliPalette.green)
                            .offset(y: -2)
                    }
            } else {
                Image(systemName: symbol)
                    .font(.title3.weight(.regular))
                    .foregroundStyle(SMobiiliPalette.green)
            }
        }
        .accessibilityHidden(true)
    }
}
