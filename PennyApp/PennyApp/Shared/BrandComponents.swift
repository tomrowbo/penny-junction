import SwiftUI

enum PennyBrand {
    static let productName = "Penny"
    static let markAssetName = "PennyMark"
    static let partnerDescriptor = "for S-Bank"
    static let tagline = "Your money, in plain language"
}

struct PennyMark: View {
    var size: CGFloat = 44
    var inverse = false

    var body: some View {
        Image(PennyBrand.markAssetName)
            .resizable()
            .scaledToFit()
            .padding(inverse ? size * 0.08 : 0)
            .frame(width: size, height: size)
            .background(
                inverse ? Color.white.opacity(0.92) : Color.clear,
                in: Circle()
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
        .foregroundStyle(PennyTheme.textPrimary)
        .pennyGlassSurface(cornerRadius: 20)
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

