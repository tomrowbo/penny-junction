import SwiftUI

enum PennyTheme {
    static let visualIdentity = "obsidian-emerald"
    static let usesPaleGreenSurfaces = false
    static let spendHeroAssetName = "SpendAurora"

    static let obsidian = Color(red: 0.025, green: 0.075, blue: 0.055)
    static let forest = Color(red: 0.025, green: 0.22, blue: 0.14)
    static let emerald = Color(red: 0.00, green: 0.58, blue: 0.31)
    static let emeraldBright = Color(red: 0.00, green: 0.48, blue: 0.25)
    static let heroAccent = Color(red: 0.24, green: 0.96, blue: 0.58)
    static let heroSecondary = Color.white.opacity(0.68)
    static let glassOpaque = Color.white
    static let glassEdge = Color.black.opacity(0.10)
    static let textPrimary = Color(red: 0.055, green: 0.075, blue: 0.065)
    static let textSecondary = Color(red: 0.31, green: 0.34, blue: 0.32)

    static let green = emerald
    static let darkGreen = emeraldBright
    static let vividGreen = emeraldBright
    static let mint = Color.black.opacity(0.045)
    static let paleGreen = Color.white
    static let canvas = Color(red: 0.965, green: 0.965, blue: 0.95)
    static let warning = Color(red: 1.00, green: 0.70, blue: 0.25)
}

struct PennyAtmosphere: View {
    var body: some View {
        ZStack {
            PennyTheme.canvas
            RadialGradient(
                colors: [PennyTheme.emerald.opacity(0.10), .clear],
                center: .topTrailing,
                startRadius: 12,
                endRadius: 420
            )
            LinearGradient(
                colors: [Color.white.opacity(0.82), PennyTheme.canvas.opacity(0.96)],
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
                        .fill(PennyTheme.glassOpaque.opacity(reduceTransparency ? 1 : 0.68))
                    if !reduceTransparency {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(.ultraThinMaterial)
                    }
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Color.black.opacity(contrast == .increased ? 0.22 : 0.09), lineWidth: 0.75)
            }
            .shadow(color: PennyTheme.obsidian.opacity(0.10), radius: 18, y: 10)
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
