import SwiftUI

struct SEtukorttiHomeView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        @Bindable var store = store
        NavigationStack {
            VStack(spacing: 0) {
                TabView(selection: $store.cardPage) {
                    bonusOverview.tag(0)
                    benefitsOverview.tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                HStack(spacing: 7) {
                    ForEach(0..<SEtukorttiDemoContent.pageCount, id: \.self) { page in
                        Circle()
                            .fill(page == store.cardPage ? SMobiiliPalette.green : Color(.systemGray4))
                            .frame(width: 6, height: 6)
                    }
                }
                .padding(.vertical, 8)
                .background(SMobiiliPalette.canvas)
            }
            .background(SMobiiliPalette.canvas)
            .toolbar(.hidden, for: .navigationBar)
            .background(SMobiiliPalette.surface.ignoresSafeArea(edges: .top))
            .navigationDestination(for: SMobiiliRoute.self) { route in
                switch route {
                case .wallet: WalletView()
                case .receipt: ReceiptView()
                case .saver: EmptyView()
                case .conceptInfo:
                    ContentUnavailableView(
                        "Demo view",
                        systemImage: "sparkles",
                        description: Text("This S-mobiili service is shown as a static Junction concept.")
                    )
                }
            }
        }
    }

    private var bonusOverview: some View {
        ScrollView {
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Spacer()
                    SMobiiliMessageButton()
                }
                .padding(.horizontal, 16)

                HStack(spacing: 7) {
                    Circle().fill(SMobiiliPalette.green).frame(width: 6, height: 6)
                    Circle().fill(Color(.systemGray4)).frame(width: 6, height: 6)
                }
                .padding(.bottom, 4)

                VStack(spacing: 8) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("To the next Bonus level 10,44 €")
                        Spacer()
                        Text("200 €")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(SMobiiliPalette.green)
                    Text("You may already be on the next Bonus level")
                        .font(.caption2)
                        .foregroundStyle(SMobiiliPalette.secondaryLabel)

                    HStack(spacing: 8) {
                        Text("1,5 %")
                        Rectangle()
                            .fill(SMobiiliPalette.green.opacity(0.5))
                            .frame(height: 1)
                    }
                    .font(.caption2)
                    .foregroundStyle(SMobiiliPalette.green)

                    VStack(spacing: 2) {
                        Text("Bonus now")
                            .font(.caption)
                        Text("40,27 €")
                            .font(.title.weight(.bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: 170, minHeight: 90)
                    .background(SMobiiliPalette.green, in: RoundedRectangle(cornerRadius: 3))

                    HStack {
                        Text("1,0 %")
                        Spacer()
                        Text("50 €")
                    }
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(SMobiiliPalette.green)

                    Text("See your total benefits  ›")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SMobiiliPalette.green)
                    Text("Bonus 50,26 € from September to be paid 10.10.")
                        .font(.caption2)
                        .foregroundStyle(SMobiiliPalette.secondaryLabel)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 18)

                HStack {
                    shortcut("New payment", "plus")
                    shortcut("Own transfer", "arrow.left.arrow.right")
                    shortcut("Benefits nearby", "location")
                    shortcut("Saved benefits", "bookmark")
                }
                .padding(.vertical, 14)
                .background(SMobiiliPalette.canvas)

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Accounts and cards")
                            .font(.headline)
                            .foregroundStyle(SMobiiliPalette.green)
                        Spacer()
                        Text("812,34 €")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(SMobiiliPalette.green)
                    }
                    accountRow("S-Tili", "80,34 €", "creditcard")
                    accountRow("Taloustili", "2 000,00 €", "creditcard")
                }
                .padding(16)
            }
        }
        .background(SMobiiliPalette.surface)
    }

    private var benefitsOverview: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    HStack {
                        Text("S-ETUKORTTI")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.white)
                        Spacer()
                        NavigationLink(value: SMobiiliRoute.wallet) {
                            Image(systemName: "barcode")
                                .foregroundStyle(SMobiiliPalette.green)
                                .frame(width: 44, height: 44)
                                .background(.white, in: Circle())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 12)
                    .background(SMobiiliPalette.brightGreen)

                    HStack(spacing: 10) {
                        ForEach(SEtukorttiDemoContent.primaryActions) { action in
                            NavigationLink(value: action.route) {
                                VStack(spacing: 8) {
                                    Image(systemName: action.symbol)
                                        .foregroundStyle(SMobiiliPalette.green)
                                    Text(action.title)
                                        .font(.caption)
                                        .foregroundStyle(.primary)
                                }
                                .frame(maxWidth: .infinity, minHeight: 82)
                                .background(SMobiiliPalette.surface, in: RoundedRectangle(cornerRadius: 5))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(12)

                    VStack(alignment: .leading, spacing: 12) {
                        sectionHeader(SEtukorttiDemoContent.benefitSectionTitle)
                        HStack(spacing: 10) {
                            benefitCard("With S-Etukortti\nOmistajan Tilipäivänä", "-10%", image: "OwnerBenefit")
                            benefitCard("Coupon\nKosmetiikkatuote", "-25%", image: "CosmeticsBenefit")
                        }

                        sectionHeader("What’s new")
                            .id("benefit-cards")
                        HStack(spacing: 10) {
                            campaignCard("Rosson lista vaihtui!", image: "RossoCampaign", location: "Rosso Iso Omena, Espoo")
                            campaignCard("Tutustu uutuuksiin", image: "BistroCampaign", location: "S-market Vallila")
                        }

                        Text("Favourite locations")
                            .font(.headline)
                            .foregroundStyle(SMobiiliPalette.green)
                            .padding(.top, 4)
                        HStack(spacing: 10) {
                            locationCard("S-market\nOulunkylä", image: "SMarketBadge")
                            locationCard("Prisma Olari", image: "PrismaBadge")
                            locationCard("Add new", symbol: "plus")
                        }

                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "bell.fill")
                                .foregroundStyle(SMobiiliPalette.green)
                                .frame(width: 38, height: 38)
                                .background(SMobiiliPalette.canvas, in: Circle())
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Don’t miss out on your benefits!")
                                    .font(.subheadline.weight(.semibold))
                                Text("Tap to enable notifications to stay up to date on benefits that are suitable for you.")
                                    .font(.caption)
                                    .foregroundStyle(SMobiiliPalette.secondaryLabel)
                                Text("Here’s how you do it  ›")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(SMobiiliPalette.green)
                                    .padding(.top, 4)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(SMobiiliPalette.secondaryLabel)
                        }
                        .padding(16)
                        .frame(minHeight: 158)
                        .background(SMobiiliPalette.surface, in: RoundedRectangle(cornerRadius: 7))
                        .padding(.trailing, 16)

                        if store.cardScrollTarget != nil {
                            Color.clear.frame(height: 340)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 20)
                }
            }
            .task(id: store.cardScrollTarget) {
                guard let target = store.cardScrollTarget else { return }
                try? await Task.sleep(for: .milliseconds(120))
                proxy.scrollTo(target, anchor: .top)
            }
        }
        .background(SMobiiliPalette.canvas)
    }

    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundStyle(SMobiiliPalette.green)
            Spacer()
            Text("Show all")
                .font(.caption)
                .foregroundStyle(SMobiiliPalette.green)
        }
    }

    private func shortcut(_ title: String, _ symbol: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: symbol)
                .foregroundStyle(.white)
                .frame(width: 38, height: 38)
                .background(SMobiiliPalette.green, in: Circle())
            Text(title)
                .font(.caption2)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
    }

    private func accountRow(_ title: String, _ amount: String, _ symbol: String) -> some View {
        HStack {
            Image(systemName: symbol).foregroundStyle(SMobiiliPalette.green)
            Text(title).font(.subheadline)
            Spacer()
            Text(amount).font(.subheadline.weight(.semibold)).foregroundStyle(SMobiiliPalette.green)
        }
    }

    private func benefitCard(_ title: String, _ value: String, image: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(image)
                .resizable()
                .scaledToFill()
                .frame(height: 88)
                .clipped()
            Text(title).font(.caption).foregroundStyle(.primary)
            Text(value).font(.headline).foregroundStyle(SMobiiliPalette.green)
        }
        .frame(maxWidth: .infinity, minHeight: 156, alignment: .topLeading)
        .background(SMobiiliPalette.surface, in: RoundedRectangle(cornerRadius: 5))
        .clipShape(RoundedRectangle(cornerRadius: 5))
    }

    private func campaignCard(_ title: String, image: String, location: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(image)
                .resizable()
                .scaledToFill()
                .frame(height: 128)
                .clipped()
            VStack(alignment: .leading, spacing: 3) {
                Text("Campaign")
                    .font(.caption2)
                    .foregroundStyle(SMobiiliPalette.secondaryLabel)
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.primary)
                Spacer(minLength: 14)
                Text("Valid until 31.10.2023")
                    .font(.caption2)
                    .foregroundStyle(SMobiiliPalette.secondaryLabel)
                Text(location)
                    .font(.caption2)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 10)
        }
        .frame(maxWidth: .infinity, minHeight: 300, alignment: .topLeading)
        .background(SMobiiliPalette.surface, in: RoundedRectangle(cornerRadius: 5))
        .clipShape(RoundedRectangle(cornerRadius: 5))
    }

    private func locationCard(_ title: String, image: String? = nil, symbol: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if let image {
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 52, height: 52)
                    .clipShape(Circle())
            } else if let symbol {
                Image(systemName: symbol)
                    .font(.title3)
                    .foregroundStyle(SMobiiliPalette.green)
                    .frame(width: 52, height: 52)
                    .background(SMobiiliPalette.surface, in: Circle())
            }
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, minHeight: 100, alignment: .top)
    }
}
