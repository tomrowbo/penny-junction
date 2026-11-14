import SwiftUI

struct PennyGoalPlanCard: View {
    let plan: PennyGoalPlan
    let asOf: Date
    let onDiscuss: () -> Void
    let onEdit: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .headline) private var progressSize = 78

    private var projection: PennyGoalProjection { plan.projection(asOf: asOf) }
    private var percentage: String {
        projection.progressFraction.formatted(.percent.precision(.fractionLength(0)))
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button(action: onDiscuss) {
                VStack(alignment: .leading, spacing: 24) {
                    HStack(alignment: .top, spacing: 14) {
                        Image(systemName: goalSymbol)
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundStyle(PennyTheme.forest)
                            .frame(width: 54, height: 54)
                            .background(Color(red: 1, green: 0.84, blue: 0.40), in: RoundedRectangle(cornerRadius: 17))
                            .accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 8) {
                            Text(plan.title)
                                .font(.title2.weight(.bold))
                                .fixedSize(horizontal: false, vertical: true)
                            Label(projection.status.title, systemImage: statusSymbol)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(statusColor)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.trailing, 32)

                    if projection.status != .needsDetails {
                        if dynamicTypeSize.isAccessibilitySize {
                            VStack(alignment: .leading, spacing: 20) {
                                savings
                                progressRing
                            }
                        } else {
                            HStack(alignment: .center, spacing: 18) {
                                savings
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                progressRing
                            }
                        }

                        ViewThatFits(in: .horizontal) {
                            HStack(alignment: .firstTextBaseline, spacing: 16) {
                                monthlyContribution
                                Spacer(minLength: 0)
                                targetMonth
                            }
                            VStack(alignment: .leading, spacing: 8) {
                                monthlyContribution
                                targetMonth
                            }
                        }
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.88))
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.white)
                .contentShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
            .accessibilityHint("Opens a new Penny conversation about this goal")

            Button(action: onEdit) {
                Image(systemName: "ellipsis")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .padding(10)
            .accessibilityLabel("Edit \(plan.title)")
            .accessibilityHint("Opens goal details")
        }
        .background {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(LinearGradient(
                    colors: [PennyTheme.forest, Color(red: 0, green: 0.38, blue: 0.23)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
        }
        .shadow(color: PennyTheme.forest.opacity(0.16), radius: 16, y: 8)
        .accessibilityElement(children: .contain)
    }

    private var savings: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(plan.currentAmount.euroCurrency)
                .font(.title.weight(.bold))
                .monospacedDigit()
                .fixedSize(horizontal: false, vertical: true)
            Text("of \(plan.targetAmount.euroCurrency)")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.88))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var progressRing: some View {
        ZStack {
            Circle().stroke(.white.opacity(0.20), lineWidth: 6)
            Circle()
                .trim(from: 0, to: projection.progressFraction)
                .stroke(.white, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text(percentage)
                .font(.headline.weight(.bold))
                .monospacedDigit()
        }
        .frame(width: progressSize, height: progressSize)
        .accessibilityLabel("\(percentage) saved")
    }

    private var monthlyContribution: some View {
        Text("\(plan.monthlyContribution.euroCurrency)/month")
            .fixedSize(horizontal: false, vertical: true)
    }

    private var targetMonth: some View {
        Text("By \(plan.targetDate.formatted(.dateTime.month(.abbreviated).year()))")
            .fixedSize(horizontal: false, vertical: true)
    }

    private var statusColor: Color {
        switch projection.status {
        case .needsAttention, .overdue, .needsDetails: Color(red: 1, green: 0.84, blue: 0.40)
        case .onTrack, .completed: .white
        }
    }

    private var statusSymbol: String {
        switch projection.status {
        case .onTrack: "checkmark.circle.fill"
        case .completed: "checkmark.seal.fill"
        case .needsAttention, .overdue: "exclamationmark.circle.fill"
        case .needsDetails: "questionmark.circle.fill"
        }
    }

    private var goalSymbol: String {
        let title = plan.title.lowercased()
        if ["travel", "holiday", "vacation", "trip"].contains(where: title.contains) { return "airplane" }
        if ["home", "house", "deposit"].contains(where: title.contains) { return "house.fill" }
        if ["car", "vehicle"].contains(where: title.contains) { return "car.fill" }
        if ["emergency", "buffer", "rainy"].contains(where: title.contains) { return "shield.fill" }
        if ["study", "education", "university"].contains(where: title.contains) { return "graduationcap.fill" }
        if ["wedding", "marriage"].contains(where: title.contains) { return "heart.fill" }
        return "flag.checkered"
    }
}
