import XCTest
@testable import PennyApp

@MainActor
final class AppStoreTests: XCTestCase {
    func testTopLevelTabsBelongToStandalonePenny() {
        XCTAssertEqual(AppTab.allCases, [.spend, .plan, .askPenny, .incoming])
        XCTAssertEqual(AppTab.allCases.map(\.title), ["Spend", "Plan", "Ask Penny", "Incoming"])
    }

    func testCardBenefitsLaunchStateSelectsSecondCardPage() {
        let store = AppStore()

        store.applyDemoState(.cardBenefits)

        XCTAssertTrue(store.isAuthenticated)
        XCTAssertEqual(store.selectedTab, .spend)
        XCTAssertEqual(store.cardPage, 1)
        XCTAssertNil(store.presentedReferenceRoute)
    }

    func testBenefitCardsLaunchStateSelectsBenefitsAndRequestsLowerSection() {
        let store = AppStore()

        store.applyDemoState(.benefitCards)

        XCTAssertEqual(store.selectedTab, .spend)
        XCTAssertEqual(store.cardPage, 1)
        XCTAssertEqual(store.cardScrollTarget, "benefit-cards")
    }

    func testReferenceDetailLaunchStatesExposeExpectedRoute() {
        let cases: [(DemoLaunchState, SMobiiliRoute)] = [
            (.wallet, .wallet),
            (.receipt, .receipt),
            (.saver, .saver)
        ]

        for (state, route) in cases {
            let store = AppStore()
            store.applyDemoState(state)
            XCTAssertTrue(store.isAuthenticated)
            XCTAssertEqual(store.presentedReferenceRoute, route)
        }
    }

    func testFakeLoginAuthenticatesAndSelectsPennyTab() {
        let store = AppStore()

        store.login()

        XCTAssertTrue(store.isAuthenticated)
        XCTAssertEqual(store.selectedTab, .spend)
    }

    func testFreshStoreContainsNoExternalInstitution() {
        let store = AppStore()

        XCTAssertEqual(Set(store.accounts.map(\.institution)), [.sBank])
        XCTAssertFalse(store.hasConnectedExternalBank)
    }

    func testConnectedStateStillSelectsPenny() {
        let store = AppStore()

        store.applyDemoState(.connected)

        XCTAssertEqual(store.selectedTab, .spend)
        XCTAssertTrue(store.hasConnectedExternalBank)
    }

    func testTransactionHandoffSelectsPennyTab() {
        let store = AppStore()
        store.applyDemoState(.transaction)

        XCTAssertEqual(store.selectedTab, .spend)

        store.discussWithPenny()

        XCTAssertEqual(store.selectedTab, .askPenny)
        XCTAssertNil(store.presentedReferenceRoute)
        XCTAssertNil(store.previewTransactionID)
    }

    func testContextResolvesRecordedTransactionWithoutAccountNumber() throws {
        let store = AppStore(goalPlanStore: InMemoryPennyGoalPlanStore())
        let context = try XCTUnwrap(store.context(for: .transaction("tx-prisma")))

        XCTAssertEqual(context.type, .transaction)
        XCTAssertEqual(context.referenceID, "tx-prisma")
        XCTAssertEqual(context.title, "Prisma Kaari")
        XCTAssertTrue(context.subtitle.contains("63,20"))
        XCTAssertTrue(context.subtitle.contains("Groceries"))
        XCTAssertEqual(context.accountIDs, ["sbank-everyday"])
        XCTAssertEqual(context.transactionIDs, ["tx-prisma"])
        XCTAssertEqual(context.suggestedPrompts.count, 2)
        XCTAssertFalse(context.subtitle.contains("4821"))
    }

    func testContextResolvesAccountFromStoredBalance() throws {
        let store = AppStore(goalPlanStore: InMemoryPennyGoalPlanStore())
        let context = try XCTUnwrap(store.context(for: .account("sbank-savings")))

        XCTAssertEqual(context.type, .account)
        XCTAssertEqual(context.title, "Savings")
        XCTAssertTrue(context.subtitle.contains("S-Bank"))
        XCTAssertTrue(context.subtitle.contains("8\u{00a0}500,00"))
        XCTAssertEqual(context.accountIDs, ["sbank-savings"])
        XCTAssertTrue(context.transactionIDs.isEmpty)
        XCTAssertFalse(context.subtitle.contains("1904"))
    }

    func testContextUsesSavedGoalAndOnlyExistingRelatedAccounts() throws {
        let store = AppStore(goalPlanStore: InMemoryPennyGoalPlanStore())
        let id = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
        store.saveGoalPlan(PennyGoalPlan(id: id, title: "Rainy day", targetAmount: 1_200,
            currentAmount: 300, targetDate: Date(timeIntervalSince1970: 1_800_000_000),
            monthlyContribution: 75, createdAt: Date(timeIntervalSince1970: 1_700_000_000),
            accountIDs: ["sbank-savings", "missing-account"]))
        let context = try XCTUnwrap(store.context(for: .goal(id)))

        XCTAssertEqual(context.type, .goal)
        XCTAssertEqual(context.referenceID, id.uuidString)
        XCTAssertEqual(context.title, "Rainy day")
        XCTAssertTrue(context.subtitle.contains("1\u{00a0}200,00"))
        XCTAssertTrue(context.subtitle.contains("300,00"))
        XCTAssertTrue(context.subtitle.contains("75,00"))
        XCTAssertEqual(context.accountIDs, ["sbank-savings"])
        XCTAssertTrue(context.transactionIDs.isEmpty)
    }

    func testContextResolvesDetectedUpcomingItemWithSourceTransactions() throws {
        let date = ISO8601DateFormatter()
        var transactions = ["2026-08-10", "2026-09-10", "2026-10-10"].enumerated().map { index, day in
            BankTransaction(id: "rent-\(index)", accountID: "sbank-everyday", institution: .sBank,
                merchant: "Recorded rent", amount: -940,
                date: date.date(from: "\(day)T12:00:00Z")!, category: "Housing")
        }
        transactions.append(BankTransaction(id: "anchor", accountID: "sbank-everyday", institution: .sBank,
            merchant: "One-off purchase", amount: -5, date: date.date(from: "2026-10-15T12:00:00Z")!, category: "Groceries"))
        let store = AppStore(snapshot: DemoSnapshot(accounts: DemoData.initial.accounts, transactions: transactions),
                             goalPlanStore: InMemoryPennyGoalPlanStore())
        let item = try XCTUnwrap(store.upcomingMoney.items.first)
        let context = try XCTUnwrap(store.context(for: .upcoming(item.id)))

        XCTAssertEqual(context.type, .upcoming)
        XCTAssertEqual(context.referenceID, item.id)
        XCTAssertEqual(context.title, "Recorded rent")
        XCTAssertTrue(context.subtitle.contains("940,00"))
        XCTAssertTrue(context.subtitle.lowercased().contains("estimate"))
        XCTAssertTrue(context.subtitle.contains("Monthly"))
        XCTAssertEqual(context.accountIDs, ["sbank-everyday"])
        XCTAssertEqual(Set(context.transactionIDs), Set(["rent-0", "rent-1", "rent-2"]))
    }

    func testStartingContextualChatClearsPreviewRoutesAndSelectsAskPenny() throws {
        let store = AppStore(goalPlanStore: InMemoryPennyGoalPlanStore())
        store.presentedReferenceRoute = .receipt
        store.previewTransactionID = "tx-prisma"
        store.previewChatID = "car"
        store.isTabBarHidden = true

        store.startPennyChat(about: .transaction("tx-prisma"))

        XCTAssertEqual(store.selectedTab, .askPenny)
        XCTAssertEqual(store.pendingPennyChatContext?.referenceID, "tx-prisma")
        XCTAssertNil(store.presentedReferenceRoute)
        XCTAssertNil(store.previewTransactionID)
        XCTAssertNil(store.previewChatID)
        XCTAssertFalse(store.isTabBarHidden)
    }

    func testMissingSubjectFallsBackToGenericChatAndClearsPriorContext() {
        let store = AppStore(goalPlanStore: InMemoryPennyGoalPlanStore())
        let missing: [PennyChatSubject] = [.transaction("missing"), .account("missing"),
                                         .goal(UUID()), .upcoming("missing")]
        for subject in missing {
            store.startPennyChat(about: .transaction("tx-prisma"))
            XCTAssertNotNil(store.pendingPennyChatContext)
            XCTAssertNil(store.context(for: subject))

            store.startPennyChat(about: subject)

            XCTAssertEqual(store.selectedTab, .askPenny)
            XCTAssertNil(store.pendingPennyChatContext)
        }
        store.startPennyChat(about: .account("sbank-savings"))
        store.discussWithPenny()
        XCTAssertNil(store.pendingPennyChatContext)
    }

    func testChatRequestEncodesSelectedContextOnlyWhenPresent() throws {
        let store = AppStore(goalPlanStore: InMemoryPennyGoalPlanStore())
        let context = try XCTUnwrap(store.context(for: .transaction("tx-prisma")))
        let service = PennyChatService(baseURL: URL(string: "https://example.com")!)
        let contextual = try service.makeRequest(goal: "Review this", messages: [],
            accounts: store.accounts, transactions: store.transactions, context: context)
        let body = try XCTUnwrap(JSONSerialization.jsonObject(with: XCTUnwrap(contextual.httpBody)) as? [String: Any])
        let selected = try XCTUnwrap(body["selectedContext"] as? [String: Any])
        XCTAssertEqual(selected["type"] as? String, "transaction")
        XCTAssertEqual(selected["referenceID"] as? String, "tx-prisma")
        XCTAssertEqual(selected["transactionIDs"] as? [String], ["tx-prisma"])
        XCTAssertNil(body["context"])

        let generic = try service.makeRequest(goal: "Review this", messages: [],
            accounts: store.accounts, transactions: store.transactions, context: nil)
        let genericBody = try XCTUnwrap(JSONSerialization.jsonObject(with: XCTUnwrap(generic.httpBody)) as? [String: Any])
        XCTAssertNil(genericBody["selectedContext"])
    }

    func testOfficialSummaryReplacesOnlySBankDataAndPreservesConnectedBank() throws {
        let store = AppStore()
        store.applyDemoState(.transaction)
        store.merge(connection: DemoOpenBankingService.connection(for: .nordea))
        let payload = """
        {
          "source": "official-synthetic-dataset",
          "anchorDate": "2026-09-30",
          "coverage": { "from": "2024-10-05", "to": "2026-09-30", "transactionCount": 1024 },
          "accounts": [{ "id": "ACC003948", "institution": "S-Bank", "name": "S-Tili", "kind": "Everyday account", "balance": 33788.46, "maskedNumber": "•• 3948" }],
          "transactions": [{ "id": "sbank-1", "accountID": "ACC003948", "institution": "S-Bank", "merchant": "MRC-GRO-0048", "amount": -60.69, "date": "2026-09-30T17:12:06Z", "category": "Groceries" }]
        }
        """.data(using: .utf8)!

        let summary = try SBankDataService.decode(payload)
        store.replaceSBankData(with: summary)

        XCTAssertEqual(store.accounts.first(where: { $0.institution == .sBank })?.id, "ACC003948")
        XCTAssertTrue(store.accounts.contains { $0.institution == .nordea })
        XCTAssertEqual(store.transactions.first(where: { $0.institution == .sBank })?.id, "sbank-1")
        XCTAssertTrue(store.transactions.contains { $0.institution == .nordea })
        XCTAssertEqual(store.sBankDataStatus, .official(coverage: "5 Oct 2024–30 Sep 2026"))
        XCTAssertEqual(store.previewTransactionID, "sbank-1")
    }
}
