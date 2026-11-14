import SwiftUI

enum PennyBrand {
    static let productName = "Penny"
    static let partnerDescriptor = "for S-Bank"
    static let tagline = "Your money, in plain language"
    static let conceptDisclosure = "Junction concept using synthetic S-Bank data"
}

struct PennyMark: View {
    var size: CGFloat = 44
    var inverse = false

    var body: some View {
        Image(systemName: "sparkles")
            .font(.system(size: size * 0.62, weight: .bold))
            .foregroundStyle(inverse ? .white : PennyTheme.green)
            .frame(width: size, height: size)
            .background(
                (inverse ? Color.white.opacity(0.14) : PennyTheme.mint),
                in: RoundedRectangle(cornerRadius: size * 0.3, style: .continuous)
            )
            .accessibilityLabel(PennyBrand.productName)
    }
}

struct SMark: View {
    var size: CGFloat = 44
    var inverse = false

    var body: some View {
        Image("SBankMark")
            .resizable()
            .renderingMode(.template)
            .scaledToFit()
            .foregroundStyle(inverse ? .white : SMobiiliPalette.green)
            .frame(width: size, height: size)
            .accessibilityLabel("S-mobiili")
    }
}

struct BrandCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
        }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: SMobiiliMetrics.serviceRowRadius, style: .continuous))
    }
}

struct InstitutionBadge: View {
    let institution: Institution
    var size: CGFloat = 38

    var body: some View {
        Group {
            if institution == .sBank {
                SMark(size: size)
            } else {
                Image(assetName)
                    .resizable()
                    .scaledToFit()
                    .padding(7)
                    .frame(width: size, height: size)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: size * 0.28, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                            .stroke(Color(.separator), lineWidth: 0.5)
                    }
            }
        }
        .accessibilityLabel(institution.rawValue)
    }

    private var assetName: String {
        switch institution {
        case .sBank: "SBankLogo"
        case .nordea: "NordeaLogo"
        case .op: "OPLogo"
        case .danske: "DanskeLogo"
        }
    }
}

