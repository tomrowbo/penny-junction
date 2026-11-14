import SwiftUI

struct PennySpendView: View {
    @Environment(AppStore.self) private var store
    @State private var showsConnectBank = false

    var body: some View {
        NavigationStack {
            ZStack {
                PennyAtmosphere()
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 24) {
                        PennyRootHeader(title: "Spend", subtitle: "A clear view of what is available now.")
                        SafeToSpendCard(result: store.safeToSpend)
                        balanceSummary
                        accounts
                        recentTransactions
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
                    .padding(.bottom, 26)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: String.self) { transactionID in
                TransactionDetailView(transactionID: transactionID)
            }
            .sheet(isPresented: $showsConnectBank) {
                ConnectBankView()
            }
        }
    }

    private var balanceSummary: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Across your accounts")
                .font(.headline)
                .foregroundStyle(PennyTheme.textSecondary)
            Text(store.totalPositiveBalance.euroCurrency)
                .font(.system(.largeTitle, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(PennyTheme.textPrimary)
            Text(store.hasConnectedExternalBank ? "Connected view across your banks" : "S-Bank accounts only")
                .font(.subheadline)
                .foregroundStyle(PennyTheme.textSecondary)
        }
        .accessibilityElement(children: .combine)
    }

    private var accounts: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Accounts").font(.title2.weight(.bold))
                Spacer()
                Button(store.hasConnectedExternalBank ? "Connected" : "Connect bank") {
                    showsConnectBank = true
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(PennyTheme.emeraldBright)
                .frame(minHeight: 44)
            }
            VStack(spacing: 0) {
                ForEach(store.accounts) { account in
                    HStack(spacing: 12) {
                        InstitutionBadge(institution: account.institution, size: 36)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(account.name).font(.subheadline.weight(.semibold))
                            Text("\(account.institution.rawValue) · \(account.maskedNumber)")
                                .font(.caption)
                                .foregroundStyle(PennyTheme.textSecondary)
                        }
                        Spacer(minLength: 8)
                        Text(account.balance.euroCurrency)
                            .font(.subheadline.weight(.bold))
                            .monospacedDigit()
                    }
                    .padding(.horizontal, 16)
                    .frame(minHeight: 66)
                    if account.id != store.accounts.last?.id {
                        Divider().overlay(Color.black.opacity(0.08)).padding(.leading, 64)
                    }
                }
            }
            .pennyGlassSurface(cornerRadius: 22)
        }
        .foregroundStyle(PennyTheme.textPrimary)
    }

    private var recentTransactions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent spending").font(.title2.weight(.bold)).foregroundStyle(PennyTheme.textPrimary)
            VStack(spacing: 0) {
                ForEach(Array(store.transactions.prefix(5))) { transaction in
                    NavigationLink(value: transaction.id) {
                        HStack(spacing: 12) {
                            Image(systemName: symbol(for: transaction.category))
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(PennyTheme.emeraldBright)
                                .frame(width: 38, height: 38)
                                .background(Color.black.opacity(0.045), in: Circle())
                            VStack(alignment: .leading, spacing: 3) {
                                Text(transaction.merchant).font(.subheadline.weight(.semibold))
                                Text(transaction.category).font(.caption).foregroundStyle(PennyTheme.textSecondary)
                            }
                            Spacer(minLength: 8)
                            Text(transaction.amount.euroCurrency)
                                .font(.subheadline.weight(.semibold))
                                .monospacedDigit()
                        }
                        .foregroundStyle(PennyTheme.textPrimary)
                        .padding(.horizontal, 16)
                        .frame(minHeight: 64)
                    }
                    .buttonStyle(.plain)
                    if transaction.id != store.transactions.prefix(5).last?.id {
                        Divider().overlay(Color.black.opacity(0.08)).padding(.leading, 64)
                    }
                }
            }
            .pennyGlassSurface(cornerRadius: 22)
        }
    }

    private func symbol(for category: String) -> String {
        switch category {
        case "Groceries": "basket"
        case "Transport": "tram"
        case "Housing": "house"
        case "Income": "arrow.down"
        default: "creditcard"
        }
    }
}
