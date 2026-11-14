import SwiftUI

@main
struct PennyApp: App {
    @State private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            Group {
                if let chatID = store.previewChatID,
                   let thread = PennyChatThread.samples.first(where: { $0.id == chatID }) {
                    NavigationStack {
                        PennyChatView(thread: thread)
                    }
                } else if let transactionID = store.previewTransactionID {
                    NavigationStack {
                        TransactionDetailView(transactionID: transactionID)
                    }
                } else if let route = store.presentedReferenceRoute {
                    NavigationStack {
                        switch route {
                        case .wallet: WalletView()
                        case .receipt: ReceiptView()
                        case .saver: SaverView()
                        case .conceptInfo: ContentUnavailableView("Service unavailable", systemImage: "sparkles")
                        }
                    }
                } else if store.isAuthenticated {
                    MainTabView()
                } else {
                    LoginView()
                }
            }
            .environment(store)
            .tint(PennyTheme.green)
            .preferredColorScheme(.dark)
            .task(id: store.isAuthenticated) {
                if store.isAuthenticated {
                    await store.loadOfficialSBankData()
                }
            }
        }
    }
}

private struct MainTabView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        @Bindable var store = store
        Group {
            switch store.selectedTab {
            case .spend:
                NavigationStack {
                    BankOverviewView()
                }
            case .plan:
                PennyCoachView()
            case .askPenny:
                PennyCoachView()
            case .incoming:
                PennyCoachView()
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if !store.isTabBarHidden {
                PennyGlassTabBar(selection: $store.selectedTab)
            }
        }
    }
}

