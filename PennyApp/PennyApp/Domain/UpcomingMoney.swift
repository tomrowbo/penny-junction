import Foundation

enum UpcomingMoneyDirection: String, Codable, Sendable {
    case outflow, income
}

enum UpcomingMoneyCadence: String, Codable, CaseIterable, Sendable {
    case weekly, fortnightly, monthly, quarterly, yearly

    var label: String {
        switch self {
        case .weekly: "Weekly"
        case .fortnightly: "Every two weeks"
        case .monthly: "Monthly"
        case .quarterly: "Every three months"
        case .yearly: "Yearly"
        }
    }

    fileprivate var months: Int? {
        switch self {
        case .monthly: 1
        case .quarterly: 3
        case .yearly: 12
        default: nil
        }
    }
}

enum UpcomingMoneyConfidence: String, Codable, Sendable {
    case low, medium, high
}

/// Observed changes in charges, rather than a claim about a provider's future pricing.
struct UpcomingMoneyPriceChange: Equatable, Codable, Sendable {
    let previousAmount: Decimal
    let latestAmount: Decimal
    let sourceTransactionIDs: [String]

    var difference: Decimal { latestAmount - previousAmount }
}

struct UpcomingMoneyItem: Identifiable, Equatable, Codable, Sendable {
    let id: String
    let seriesID: String
    let merchant: String
    let accountID: String
    let institution: Institution
    let direction: UpcomingMoneyDirection
    /// Positive magnitude; direction carries the sign.
    let amount: Decimal
    let nextDate: Date
    let cadence: UpcomingMoneyCadence
    let confidence: UpcomingMoneyConfidence
    let sourceTransactionIDs: [String]
    let priceChange: UpcomingMoneyPriceChange?

    var isIncludedInTotals: Bool { confidence != .low }
}

struct UpcomingMoneySummary: Equatable, Sendable {
    let calendar: Calendar
    let startDate: Date
    /// Exclusive end of the 30-calendar-day window.
    let endDate: Date
    let items: [UpcomingMoneyItem]
    let assumptions: [String]

    /// Estimated commitments, excluding tentative patterns.
    var totalOutflow: Decimal { total(for: .outflow) }
    var totalIncome: Decimal { total(for: .income) }
    var sourceTransactionIDs: [String] { Array(Set(items.flatMap(\.sourceTransactionIDs))).sorted() }
    var accountIDs: [String] { Array(Set(items.map(\.accountID))).sorted() }

    private func total(for direction: UpcomingMoneyDirection) -> Decimal {
        items.filter { $0.direction == direction && $0.isIncludedInTotals }.reduce(0) { $0 + $1.amount }
    }
}

enum UpcomingMoneyDetector {
    static var defaultCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    /// Uses recorded transactions only. No merchant/category allowlist or language-model guesses.
    static func detect(transactions: [BankTransaction], asOf: Date, calendar: Calendar = defaultCalendar) -> UpcomingMoneySummary {
        let start = calendar.startOfDay(for: asOf)
        let end = calendar.date(byAdding: .day, value: 30, to: start)!
        var seen = Set<String>()
        let history = transactions.sorted(by: transactionOrder).filter { transaction in
            guard transaction.date <= asOf, !transaction.amount.isNaN, transaction.amount != 0,
                  !normalize(transaction.merchant).isEmpty else { return false }
            // Preserve separate accounts even if an aggregator reuses an identifier.
            return seen.insert(identity([transaction.institution.rawValue, transaction.accountID, transaction.id])).inserted
        }
        let grouped = Dictionary(grouping: history) { transaction in
            identity([transaction.institution.rawValue, transaction.accountID, normalize(transaction.merchant), transaction.amount < 0 ? "outflow" : "income"])
        }
        let items = grouped.keys.sorted().flatMap { key -> [UpcomingMoneyItem] in
            guard let payments = grouped[key], payments.count >= 2 else { return [] }
            return predictions(payments, seriesID: key, start: start, end: end, calendar: calendar)
        }.sorted { lhs, rhs in
            lhs.nextDate == rhs.nextDate ? lhs.id < rhs.id : lhs.nextDate < rhs.nextDate
        }
        return UpcomingMoneySummary(calendar: calendar, startDate: start, endDate: end, items: items, assumptions: [
            "Estimates use recurring transactions in connected accounts; bills and income can change.",
            "Tentative patterns are excluded from totals. Unseen commitments and account transfers may be missing or misclassified.",
            "Patterns stop predicting when their next expected payment is already past."
        ])
    }

    private static func predictions(_ history: [BankTransaction], seriesID: String, start: Date, end: Date, calendar: Calendar) -> [UpcomingMoneyItem] {
        let dates = history.map { calendar.startOfDay(for: $0.date) }
        // Multiple charges on the same day cannot be safely treated as one recurring bill.
        guard Set(dates).count == dates.count,
              let first = dates.first, let last = history.last,
              let cadence = UpcomingMoneyCadence.allCases.first(where: { candidate in
                  dates.enumerated().allSatisfy { index, observed in
                      guard let expected = nextDate(from: first, offset: index, cadence: candidate, dates: dates, calendar: calendar) else { return false }
                      let error = abs(calendar.dateComponents([.day], from: expected, to: observed).day ?? Int.max)
                      return error <= (candidate.months == nil ? 1 : 3)
                  }
              }) else { return [] }

        let amounts = history.map { magnitude($0.amount) }
        let change = priceChange(history: history, amounts: amounts)
        let stable = isStable(amounts)
        let confidence: UpcomingMoneyConfidence
        if history.count < 3 || (!stable && change == nil) {
            confidence = .low
        } else if history.count >= 4 && stable {
            confidence = .high
        } else {
            confidence = .medium
        }
        var results: [UpcomingMoneyItem] = []
        // At most five weekly occurrences fit in the window; this also bounds malformed-calendar work.
        for offset in 1...32 {
            guard let predicted = nextDate(from: calendar.startOfDay(for: last.date), offset: offset, cadence: cadence, dates: dates, calendar: calendar),
                  predicted >= start, predicted < end else { break }
            results.append(UpcomingMoneyItem(
                id: identity([seriesID, String(predicted.timeIntervalSince1970)]), seriesID: seriesID,
                merchant: last.merchant, accountID: last.accountID, institution: last.institution,
                direction: last.amount < 0 ? .outflow : .income, amount: magnitude(last.amount),
                nextDate: predicted, cadence: cadence, confidence: confidence,
                sourceTransactionIDs: history.map(\.id), priceChange: change
            ))
        }
        return results
    }

    private static func nextDate(from anchor: Date, offset: Int, cadence: UpcomingMoneyCadence, dates: [Date], calendar: Calendar) -> Date? {
        guard let months = cadence.months else {
            return calendar.date(byAdding: .day, value: offset * (cadence == .weekly ? 7 : 14), to: anchor)
        }
        // Construct from the target month so a February payment never drifts March's day.
        let anchorMonth = calendar.date(from: calendar.dateComponents([.era, .year, .month], from: anchor))!
        guard let month = calendar.date(byAdding: .month, value: offset * months, to: anchorMonth),
              let days = calendar.range(of: .day, in: .month, for: month) else { return nil }
        let isMonthEnd = dates.allSatisfy { date in
            calendar.component(.day, from: date) == calendar.range(of: .day, in: .month, for: date)?.count
        }
        let anchorDay = dates.map { calendar.component(.day, from: $0) }.max() ?? 1
        return calendar.date(byAdding: .day, value: (isMonthEnd ? days.count : min(anchorDay, days.count)) - 1, to: month)
    }

    private static func priceChange(history: [BankTransaction], amounts: [Decimal]) -> UpcomingMoneyPriceChange? {
        guard amounts.count >= 3 else { return nil }
        // Two stable prior charges establish a baseline. A changed latest charge is evidence,
        // but confidence stays medium until a stable history is established again.
        for split in (2..<amounts.count).reversed() {
            let before = Array(amounts[..<split])
            let after = Array(amounts[split...])
            guard isStable(before), isStable(after), let previous = before.last, let latest = after.last,
                  magnitude(latest - previous) > tolerance(previous) else { continue }
            return UpcomingMoneyPriceChange(previousAmount: previous, latestAmount: latest, sourceTransactionIDs: history.map(\.id))
        }
        return nil
    }

    private static func isStable(_ amounts: [Decimal]) -> Bool {
        guard let first = amounts.first else { return false }
        return amounts.allSatisfy { magnitude($0 - first) <= tolerance(first) }
    }

    private static func tolerance(_ amount: Decimal) -> Decimal { max(Decimal(string: "0.50")!, amount * Decimal(string: "0.02")!) }
    private static func magnitude(_ value: Decimal) -> Decimal { value < 0 ? -value : value }
    private static func normalize(_ merchant: String) -> String {
        merchant.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "en_US_POSIX"))
            .split(whereSeparator: \.isWhitespace).joined(separator: " ")
    }

    private static func identity(_ parts: [String]) -> String { parts.map { "\($0.utf8.count):\($0)" }.joined() }
    private static func transactionOrder(_ lhs: BankTransaction, _ rhs: BankTransaction) -> Bool {
        if lhs.date != rhs.date { return lhs.date < rhs.date }
        return identity([lhs.institution.rawValue, lhs.accountID, lhs.id, lhs.merchant, lhs.amount.description])
            < identity([rhs.institution.rawValue, rhs.accountID, rhs.id, rhs.merchant, rhs.amount.description])
    }
}
