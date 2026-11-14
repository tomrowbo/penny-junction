import Foundation

enum DashboardSubtitleBuilder {
    static func make(
        transactions: [BankTransaction],
        goals: [PennyGoalPlan],
        asOf: Date,
        calendar: Calendar = .current
    ) -> [String] {
        var subtitles: [String] = []

        if let comparison = spendingComparison(transactions: transactions, asOf: asOf, calendar: calendar) {
            subtitles.append(comparison)
        }

        if let goal = goals.first(where: { $0.targetAmount > 0 && $0.currentAmount >= 0 }) {
            let progress = min(1, NSDecimalNumber(decimal: goal.currentAmount / goal.targetAmount).doubleValue)
            let name = goalName(from: goal.title)
            if progress >= 1 {
                subtitles.append("You reached your \(name) goal!")
            } else {
                let remaining = (1 - progress).formatted(.percent.precision(.fractionLength(0)))
                subtitles.append("Only \(remaining) left to your \(name) goal!")
            }
        }

        return subtitles
    }

    private static func goalName(from title: String) -> String {
        let value = title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let prefixes = ["buy a new ", "buy a ", "save for a new ", "save for a ", "save for "]
        if let prefix = prefixes.first(where: value.hasPrefix) {
            return String(value.dropFirst(prefix.count))
        }
        return value.hasSuffix(" goal") ? String(value.dropLast(5)) : value
    }

    private static func spendingComparison(
        transactions: [BankTransaction],
        asOf: Date,
        calendar: Calendar
    ) -> String? {
        let components = calendar.dateComponents([.era, .year, .month], from: asOf)
        guard let currentMonth = calendar.date(from: components),
              let lastMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth),
              let monthBefore = calendar.date(byAdding: .month, value: -2, to: currentMonth) else { return nil }

        let excludedCategories = Set(["Invest Deposit", "Invest Withdraw", "Salary Sweep"])
        let spend = transactions.filter { $0.amount < 0 && !excludedCategories.contains($0.category) }
        let lastMonthRows = spend.filter { $0.date >= lastMonth && $0.date < currentMonth }
        let priorMonthRows = spend.filter { $0.date >= monthBefore && $0.date < lastMonth }
        let lastMonthInstitutions = Set(lastMonthRows.map(\.institution))
        let priorMonthInstitutions = Set(priorMonthRows.map(\.institution))
        guard !lastMonthRows.isEmpty, !priorMonthRows.isEmpty,
              lastMonthInstitutions == priorMonthInstitutions else { return nil }

        let lastMonthTotal = lastMonthRows.reduce(Decimal.zero) { $0 - $1.amount }
        let priorMonthTotal = priorMonthRows.reduce(Decimal.zero) { $0 - $1.amount }
        let difference = lastMonthTotal - priorMonthTotal
        guard difference != 0 else { return nil }

        if difference < 0 {
            return "You spent \((-difference).euroCurrency) less last month."
        }
        return "You spent \(difference.euroCurrency) more last month."
    }
}
