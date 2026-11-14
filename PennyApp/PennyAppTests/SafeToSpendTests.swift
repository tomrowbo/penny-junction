import XCTest
@testable import PennyApp

final class SafeToSpendTests: XCTestCase {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    private func date(_ day: Int, month: Int = 11) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: month, day: day))!
    }

    private func account(_ id: String = "current", balance: Decimal = 1_000, kind: AccountKind = .current) -> BankAccount {
        BankAccount(id: id, institution: .sBank, name: id, kind: kind, balance: balance, maskedNumber: "1234")
    }

    private func transaction(_ id: String = "rent", accountID: String = "current", day: Int = 1) -> BankTransaction {
        BankTransaction(id: id, accountID: accountID, institution: .sBank, merchant: "Rent", amount: -200, date: date(day), category: "Housing")
    }

    func testReservesBillsAndGoalBeforeDividingAvailableBalance() {
        // Omitting either reserve or counting savings as spendable breaks this fixture.
        let result = SafeToSpendCalculator.calculate(
            accounts: [account(), account("savings", balance: 5_000, kind: .savings)],
            transactions: [transaction()],
            asOf: date(14), nextPayday: date(24),
            commitments: [SafeToSpendCommitment(id: "rent", label: "Rent", amount: 200, dueDate: date(20), sourceTransactionIDs: ["rent"])],
            goalContribution: 100, dataIsComplete: true, calendar: calendar
        )

        XCTAssertEqual(result.safeUntilPayday, 700)
        XCTAssertEqual(result.safeToday, 70)
        XCTAssertEqual(result.reservedCommitments, 200)
        XCTAssertEqual(result.goalContribution, 100)
        XCTAssertEqual(result.period.end, date(24))
        XCTAssertEqual(result.daysUntilPayday, 10)
        XCTAssertEqual(result.accountIDs, ["current"])
        XCTAssertEqual(result.sourceTransactionIDs, ["rent"])
    }

    func testPaydayBoundaryDoesNotReserveBillsDueAfterIncomeArrives() {
        let bills = [
            SafeToSpendCommitment(id: "today", label: "Today", amount: 100, dueDate: date(14)),
            SafeToSpendCommitment(id: "payday", label: "Payday", amount: 400, dueDate: date(24)),
            SafeToSpendCommitment(id: "later", label: "Later", amount: 300, dueDate: date(25))
        ]
        let result = SafeToSpendCalculator.calculate(accounts: [account()], transactions: [], asOf: date(14), nextPayday: date(24), commitments: bills, calendar: calendar)

        XCTAssertEqual(result.reservedCommitments, 100)
        XCTAssertEqual(result.safeUntilPayday, 900)
    }

    func testMissingPaydayAndTransactionsDiscloseFallbackAndInsufficientData() {
        let result = SafeToSpendCalculator.calculate(accounts: [account()], transactions: [], asOf: date(14), calendar: calendar)

        XCTAssertEqual(result.daysUntilPayday, 30)
        XCTAssertTrue(result.usesFallbackPeriod)
        XCTAssertEqual(result.confidence, .low)
        XCTAssertEqual(result.dataCompleteness, .insufficient)
        XCTAssertFalse(result.assumptions.isEmpty)
    }

    func testOverdrawnAccountsReduceAvailableCashAndNeverProduceNegativeAllowance() {
        let result = SafeToSpendCalculator.calculate(
            accounts: [account(balance: 100), account("overdraft", balance: -150), account("loan", balance: -10_000, kind: .mortgage)],
            transactions: [], asOf: date(14), nextPayday: date(24), goalContribution: 50, calendar: calendar
        )

        XCTAssertEqual(result.availableBalance, -50)
        XCTAssertEqual(result.safeToday, 0)
        XCTAssertEqual(result.safeUntilPayday, 0)
        XCTAssertEqual(result.shortfall, 100)
    }

    func testDailyAmountRoundsDownToAvoidOverspending() {
        let result = SafeToSpendCalculator.calculate(accounts: [account(balance: 100)], transactions: [], asOf: date(14), nextPayday: date(17), calendar: calendar)
        XCTAssertEqual(result.safeToday, Decimal(string: "33.33"))
    }

    func testOverdueUnpaidCommitmentsRemainReserved() {
        let result = SafeToSpendCalculator.calculate(
            accounts: [account()], transactions: [], asOf: date(14), nextPayday: date(24),
            commitments: [SafeToSpendCommitment(id: "overdue", label: "Unpaid bill", amount: 100, dueDate: date(13))],
            calendar: calendar
        )

        XCTAssertEqual(result.reservedCommitments, 100)
        XCTAssertEqual(result.safeUntilPayday, 900)
    }

    func testEvidenceOnlyContainsKnownHistoricalTransactionsForIncludedAccounts() {
        let result = SafeToSpendCalculator.calculate(
            accounts: [account(), account("savings", kind: .savings)],
            transactions: [transaction(), transaction("future", day: 25), transaction("savings", accountID: "savings")],
            asOf: date(14), nextPayday: date(24),
            commitments: [SafeToSpendCommitment(id: "bill", label: "Bill", amount: 50, dueDate: date(20), sourceTransactionIDs: ["rent", "missing", "future", "savings", "rent"])],
            calendar: calendar
        )

        XCTAssertEqual(result.sourceTransactionIDs, ["rent"])
        XCTAssertEqual(result.dataCompleteness, .partial)
        XCTAssertNotEqual(result.confidence, .high)
    }

    func testDuplicateCommitmentsAndNegativeReservesCannotInflateSpending() {
        let bill = SafeToSpendCommitment(id: "bill", label: "Bill", amount: 200, dueDate: date(20))
        let result = SafeToSpendCalculator.calculate(
            accounts: [account(), account()], transactions: [], asOf: date(14), nextPayday: date(24),
            commitments: [bill, bill, SafeToSpendCommitment(id: "refund", label: "Refund", amount: -100, dueDate: date(20))],
            goalContribution: -50, calendar: calendar
        )

        XCTAssertEqual(result.safeUntilPayday, 800)
        XCTAssertEqual(result.goalContribution, 0)
    }

    func testCompleteCoverageAndExplicitPaydaySupportHigherConfidence() {
        let history = BankTransaction(id: "old", accountID: "current", institution: .sBank, merchant: "Rent", amount: -200, date: date(1, month: 8), category: "Housing")
        let result = SafeToSpendCalculator.calculate(accounts: [account()], transactions: [history, transaction()], asOf: date(14), nextPayday: date(24), dataIsComplete: true, calendar: calendar)

        XCTAssertEqual(result.confidence, .high)
        XCTAssertEqual(result.dataCompleteness, .complete)
        XCTAssertEqual(result.transactionCoverage?.start, date(1, month: 8))
    }
}
