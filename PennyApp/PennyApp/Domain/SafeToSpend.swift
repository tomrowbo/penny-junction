import Foundation

/// An unpaid outflow supplied by the upcoming-money calculation or the customer.
/// Amounts are positive reserves; an expected refund must not increase spendable cash.
struct SafeToSpendCommitment: Identifiable, Equatable, Sendable {
    let id: String
    let label: String
    let amount: Decimal
    let dueDate: Date
    var sourceTransactionIDs: [String] = []
}

struct SafeToSpendResult: Equatable, Sendable {
    enum Confidence: String, Sendable {
        case low, medium, high
    }

    enum DataCompleteness: String, Sendable {
        case insufficient, partial, complete

        var label: String {
            switch self {
            case .insufficient: "Limited data"
            case .partial: "Partial data"
            case .complete: "Connected data complete"
            }
        }
    }

    let safeToday: Decimal
    let safeUntilPayday: Decimal
    let availableBalance: Decimal
    let reservedCommitments: Decimal
    let goalContribution: Decimal
    let shortfall: Decimal
    /// Starts today and ends at the start of payday, excluding the payday itself.
    let period: DateInterval
    let daysUntilPayday: Int
    let usesFallbackPeriod: Bool
    let confidence: Confidence
    let dataCompleteness: DataCompleteness
    let assumptions: [String]
    let accountIDs: [String]
    let accountNames: [String]
    let sourceTransactionIDs: [String]
    let transactionCoverage: DateInterval?
}

enum SafeToSpendCalculator {
    /// Balances already include booked transactions: history is evidence, never subtracted again.
    /// The caller supplies unpaid commitments and the goal reserve for this same period.
    static func calculate(
        accounts: [BankAccount],
        transactions: [BankTransaction],
        asOf: Date,
        nextPayday: Date? = nil,
        commitments: [SafeToSpendCommitment] = [],
        goalContribution: Decimal = 0,
        dataIsComplete: Bool = false,
        calendar: Calendar = Calendar(identifier: .gregorian)
    ) -> SafeToSpendResult {
        let start = calendar.startOfDay(for: asOf)
        let suppliedPayday = nextPayday.map { calendar.startOfDay(for: $0) }
        let payday = suppliedPayday.flatMap { $0 > start ? $0 : nil }
        let end = payday ?? calendar.date(byAdding: .day, value: 30, to: start)!
        let days = max(1, calendar.dateComponents([.day], from: start, to: end).day ?? 30)

        var seenAccounts = Set<String>()
        let spendingAccounts = accounts.filter { $0.kind == .current && seenAccounts.insert($0.id).inserted }
        let accountIDs = Set(spendingAccounts.map(\.id))
        var seenTransactions = Set<String>()
        let history = transactions.filter {
            accountIDs.contains($0.accountID) && $0.date <= asOf && seenTransactions.insert($0.id).inserted
        }
        let validSourceIDs = Set(history.map(\.id))
        var seenCommitments = Set<String>()
        let reserves = commitments.filter {
            $0.dueDate < end && !$0.amount.isNaN && $0.amount > 0 && seenCommitments.insert($0.id).inserted
        }
        let requestedSources = Set(reserves.flatMap(\.sourceTransactionIDs))
        let evidenceIsValid = requestedSources.isSubset(of: validSourceIDs)
        let sources = requestedSources.intersection(validSourceIDs).sorted()
        let balance = spendingAccounts.reduce(Decimal.zero) { $0 + ($1.balance.isNaN ? 0 : $1.balance) }
        let reserved = reserves.reduce(Decimal.zero) { $0 + $1.amount }
        let goal = goalContribution.isNaN ? 0 : max(0, goalContribution)
        let remainder = balance - reserved - goal
        let available = roundedDown(max(0, remainder))
        let coverage = history.map(\.date).min().map { first in
            DateInterval(start: first, end: history.map(\.date).max() ?? first)
        }
        let observedAccounts = Set(history.map(\.accountID))
        let hasInvalidBalance = spendingAccounts.contains { $0.balance.isNaN }
        let completeness: SafeToSpendResult.DataCompleteness
        if spendingAccounts.isEmpty || history.isEmpty {
            completeness = .insufficient
        } else if dataIsComplete && observedAccounts == accountIDs && evidenceIsValid && !hasInvalidBalance {
            completeness = .complete
        } else {
            completeness = .partial
        }
        let historyDays = coverage.map { calendar.dateComponents([.day], from: $0.start, to: asOf).day ?? 0 } ?? 0
        let confidence: SafeToSpendResult.Confidence
        if payday == nil || completeness == .insufficient {
            confidence = .low
        } else if completeness == .complete && historyDays >= 60 {
            confidence = .high
        } else {
            confidence = .medium
        }

        var assumptions = [
            "Uses current-account balances only; savings and loans are excluded.",
            "Booked transactions are already included in balances. Only unpaid commitments before payday are reserved.",
            "Expected income is not added before it arrives. Everyday spending comes from the remaining amount."
        ]
        if payday == nil {
            assumptions.append("No future payday is confirmed; this estimate uses the next 30 days.")
        }
        if completeness != .complete {
            assumptions.append("Missing accounts, pending payments or undetected bills may reduce what is available.")
        }
        if historyDays < 60 {
            assumptions.append("Less than 60 days of transaction history is available for checking regular costs.")
        }
        if reserves.isEmpty {
            assumptions.append("No upcoming commitments were supplied for this period; this does not mean there are no bills.")
        }
        if !evidenceIsValid {
            assumptions.append("Some commitment evidence is unavailable in the connected transaction history.")
        }
        if hasInvalidBalance {
            assumptions.append("An unavailable account balance is treated as zero.")
        }

        return SafeToSpendResult(
            safeToday: roundedDown(available / Decimal(days)),
            safeUntilPayday: available,
            availableBalance: balance,
            reservedCommitments: reserved,
            goalContribution: goal,
            shortfall: max(0, -remainder),
            period: DateInterval(start: start, end: end),
            daysUntilPayday: days,
            usesFallbackPeriod: payday == nil,
            confidence: confidence,
            dataCompleteness: completeness,
            assumptions: assumptions,
            accountIDs: spendingAccounts.map(\.id).sorted(),
            accountNames: spendingAccounts.sorted { $0.id < $1.id }.map(\.name),
            sourceTransactionIDs: sources,
            transactionCoverage: coverage
        )
    }

    private static func roundedDown(_ amount: Decimal) -> Decimal {
        var value = amount
        var rounded = Decimal.zero
        NSDecimalRound(&rounded, &value, 2, .down)
        return rounded
    }
}
