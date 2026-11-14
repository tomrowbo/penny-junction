struct UnavailableOpenBankingService: OpenBankingService {
    func availableBanks() async throws -> [AvailableBank] {
        throw OpenBankingError.backendNotConfigured
    }

    func connect(_ bank: AvailableBank) async throws -> BankConnection {
        throw OpenBankingError.backendNotConfigured
    }
}

