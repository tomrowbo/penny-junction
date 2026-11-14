import SwiftUI

struct SaverView: View {
    @Environment(\.dismiss) private var dismiss
    @ScaledMetric(relativeTo: .largeTitle) private var amountSize = 42.0

    var body: some View {
        VStack(spacing: 0) {
            SMobiiliHeader(
                title: "",
                leading: AnyView(
                    Button { dismiss() } label: { Image(systemName: "chevron.left") }
                        .foregroundStyle(.primary)
                        .frame(width: SMobiiliMetrics.minimumTapTarget, height: SMobiiliMetrics.minimumTapTarget)
                        .accessibilityLabel("Back")
                )
            )

            ScrollView {
                VStack(spacing: 0) {
                    VStack(spacing: 9) {
                        Text(SaverDemoContent.title)
                            .font(.title3.weight(.bold))
                        Text(SaverDemoContent.amount)
                            .font(.system(size: amountSize, weight: .bold))
                            .foregroundStyle(SMobiiliPalette.green)
                        GeometryReader { proxy in
                            ZStack(alignment: .leading) {
                                Capsule().fill(SMobiiliPalette.canvas)
                                Capsule().fill(SMobiiliPalette.green)
                                    .frame(width: proxy.size.width * 0.57)
                            }
                        }
                        .frame(height: 6)
                        HStack(alignment: .top) {
                            Text("11.2.2020")
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("11.2.2025")
                                Text("12 000,00 €")
                            }
                        }
                        .font(.caption)
                        .foregroundStyle(SMobiiliPalette.secondaryLabel)
                        Text(SaverDemoContent.status).font(.subheadline).padding(.top, 8)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, -8)
                    .padding(.bottom, 20)
                    Divider()
                    conceptLink("Transfer money to target", symbol: "plus")
                    Divider()
                    conceptLink("My profile", symbol: "person")
                    Divider()
                    conceptLink("How does Säästäjä work?", symbol: "info.circle")
                    Divider()
                }
                .background(SMobiiliPalette.surface)
            }
            .background(Color(.systemGray6))
        }
        .toolbar(.hidden, for: .navigationBar)
        .background(SMobiiliPalette.surface.ignoresSafeArea(edges: .top))
        .navigationDestination(for: SMobiiliRoute.self) { _ in
            ContentUnavailableView(
                "Service unavailable",
                systemImage: "target",
                description: Text("Please try again later.")
            )
        }
    }

    private func conceptLink(_ title: String, symbol: String) -> some View {
        NavigationLink(value: SMobiiliRoute.conceptInfo) {
            SMobiiliActionRow(title: title, symbol: symbol)
        }
        .buttonStyle(.plain)
    }
}
