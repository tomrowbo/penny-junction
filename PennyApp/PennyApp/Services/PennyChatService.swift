import Foundation

struct PennyChatService: Sendable {
    let baseURL: URL

    func reply(
        goal: String,
        messages: [PennyChatMessage],
        accounts: [BankAccount],
        transactions: [BankTransaction],
        goals: [PennyGoalPlan] = [],
        context: PennyChatContext? = nil
    ) async throws -> PennyChatReply {
        let request = try makeRequest(goal: goal, messages: messages, accounts: accounts,
                                      transactions: transactions, goals: goals, context: context)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw PennyChatError.invalidResponse }
        guard (200..<300).contains(http.statusCode) else {
            let error = try? JSONDecoder().decode(APIError.self, from: data)
            throw PennyChatError.server(error?.error ?? "Penny returned \(http.statusCode).")
        }
        guard let reply = try? Self.decode(data), !reply.message.isEmpty else {
            throw PennyChatError.invalidResponse
        }
        return reply
    }

    func makeRequest(
        goal: String,
        messages: [PennyChatMessage],
        accounts: [BankAccount],
        transactions: [BankTransaction],
        goals: [PennyGoalPlan] = [],
        context: PennyChatContext?
    ) throws -> URLRequest {
        var request = URLRequest(url: baseURL.appending(path: "api/chat"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let limitedMessages = Array(messages.filter { $0.source != "example" }.suffix(30))
        let limitedAccounts = Array(accounts.prefix(20))
        let limitedTransactions = Array(transactions.sorted { $0.date > $1.date }.prefix(500))
        let payload = ChatRequest(
            goal: goal,
            messages: limitedMessages.map {
                ChatMessage(role: $0.role == .user ? "user" : "assistant", text: String($0.text.prefix(4_000)))
            },
            financialData: FinancialData(accounts: limitedAccounts, transactions: limitedTransactions),
            selectedContext: context,
            goals: Array(goals.prefix(50)).map(GoalPlan.init)
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(payload)

        return request
    }

    private struct ChatRequest: Encodable {
        let goal: String
        let messages: [ChatMessage]
        let financialData: FinancialData
        let selectedContext: PennyChatContext?
        let goals: [GoalPlan]
    }

    private struct ChatMessage: Encodable {
        let role: String
        let text: String
    }

    private struct FinancialData: Encodable {
        let accounts: [BankAccount]
        let transactions: [BankTransaction]
    }

    private struct GoalPlan: Encodable {
        let id: UUID
        let title: String
        let targetAmount: Decimal
        let currentAmount: Decimal
        let targetDate: Date
        let monthlyContribution: Decimal

        init(_ plan: PennyGoalPlan) {
            id = plan.id
            title = plan.title
            targetAmount = plan.targetAmount
            currentAmount = plan.currentAmount
            targetDate = plan.targetDate
            monthlyContribution = plan.monthlyContribution
        }
    }

    private struct APIError: Decodable { let error: String }

    static func decode(_ data: Data) throws -> PennyChatReply {
        try JSONDecoder().decode(PennyChatReply.self, from: data)
    }
}

enum PennyChatError: LocalizedError {
    case invalidResponse
    case server(String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse: "Penny returned an unexpected response."
        case .server(let message): message
        }
    }
}
