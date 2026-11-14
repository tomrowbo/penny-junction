import SwiftUI

struct UpcomingMoneyCard: View {
    let summary: UpcomingMoneySummary
    var transactions: [BankTransaction] = []
    var accounts: [BankAccount] = []
    @State private var showsDetails = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Upcoming money")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            Text(periodLabel)
                .font(.caption)
                .foregroundStyle(.secondary)

            if summary.items.isEmpty {
                Text("No recurring payments found")
                    .font(.body.weight(.semibold))
                Text("More transaction history can help Penny estimate what comes next. Other bills may still be due.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text(summary.totalOutflow.euroCurrency)
                        .font(.title2.weight(.bold))
                        .monospacedDigit()
                    Text("Estimated outgoing · next 30 days")
                        .font(.subheadline)
                    Text("Estimated incoming: \(summary.totalIncome.euroCurrency)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .accessibilityElement(children: .combine)
                Divider()
                ForEach(summary.items.prefix(3)) { item in
                    UpcomingMoneyRow(item: item, calendar: summary.calendar)
                }
                Text("Estimates, not scheduled payments. Tentative items are excluded from totals.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Button {
                showsDetails = true
            } label: {
                HStack {
                    Text("Review upcoming money")
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .accessibilityHidden(true)
                }
                .frame(minHeight: 44)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .foregroundStyle(SMobiiliPalette.green)
            .accessibilityHint("Shows all estimates, assumptions and supporting transactions")
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(.white)
        .pennyGlassSurface(cornerRadius: 24)
        .sheet(isPresented: $showsDetails) {
            details
        }
    }

    private var periodLabel: String {
        let lastDay = summary.endDate.addingTimeInterval(-1)
        return "\(formattedDate(summary.startDate)) – \(formattedDate(lastDay))"
    }

    private var details: some View {
        NavigationStack {
            List {
                Section {
                    LabeledContent("Estimated outgoing", value: summary.totalOutflow.euroCurrency)
                    LabeledContent("Estimated incoming", value: summary.totalIncome.euroCurrency)
                } header: {
                    Text(periodLabel)
                } footer: {
                    Text("Totals exclude tentative patterns. These estimates do not schedule or move money.")
                }
                if summary.items.isEmpty {
                    Section {
                        Text("There is not enough recent, regular history to predict upcoming money.")
                    }
                }
                ForEach(summary.items) { item in
                    Section {
                        UpcomingMoneyRow(item: item, calendar: summary.calendar)
                        Text("\(item.institution.rawValue) · \(accountName(for: item))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        evidence(for: item)
                    }
                }
                Section("How Penny estimated this") {
                    ForEach(summary.assumptions, id: \.self) { assumption in
                        Text(assumption)
                            .font(.subheadline)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(PennyAtmosphere())
            .navigationTitle("Upcoming money")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { showsDetails = false }
                        .frame(minWidth: 44, minHeight: 44)
                }
            }
        }
        .tint(SMobiiliPalette.green)
    }

    @ViewBuilder
    private func evidence(for item: UpcomingMoneyItem) -> some View {
        let sources = transactions.filter {
            item.sourceTransactionIDs.contains($0.id) && $0.accountID == item.accountID && $0.institution == item.institution
        }.sorted { $0.date == $1.date ? $0.id < $1.id : $0.date < $1.date }
        if sources.isEmpty {
            Text("Based on \(item.sourceTransactionIDs.count) previous transactions.")
                .font(.caption)
                .foregroundStyle(.secondary)
        } else {
            DisclosureGroup {
                ForEach(sources) { source in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(source.merchant).font(.subheadline)
                        Text("\(formattedDate(source.date)) · \(source.amount.euroCurrency)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityElement(children: .combine)
                    .padding(.vertical, 4)
                }
            } label: {
                Text("\(sources.count) supporting transactions")
                    .font(.subheadline)
                    .frame(minHeight: 44)
            }
        }
    }

    private func accountName(for item: UpcomingMoneyItem) -> String {
        accounts.first { $0.id == item.accountID && $0.institution == item.institution }?.name ?? "Connected account"
    }

    private func formattedDate(_ date: Date) -> String {
        date.formatted(Date.FormatStyle(date: .abbreviated, time: .omitted, calendar: summary.calendar, timeZone: summary.calendar.timeZone))
    }
}

private struct UpcomingMoneyRow: View {
    let item: UpcomingMoneyItem
    let calendar: Calendar
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            if dynamicTypeSize.isAccessibilitySize {
                title
                amount
            } else {
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    title
                    Spacer(minLength: 0)
                    amount
                }
            }
            Text("Expected \(item.nextDate.formatted(Date.FormatStyle(date: .abbreviated, time: .omitted, calendar: calendar, timeZone: calendar.timeZone))) · \(item.cadence.label)")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(confidenceLabel)
                .font(.caption)
                .foregroundStyle(.secondary)
            if let change = item.priceChange {
                Label("Latest amount \(change.difference > 0 ? "increased" : "decreased") by \(abs(change.difference).euroCurrency)", systemImage: change.difference > 0 ? "arrow.up.right" : "arrow.down.right")
                    .font(.caption)
                    .foregroundStyle(.primary)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }

    private var title: some View {
        Text(item.merchant)
            .font(.subheadline.weight(.semibold))
            .fixedSize(horizontal: false, vertical: true)
    }

    private var amount: some View {
        Text("\(item.direction == .income ? "+" : "−")\(item.amount.euroCurrency)")
            .font(.subheadline.weight(.semibold))
            .monospacedDigit()
            .fixedSize(horizontal: true, vertical: false)
            .accessibilityLabel("\(item.direction == .income ? "Incoming" : "Outgoing") \(item.amount.euroCurrency)")
    }

    private var confidenceLabel: String {
        switch item.confidence {
        case .low: "Tentative · excluded from totals"
        case .medium: "Estimate · medium confidence"
        case .high: "Estimate · high confidence"
        }
    }
}
