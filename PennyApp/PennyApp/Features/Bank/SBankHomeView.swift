import SwiftUI

struct SBankHomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SMobiiliHeader(title: "S-Bank")
                ScrollView {
                    LazyVStack(spacing: SMobiiliMetrics.serviceRowGap) {
                        ForEach(SMobiiliBankContent.services) { service in
                            NavigationLink(value: service.destination) {
                                SMobiiliServiceRow(title: service.title, detail: service.detail, symbol: service.symbol)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(SMobiiliMetrics.contentInset)
                }
                .background(SMobiiliPalette.canvas)
            }
            .toolbar(.hidden, for: .navigationBar)
            .background(SMobiiliPalette.surface.ignoresSafeArea(edges: .top))
            .navigationDestination(for: BankServiceDestination.self) { destination in
                switch destination {
                case .accounts: BankOverviewView()
                case .saver: SaverView()
                case .conceptInfo:
                    ContentUnavailableView(
                        "Service unavailable",
                        systemImage: "building.columns",
                        description: Text("Please try again later.")
                    )
                }
            }
        }
    }
}
