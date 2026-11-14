import SwiftUI

enum SMobiiliPalette {
    static let green = PennyTheme.emerald
    static let brightGreen = PennyTheme.emeraldBright
    static let darkGreen = PennyTheme.obsidian
    static let canvas = PennyTheme.canvas
    static let surface = Color.white
    static let secondarySurface = Color.black.opacity(0.045)
    static let separator = Color.black.opacity(0.10)
    static let secondaryLabel = PennyTheme.textSecondary
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
