import SwiftUI

struct PennyIncomingView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        NavigationStack {
            ZStack {
                PennyAtmosphere()
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        PennyRootHeader(title: "Incoming", subtitle: "Expected bills, subscriptions and income in one place.")
                        switch store.sBankDataStatus {
                        case .loading:
                            IncomingLoadingSkeleton()
                        case .unavailable:
                            PennyDataUnavailableCard(
                                title: "Upcoming money is unavailable",
                                message: "Check your connection and try again.",
                                retry: { Task { await store.loadOfficialSBankData() } }
                            )
                        case .official, .fallback:
                            UpcomingMoneyCard(
                                summary: store.upcomingMoney,
                                transactions: store.transactions,
                                accounts: store.accounts,
                                onDiscuss: { store.startPennyChat(about: .upcoming($0)) }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
                    .padding(.bottom, 26)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}
