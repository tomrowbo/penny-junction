import XCTest
@testable import PennyApp

final class UpcomingMoneyTests: XCTestCase {
    func testMonthlyBillsPredictNextDateAndKeepEvidence() throws {
        let history = monthlyBills()
        let result = UpcomingMoneyDetector.detect(transactions: history, asOf: date(2026, 11, 14))
        let item = try XCTUnwrap(result.items.first)

        XCTAssertEqual(item.nextDate, date(2026, 12, 1))
        XCTAssertEqual(item.amount, 800)
        XCTAssertEqual(item.direction, .outflow)
        XCTAssertEqual(item.cadence, .monthly)
        XCTAssertEqual(item.confidence, .high)
        XCTAssertEqual(Set(item.sourceTransactionIDs), Set(history.map(\.id)))
        XCTAssertEqual(result.totalOutflow, 800)
        XCTAssertEqual(result.totalIncome, 0)
    }

    func testTwoPaymentsRemainTentativeAndAreExcludedFromTotals() throws {
        let history = [payment("a", 2026, 10, 1, -20), payment("b", 2026, 11, 1, -20)]
        let result = UpcomingMoneyDetector.detect(transactions: history, asOf: date(2026, 11, 14))

        XCTAssertEqual(try XCTUnwrap(result.items.first).confidence, .low)
        XCTAssertEqual(result.totalOutflow, 0)
        XCTAssertTrue(result.assumptions.contains { $0.contains("excluded") })
    }

    func testWeeklyIncomeIncludesEveryOccurrenceInsideThirtyDays() {
        let history = [1, 8, 15, 22].map { payment("salary-\($0)", 2026, 10, $0, 500, merchant: "Employer") }
        let result = UpcomingMoneyDetector.detect(transactions: history, asOf: date(2026, 10, 23))

        XCTAssertEqual(result.items.map(\.nextDate), [date(2026, 10, 29), date(2026, 11, 5), date(2026, 11, 12), date(2026, 11, 19)])
        XCTAssertEqual(result.totalIncome, 2_000)
        XCTAssertEqual(result.totalOutflow, 0)
    }

    func testNoRecurrenceIsInventedForSingleIrregularOrExpiredPatterns() {
        let history = [payment("one", 2026, 11, 1, -90, merchant: "One off")]
            + [payment("i1", 2026, 9, 1, -30), payment("i2", 2026, 10, 7, -30), payment("i3", 2026, 11, 2, -30)]
            + [payment("old1", 2026, 1, 1, -10, merchant: "Cancelled"), payment("old2", 2026, 2, 1, -10, merchant: "Cancelled"), payment("old3", 2026, 3, 1, -10, merchant: "Cancelled")]

        XCTAssertTrue(UpcomingMoneyDetector.detect(transactions: history, asOf: date(2026, 11, 14)).items.isEmpty)
    }

    func testMonthEndUsesCalendarMonthsWithoutDriftingAfterFebruary() throws {
        let history = [payment("jan", 2026, 1, 31, -50), payment("feb", 2026, 2, 28, -50), payment("mar", 2026, 3, 31, -50)]
        let result = UpcomingMoneyDetector.detect(transactions: history, asOf: date(2026, 4, 1))

        XCTAssertEqual(try XCTUnwrap(result.items.first).nextDate, date(2026, 4, 30))
    }

    func testLatestChargeChangeNamesEvidenceAndUsesLatestAmount() throws {
        let history = [payment("aug", 2026, 8, 1, -10), payment("sep", 2026, 9, 1, -10), payment("oct", 2026, 10, 1, -10), payment("nov", 2026, 11, 1, -12)]
        let item = try XCTUnwrap(UpcomingMoneyDetector.detect(transactions: history, asOf: date(2026, 11, 14)).items.first)
        let change = try XCTUnwrap(item.priceChange)

        XCTAssertEqual(item.amount, 12)
        XCTAssertEqual(item.confidence, .medium)
        XCTAssertEqual(change.previousAmount, 10)
        XCTAssertEqual(change.latestAmount, 12)
        XCTAssertEqual(change.difference, 2)
        XCTAssertEqual(change.sourceTransactionIDs, ["aug", "sep", "oct", "nov"])
    }

    func testVariableAmountsRemainTentativeWithoutAClaimOfPriceChange() throws {
        let history = [payment("aug", 2026, 8, 1, -30), payment("sep", 2026, 9, 1, -90), payment("oct", 2026, 10, 1, -10), payment("nov", 2026, 11, 1, -70)]
        let result = UpcomingMoneyDetector.detect(transactions: history, asOf: date(2026, 11, 14))
        let item = try XCTUnwrap(result.items.first)

        XCTAssertEqual(item.confidence, .low)
        XCTAssertNil(item.priceChange)
        XCTAssertEqual(result.totalOutflow, 0)
    }

    func testAccountsAndDirectionsStaySeparateAndFutureTransactionsAreIgnored() {
        let history = monthlyBills() + [payment("refund", 2026, 11, 1, 800), payment("future", 2026, 12, 1, -900)]
            + [payment("other", 2026, 11, 1, -800, accountID: "other")]
        let result = UpcomingMoneyDetector.detect(transactions: history, asOf: date(2026, 11, 14))

        XCTAssertEqual(result.items.count, 1)
        XCTAssertEqual(result.totalOutflow, 800)
        XCTAssertFalse(result.sourceTransactionIDs.contains("future"))
    }

    func testDuplicateInputAndOrderDoNotChangePredictionOrIDs() {
        let history = monthlyBills()
        let first = UpcomingMoneyDetector.detect(transactions: history, asOf: date(2026, 11, 14))
        let second = UpcomingMoneyDetector.detect(transactions: Array(history.reversed()) + history, asOf: date(2026, 11, 14))

        XCTAssertEqual(first, second)
    }

    func testWindowIncludesTodayAndExcludesDayThirty() {
        let history = [payment("aug", 2026, 8, 14, -10), payment("sep", 2026, 9, 14, -10), payment("oct", 2026, 10, 14, -10)]
        let result = UpcomingMoneyDetector.detect(transactions: history, asOf: date(2026, 11, 14))

        XCTAssertEqual(result.items.map(\.nextDate), [date(2026, 11, 14)])
        XCTAssertEqual(result.endDate, date(2026, 12, 14))
    }

    func testSummaryPreservesTheCalendarUsedForPredictedDates() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/New_York")!
        let result = UpcomingMoneyDetector.detect(transactions: [], asOf: date(2026, 11, 14), calendar: calendar)

        XCTAssertEqual(result.calendar.timeZone, calendar.timeZone)
        XCTAssertEqual(result.startDate, calendar.startOfDay(for: date(2026, 11, 14)))
    }

    func testQuarterlyYearlyAndFortnightlySchedulesUseTheirOwnCadence() throws {
        let quarterly = [2, 5, 8].map { payment("q-\($0)", 2026, $0, 1, -60) }
        let quarter = try XCTUnwrap(UpcomingMoneyDetector.detect(transactions: quarterly, asOf: date(2026, 10, 20)).items.first)
        XCTAssertEqual(quarter.cadence, .quarterly)
        XCTAssertEqual(quarter.nextDate, date(2026, 11, 1))

        let yearly = [2024, 2025, 2026].map { payment("y-\($0)", $0, 1, 1, -100) }
        let year = try XCTUnwrap(UpcomingMoneyDetector.detect(transactions: yearly, asOf: date(2026, 12, 15)).items.first)
        XCTAssertEqual(year.cadence, .yearly)
        XCTAssertEqual(year.nextDate, date(2027, 1, 1))

        let fortnightly = [payment("f1", 2026, 10, 1, -20), payment("f2", 2026, 10, 15, -20), payment("f3", 2026, 10, 29, -20), payment("f4", 2026, 11, 12, -20)]
        let result = UpcomingMoneyDetector.detect(transactions: fortnightly, asOf: date(2026, 11, 14))
        XCTAssertEqual(result.items.map(\.nextDate), [date(2026, 11, 26), date(2026, 12, 10)])
        XCTAssertTrue(result.items.allSatisfy { $0.cadence == .fortnightly })
        XCTAssertEqual(result.totalOutflow, 40)
    }

    func testRepeatedIncreaseRetainsChangeEvidence() throws {
        let history = [payment("aug", 2026, 8, 1, -10), payment("sep", 2026, 9, 1, -10), payment("oct", 2026, 10, 1, -12), payment("nov", 2026, 11, 1, -12)]
        let item = try XCTUnwrap(UpcomingMoneyDetector.detect(transactions: history, asOf: date(2026, 11, 14)).items.first)

        XCTAssertEqual(item.priceChange?.difference, 2)
        XCTAssertEqual(item.confidence, .medium)
        XCTAssertEqual(item.amount, 12)
    }

    func testMerchantNormalizationAllowsCaseSpacingAndAccents() {
        let history = [payment("sep", 2026, 9, 1, -10, merchant: "Rent"), payment("oct", 2026, 10, 1, -10, merchant: "  RÉNT  "), payment("nov", 2026, 11, 1, -10, merchant: "rent")]
        let result = UpcomingMoneyDetector.detect(transactions: history, asOf: date(2026, 11, 14))

        XCTAssertEqual(result.items.count, 1)
        XCTAssertEqual(result.totalOutflow, 10)
    }

    func testAmbiguousMultipleChargesOnOneDayDoNotBecomeARecurringBill() {
        let history = monthlyBills() + [payment("second-charge", 2026, 11, 1, -200)]

        XCTAssertTrue(UpcomingMoneyDetector.detect(transactions: history, asOf: date(2026, 11, 14)).items.isEmpty)
    }

    private func monthlyBills() -> [BankTransaction] {
        (8...11).map { payment("rent-\($0)", 2026, $0, 1, -800) }
    }

    private func payment(_ id: String, _ year: Int, _ month: Int, _ day: Int, _ amount: Decimal, merchant: String = "Rent", accountID: String = "current") -> BankTransaction {
        BankTransaction(id: id, accountID: accountID, institution: .sBank, merchant: merchant, amount: amount, date: date(year, month, day), category: "Bills")
    }

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }
}
