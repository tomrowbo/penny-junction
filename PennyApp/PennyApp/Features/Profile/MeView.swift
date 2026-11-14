import SwiftUI

enum PennyProfileContent {
    static let customerName = "Demo customer"
    static let sectionTitles = ["Connected data", "Privacy and permissions", "About Penny"]
    static let disclosure = PennyBrand.conceptDisclosure
    static let privacyStatements = [
        "Penny can read balances and transactions, but cannot move money.",
        "Financial calculations happen before minimised facts reach the language model.",
        "External-bank access is read-only and consent-based."
    ]
}

struct MeView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SMobiiliHeader(title: "Me", showsMessages: false)
                ScrollView {
                    VStack(spacing: 14) {
                        identityCard
                        connectedDataCard
                        privacyCard
                        aboutCard
                    }
                    .padding(SMobiiliMetrics.contentInset)
                }
                .background(PennyTheme.canvas)
            }
            .toolbar(.hidden, for: .navigationBar)
            .background(SMobiiliPalette.surface.ignoresSafeArea(edges: .top))
        }
    }

    private var identityCard: some View {
        BrandCard {
            HStack(spacing: 14) {
                PennyMark(size: 58)
                VStack(alignment: .leading, spacing: 3) {
                    Text(PennyProfileContent.customerName)
                        .font(.headline)
                    Text("\(PennyBrand.productName) \(PennyBrand.partnerDescriptor)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(PennyTheme.green)
                }
                Spacer()
            }
        }
    }

    private var connectedDataCard: some View {
        profileSection(PennyProfileContent.sectionTitles[0], symbol: "building.columns") {
            ForEach(connectedInstitutions, id: \.self) { institution in
                HStack(spacing: 12) {
                    InstitutionBadge(institution: institution, size: 34)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(institution.rawValue).font(.subheadline.weight(.semibold))
                        Text(institution == .sBank ? officialDataLabel : "Read-only connected account")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(PennyTheme.green)
                }
            }
        }
    }

    private var privacyCard: some View {
        profileSection(PennyProfileContent.sectionTitles[1], symbol: "lock.shield.fill") {
            Label(PennyProfileContent.privacyStatements[0], systemImage: "eye.fill")
            Label(PennyProfileContent.privacyStatements[1], systemImage: "function")
            Label(PennyProfileContent.privacyStatements[2], systemImage: "checkmark.shield.fill")
        }
    }

    private var aboutCard: some View {
        profileSection(PennyProfileContent.sectionTitles[2], symbol: "sparkles") {
            Text(PennyBrand.tagline)
                .font(.subheadline.weight(.semibold))
            Text(PennyProfileContent.disclosure)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("Penny is a standalone Junction prototype designed for S-Bank. It is not an official production banking application.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func profileSection<Content: View>(
        _ title: String,
        symbol: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        BrandCard {
            Label(title, systemImage: symbol)
                .font(.headline)
                .foregroundStyle(PennyTheme.darkGreen)
            VStack(alignment: .leading, spacing: 12) {
                content()
            }
            .font(.caption)
        }
    }

    private var connectedInstitutions: [Institution] {
        Array(Set(store.accounts.map(\.institution))).sorted { $0.rawValue < $1.rawValue }
    }

    private var officialDataLabel: String {
        switch store.sBankDataStatus {
        case .official(let coverage): "Official synthetic data · \(coverage)"
        case .loading: "Loading official synthetic data…"
        case .unavailable: "Official dataset unavailable"
        case .fallback: "Synthetic demo data"
        }
    }
}
