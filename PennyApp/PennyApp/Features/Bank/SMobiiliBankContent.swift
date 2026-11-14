import Foundation

enum BankServiceDestination: Hashable, Sendable {
    case accounts
    case saver
    case conceptInfo
}

struct SMobiiliBankService: Identifiable, Hashable, Sendable {
    let title: String
    let detail: String
    let symbol: String
    let destination: BankServiceDestination
    var id: String { title }
}

enum SMobiiliBankContent {
    static let services = [
        SMobiiliBankService(title: "Accounts", detail: "S-Tili 80,34 €        Taloustili 800,00 €", symbol: "creditcard", destination: .accounts),
        SMobiiliBankService(title: "Payments and e-invoices", detail: "Make a new payment or view and order e-invoices", symbol: "eurosign.square", destination: .conceptInfo),
        SMobiiliBankService(title: "Cards", detail: "S-Etukortti Visa Credit/Debit\n2000,00 €", symbol: "creditcard", destination: .conceptInfo),
        SMobiiliBankService(title: "Säästäjä", detail: "Oma tavoitteeni\n500,00 €", symbol: "trophy", destination: .saver),
        SMobiiliBankService(title: "Investments", detail: "Value of your investments 543,67 €", symbol: "briefcase", destination: .conceptInfo),
        SMobiiliBankService(title: "Loans", detail: "View loans and offers", symbol: "house", destination: .conceptInfo)
    ]
}

enum SaverDemoContent {
    static let title = "New car"
    static let amount = "5987,65 €"
    static let status = "You’re 33,17 € ahead your target."
}
