import Foundation

enum SBankDataStatus: Equatable, Sendable {
    case fallback
    case loading
    case official(coverage: String)
    case unavailable
}

struct SBankCustomerSummary: Decodable, Sendable {
    struct Coverage: Decodable, Sendable {
        let from: String
        let to: String
        let transactionCount: Int

        var displayRange: String {
            let parser = ISO8601DateFormatter()
            parser.formatOptions = [.withFullDate]
            guard let fromDate = parser.date(from: from), let toDate = parser.date(from: to) else {
                return "\(from)–\(to)"
            }
            let style = Date.FormatStyle(date: .abbreviated, time: .omitted, locale: Locale(identifier: "en_GB"))
            return "\(fromDate.formatted(style))–\(toDate.formatted(style))"
        }
    }

    let source: String
    let anchorDate: String
    let coverage: Coverage
    let accounts: [BankAccount]
    let transactions: [BankTransaction]
}

struct SBankDataService: Sendable {
    let baseURL: URL

    func summary() async throws -> SBankCustomerSummary {
        let (data, response) = try await URLSession.shared.data(from: baseURL.appending(path: "api/customer/summary"))
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw PennyChatError.invalidResponse
        }
        return try Self.decode(data)
    }

    static func decode(_ data: Data) throws -> SBankCustomerSummary {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(SBankCustomerSummary.self, from: data)
    }
}
