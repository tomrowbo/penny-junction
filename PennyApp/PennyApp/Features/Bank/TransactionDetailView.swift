import SwiftUI

struct TransactionDetailView: View {
    @Environment(AppStore.self) private var store
    let transactionID: String

    var body: some View {
        Group {
            if let transaction = store.transaction(id: transactionID) {
                ScrollView {
                    VStack(spacing: 14) {
                        VStack(spacing: 8) {
                            InstitutionBadge(institution: transaction.institution, size: 52)
                            Text(transaction.merchant)
                                .font(.title2.weight(.bold))
                            Text(transaction.amount.euroCurrency)
                                .font(.largeTitle.weight(.bold))
                            Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)

                        BrandCard {
                            LabeledContent("Category", value: transaction.category)
                            Divider()
                            LabeledContent("Account provider", value: transaction.institution.rawValue)
                            Divider()
                            LabeledContent("Transaction ID", value: transaction.id.uppercased())
                        }

                        Button {
                            store.startPennyChat(about: .transaction(transaction.id))
                        } label: {
                            HStack(spacing: 10) {
                                PennyMark(size: 26)
                                Text("Discuss with Penny")
                                    .font(.headline)
                            }
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(PennyTheme.forest, in: RoundedRectangle(cornerRadius: 18))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding()
                }
                .background(PennyAtmosphere())
                .navigationTitle("Transaction")
                .navigationBarTitleDisplayMode(.inline)
            } else {
                ContentUnavailableView("Transaction unavailable", systemImage: "exclamationmark.triangle")
            }
        }
        .foregroundStyle(PennyTheme.textPrimary)
    }
}
