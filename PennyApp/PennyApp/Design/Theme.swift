import SwiftUI

enum PennyTheme {
    static let visualIdentity = "obsidian-emerald"
    static let usesPaleGreenSurfaces = false
    static let spendHeroAssetName = "SpendAurora"

    static let obsidian = Color(red: 0.018, green: 0.027, blue: 0.025)
    static let forest = Color(red: 0.025, green: 0.115, blue: 0.082)
    static let emerald = Color(red: 0.08, green: 0.82, blue: 0.43)
    static let emeraldBright = Color(red: 0.26, green: 0.96, blue: 0.58)
    static let glassOpaque = Color(red: 0.045, green: 0.075, blue: 0.065)
    static let glassEdge = Color.white.opacity(0.14)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.68)

    static let green = emerald
    static let darkGreen = emeraldBright
    static let vividGreen = emeraldBright
    static let mint = Color.white.opacity(0.075)
    static let paleGreen = glassOpaque
    static let canvas = obsidian
    static let warning = Color(red: 1.00, green: 0.70, blue: 0.25)
}

struct PennyAtmosphere: View {
    var body: some View {
        ZStack {
            PennyTheme.obsidian
            RadialGradient(
                colors: [PennyTheme.emerald.opacity(0.17), .clear],
                center: .topTrailing,
                startRadius: 12,
                endRadius: 420
            )
            LinearGradient(
                colors: [PennyTheme.forest.opacity(0.72), PennyTheme.obsidian.opacity(0.96)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .ignoresSafeArea()
    }
}

private struct PennyGlassSurfaceModifier: ViewModifier {
    let cornerRadius: CGFloat
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var contrast

    func body(content: Content) -> some View {
        content
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(PennyTheme.glassOpaque.opacity(reduceTransparency ? 1 : 0.58))
                    if !reduceTransparency {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(.ultraThinMaterial)
                    }
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Color.white.opacity(contrast == .increased ? 0.32 : 0.13), lineWidth: 0.75)
            }
            .shadow(color: .black.opacity(0.25), radius: 18, y: 10)
    }
}

extension View {
    func pennyGlassSurface(cornerRadius: CGFloat = 24) -> some View {
        modifier(PennyGlassSurfaceModifier(cornerRadius: cornerRadius))
    }
}

extension Decimal {
    var euroCurrency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.locale = Locale(identifier: "en_FI")
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: self as NSDecimalNumber) ?? "€0.00"
    }
}
