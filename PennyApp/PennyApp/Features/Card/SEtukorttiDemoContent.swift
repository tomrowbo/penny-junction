import Foundation

struct SMobiiliDemoAction: Identifiable, Hashable, Sendable {
    let title: String
    let symbol: String
    let route: SMobiiliRoute
    var id: String { title }
}

struct SMobiiliReceipt: Equatable, Sendable {
    let merchant: String
    let total: String
    let lines: [String]
}

enum SEtukorttiDemoContent {
    static let pageCount = 2
    static let benefitSectionTitle = "Your benefits"
    static let walletRoute = SMobiiliRoute.wallet

    static let primaryActions = [
        SMobiiliDemoAction(title: "Bonus and purchases", symbol: "bag", route: .conceptInfo),
        SMobiiliDemoAction(title: "Receipts", symbol: "receipt", route: .receipt)
    ]

    static let receipt = SMobiiliReceipt(
        merchant: "Prisma Mylly",
        total: "60,00 €",
        lines: [
            "MYLLYN PRISMA p.0107643000",
            "Turun Osuuskauppa, Y-0142122-9",
            "",
            "16 K16 M000503/7253E 15:03 17:57",
            "20-03-2021",
            "",
            "VÄHÄSUOL.VIHR.OLIIVI 142/       0.95",
            "TOMAATTIMURSKA 2-PACK             1.09",
            "PARMIGIANO REGGIANO STICK         3.49",
            "KURKKU SNACK LUOMU                 1.89",
            "PALVARIN LIHAPYÖRYKÄT              2.59",
            "VEHNÄPAAHTOLEIPÄ                   0.98",
            "KESÄKURPITSA VIHREÄ                1.03",
            "TACO-SALAATTI                      1.98",
            "MOZZARELLA LUOMU                   1.69",
            "LEGO EXTRA                         9.95"
        ]
    )
}
