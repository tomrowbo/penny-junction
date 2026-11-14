import XCTest
@testable import PennyApp

@MainActor
final class AppStoreTests: XCTestCase {
    func testTopLevelTabsBelongToStandalonePenny() {
        XCTAssertEqual(AppTab.allCases, [.penny, .accounts, .me])
        XCTAssertEqual(AppTab.allCases.map(\.title), ["Penny", "Accounts", "Me"])
    }

    func testCardBenefitsLaunchStateSelectsSecondCardPage() {
        let store = AppStore()

        store.applyDemoState(.cardBenefits)

        XCTAssertTrue(store.isAuthenticated)
        XCTAssertEqual(store.selectedTab, .penny)
        XCTAssertEqual(store.cardPage, 1)
        XCTAssertNil(store.presentedReferenceRoute)
    }

    func testBenefitCardsLaunchStateSelectsBenefitsAndRequestsLowerSection() {
        let store = AppStore()

        store.applyDemoState(.benefitCards)

        XCTAssertEqual(store.selectedTab, .penny)
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
        XCTAssertEqual(store.selectedTab, .penny)
    }

    func testFreshStoreContainsNoExternalInstitution() {
        let store = AppStore()

        XCTAssertEqual(Set(store.accounts.map(\.institution)), [.sBank])
        XCTAssertFalse(store.hasConnectedExternalBank)
    }

    func testConnectedStateStillSelectsPenny() {
        let store = AppStore()

        store.applyDemoState(.connected)

        XCTAssertEqual(store.selectedTab, .penny)
        XCTAssertTrue(store.hasConnectedExternalBank)
    }

    func testTransactionHandoffSelectsPennyTab() {
        let store = AppStore()
        store.applyDemoState(.transaction)

        XCTAssertEqual(store.selectedTab, .accounts)

        store.discussWithPenny()

        XCTAssertEqual(store.selectedTab, .penny)
        XCTAssertNil(store.presentedReferenceRoute)
        XCTAssertNil(store.previewTransactionID)
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
