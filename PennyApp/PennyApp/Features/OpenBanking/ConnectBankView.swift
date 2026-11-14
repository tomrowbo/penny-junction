import SwiftUI

struct ConnectBankView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    private let service: any OpenBankingService

    @State private var banks: [AvailableBank] = []
    @State private var isLoadingBanks = true
    @State private var selectedBank: AvailableBank?
    @State private var isConnecting = false
    @State private var errorMessage: String?
    @State private var connectionTask: Task<Void, Never>?

    init(service: (any OpenBankingService)? = nil) {
        if let service {
            self.service = service
        } else if let baseURL = PennyAPIConfiguration.baseURL {
            self.service = EnableBankingService(baseURL: baseURL)
        } else {
            self.service = UnavailableOpenBankingService()
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Read-only access", systemImage: "lock.shield.fill")
                            .font(.headline)
                            .foregroundStyle(PennyTheme.darkGreen)
                        Text("Penny will import balances, transactions, loans and mortgages. It cannot move money or make payments.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 6)
                }

                Section("Choose your bank") {
                    if isLoadingBanks {
                        HStack(spacing: 10) {
                            ProgressView()
                            Text("Loading banks…")
                                .foregroundStyle(PennyTheme.textSecondary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 64, alignment: .center)
                    }
                    ForEach(banks) { bank in
                        Button {
                            selectedBank = bank
                        } label: {
                            HStack(spacing: 12) {
                                InstitutionBadge(institution: bank.institution, size: 44)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(bank.name)
                                        .font(.body.weight(.semibold))
                                        .foregroundStyle(.primary)
                                    Text(bank.description)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                }

                Section {
                    Text("Access is read-only, protected by your bank's authentication and can be withdrawn at any time.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .scrollContentBackground(.hidden)
            .background(PennyAtmosphere())
            .navigationTitle("Connect a bank")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if #available(iOS 26.0, *) {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                            .buttonStyle(.plain)
                    }
                    .sharedBackgroundVisibility(.hidden)
                } else {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                            .buttonStyle(.plain)
                    }
                }
            }
            .task {
                isLoadingBanks = true
                defer { isLoadingBanks = false }
                do {
                    banks = try await service.availableBanks()
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
            .sheet(item: $selectedBank, onDismiss: {
                if isConnecting {
                    connectionTask?.cancel()
                    connectionTask = nil
                    isConnecting = false
                }
            }) { bank in
                BankConsentView(bank: bank, isConnecting: isConnecting) {
                    connectionTask?.cancel()
                    connectionTask = Task { await connect(bank) }
                }
                .presentationDetents([.medium])
                .interactiveDismissDisabled(isConnecting)
            }
            .alert("Unable to connect", isPresented: .constant(errorMessage != nil)) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "Please try again.")
            }
            .onDisappear {
                connectionTask?.cancel()
                connectionTask = nil
            }
        }
    }

    @MainActor
    private func connect(_ bank: AvailableBank) async {
        isConnecting = true
        do {
            let connection = try await service.connect(bank)
            try Task.checkCancellation()
            await store.refreshAllData(adding: connection)
            isConnecting = false
            connectionTask = nil
            selectedBank = nil
            dismiss()
        } catch is CancellationError {
            isConnecting = false
        } catch {
            isConnecting = false
            errorMessage = error.localizedDescription
        }
    }
}

private struct BankConsentView: View {
    let bank: AvailableBank
    let isConnecting: Bool
    let connect: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            InstitutionBadge(institution: bank.institution, size: 64)
            Text("Continue to \(bank.name)")
                .font(.title2.weight(.bold))
            Text("You will authenticate with your bank and approve 90 days of read-only access. Penny never sees your banking credentials.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button {
                connect()
            } label: {
                HStack {
                    if isConnecting { ProgressView().tint(.white) }
                    Text(isConnecting ? "Connecting…" : "Continue securely")
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(isConnecting)
        }
        .padding(24)
        .foregroundStyle(PennyTheme.textPrimary)
        .background(PennyAtmosphere())
    }
}
