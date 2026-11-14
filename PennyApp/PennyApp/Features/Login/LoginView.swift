import SwiftUI

struct LoginView: View {
    @Environment(AppStore.self) private var store
    @State private var isLoggingIn = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [PennyTheme.green, PennyTheme.darkGreen],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 18) {
                    PennyMark(size: 82, inverse: true)
                    Text(PennyBrand.productName)
                        .font(.title.weight(.black))
                        .foregroundStyle(.white)
                    Text(PennyBrand.partnerDescriptor)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.9))
                    Text(PennyBrand.tagline)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.82))
                }

                Spacer()

                VStack(spacing: 14) {
                    Label(PennyBrand.conceptDisclosure, systemImage: "sparkles")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(PennyTheme.darkGreen)

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
                    .disabled(isLoggingIn)

                    Text("No real banking credentials are requested or stored.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(24)
                .background(.white, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                .padding()
            }
        }
    }
}

