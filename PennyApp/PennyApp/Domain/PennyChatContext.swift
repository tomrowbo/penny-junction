import Foundation

/// A reference to stored data, never a caller-supplied set of financial facts.
enum PennyChatSubject: Hashable, Codable, Sendable {
    case transaction(String)
    case account(String)
    case goal(UUID)
    case upcoming(String)
}

/// A compact display snapshot. Financial calculations still belong to the finance engine.
struct PennyChatContext: Hashable, Codable, Sendable {
    enum Kind: String, Hashable, Codable, Sendable {
        case transaction, account, goal, upcoming, insight
    }

    let type: Kind
    let referenceID: String
    let title: String
    let subtitle: String
    let accountIDs: [String]
    let transactionIDs: [String]
    let suggestedPrompts: [String]
    let insight: PennyInsightContext?

    init(
        type: Kind,
        referenceID: String,
        title: String,
        subtitle: String,
        accountIDs: [String],
        transactionIDs: [String],
        suggestedPrompts: [String],
        insight: PennyInsightContext? = nil
    ) {
        self.type = type
        self.referenceID = referenceID
        self.title = title
        self.subtitle = subtitle
        self.accountIDs = accountIDs
        self.transactionIDs = transactionIDs
        self.suggestedPrompts = suggestedPrompts
        self.insight = insight
    }
}

/// The deterministic evidence envelope behind a proactive dashboard recommendation.
struct PennyInsightContext: Hashable, Codable, Sendable {
    let category: String
    let monthlyOpportunity: Decimal
    let latestMonthlySpend: Decimal
    let baselineMonthlySpend: Decimal
    let baselineFrom: String
    let latestFrom: String
    let latestTo: String
    let institutions: [String]
}
