import Foundation

enum DemoData {
    static let initial = DemoSnapshot(
        accounts: [
            BankAccount(
                id: "sbank-everyday",
                institution: .sBank,
                name: "S-Tili",
                kind: .current,
                balance: decimal("2842.16"),
                maskedNumber: "•• 4821"
            ),
            BankAccount(
                id: "sbank-savings",
                institution: .sBank,
                name: "Savings",
                kind: .savings,
                balance: decimal("8500.00"),
                maskedNumber: "•• 1904"
            )
        ],
        transactions: [
            transaction("tx-prisma", "Prisma Kaari", "-63.20", "Groceries", daysAgo: 0),
            transaction("tx-hsl", "HSL", "-32.80", "Transport", daysAgo: 1),
            transaction("tx-rent", "Vuokraovi Housing", "-940.00", "Housing", daysAgo: 3),
            transaction("tx-coffee", "Robert's Coffee", "-6.80", "Eating out", daysAgo: 4),
            transaction("tx-salary", "Salary", "3120.00", "Income", daysAgo: 8),
            transaction("tx-lidl", "Lidl Ruoholahti", "-47.35", "Groceries", daysAgo: 9)
        ]
    )

    static func decimal(_ value: String) -> Decimal {
        Decimal(string: value, locale: Locale(identifier: "en_US_POSIX")) ?? .zero
    }

    private static func transaction(
        _ id: String,
        _ merchant: String,
        _ amount: String,
        _ category: String,
        daysAgo: Int
    ) -> BankTransaction {
        BankTransaction(
            id: id,
            accountID: "sbank-everyday",
            institution: .sBank,
            merchant: merchant,
            amount: decimal(amount),
            date: Calendar.current.date(byAdding: .day, value: -daysAgo, to: .now) ?? .now,
            category: category
        )
    }
}

