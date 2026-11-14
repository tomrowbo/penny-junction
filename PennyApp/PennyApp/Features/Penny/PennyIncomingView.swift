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
                        UpcomingMoneyCard(
                            summary: store.upcomingMoney,
                            transactions: store.transactions,
                            accounts: store.accounts
                        )
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
