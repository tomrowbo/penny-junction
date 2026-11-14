import XCTest
@testable import PennyApp

final class PennyGoalPlanTests: XCTestCase {
    private var calendar: Calendar {
        var value = Calendar(identifier: .gregorian)
        value.timeZone = TimeZone(secondsFromGMT: 0)!
        return value
    }

    private func date(_ month: Int, _ day: Int = 1) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: month, day: day))!
    }

    private func plan(current: Decimal = 200, monthly: Decimal = 100, target: Decimal = 800, deadline: Date? = nil) -> PennyGoalPlan {
        PennyGoalPlan(title: "Emergency fund", targetAmount: target, currentAmount: current,
                      targetDate: deadline ?? date(7), monthlyContribution: monthly, createdAt: date(1))
    }

    func testRequiredContributionUsesRemainingBalanceAndMonthsUntilDeadline() {
        let projection = plan().projection(asOf: date(1), calendar: calendar)
        XCTAssertEqual(projection.requiredMonthlyContribution, 100)
        XCTAssertEqual(projection.remainingAmount, 600)
        XCTAssertEqual(projection.progressFraction, 0.25)
        XCTAssertEqual(projection.projectedAmountAtTarget, 800)
        XCTAssertEqual(projection.projectedCompletionDate, date(7))
        XCTAssertEqual(projection.status, .onTrack)
    }

    func testRequiredContributionRoundsUpSoCentsDoNotLeaveAShortfall() {
        let projection = plan(current: 0, monthly: 34, target: 100, deadline: date(4))
            .projection(asOf: date(1), calendar: calendar)
        XCTAssertEqual(projection.requiredMonthlyContribution, Decimal(string: "33.34"))
    }

    func testShortFinalMonthHasOneContributionByDeadline() {
        let projection = plan(current: 0, monthly: 100, target: 100, deadline: date(1, 15))
            .projection(asOf: date(1), calendar: calendar)
        XCTAssertEqual(projection.requiredMonthlyContribution, 100)
        XCTAssertEqual(projection.projectedCompletionDate, date(1, 15))
        XCTAssertEqual(projection.status, .onTrack)
    }

    func testInsufficientContributionProjectsLaterCompletion() {
        let projection = plan(monthly: 50).projection(asOf: date(1), calendar: calendar)
        XCTAssertEqual(projection.status, .needsAttention)
        XCTAssertEqual(projection.projectedAmountAtTarget, 500)
        XCTAssertEqual(projection.projectedCompletionDate, calendar.date(from: DateComponents(year: 2027, month: 1, day: 1)))
    }

    func testNoContributionHasNoCompletionEstimate() {
        let projection = plan(monthly: 0).projection(asOf: date(1), calendar: calendar)
        XCTAssertNil(projection.projectedCompletionDate)
        XCTAssertEqual(projection.status, .needsAttention)
    }

    func testPastDeadlineHasNoFutureRequiredContribution() {
        let projection = plan().projection(asOf: date(8), calendar: calendar)
        XCTAssertEqual(projection.status, .overdue)
        XCTAssertNil(projection.requiredMonthlyContribution)
        XCTAssertEqual(projection.projectedAmountAtTarget, 200)
    }

    func testCompletedGoalCapsProgressAndNeedsNoFurtherSaving() {
        let projection = plan(current: 900).projection(asOf: date(8), calendar: calendar)
        XCTAssertEqual(projection.status, .completed)
        XCTAssertEqual(projection.progressFraction, 1)
        XCTAssertEqual(projection.requiredMonthlyContribution, 0)
        XCTAssertEqual(projection.remainingAmount, 0)
    }

    func testInvalidAmountsProduceNeedsDetailsInsteadOfAProjection() {
        for invalid in [plan(current: -1), plan(monthly: -1), plan(target: 0), plan(target: .nan)] {
            let projection = invalid.projection(asOf: date(1), calendar: calendar)
            XCTAssertEqual(projection.status, .needsDetails)
            XCTAssertNil(projection.requiredMonthlyContribution)
            XCTAssertNil(projection.projectedCompletionDate)
        }
    }

    func testScenarioAddsSavingsWithoutMutatingThePlan() {
        let original = plan(monthly: 50)
        let impact = original.scenario(additionalMonthlyContribution: 50, oneOffContribution: 100,
                                       asOf: date(1), calendar: calendar)
        XCTAssertEqual(original.currentAmount, 200)
        XCTAssertEqual(original.monthlyContribution, 50)
        XCTAssertEqual(impact.baseline.status, .needsAttention)
        XCTAssertEqual(impact.projected.status, .onTrack)
        XCTAssertEqual(impact.additionalAmountAtTarget, 400)
        XCTAssertEqual(impact.projected.projectedCompletionDate, date(6))
    }

    @MainActor
    func testInMemoryStorePersistsReplacementAndDeletion() throws {
        let store = InMemoryPennyGoalPlanStore()
        try store.save([plan()])
        XCTAssertEqual(try store.load().first?.title, "Emergency fund")
        try store.save([])
        XCTAssertTrue(try store.load().isEmpty)
    }

    @MainActor
    func testUserDefaultsStoreSurvivesNewStoreInstance() throws {
        let suite = "PennyGoalPlanTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let original = plan()
        try UserDefaultsPennyGoalPlanStore(defaults: defaults).save([original])
        let reloaded = try UserDefaultsPennyGoalPlanStore(defaults: defaults).load()
        XCTAssertEqual(reloaded, [original])
        XCTAssertEqual(reloaded.first?.projection(asOf: date(1), calendar: calendar).status, .onTrack)
    }

    @MainActor
    func testMalformedPersistenceIsReportedAndNotSilentlyOverwritten() throws {
        let suite = "PennyGoalPlanTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        defaults.set(Data("bad data".utf8), forKey: "penny.goalPlans.v1")
        XCTAssertThrowsError(try UserDefaultsPennyGoalPlanStore(defaults: defaults).load())
        XCTAssertEqual(defaults.data(forKey: "penny.goalPlans.v1"), Data("bad data".utf8))
    }
}
