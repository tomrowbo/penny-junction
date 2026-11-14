import SwiftUI

struct LoginView: View {
    @Environment(AppStore.self) private var store
    @State private var isLoggingIn = false

    var body: some View {
        ZStack {
            PennyAtmosphere()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 18) {
                    PennyMark(size: 88, inverse: true)
                    Text(PennyBrand.productName)
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(PennyTheme.textPrimary)
                    Text(PennyBrand.partnerDescriptor)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(PennyTheme.emeraldBright)
                    Text(PennyBrand.tagline)
                        .font(.subheadline)
                        .foregroundStyle(PennyTheme.textSecondary)
                }

                Spacer()

                VStack(spacing: 14) {
                    Button {
                        isLoggingIn = true
                        Task { @MainActor in
                            try? await Task.sleep(for: .milliseconds(450))
                            store.login()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "faceid")
                            Text(isLoggingIn ? "Logging in…" : "Log in")
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .tint(PennyTheme.emerald)
                    .disabled(isLoggingIn)

                }
                .padding(24)
                .pennyGlassSurface(cornerRadius: 28)
                .padding()
            }
        }
    }
}

