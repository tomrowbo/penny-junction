import Foundation

@MainActor
protocol PennyGoalPlanStore {
    func load() throws -> [PennyGoalPlan]
    func save(_ plans: [PennyGoalPlan]) throws
}

/// Keep the owner on the main actor so load/modify/save operations cannot race.
@MainActor
final class UserDefaultsPennyGoalPlanStore: PennyGoalPlanStore {
    private let defaults: UserDefaults
    private let key: String

    init(defaults: UserDefaults = .standard, key: String = "penny.goalPlans.v1") {
        self.defaults = defaults
        self.key = key
    }

    func load() throws -> [PennyGoalPlan] {
        guard let data = defaults.data(forKey: key) else { return [] }
        return try JSONDecoder().decode([PennyGoalPlan].self, from: data)
    }

    func save(_ plans: [PennyGoalPlan]) throws {
        // Encode before touching the saved value so errors preserve existing plans.
        let data = try JSONEncoder().encode(plans)
        defaults.set(data, forKey: key)
    }
}

@MainActor
final class InMemoryPennyGoalPlanStore: PennyGoalPlanStore {
    private var plans: [PennyGoalPlan]

    init(plans: [PennyGoalPlan] = []) {
        self.plans = plans
    }

    func load() throws -> [PennyGoalPlan] { plans }
    func save(_ plans: [PennyGoalPlan]) throws { self.plans = plans }
}
