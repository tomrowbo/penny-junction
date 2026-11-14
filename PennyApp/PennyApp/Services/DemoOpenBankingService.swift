import Foundation

struct DemoOpenBankingService: OpenBankingService {
    func availableBanks() async throws -> [AvailableBank] {
        [
            AvailableBank(institution: .nordea, name: "Nordea", description: "Personal accounts and mortgages"),
            AvailableBank(institution: .op, name: "OP", description: "Accounts, loans and cards"),
            AvailableBank(institution: .danske, name: "Danske Bank", description: "Personal banking")
        ]
    }

    func connect(_ bank: AvailableBank) async throws -> BankConnection {
        try await Task.sleep(for: .milliseconds(850))
        return Self.connection(for: bank.institution)
    }

    static func connection(for institution: Institution) -> BankConnection {
        let prefix = institution.rawValue.lowercased().replacingOccurrences(of: " ", with: "-")
        let account = BankAccount(
            id: "\(prefix)-current",
            institution: institution,
            name: "Current account",
            kind: .current,
            balance: DemoData.decimal("1640.50"),
            maskedNumber: "•• 7714"
        )
        let mortgage = BankAccount(
            id: "\(prefix)-mortgage",
            institution: institution,
            name: "Home mortgage",
            kind: .mortgage,
            balance: DemoData.decimal("-186450.00"),
            maskedNumber: "•• 2048"
        )
        let transactions = [
            BankTransaction(
                id: "\(prefix)-fuel",
                accountID: account.id,
                institution: institution,
                merchant: "Neste Helsinki",
                amount: DemoData.decimal("-74.30"),
                date: Calendar.current.date(byAdding: .day, value: -2, to: .now) ?? .now,
                category: "Transport"
            ),
            BankTransaction(
                id: "\(prefix)-mortgage-payment",
                accountID: account.id,
                institution: institution,
                merchant: "Mortgage payment",
                amount: DemoData.decimal("-1120.00"),
                date: Calendar.current.date(byAdding: .day, value: -6, to: .now) ?? .now,
                category: "Housing"
            )
        ]
        return BankConnection(institution: institution, accounts: [account, mortgage], transactions: transactions)
    }
}

