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

                        BrandCard {
                            HStack(spacing: 8) {
                                PennyMark(size: 22)
                                Text("Included in Penny")
                            }
                                .font(.headline)
                                .foregroundStyle(PennyTheme.darkGreen)
                            Text("Penny uses this transaction with your balances, regular commitments and activity across connected banks when answering your questions.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Button {
                            store.discussWithPenny()
                        } label: {
                            Label("Discuss with Penny", systemImage: "bubble.left.and.bubble.right.fill")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
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
