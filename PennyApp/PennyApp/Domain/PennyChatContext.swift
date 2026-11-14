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
}
