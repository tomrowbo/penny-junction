import SwiftUI

enum SMobiiliPalette {
    static let green = Color(red: 0.08, green: 0.82, blue: 0.43)
    static let brightGreen = Color(red: 0.26, green: 0.96, blue: 0.58)
    static let darkGreen = Color(red: 0.26, green: 0.96, blue: 0.58)
    static let canvas = Color(red: 0.018, green: 0.027, blue: 0.025)
    static let surface = Color(red: 0.045, green: 0.075, blue: 0.065)
    static let secondarySurface = Color(red: 0.065, green: 0.095, blue: 0.085)
    static let separator = Color.white.opacity(0.13)
    static let secondaryLabel = Color.white.opacity(0.68)
}

enum SMobiiliMetrics {
    static let minimumTapTarget: CGFloat = 44
    static let contentInset: CGFloat = 20
    static let compactInset: CGFloat = 12
    static let serviceRowMinimumHeight: CGFloat = 112
    static let serviceRowRadius: CGFloat = 7
    static let serviceRowGap: CGFloat = 16
    static let serviceIconSize: CGFloat = 46
    static let navigationHeight: CGFloat = 52
    static let tabBarHeight: CGFloat = 62
}

extension Font {
    static let smobiiliSectionTitle = Font.system(size: 17, weight: .bold)
    static let smobiiliRowTitle = Font.system(size: 22, weight: .bold)
    static let smobiiliRowDetail = Font.system(size: 16)
}
