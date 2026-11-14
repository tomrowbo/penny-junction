import XCTest
import CryptoKit
@testable import PennyApp

final class DomainModelTests: XCTestCase {
    func testStandalonePennyBrandCopyKeepsPartnerSecondary() {
        XCTAssertEqual(PennyBrand.productName, "Penny")
        XCTAssertEqual(PennyBrand.partnerDescriptor, "for S-Bank")
        XCTAssertEqual(PennyBrand.tagline, "Your money, in plain language")
    }

    func testStandaloneAppIconIsNotTheLegacySBankProductMark() throws {
        let testFile = URL(fileURLWithPath: #filePath)
        let iconURL = testFile
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appending(path: "PennyApp/Assets.xcassets/AppIcon.appiconset/AppIcon.png")
        let digest = SHA256.hash(data: try Data(contentsOf: iconURL))
            .map { String(format: "%02x", $0) }
            .joined()
        XCTAssertNotEqual(digest, "be627a9442891383cf33515c1119c14514efb25c6a323704c3993ac9dbca8c17")
    }

    func testSMobiiliMetricsKeepControlsAccessibleAndMatchReferenceDensity() {
        XCTAssertEqual(SMobiiliMetrics.minimumTapTarget, 44)
        XCTAssertEqual(SMobiiliMetrics.contentInset, 20)
        XCTAssertEqual(SMobiiliMetrics.serviceRowMinimumHeight, 112)
        XCTAssertEqual(SMobiiliMetrics.serviceRowRadius, 7)
        XCTAssertEqual(SMobiiliMetrics.serviceRowGap, 16)
        XCTAssertEqual(SMobiiliMetrics.serviceIconSize, 46)
        XCTAssertEqual(SMobiiliMetrics.navigationHeight, 52)
        XCTAssertEqual(SMobiiliMetrics.tabBarHeight, 62)
    }

    func testEveryTopLevelTabHasReferenceLabelAndSymbol() {
        XCTAssertEqual(AppTab.allCases.map(\.title), ["Spend", "Plan", "Ask Penny", "Incoming"])
        XCTAssertEqual(AppTab.allCases.map(\.symbol), ["arrow.up.right", "scope", PennyBrand.markAssetName, "sparkle"])
        XCTAssertTrue(AppTab.allCases.allSatisfy { !$0.symbol.isEmpty })
    }

    func testSEtukorttiDemoContentMatchesVisibleReferenceCopy() {
        XCTAssertEqual(SEtukorttiDemoContent.pageCount, 2)
        XCTAssertEqual(SEtukorttiDemoContent.primaryActions.map(\.title), ["Bonus and purchases", "Receipts"])
        XCTAssertEqual(SEtukorttiDemoContent.benefitSectionTitle, "Your benefits")
    }

    func testReceiptDemoTotalAndMerchantMatchReference() {
        XCTAssertEqual(SEtukorttiDemoContent.receipt.merchant, "Prisma Mylly")
        XCTAssertEqual(SEtukorttiDemoContent.receipt.total, "60,00 €")
        XCTAssertFalse(SEtukorttiDemoContent.receipt.lines.isEmpty)
    }

    func testCardActionsRouteOnlyToWalletReceiptOrConceptInfo() {
        XCTAssertEqual(
            Set(SEtukorttiDemoContent.primaryActions.map(\.route)),
            Set([SMobiiliRoute.conceptInfo, .receipt])
        )
        XCTAssertEqual(SEtukorttiDemoContent.walletRoute, .wallet)
    }

    func testBankServicesMatchReferenceOrderAndCopy() {
        XCTAssertEqual(
            SMobiiliBankContent.services.map(\.title),
            ["Accounts", "Payments and e-invoices", "Cards", "Säästäjä", "Investments", "Loans"]
        )
        XCTAssertEqual(SMobiiliBankContent.services[1].detail, "Make a new payment or view and order e-invoices")
    }

    func testBankServiceDestinationsSeparateFunctionalAndConceptRoutes() {
        XCTAssertEqual(SMobiiliBankContent.services[0].destination, .accounts)
        XCTAssertEqual(SMobiiliBankContent.services[3].destination, .saver)
        XCTAssertTrue(
            SMobiiliBankContent.services.enumerated().allSatisfy { index, service in
                [0, 3].contains(index) || service.destination == .conceptInfo
            }
        )
    }

    func testSaverReferenceValuesAreStable() {
        XCTAssertEqual(SaverDemoContent.title, "New car")
        XCTAssertEqual(SaverDemoContent.amount, "5987,65 €")
        XCTAssertEqual(SaverDemoContent.status, "You’re 33,17 € ahead your target.")
    }

    func testPennyProfileExplainsDataPrivacyAndProductIdentity() {
        XCTAssertEqual(PennyProfileContent.sectionTitles, ["Connected data", "Privacy and permissions", "About Penny"])
        XCTAssertEqual(PennyProfileContent.customerName, "Tom")
        XCTAssertTrue(PennyProfileContent.privacyStatements.allSatisfy { !$0.localizedCaseInsensitiveContains("disconnect") })
    }

    func testReachableStandaloneNavigationContainsNoReplicaBrandLabels() {
        let reachableLabels = AppTab.allCases.map(\.title) + [
            PennyBrand.productName,
            PennyBrand.partnerDescriptor,
            PennyProfileContent.sectionTitles.joined(separator: " ")
        ]
        XCTAssertTrue(reachableLabels.allSatisfy { !$0.localizedCaseInsensitiveContains("S-mobiili") })
        XCTAssertTrue(reachableLabels.allSatisfy { !$0.localizedCaseInsensitiveContains("S-Etukortti") })
    }

    func testInitialDataContainsOnlySBankAccounts() {
        let data = DemoData.initial

        XCTAssertFalse(data.accounts.isEmpty)
        XCTAssertTrue(data.accounts.allSatisfy { $0.institution == .sBank })
    }

    func testInitialTransactionsAreMerchantLevelBankData() {
        let data = DemoData.initial

        XCTAssertTrue(data.transactions.allSatisfy { !$0.merchant.isEmpty && !$0.category.isEmpty })
    }

    func testPrismaTransactionStartsWithMerchantLevelDataOnly() throws {
        let transaction = try XCTUnwrap(
            DemoData.initial.transactions.first { $0.merchant == "Prisma Kaari" }
        )

        XCTAssertEqual(transaction.amount, Decimal(string: "-63.20"))
        XCTAssertEqual(transaction.category, "Groceries")
    }

    func testNewGoalStartersCoverChallengeBasketsAndFreeExploration() {
        XCTAssertEqual(PennyGoalStarter.allCases.count, 5)
        XCTAssertEqual(Set(PennyGoalStarter.allCases.map(\.kind)), Set([.regular, .irregular, .everyday, .safeToSpend, .whatIf]))
        XCTAssertTrue(PennyGoalStarter.allCases.allSatisfy { !$0.prompt.isEmpty && !$0.title.isEmpty })
    }

    func testStructuredChatReplyDecodesEvidenceAndSuggestions() throws {
        let payload = """
        {
          "message": "About €755 is safe this week.",
          "evidence": {
            "coverage": "2026-04-04–2026-09-30",
            "institutions": ["S-Bank", "Nordea"],
            "transactionCount": 216,
            "confidence": "high",
            "assumptions": ["Uses 90 days of income."],
            "baskets": [{ "id": "everyday", "label": "Everyday spending", "amount": 1766.57 }]
          },
          "suggestedPrompts": ["What if I reduced everyday spending by 20%?"],
          "source": "official-synthetic-dataset"
        }
        """.data(using: .utf8)!

        let reply = try PennyChatService.decode(payload)

        XCTAssertEqual(reply.message, "About €755 is safe this week.")
        XCTAssertEqual(reply.evidence?.confidence, "high")
        XCTAssertEqual(reply.evidence?.baskets.first?.amount, Decimal(string: "1766.57"))
        XCTAssertEqual(reply.suggestedPrompts.count, 1)
        XCTAssertEqual(reply.source, "official-synthetic-dataset")
    }

    func testSampleGoalAnswersAreMarkedAsExamplesWithoutInventedNumbers() {
        let sampleAnswers = PennyChatThread.samples.flatMap(\.initialMessages).filter { $0.role == .penny }
        XCTAssertTrue(sampleAnswers.allSatisfy { $0.source == "example" })
        XCTAssertTrue(sampleAnswers.allSatisfy { !$0.text.contains("€") && !$0.text.contains("%") })
    }
}
