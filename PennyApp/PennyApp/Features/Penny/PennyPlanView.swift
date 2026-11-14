import Charts
import SwiftUI

struct PennyPlanView: View {
    @Environment(AppStore.self) private var store
    @State private var showsNewGoal = false
    @State private var planToEdit: PennyGoalPlan?

    var body: some View {
        NavigationStack {
            ZStack {
                PennyAtmosphere()
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 18) {
                        PennyRootHeader(title: "Plan")
                        switch store.sBankDataStatus {
                        case .loading:
                            ProgressView("Loading your plan…")
                                .frame(maxWidth: .infinity, minHeight: 220)
                        case .unavailable:
                            PennyDataUnavailableCard(
                                title: "We couldn’t load your plan",
                                message: "Check your connection and try again.",
                                retry: { Task { await store.loadOfficialSBankData() } }
                            )
                        case .official:
                            planContent
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
                    .padding(.bottom, 26)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showsNewGoal) {
                PennyGoalPlanEditor(asOf: store.financialReferenceDate) { store.saveGoalPlan($0) }
            }
            .sheet(item: $planToEdit) { plan in
                PennyGoalPlanEditor(plan: plan, asOf: store.financialReferenceDate) { store.saveGoalPlan($0) }
            }
        }
    }

    @ViewBuilder
    private var planContent: some View {
        monthlySavingsSummary
        HStack(alignment: .center) {
            Text("Savings breakdown").font(.title2.weight(.bold))
            Spacer()
            Button {
                showsNewGoal = true
            } label: {
                Image(systemName: "plus")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(PennyTheme.forest, in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Add goal")
        }
        .foregroundStyle(PennyTheme.textPrimary)

        if let error = store.goalPlanError {
            Label(error, systemImage: "exclamationmark.circle")
                .font(.subheadline)
                .foregroundStyle(.orange)
        }

        if store.goalPlans.isEmpty {
            emptyState
        } else {
            ForEach(activeGoals) { plan in
                goalBreakdownRow(plan)
            }
            if activeGoals.isEmpty {
                emptyState
            }
        }
    }

    private var activeGoals: [PennyGoalPlan] {
        store.goalPlans.filter { $0.targetAmount > 0 && $0.currentAmount < $0.targetAmount }
    }

    private var monthlyTarget: Decimal {
        activeGoals.reduce(.zero) { $0 + $1.monthlyContribution }
    }

    private var savingsHistory: [MonthlySavingsPoint] {
        let calendar = Calendar.current
        let reference = store.financialReferenceDate
        guard let referenceMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: reference)) else {
            return []
        }

        return (0..<6).reversed().compactMap { offset in
            guard let month = calendar.date(byAdding: .month, value: -offset, to: referenceMonth),
                  let interval = calendar.dateInterval(of: .month, for: month) else { return nil }
            let contribution = store.transactions
                .filter {
                    $0.date >= interval.start && $0.date < interval.end
                        && $0.category == Self.savingsContributionCategory
                }
                .reduce(Decimal.zero) { total, transaction in
                    total + max(.zero, -transaction.amount)
                }
            return MonthlySavingsPoint(month: month, amount: contribution)
        }
    }

    private var savedThisMonth: Decimal {
        savingsHistory.last?.amount ?? .zero
    }

    private static let savingsContributionCategory = "Invest Deposit"

    private var monthlySavingsSummary: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Monthly savings")
                    .font(.headline)
                Text("\(savedThisMonth.euroCurrency) / \(monthlyTarget.euroCurrency)")
                    .font(.largeTitle.weight(.bold))
                    .monospacedDigit()
                    .minimumScaleFactor(0.72)
                    .lineLimit(1)
                Text("saved in \(store.financialReferenceDate.formatted(.dateTime.month(.wide)))")
                    .font(.subheadline)
                    .foregroundStyle(PennyTheme.textSecondary)
            }

            Chart {
                RuleMark(y: .value("Zero", 0))
                    .foregroundStyle(PennyTheme.textSecondary.opacity(0.35))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))

                ForEach(savingsHistory) { point in
                    AreaMark(
                        x: .value("Month", point.month),
                        yStart: .value("Zero", 0),
                        yEnd: .value("Net savings", point.chartAmount)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [PennyTheme.forest.opacity(0.24), PennyTheme.forest.opacity(0.02)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)

                    LineMark(
                        x: .value("Month", point.month),
                        y: .value("Net savings", point.chartAmount)
                    )
                    .foregroundStyle(PennyTheme.forest)
                    .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("Month", point.month),
                        y: .value("Net savings", point.chartAmount)
                    )
                    .foregroundStyle(PennyTheme.forest)
                    .symbolSize(34)
                }
            }
            .chartXAxis {
                AxisMarks(values: savingsHistory.map(\.month)) { value in
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(date.formatted(.dateTime.month(.abbreviated)))
                        }
                    }
                }
            }
            .chartYAxis(.hidden)
            .frame(height: 150)
            .accessibilityLabel("Savings contributions over the last six months")
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(PennyTheme.textPrimary)
        .pennyGlassSurface(cornerRadius: 24)
    }

    private func goalBreakdownRow(_ plan: PennyGoalPlan) -> some View {
        let progress = min(1, max(0, NSDecimalNumber(decimal: plan.currentAmount / plan.targetAmount).doubleValue))
        return ZStack(alignment: .trailing) {
            Button {
                store.startPennyChat(about: .goal(plan.id))
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: goalSymbol(for: plan))
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(PennyTheme.forest)
                        .frame(width: 46, height: 46)
                        .background(Color(red: 1, green: 0.84, blue: 0.40), in: RoundedRectangle(cornerRadius: 15))

                    VStack(alignment: .leading, spacing: 8) {
                        Text(plan.title)
                            .font(.headline)
                            .lineLimit(1)
                        ProgressView(value: progress)
                            .tint(PennyTheme.forest)
                    }

                    VStack(alignment: .trailing, spacing: 5) {
                        Text(plan.monthlyContribution.euroCurrency)
                            .font(.headline)
                            .monospacedDigit()
                        Text("per month")
                            .font(.caption)
                            .foregroundStyle(PennyTheme.textSecondary)
                    }
                    .padding(.trailing, 34)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(PennyTheme.textPrimary)
                .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            }
            .buttonStyle(.plain)
            .accessibilityHint("Opens a new Penny conversation about this goal")

            Button { planToEdit = plan } label: {
                Image(systemName: "ellipsis")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(PennyTheme.textSecondary)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Edit \(plan.title)")
            .padding(.trailing, 4)
        }
        .pennyGlassSurface(cornerRadius: 22)
    }

    private func goalSymbol(for plan: PennyGoalPlan) -> String {
        let title = plan.title.lowercased()
        if ["travel", "holiday", "vacation", "trip"].contains(where: title.contains) { return "airplane" }
        if ["home", "house", "deposit"].contains(where: title.contains) { return "house.fill" }
        if ["car", "vehicle"].contains(where: title.contains) { return "car.fill" }
        if ["emergency", "buffer", "rainy"].contains(where: title.contains) { return "shield.fill" }
        if ["study", "education", "university"].contains(where: title.contains) { return "graduationcap.fill" }
        if ["wedding", "marriage"].contains(where: title.contains) { return "heart.fill" }
        return "flag.checkered"
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 18) {
            Image(systemName: "flag.checkered")
                .font(.system(size: 42, weight: .semibold))
                .foregroundStyle(PennyTheme.forest)
                .frame(width: 80, height: 80)
                .background(Color(red: 1, green: 0.84, blue: 0.40), in: RoundedRectangle(cornerRadius: 24))
                .accessibilityHidden(true)
            Text("What are you saving for?")
                .font(.title2.weight(.bold))
            Text("Make a plan for something that matters to you.")
                .font(.subheadline)
                .foregroundStyle(PennyTheme.textSecondary)
            Button { showsNewGoal = true } label: {
                Text("Create goal")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(PennyTheme.forest, in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(PennyTheme.textPrimary)
        .pennyGlassSurface(cornerRadius: 24)
    }
}

private struct MonthlySavingsPoint: Identifiable {
    let month: Date
    let amount: Decimal

    var id: Date { month }
    var chartAmount: Double { NSDecimalNumber(decimal: amount).doubleValue }
}
