import Foundation

/// A user-confirmed savings plan. Amounts are EUR; balances are entered or verified,
/// never inferred from a chat answer. Saving a plan does not transfer money.
struct PennyGoalPlan: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    var title: String
    var targetAmount: Decimal
    var currentAmount: Decimal
    var targetDate: Date
    var monthlyContribution: Decimal
    let createdAt: Date
    var accountIDs: [String]

    init(id: UUID = UUID(), title: String, targetAmount: Decimal, currentAmount: Decimal,
         targetDate: Date, monthlyContribution: Decimal, createdAt: Date,
         accountIDs: [String] = []) {
        self.id = id
        self.title = title
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.targetDate = targetDate
        self.monthlyContribution = monthlyContribution
        self.createdAt = createdAt
        self.accountIDs = accountIDs
    }

    /// Uses one contribution per calendar month, plus one at the deadline for a
    /// final partial month. Assumes no interest, investment return or withdrawals.
    func projection(asOf date: Date, calendar: Calendar = .current) -> PennyGoalProjection {
        guard !targetAmount.isNaN, !currentAmount.isNaN, !monthlyContribution.isNaN,
              targetAmount > 0, currentAmount >= 0, monthlyContribution >= 0,
              date.timeIntervalSinceReferenceDate.isFinite,
              targetDate.timeIntervalSinceReferenceDate.isFinite else {
            return PennyGoalProjection(status: .needsDetails, remainingAmount: 0, progressFraction: 0,
                                       requiredMonthlyContribution: nil, projectedAmountAtTarget: 0,
                                       projectedCompletionDate: nil)
        }

        let remaining = max(0, targetAmount - currentAmount)
        let fraction = min(1, NSDecimalNumber(decimal: currentAmount / targetAmount).doubleValue)
        if remaining == 0 {
            return PennyGoalProjection(status: .completed, remainingAmount: 0, progressFraction: 1,
                                       requiredMonthlyContribution: 0, projectedAmountAtTarget: currentAmount,
                                       projectedCompletionDate: date)
        }

        let start = calendar.startOfDay(for: date)
        let deadline = calendar.startOfDay(for: targetDate)
        let periods = contributionPeriods(from: start, to: deadline, calendar: calendar)
        let required = periods > 0 ? Self.roundUp(remaining / Decimal(periods), scale: 2) : nil
        let projected = currentAmount + monthlyContribution * Decimal(periods)
        let status: PennyGoalStatus = deadline <= start ? .overdue : (projected >= targetAmount ? .onTrack : .needsAttention)
        var completion: Date?
        if monthlyContribution > 0 {
            let months = Self.roundUp(remaining / monthlyContribution, scale: 0)
            // A distant estimate is not useful enough to justify an unsafe Int
            // conversion or a date outside the supported calendar horizon.
            if months <= 1_200 {
                completion = calendar.date(byAdding: .month, value: NSDecimalNumber(decimal: months).intValue, to: start)
                if periods > 0, months <= Decimal(periods), let estimated = completion {
                    completion = min(estimated, deadline)
                }
            }
        }
        return PennyGoalProjection(status: status, remainingAmount: remaining, progressFraction: fraction,
                                   requiredMonthlyContribution: required, projectedAmountAtTarget: projected,
                                   projectedCompletionDate: completion)
    }

    /// A pure what-if calculation; the original goal and stored balance stay intact.
    func scenario(additionalMonthlyContribution: Decimal, oneOffContribution: Decimal = 0,
                  asOf date: Date, calendar: Calendar = .current) -> PennyGoalScenarioImpact {
        var changed = self
        changed.monthlyContribution += additionalMonthlyContribution
        changed.currentAmount += oneOffContribution
        let baseline = projection(asOf: date, calendar: calendar)
        let projected = changed.projection(asOf: date, calendar: calendar)
        return PennyGoalScenarioImpact(baseline: baseline, projected: projected,
                                       additionalAmountAtTarget: projected.projectedAmountAtTarget - baseline.projectedAmountAtTarget)
    }

    private func contributionPeriods(from start: Date, to deadline: Date, calendar: Calendar) -> Int {
        guard deadline > start else { return 0 }
        let wholeMonths = max(0, calendar.dateComponents([.month], from: start, to: deadline).month ?? 0)
        guard let anniversary = calendar.date(byAdding: .month, value: wholeMonths, to: start) else { return 0 }
        return wholeMonths + (anniversary < deadline ? 1 : 0)
    }

    private static func roundUp(_ value: Decimal, scale: Int) -> Decimal {
        var input = value
        var output = Decimal()
        NSDecimalRound(&output, &input, scale, .up)
        return output
    }
}

enum PennyGoalStatus: String, Codable, Sendable {
    case onTrack
    case needsAttention
    case completed
    case overdue
    case needsDetails

    var title: String {
        switch self {
        case .onTrack: "On track"
        case .needsAttention: "Needs attention"
        case .completed: "Goal reached"
        case .overdue: "Target date passed"
        case .needsDetails: "Check goal details"
        }
    }
}

struct PennyGoalProjection: Codable, Equatable, Sendable {
    let status: PennyGoalStatus
    let remainingAmount: Decimal
    let progressFraction: Double
    /// Nil means the deadline has passed or the plan needs valid details.
    let requiredMonthlyContribution: Decimal?
    let projectedAmountAtTarget: Decimal
    /// Nil means no completion can be estimated within 100 years at this rate.
    let projectedCompletionDate: Date?
}

struct PennyGoalScenarioImpact: Codable, Equatable, Sendable {
    let baseline: PennyGoalProjection
    let projected: PennyGoalProjection
    let additionalAmountAtTarget: Decimal
}
