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
                        HStack(alignment: .center) {
                            Text("Your goals").font(.title2.weight(.bold))
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
                            ForEach(store.goalPlans) { plan in
                                PennyGoalPlanCard(
                                    plan: plan,
                                    asOf: store.financialReferenceDate,
                                    onDiscuss: { store.startPennyChat(about: .goal(plan.id)) },
                                    onEdit: { planToEdit = plan }
                                )
                            }
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
