import SwiftUI

struct PennyGoalPlanEditor: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title: String
    @State private var targetAmount: String
    @State private var currentAmount: String
    @State private var monthlyContribution: String
    @State private var targetDate: Date
    @State private var attemptedSave = false
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case name, target, saved, monthly
    }

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
            ScrollView {
                VStack(spacing: 20) {
                    Image(systemName: goalSymbol)
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(PennyTheme.forest)
                        .frame(width: 64, height: 64)
                        .background(Color(red: 1, green: 0.84, blue: 0.40), in: RoundedRectangle(cornerRadius: 21))
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Goal").font(.headline)
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Name")
                                .font(.caption)
                                .foregroundStyle(PennyTheme.textSecondary)
                            TextField("What are you saving for?", text: $title)
                                .font(.title3.weight(.semibold))
                                .textInputAutocapitalization(.sentences)
                                .focused($focusedField, equals: .name)
                                .submitLabel(.done)
                                .onSubmit { focusedField = nil }
                                .accessibilityLabel("Goal name")
                        }
                        Divider()
                        amountField("Target amount", text: $targetAmount, field: .target)
                        Divider()
                        DatePicker("Target date", selection: $targetDate, displayedComponents: .date)
                            .font(.subheadline)
                            .datePickerStyle(.compact)
                    }
                    .padding(20)
                    .pennyGlassSurface(cornerRadius: 24)

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your plan").font(.headline)
                        HStack(alignment: .top, spacing: 18) {
                            amountField("Saved so far", text: $currentAmount, field: .saved)
                            Rectangle()
                                .fill(PennyTheme.textSecondary.opacity(0.18))
                                .frame(width: 1, height: 52)
                            amountField("Per month", text: $monthlyContribution, field: .monthly)
                        }
                    }
                    .padding(20)
                    .pennyGlassSurface(cornerRadius: 24)

                    if attemptedSave, let validationMessage {
                        Label(validationMessage, systemImage: "exclamationmark.circle")
                            .font(.subheadline)
                            .foregroundStyle(.red)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(14)
                            .background(Color.red.opacity(0.06), in: RoundedRectangle(cornerRadius: 16))
                            .accessibilityIdentifier("goalPlanValidationError")
                    }

                    Button(action: save) {
                        Text(originalPlan == nil ? "Create goal" : "Save changes")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: 54)
                            .background(PennyTheme.forest, in: Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Save goal")
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 28)
                .foregroundStyle(PennyTheme.textPrimary)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(PennyAtmosphere())
            .navigationTitle(originalPlan == nil ? "Create goal" : "Edit goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Text("Cancel")
                            .font(.body.weight(.medium))
                            .foregroundStyle(PennyTheme.textPrimary)
                            .fixedSize()
                            .frame(minWidth: 64, minHeight: 44)
                    }
                    .buttonStyle(.plain)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focusedField = nil }
                        .fontWeight(.semibold)
                }
            }
            .toolbarBackground(Color.white.opacity(0.96), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .tint(PennyTheme.forest)
        }
    }

    private func amountField(_ label: String, text: Binding<String>, field: Field) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundStyle(PennyTheme.textSecondary)
            HStack(spacing: 5) {
                TextField("0.00", text: text)
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: field)
                    .monospacedDigit()
                    .accessibilityLabel("\(label), euros")
                Text("€").foregroundStyle(PennyTheme.textSecondary)
            }
            .font(.title3.weight(.semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var goalSymbol: String {
        let name = title.lowercased()
        if ["travel", "holiday", "vacation", "trip"].contains(where: name.contains) { return "airplane" }
        if ["home", "house", "deposit"].contains(where: name.contains) { return "house.fill" }
        if ["car", "vehicle"].contains(where: name.contains) { return "car.fill" }
        if ["emergency", "buffer", "rainy"].contains(where: name.contains) { return "shield.fill" }
        if ["study", "education", "university"].contains(where: name.contains) { return "graduationcap.fill" }
        if ["wedding", "marriage"].contains(where: name.contains) { return "heart.fill" }
        return "flag.checkered"
    }

    private var validationMessage: String? {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return "Give your goal a name."
        }
        guard let target = amount(targetAmount), target > 0 else {
            return "Enter a target amount greater than zero, with up to two decimal places."
        }
        guard amount(currentAmount) != nil else {
            return "Enter zero or a positive amount saved, with up to two decimal places."
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
            accountIDs: []
        )
        onSave(plan)
        dismiss()
    }
}
