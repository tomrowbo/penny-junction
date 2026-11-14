import SwiftUI

struct ReceiptView: View {
    @Environment(\.dismiss) private var dismiss
    private let receipt = SEtukorttiDemoContent.receipt
    @State private var showsDemoNotice = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    Circle()
                        .fill(SMobiiliPalette.green)
                        .frame(width: 34, height: 34)
                        .overlay(Text("PRISMA").font(.system(size: 7, weight: .bold)).foregroundStyle(.white))
                    Text(receipt.merchant).font(.subheadline)
                    Spacer()
                    Image(systemName: "chevron.right").font(.caption)
                }
                .padding(.horizontal, 16)
                .frame(height: 58)
                Divider()

                HStack {
                    Text("Total")
                    Spacer()
                    Text(receipt.total)
                }
                .font(.subheadline)
                .padding(.horizontal, 16)
                .frame(height: 48)
                Divider()

                Button { showsDemoNotice = true } label: {
                    SMobiiliActionRow(title: "Open receipt barcode", symbol: "barcode")
                }
                .buttonStyle(.plain)
                Divider()
                Button { showsDemoNotice = true } label: {
                    SMobiiliActionRow(title: "Share or download the PDF receipt", symbol: "square.and.arrow.up")
                }
                .buttonStyle(.plain)

                Text(receipt.lines.joined(separator: "\n"))
                    .font(.system(size: 15, weight: .regular, design: .monospaced))
                    .lineSpacing(1)
                    .foregroundStyle(SMobiiliPalette.secondaryLabel)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(receiptPaper)
            }
        }
        .navigationTitle("Receipt")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                }
                .accessibilityLabel("Back")
            }
        }
        .background(Color(.systemBackground))
        .alert("Demo action", isPresented: $showsDemoNotice) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Receipt export is not connected in this Junction concept.")
        }
    }

    private var receiptPaper: Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor.secondarySystemBackground
                : UIColor(white: 0.95, alpha: 1)
        })
    }
}
