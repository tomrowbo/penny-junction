import SwiftUI

enum SMobiiliPalette {
    static let green = Color(red: 0.00, green: 0.52, blue: 0.25)
    static let brightGreen = Color(red: 0.00, green: 0.72, blue: 0.27)
    static let darkGreen = Color(red: 0.00, green: 0.34, blue: 0.18)
    static let canvas = Color(red: 0.91, green: 0.97, blue: 0.92)
    static let surface = Color(.systemBackground)
    static let secondarySurface = Color(.secondarySystemBackground)
    static let separator = Color(.separator)
    static let secondaryLabel = Color(.secondaryLabel)
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
