import SwiftUI

struct PennyGoalPlanCard: View {
    let plan: PennyGoalPlan
    let asOf: Date
    var onReview: (() -> Void)? = nil

    private var projection: PennyGoalProjection { plan.projection(asOf: asOf) }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(plan.title)
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            Label(projection.status.title, systemImage: statusSymbol)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary)
            if projection.status != .needsDetails {
                VStack(alignment: .leading, spacing: 4) {
                    Text(plan.currentAmount.euroCurrency)
                        .font(.title2.weight(.bold))
                        .monospacedDigit()
                    Text("of \(plan.targetAmount.euroCurrency) · by \(plan.targetDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .accessibilityElement(children: .combine)

                ProgressView(value: projection.progressFraction, total: 1)
                    .tint(SMobiiliPalette.green)
                    .accessibilityLabel("Goal progress")
                    .accessibilityValue(projection.progressFraction.formatted(.percent.precision(.fractionLength(0))))

                if let required = projection.requiredMonthlyContribution, required > 0 {
                    Text("\(required.euroCurrency) a month needed")
                        .font(.subheadline.weight(.semibold))
                }
                if projection.status != .completed {
                    Text("Planned: \(plan.monthlyContribution.euroCurrency) a month")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if let completion = projection.projectedCompletionDate {
                        Text("At this pace: \(completion.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("No completion estimate at this pace")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text("Estimate assumes monthly saving, including a final payment by your target date, with no interest or withdrawals.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("Add a positive target and non-negative savings amounts to see your progress.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            if let onReview {
                Button(action: onReview) {
                    Text("Review goal")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: SMobiiliMetrics.minimumTapTarget, alignment: .leading)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(SMobiiliPalette.green)
                .accessibilityLabel("Review \(plan.title)")
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(.white)
        .pennyGlassSurface(cornerRadius: 24)
        .accessibilityElement(children: .contain)
    }

    private var statusSymbol: String {
        switch projection.status {
        case .onTrack: "checkmark.circle"
        case .completed: "checkmark.seal"
        case .needsAttention, .overdue: "exclamationmark.circle"
        case .needsDetails: "questionmark.circle"
        }
    }
}
