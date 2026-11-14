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
                        PennyRootHeader(title: "Plan", subtitle: "Turn the next big thing into a monthly plan.")
                        HStack(alignment: .firstTextBaseline) {
                            Text("Your goals").font(.title2.weight(.bold))
                            Spacer()
                            Button {
                                showsNewGoal = true
                            } label: {
                                Label("Add goal", systemImage: "plus")
                                    .font(.subheadline.weight(.semibold))
                                    .frame(minHeight: 44)
                            }
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
                                PennyGoalPlanCard(plan: plan, asOf: store.financialReferenceDate) {
                                    planToEdit = plan
                                }
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
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: "scope")
                .font(.largeTitle)
                .foregroundStyle(PennyTheme.emeraldBright)
            Text("Give your money a direction")
                .font(.title3.weight(.bold))
            Text("Set a target and monthly amount. Penny will keep the projection here as your finances change.")
                .font(.subheadline)
                .foregroundStyle(PennyTheme.textSecondary)
            Button("Create your first goal") { showsNewGoal = true }
                .buttonStyle(.borderedProminent)
                .tint(PennyTheme.emerald)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(PennyTheme.textPrimary)
        .pennyGlassSurface(cornerRadius: 24)
    }
}
