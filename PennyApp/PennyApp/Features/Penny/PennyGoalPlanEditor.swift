import SwiftUI

struct PennyGoalPlanEditor: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title: String
    @State private var targetAmount: String
    @State private var currentAmount: String
    @State private var monthlyContribution: String
    @State private var targetDate: Date
    @State private var attemptedSave = false

    private let originalPlan: PennyGoalPlan?
    private let asOf: Date
    private let onSave: (PennyGoalPlan) -> Void

    init(plan: PennyGoalPlan? = nil, asOf: Date = .now,
         onSave: @escaping (PennyGoalPlan) -> Void) {
        originalPlan = plan
        self.asOf = asOf
        self.onSave = onSave
        _title = State(initialValue: plan?.title ?? "")
        _targetAmount = State(initialValue: plan.map { NSDecimalNumber(decimal: $0.targetAmount).stringValue } ?? "")
        _currentAmount = State(initialValue: plan.map { NSDecimalNumber(decimal: $0.currentAmount).stringValue } ?? "0")
        _monthlyContribution = State(initialValue: plan.map { NSDecimalNumber(decimal: $0.monthlyContribution).stringValue } ?? "0")
        _targetDate = State(initialValue: plan?.targetDate ?? Calendar.current.date(byAdding: .month, value: 6, to: asOf) ?? asOf)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Your goal") {
                    TextField("Goal name", text: $title)
                        .textInputAutocapitalization(.sentences)
                        .accessibilityLabel("Goal name")
                    amountField("Target amount", text: $targetAmount)
                    DatePicker("Target date", selection: $targetDate, displayedComponents: .date)
                }
                Section {
                    amountField("Already saved", text: $currentAmount)
                    amountField("Monthly contribution", text: $monthlyContribution)
                } header: {
                    Text("Your saving plan")
                } footer: {
                    Text("Enter amounts in euros, with up to two decimal places. Choose how much you plan to set aside each month.")
                }
                if attemptedSave, let validationMessage {
                    Section {
                        Label(validationMessage, systemImage: "exclamationmark.circle")
                            .font(.subheadline)
                            .foregroundStyle(.red)
                            .fixedSize(horizontal: false, vertical: true)
                            .accessibilityIdentifier("goalPlanValidationError")
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(SMobiiliPalette.canvas)
            .navigationTitle(originalPlan == nil ? "Create goal" : "Edit goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .frame(minWidth: SMobiiliMetrics.minimumTapTarget, minHeight: SMobiiliMetrics.minimumTapTarget)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .fontWeight(.semibold)
                        .frame(minWidth: SMobiiliMetrics.minimumTapTarget, minHeight: SMobiiliMetrics.minimumTapTarget)
                        .accessibilityLabel("Save goal")
                }
            }
            .tint(SMobiiliPalette.green)
        }
    }

    private func amountField(_ label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label).font(.subheadline)
            TextField("0.00", text: text)
                .keyboardType(.decimalPad)
                .monospacedDigit()
                .accessibilityLabel("\(label), euros")
        }
        .padding(.vertical, 3)
    }

    private var validationMessage: String? {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return "Give your goal a name."
        }
        guard let target = amount(targetAmount), target > 0 else {
            return "Enter a target amount greater than zero, with up to two decimal places."
        }
        guard amount(currentAmount) != nil else {
            return "Enter zero or a positive amount already saved, with up to two decimal places."
        }
        guard amount(monthlyContribution) != nil else {
            return "Enter zero or a positive monthly contribution, with up to two decimal places."
        }
        guard Calendar.current.startOfDay(for: targetDate) > Calendar.current.startOfDay(for: asOf) else {
            return "Choose a target date after today."
        }
        return nil
    }

    /// Accept decimal comma and decimal point without interpreting a grouping
    /// separator or silently accepting an otherwise invalid numeric prefix.
    private func amount(_ text: String) -> Decimal? {
        let normalized = text.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")
        let parts = normalized.split(separator: ".", omittingEmptySubsequences: false)
        guard (1...2).contains(parts.count), !parts[0].isEmpty,
              parts.allSatisfy({ $0.allSatisfy { ("0"..."9").contains($0) } }),
              parts.count == 1 || (1...2).contains(parts[1].count),
              let value = Decimal(string: normalized, locale: Locale(identifier: "en_US_POSIX")),
              !value.isNaN, value >= 0 else { return nil }
        return value
    }

    private func save() {
        attemptedSave = true
        guard validationMessage == nil,
              let target = amount(targetAmount), let current = amount(currentAmount),
              let monthly = amount(monthlyContribution) else { return }

        let plan = PennyGoalPlan(
            id: originalPlan?.id ?? UUID(),
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            targetAmount: target,
            currentAmount: current,
            targetDate: Calendar.current.startOfDay(for: targetDate),
            monthlyContribution: monthly,
            createdAt: originalPlan?.createdAt ?? asOf,
            accountIDs: originalPlan?.accountIDs ?? []
        )
        onSave(plan)
        dismiss()
    }
}
