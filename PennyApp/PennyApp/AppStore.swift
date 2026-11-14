import Foundation
import Observation

enum AppTab: String, CaseIterable, Hashable {
    case penny
    case accounts
    case me

    var title: String {
        switch self {
        case .penny: "Penny"
        case .accounts: "Accounts"
        case .me: "Me"
        }
    }

    var symbol: String {
        switch self {
        case .penny: PennyBrand.markAssetName
        case .accounts: "building.columns"
        case .me: "person"
        }
    }
}

enum SMobiiliRoute: String, Hashable, Sendable {
    case wallet
    case receipt
    case saver
    case conceptInfo
}

enum DemoLaunchState: String, Sendable {
    case cardOverview = "card"
    case cardBenefits = "benefits"
    case benefitCards = "benefit-cards"
    case bank
    case penny
    case me
    case wallet
    case receipt
    case saver
    case transaction
    case connected
    case chat
}

@MainActor
@Observable
final class AppStore {
    var isAuthenticated = false
    var selectedTab: AppTab = .penny
    var isTabBarHidden = false
    var cardPage = 0
    var cardScrollTarget: String?
    var presentedReferenceRoute: SMobiiliRoute?
    var previewTransactionID: String?
    var previewChatID: String?
    private(set) var accounts: [BankAccount]
    private(set) var transactions: [BankTransaction]
    private(set) var sBankDataStatus: SBankDataStatus = .fallback

    init(snapshot: DemoSnapshot = DemoData.initial) {
        accounts = snapshot.accounts
        transactions = snapshot.transactions

        if let rawState = ProcessInfo.processInfo.environment["PENNY_DEMO_STATE"],
           let launchState = DemoLaunchState(rawValue: rawState) {
            applyDemoState(launchState)
        }
    }

    func applyDemoState(_ state: DemoLaunchState) {
        isAuthenticated = true
        cardPage = 0
        cardScrollTarget = nil
        presentedReferenceRoute = nil
        previewTransactionID = nil
        previewChatID = nil
        isTabBarHidden = false

        switch state {
        case .cardOverview:
            selectedTab = .penny
        case .cardBenefits:
            selectedTab = .penny
            cardPage = 1
        case .benefitCards:
            selectedTab = .penny
            cardPage = 1
            cardScrollTarget = "benefit-cards"
        case .bank:
            selectedTab = .accounts
        case .penny:
            selectedTab = .penny
        case .me:
            selectedTab = .me
        case .wallet:
            selectedTab = .penny
            presentedReferenceRoute = .wallet
        case .receipt:
            selectedTab = .penny
            presentedReferenceRoute = .receipt
        case .saver:
            selectedTab = .accounts
            presentedReferenceRoute = .saver
        case .transaction:
            selectedTab = .accounts
            previewTransactionID = "tx-prisma"
        case .connected:
            selectedTab = .penny
            merge(connection: DemoOpenBankingService.connection(for: .nordea))
        case .chat:
            selectedTab = .penny
            previewChatID = "car"
        }
    }

    var hasConnectedExternalBank: Bool {
        accounts.contains { $0.institution != .sBank }
    }

    var totalPositiveBalance: Decimal {
        accounts
            .filter { $0.kind != .mortgage }
            .reduce(.zero) { $0 + $1.balance }
    }

    func login() {
        selectedTab = .penny
        isTabBarHidden = false
        isAuthenticated = true
    }

    func discussWithPenny() {
        presentedReferenceRoute = nil
        previewTransactionID = nil
        previewChatID = nil
        isTabBarHidden = false
        selectedTab = .penny
    }

    func transaction(id: String) -> BankTransaction? {
        transactions.first { $0.id == id }
    }

    func merge(connection: BankConnection) {
        let accountIDs = Set(accounts.map(\.id))
        accounts.append(contentsOf: connection.accounts.filter { !accountIDs.contains($0.id) })

        let transactionIDs = Set(transactions.map(\.id))
        transactions.append(contentsOf: connection.transactions.filter { !transactionIDs.contains($0.id) })
        transactions.sort { $0.date > $1.date }
    }

    func replaceSBankData(with summary: SBankCustomerSummary) {
        let requestedPreview = previewTransactionID
        accounts.removeAll { $0.institution == .sBank }
        accounts.insert(contentsOf: summary.accounts, at: 0)
        transactions.removeAll { $0.institution == .sBank }
        transactions.append(contentsOf: summary.transactions)
        transactions.sort { $0.date > $1.date }
        if let requestedPreview, transaction(id: requestedPreview) == nil {
            previewTransactionID = summary.transactions.first?.id
        }
        sBankDataStatus = .official(coverage: summary.coverage.displayRange)
    }

    func loadOfficialSBankData() async {
        guard let baseURL = PennyAPIConfiguration.baseURL else { return }
        sBankDataStatus = .loading
        do {
            replaceSBankData(with: try await SBankDataService(baseURL: baseURL).summary())
        } catch {
            sBankDataStatus = .unavailable
        }
    }

}


