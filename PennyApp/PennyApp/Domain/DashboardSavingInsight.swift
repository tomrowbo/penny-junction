import Foundation

struct DashboardSavingInsight: Equatable, Sendable {
    let category: String
    let monthlyOpportunity: Decimal
    let latestMonthlySpend: Decimal
    let baselineMonthlySpend: Decimal
    let baselineStart: Date
    let latestMonthStart: Date
    let latestMonthEnd: Date
    let institutions: [String]
    let transactionIDs: [String]
    let goalID: UUID?
    let goalTitle: String?
    let goalMonthlyContribution: Decimal?
}

enum DashboardSavingInsightCalculator {
    private static let minimumOpportunity = Decimal(5)

    static func make(
        transactions: [BankTransaction],
        goals: [PennyGoalPlan],
        asOf: Date,
        calendar: Calendar = .current
    ) -> DashboardSavingInsight? {
        guard let currentMonthStart = startOfMonth(containing: asOf, calendar: calendar),
              let latestMonthStart = calendar.date(byAdding: .month, value: -1, to: currentMonthStart),
              let baselineStart = calendar.date(byAdding: .month, value: -3, to: latestMonthStart) else {
            return nil
        }

        let monthStarts = (0..<4).compactMap {
            calendar.date(byAdding: .month, value: $0, to: baselineStart)
        }
        guard monthStarts.count == 4 else { return nil }

        let coveredInstitutions = monthStarts.reduce(nil as Set<Institution>?) { common, monthStart in
            guard let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) else { return [] }
            let present = Set(transactions.lazy
                .filter { $0.date >= monthStart && $0.date < monthEnd }
                .map(\.institution))
            return common.map { $0.intersection(present) } ?? present
        } ?? []
        guard !coveredInstitutions.isEmpty else { return nil }

        let comparable = transactions.filter {
            coveredInstitutions.contains($0.institution)
                && $0.date >= baselineStart
                && $0.date < currentMonthStart
                && $0.amount < 0
        }

        var candidates: [DashboardSavingInsight] = []
        for category in Set(comparable.compactMap({ supportedCategory($0.category) })) {
            let categoryRows = comparable.filter { supportedCategory($0.category) == category }
            let baselineRows = categoryRows.filter { $0.date < latestMonthStart }
            let baselineMonths = Set(baselineRows.compactMap {
                startOfMonth(containing: $0.date, calendar: calendar)
            })
            guard baselineMonths.count >= 2 else { continue }

            let baselineTotal = baselineRows.reduce(Decimal.zero) { $0 - $1.amount }
            let baselineAverage = round(baselineTotal / 3, scale: 2, mode: .plain)
            let latestRows = categoryRows.filter { $0.date >= latestMonthStart }
            let latestSpend = latestRows.reduce(Decimal.zero) { $0 - $1.amount }
            let opportunity = round(latestSpend - baselineAverage, scale: 0, mode: .down)
            guard opportunity >= minimumOpportunity else { continue }

            let goal = goals.first { $0.projection(asOf: asOf, calendar: calendar).status != .completed }
            candidates.append(DashboardSavingInsight(
                category: category,
                monthlyOpportunity: opportunity,
                latestMonthlySpend: latestSpend,
                baselineMonthlySpend: baselineAverage,
                baselineStart: baselineStart,
                latestMonthStart: latestMonthStart,
                latestMonthEnd: currentMonthStart,
                institutions: coveredInstitutions.map(\.rawValue).sorted(),
                transactionIDs: categoryRows.map(\.id),
                goalID: goal?.id,
                goalTitle: goal?.title,
                goalMonthlyContribution: goal?.monthlyContribution
            ))
        }

        return candidates.sorted {
            if $0.monthlyOpportunity == $1.monthlyOpportunity { return $0.category < $1.category }
            return $0.monthlyOpportunity > $1.monthlyOpportunity
        }.first
    }

    private static func startOfMonth(containing date: Date, calendar: Calendar) -> Date? {
        calendar.date(from: calendar.dateComponents([.era, .year, .month], from: date))
    }

    private static func supportedCategory(_ rawCategory: String) -> String? {
        let category = rawCategory.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        switch category {
        case "dining", "dining out", "restaurant", "restaurants", "cafe", "coffee":
            return "Dining"
        case "entertainment":
            return "Entertainment"
        case "lifestyle", "shopping":
            return "Lifestyle"
        case "travel":
            return "Travel"
        case "home & tech", "home and tech", "technology":
            return "Home & Tech"
        default:
            return nil
        }
    }

    private static func round(
        _ value: Decimal,
        scale: Int,
        mode: Decimal.RoundingMode
    ) -> Decimal {
        var input = value
        var output = Decimal()
        NSDecimalRound(&output, &input, scale, mode)
        return output
    }
}
