import SwiftUI

struct PennySkeletonBlock: View {
    var cornerRadius: CGFloat = 14
    @State private var shimmerOffset: CGFloat = -1

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Color.black.opacity(0.065))
            .overlay {
                GeometryReader { proxy in
                    LinearGradient(
                        colors: [.clear, Color.white.opacity(0.72), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: proxy.size.width * 0.55)
                    .offset(x: shimmerOffset * proxy.size.width * 1.6)
                }
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            }
            .onAppear {
                withAnimation(.linear(duration: 1.35).repeatForever(autoreverses: false)) {
                    shimmerOffset = 1
                }
            }
            .accessibilityHidden(true)
    }
}

struct SpendLoadingSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            PennySkeletonBlock(cornerRadius: 28)
                .frame(height: 190)
            skeletonSection(titleWidth: 94, rows: 2, rowHeight: 70)
            skeletonSection(titleWidth: 156, rows: 3, rowHeight: 62)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Loading your accounts and spending")
    }

    private func skeletonSection(titleWidth: CGFloat, rows: Int, rowHeight: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            PennySkeletonBlock(cornerRadius: 7)
                .frame(width: titleWidth, height: 24)
            VStack(spacing: 1) {
                ForEach(0..<rows, id: \.self) { _ in
                    HStack(spacing: 12) {
                        PennySkeletonBlock(cornerRadius: 14).frame(width: 42, height: 42)
                        VStack(alignment: .leading, spacing: 7) {
                            PennySkeletonBlock(cornerRadius: 5).frame(width: 126, height: 13)
                            PennySkeletonBlock(cornerRadius: 5).frame(width: 86, height: 10)
                        }
                        Spacer()
                        PennySkeletonBlock(cornerRadius: 5).frame(width: 64, height: 14)
                    }
                    .padding(.horizontal, 16)
                    .frame(height: rowHeight)
                }
            }
            .background(Color.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
    }
}

struct IncomingLoadingSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            PennySkeletonBlock(cornerRadius: 7).frame(width: 150, height: 20)
            PennySkeletonBlock(cornerRadius: 7).frame(width: 92, height: 11)
            PennySkeletonBlock(cornerRadius: 8).frame(width: 176, height: 34)
            ForEach(0..<3, id: \.self) { _ in
                HStack {
                    VStack(alignment: .leading, spacing: 7) {
                        PennySkeletonBlock(cornerRadius: 5).frame(width: 130, height: 13)
                        PennySkeletonBlock(cornerRadius: 5).frame(width: 98, height: 10)
                    }
                    Spacer()
                    PennySkeletonBlock(cornerRadius: 5).frame(width: 70, height: 14)
                }
                .frame(height: 52)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Loading upcoming money")
    }
}

struct PennyDataUnavailableCard: View {
    let title: String
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: "wifi.exclamationmark")
                .font(.title2.weight(.semibold))
                .foregroundStyle(PennyTheme.forest)
            Text(title)
                .font(.headline)
                .foregroundStyle(PennyTheme.textPrimary)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(PennyTheme.textSecondary)
            Button("Try again", action: retry)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: 46)
                .background(PennyTheme.forest, in: Capsule())
                .buttonStyle(.plain)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .pennyGlassSurface(cornerRadius: 24)
    }
}
