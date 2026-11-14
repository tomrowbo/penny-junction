import SwiftUI

struct SafeToSpendCard: View {
    let result: SafeToSpendResult
    @State private var showsCalculation = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Safe to spend", systemImage: "checkmark.shield")
                .font(.headline)
                .foregroundStyle(PennyTheme.heroAccent)
                .accessibilityAddTraits(.isHeader)

            VStack(alignment: .leading, spacing: 4) {
                Text(result.safeToday.euroCurrency)
                    .font(.largeTitle.weight(.bold))
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityLabel("Estimated safe to spend today, \(result.safeToday.euroCurrency)")
                Text("For today")
                    .font(.subheadline)
                    .foregroundStyle(PennyTheme.heroSecondary)
                Text("\(result.safeUntilPayday.euroCurrency) \(result.usesFallbackPeriod ? "over the next 30 days" : "until payday")")
                    .font(.subheadline.weight(.semibold))
            }

            Text(periodLabel)
                .font(.caption)
                .foregroundStyle(PennyTheme.heroSecondary)
            Text("Estimate · \(result.dataCompleteness.label) · \(result.confidence.rawValue.capitalized) confidence")
                .font(.caption)
                .foregroundStyle(PennyTheme.heroSecondary)
                .fixedSize(horizontal: false, vertical: true)

            if result.shortfall > 0 {
                Label("\(result.shortfall.euroCurrency) more is needed for your reserves.", systemImage: "exclamationmark.circle")
                    .font(.subheadline)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button {
                if reduceMotion {
                    showsCalculation.toggle()
                } else {
                    withAnimation(.snappy(duration: 0.22)) {
                        showsCalculation.toggle()
                    }
                }
            } label: {
                HStack {
                    Text("How this is calculated")
                    Spacer()
                    Image(systemName: showsCalculation ? "chevron.down" : "chevron.right")
                }
                .font(.subheadline.weight(.semibold))
                .frame(minHeight: SMobiiliMetrics.minimumTapTarget, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
            .accessibilityValue(showsCalculation ? "Expanded" : "Collapsed")

            if showsCalculation {
                VStack(alignment: .leading, spacing: 10) {
                    amountRow("Current-account balance", result.availableBalance)
                    amountRow("Reserved commitments", result.reservedCommitments)
                    amountRow("Goal contribution", result.goalContribution)
                    Text(result.accountNames.isEmpty ? "No everyday accounts connected." : "Accounts: \(result.accountNames.joined(separator: ", ")).")
                    if let coverage = result.transactionCoverage {
                        Text("Transaction history: \(coverage.start.formatted(date: .abbreviated, time: .omitted)) – \(coverage.end.formatted(date: .abbreviated, time: .omitted)).")
                    }
                    ForEach(Array(result.assumptions.enumerated()), id: \.offset) { _, assumption in
                        Text(assumption)
                    }
                    Text("\(result.sourceTransactionIDs.count) source transactions support the reserved commitments.")
                }
                .font(.caption)
                .foregroundStyle(PennyTheme.heroSecondary)
                .padding(.top, 8)
                .accessibilityElement(children: .contain)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(.white)
        .background {
            GeometryReader { proxy in
                ZStack {
                    Image(PennyTheme.spendHeroAssetName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                    LinearGradient(
                        colors: [Color.black.opacity(0.22), Color.black.opacity(0.72), PennyTheme.obsidian.opacity(0.94)],
                        startPoint: .topTrailing,
                        endPoint: .bottomLeading
                    )
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(Color.white.opacity(0.16), lineWidth: 0.75)
        }
        .shadow(color: .black.opacity(0.32), radius: 22, y: 12)
        .accessibilityElement(children: .contain)
    }

    private var periodLabel: String {
        "\(result.period.start.formatted(date: .abbreviated, time: .omitted)) – \(result.period.end.formatted(date: .abbreviated, time: .omitted)) · \(result.daysUntilPayday) days"
    }

    private func amountRow(_ label: String, _ amount: Decimal) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack {
                Text(label)
                Spacer()
                Text(amount.euroCurrency)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(label)
                Text(amount.euroCurrency)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
