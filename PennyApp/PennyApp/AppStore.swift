import Foundation
import Observation

enum AppTab: String, CaseIterable, Hashable {
    case spend
    case plan
    case askPenny
    case incoming

    var title: String {
        switch self {
        case .spend: "Spend"
        case .plan: "Plan"
        case .askPenny: "Ask Penny"
        case .incoming: "Incoming"
        }
    }

    var symbol: String {
        switch self {
        case .spend: "arrow.up.right"
        case .plan: "scope"
        case .askPenny: PennyBrand.markAssetName
        case .incoming: "sparkle"
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
    var selectedTab: AppTab = .spend
    var isTabBarHidden = false
    var cardPage = 0
    var cardScrollTarget: String?
    var presentedReferenceRoute: SMobiiliRoute?
    var previewTransactionID: String?
    var previewChatID: String?
    private(set) var accounts: [BankAccount]
    private(set) var transactions: [BankTransaction]
    private(set) var sBankDataStatus: SBankDataStatus = .fallback
    private(set) var goalPlans: [PennyGoalPlan]
    private(set) var goalPlanError: String?
    private let goalPlanStore: any PennyGoalPlanStore

    init(
        snapshot: DemoSnapshot = DemoData.initial,
        goalPlanStore: (any PennyGoalPlanStore)? = nil
    ) {
        accounts = snapshot.accounts
        transactions = snapshot.transactions
        let resolvedGoalPlanStore = goalPlanStore ?? UserDefaultsPennyGoalPlanStore()
        self.goalPlanStore = resolvedGoalPlanStore
        do {
            let saved = try resolvedGoalPlanStore.load()
            if saved.isEmpty {
                let sample = Self.sampleGoalPlan(referenceDate: snapshot.transactions.map(\.date).max() ?? .now)
                goalPlans = [sample]
                try resolvedGoalPlanStore.save(goalPlans)
            } else {
                goalPlans = saved
            }
        } catch {
            goalPlans = [Self.sampleGoalPlan(referenceDate: snapshot.transactions.map(\.date).max() ?? .now)]
            goalPlanError = "Saved goals could not be loaded. Showing the demo goal instead."
        }

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
            selectedTab = .spend
        case .cardBenefits:
            selectedTab = .spend
            cardPage = 1
        case .benefitCards:
            selectedTab = .spend
            cardPage = 1
            cardScrollTarget = "benefit-cards"
        case .bank:
            selectedTab = .spend
        case .penny:
            selectedTab = .askPenny
        case .me:
            selectedTab = .spend
        case .wallet:
            selectedTab = .spend
            presentedReferenceRoute = .wallet
        case .receipt:
            selectedTab = .spend
            presentedReferenceRoute = .receipt
        case .saver:
            selectedTab = .plan
            presentedReferenceRoute = .saver
        case .transaction:
            selectedTab = .spend
            previewTransactionID = "tx-prisma"
        case .connected:
            selectedTab = .spend
            merge(connection: DemoOpenBankingService.connection(for: .nordea))
        case .chat:
            selectedTab = .askPenny
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

    var financialReferenceDate: Date {
        transactions.map(\.date).max() ?? .now
    }

    var upcomingMoney: UpcomingMoneySummary {
        UpcomingMoneyDetector.detect(transactions: transactions, asOf: financialReferenceDate)
    }

    var safeToSpend: SafeToSpendResult {
        let upcoming = upcomingMoney
        let payday = upcoming.items
            .filter { $0.direction == .income && $0.isIncludedInTotals }
            .map(\.nextDate)
            .min()
        let periodEnd = payday ?? Calendar.current.date(byAdding: .day, value: 30, to: financialReferenceDate) ?? financialReferenceDate
        let commitments = upcoming.items
            .filter { $0.direction == .outflow && $0.isIncludedInTotals && $0.nextDate < periodEnd }
            .map {
                SafeToSpendCommitment(
                    id: $0.id,
                    label: $0.merchant,
                    amount: $0.amount,
                    dueDate: $0.nextDate,
                    sourceTransactionIDs: $0.sourceTransactionIDs
                )
            }
        let days = max(1, Calendar.current.dateComponents([.day], from: financialReferenceDate, to: periodEnd).day ?? 30)
        let goalReserve = goalPlans
            .filter { $0.projection(asOf: financialReferenceDate).status != .completed }
            .reduce(Decimal.zero) { $0 + $1.monthlyContribution * Decimal(days) / Decimal(string: "30.4375")! }
        let externalInstitutions = Set(accounts.filter { $0.institution != .sBank }.map(\.institution))
        let externalWithTransactions = Set(transactions.filter { $0.institution != .sBank }.map(\.institution))
        let dataIsComplete: Bool
        if case .official = sBankDataStatus {
            dataIsComplete = externalInstitutions.isSubset(of: externalWithTransactions)
        } else {
            dataIsComplete = false
        }
        return SafeToSpendCalculator.calculate(
            accounts: accounts,
            transactions: transactions,
            asOf: financialReferenceDate,
            nextPayday: payday,
            commitments: commitments,
            goalContribution: goalReserve,
            dataIsComplete: dataIsComplete
        )
    }

    func saveGoalPlan(_ plan: PennyGoalPlan) {
        if let index = goalPlans.firstIndex(where: { $0.id == plan.id }) {
            goalPlans[index] = plan
        } else {
            goalPlans.append(plan)
        }
        persistGoalPlans()
    }

    func deleteGoalPlan(id: UUID) {
        goalPlans.removeAll { $0.id == id }
        persistGoalPlans()
    }

    func login() {
        selectedTab = .spend
        isTabBarHidden = false
        isAuthenticated = true
    }

    func discussWithPenny() {
        presentedReferenceRoute = nil
        previewTransactionID = nil
        previewChatID = nil
        isTabBarHidden = false
        selectedTab = .askPenny
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

    private func persistGoalPlans() {
        do {
            try goalPlanStore.save(goalPlans)
            goalPlanError = nil
        } catch {
            goalPlanError = "Goal changes could not be saved."
        }
    }

    private static func sampleGoalPlan(referenceDate: Date) -> PennyGoalPlan {
        let calendar = Calendar.current
        return PennyGoalPlan(
            id: UUID(uuidString: "A58D8407-741B-4D68-9C5F-B371B723A710")!,
            title: "Buy a new car",
            targetAmount: Decimal(12_000),
            currentAmount: Decimal(2_400),
            targetDate: calendar.date(byAdding: .month, value: 24, to: referenceDate) ?? referenceDate,
            monthlyContribution: Decimal(400),
            createdAt: referenceDate
        )
    }

}


