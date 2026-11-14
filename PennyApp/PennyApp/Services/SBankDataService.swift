import Foundation

enum SBankDataStatus: Equatable, Sendable {
    case loading
    case official(coverage: String)
    case unavailable
}

struct SBankCustomerSummary: Codable, Sendable {
    struct Coverage: Codable, Sendable {
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

struct CachedFinancialData: Codable, Sendable {
    let coverage: String
    let accounts: [BankAccount]
    let transactions: [BankTransaction]
    let openBankingSessionIDs: [String]
}

struct FinancialDataCache {
    private let defaults: UserDefaults
    private let key = "penny.financialData.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> CachedFinancialData? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(CachedFinancialData.self, from: data)
    }

    func save(_ value: CachedFinancialData) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        defaults.set(data, forKey: key)
    }
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
