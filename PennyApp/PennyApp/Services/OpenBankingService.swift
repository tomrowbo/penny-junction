import Foundation

struct AvailableBank: Identifiable, Hashable, Sendable {
    let institution: Institution
    let name: String
    let description: String

    var id: String { institution.id }
}

protocol OpenBankingService: Sendable {
    func availableBanks() async throws -> [AvailableBank]
    func connect(_ bank: AvailableBank) async throws -> BankConnection
}

enum OpenBankingError: LocalizedError {
    case invalidResponse
    case backendNotConfigured
    case providerMessage(String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse: "The bank connection returned an unexpected response."
        case .backendNotConfigured: "The live open-banking backend has not been configured."
        case .providerMessage(let message): message
        }
    }
}

