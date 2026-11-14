import Foundation

enum Institution: String, Codable, CaseIterable, Identifiable, Sendable {
    case sBank = "S-Bank"
    case nordea = "Nordea"
    case op = "OP"
    case danske = "Danske Bank"

    var id: String { rawValue }
}

enum AccountKind: String, Codable, Sendable {
    case current = "Everyday account"
    case savings = "Savings account"
    case mortgage = "Mortgage"
}

struct BankAccount: Identifiable, Codable, Equatable, Sendable {
    let id: String
    let institution: Institution
    let name: String
    let kind: AccountKind
    let balance: Decimal
    let maskedNumber: String
}

struct BankTransaction: Identifiable, Codable, Equatable, Sendable {
    let id: String
    let accountID: String
    let institution: Institution
    let merchant: String
    let amount: Decimal
    let date: Date
    let category: String
}

struct BankConnection: Equatable, Sendable {
    let institution: Institution
    let accounts: [BankAccount]
    let transactions: [BankTransaction]
}

struct DemoSnapshot: Equatable, Sendable {
    let accounts: [BankAccount]
    let transactions: [BankTransaction]
}

struct PennyGoalStarter: Identifiable, CaseIterable, Hashable, Sendable {
    enum Kind: Hashable, Sendable {
        case regular
        case irregular
        case everyday
        case safeToSpend
        case whatIf
    }

    let kind: Kind
    let title: String
    let prompt: String
    let symbol: String
    var id: Kind { kind }

    static let allCases: [PennyGoalStarter] = [
        PennyGoalStarter(kind: .regular, title: "Regular essentials", prompt: "How much of my money goes to rent and other regular essentials?", symbol: "house.fill"),
        PennyGoalStarter(kind: .irregular, title: "Unexpected essentials", prompt: "Am I prepared for irregular costs like repairs or a broken appliance?", symbol: "wrench.and.screwdriver.fill"),
        PennyGoalStarter(kind: .everyday, title: "Everyday spending", prompt: "What everyday spending is slipping through my fingers?", symbol: "cup.and.saucer.fill"),
        PennyGoalStarter(kind: .safeToSpend, title: "Safe to spend", prompt: "What is safe for me to spend this week?", symbol: "checkmark.shield.fill"),
        PennyGoalStarter(kind: .whatIf, title: "Try a what-if", prompt: "What if I reduced restaurants by 20%?", symbol: "arrow.triangle.2.circlepath")
    ]
}

struct PennyBasketEvidence: Decodable, Hashable, Sendable {
    let id: String
    let label: String
    let amount: Decimal
}

struct PennyEvidence: Decodable, Hashable, Sendable {
    let coverage: String
    let institutions: [String]
    let transactionCount: Int
    let confidence: String
    let assumptions: [String]
    let baskets: [PennyBasketEvidence]
}

struct PennyChatReply: Decodable, Hashable, Sendable {
    let message: String
    let evidence: PennyEvidence?
    let suggestedPrompts: [String]
    let source: String
}

