import SwiftUI

struct SafeToSpendCard: View {
    let result: SafeToSpendResult
    @ScaledMetric(relativeTo: .largeTitle) private var amountSize = 48

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.shield")
                    .font(.largeTitle)
                    .foregroundStyle(PennyTheme.heroAccent)
                    .accessibilityHidden(true)
                Text("Safe to spend")
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(result.safeToday.euroCurrency)
                    .font(.system(size: amountSize, weight: .bold))
                    .monospacedDigit()
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityLabel("Safe to spend today, \(result.safeToday.euroCurrency)")
                Text("Today")
                    .font(.subheadline)
                    .foregroundStyle(PennyTheme.heroSecondary)
                Text("\(result.safeUntilPayday.euroCurrency) \(result.usesFallbackPeriod ? "over the next 30 days" : "until payday")")
                    .font(.subheadline.weight(.semibold))
            }
        }
        .padding(20)
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
}
