import SwiftUI

enum PennyTheme {
    static let green = SMobiiliPalette.green
    static let darkGreen = SMobiiliPalette.darkGreen
    static let vividGreen = SMobiiliPalette.brightGreen
    static let mint = Color(red: 0.91, green: 0.97, blue: 0.93)
    static let paleGreen = Color(red: 0.82, green: 0.93, blue: 0.84)
    static let canvas = SMobiiliPalette.canvas
    static let warning = Color(red: 1.00, green: 0.94, blue: 0.72)
}

extension Decimal {
    var euroCurrency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.locale = Locale(identifier: "en_FI")
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: self as NSDecimalNumber) ?? "€0.00"
    }
}
