import SwiftUI

struct BankOverviewView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                balanceCard
                accountsSection
                transactionsSection
            }
            .padding()
        }
        .background(PennyTheme.canvas)
        .navigationTitle("Accounts")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "bubble.left")
                }
                .accessibilityLabel("Messages")
            }
        }
    }

    private var balanceCard: some View {
        BrandCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Total available")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(store.totalPositiveBalance.euroCurrency)
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(PennyTheme.darkGreen)
                HStack(spacing: 6) {
                    Circle().fill(PennyTheme.green).frame(width: 7, height: 7)
                    Text(store.hasConnectedExternalBank ? "Complete view across connected banks" : "S-Bank accounts only")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var accountsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Accounts")
                .font(.headline)

            ForEach(store.accounts) { account in
                HStack(spacing: 12) {
                    InstitutionBadge(institution: account.institution)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(account.name).font(.body.weight(.semibold))
                        Text("\(account.institution.rawValue) · \(account.maskedNumber)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(account.balance.euroCurrency)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(account.balance < 0 ? Color.primary : PennyTheme.darkGreen)
                }
                .padding()
                .background(.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
    }

    private var transactionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Latest transactions")
                .font(.headline)

            VStack(spacing: 0) {
                ForEach(store.transactions) { transaction in
                    NavigationLink(value: transaction.id) {
                        TransactionRow(transaction: transaction)
                    }
                    .buttonStyle(.plain)

                    if transaction.id != store.transactions.last?.id {
                        Divider().padding(.leading, 56)
                    }
                }
            }
            .background(.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .navigationDestination(for: String.self) { id in
            if let transaction = store.transaction(id: id) {
                TransactionDetailView(transactionID: transaction.id)
            }
        }
    }
}

private struct TransactionRow: View {
    let transaction: BankTransaction

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .fill(PennyTheme.mint)
                Image(systemName: symbol)
                    .foregroundStyle(PennyTheme.green)
            }
            .frame(width: 42, height: 42)

            VStack(alignment: .leading, spacing: 3) {
                Text(transaction.merchant)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(transaction.category)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(transaction.amount.euroCurrency)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(transaction.amount > 0 ? PennyTheme.green : Color.primary)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }

    private var symbol: String {
        switch transaction.category {
        case "Groceries": "basket"
        case "Transport": "tram"
        case "Housing": "house"
        case "Income": "arrow.down"
        default: "creditcard"
        }
    }
}

