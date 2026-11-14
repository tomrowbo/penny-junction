import SwiftUI

struct WalletView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                HStack {
                    Text("Wallet")
                        .font(.largeTitle.weight(.bold))
                    Spacer()
                    Image(systemName: "cube.fill")
                        .foregroundStyle(.white)
                        .frame(width: 34, height: 34)
                        .background(.black, in: Circle())
                    Image(systemName: "plus")
                        .foregroundStyle(.white)
                        .frame(width: 34, height: 34)
                        .background(.black, in: Circle())
                }

                walletCard(title: "S PANKKI", kind: "Credit", name: nil, visa: true)
                walletCard(title: "S-ETUKORTTI", kind: "Bonus", name: "ANNA ASIAKASOMISTAJA", visa: false)
            }
            .padding(16)
        }
        .background(Color(.systemBackground))
        .navigationBarBackButtonHidden(false)
        .toolbar(.hidden, for: .navigationBar)
    }

    private func walletCard(title: String, kind: String, name: String?, visa: Bool) -> some View {
        ZStack {
            SMark(size: visa ? 210 : 135, inverse: true)

            VStack(alignment: .leading) {
                HStack {
                    SMark(size: 25, inverse: true)
                    Text(title).font(.subheadline.weight(.bold))
                    Spacer()
                    Text(kind).font(.subheadline)
                }
                Spacer()
                if let name {
                    Text("NAME").font(.caption2)
                    Text(name).font(.title3)
                }
                if visa {
                    Text("VISA")
                        .font(.title.weight(.black))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
        .foregroundStyle(.white)
        .padding(16)
        .frame(maxWidth: .infinity)
        .frame(height: 232)
        .background(SMobiiliPalette.brightGreen, in: RoundedRectangle(cornerRadius: 9))
    }
}
