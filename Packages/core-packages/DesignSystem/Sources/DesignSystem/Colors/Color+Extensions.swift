import SwiftUI

public extension Color {

    // MARK: - Brand Colors (prefixed to avoid SwiftUI conflicts)

    static var themePrimary: Color { DesignSystem.colors.primary }
    static var themeSecondary: Color { DesignSystem.colors.secondary }
    static var themeAccent: Color { DesignSystem.colors.accent }

    // MARK: - Semantic Colors

    static var success: Color { DesignSystem.colors.success }
    static var warning: Color { DesignSystem.colors.warning }
    static var error: Color { DesignSystem.colors.error }
    static var info: Color { DesignSystem.colors.info }

    // MARK: - Background Colors

    static var backgroundPrimary: Color { DesignSystem.colors.backgroundPrimary }
    static var backgroundSecondary: Color { DesignSystem.colors.backgroundSecondary }
    static var backgroundTertiary: Color { DesignSystem.colors.backgroundTertiary }

    // MARK: - Text Colors

    static var textPrimary: Color { DesignSystem.colors.textPrimary }
    static var textSecondary: Color { DesignSystem.colors.textSecondary }
    static var textTertiary: Color { DesignSystem.colors.textTertiary }
    static var textOnPrimary: Color { DesignSystem.colors.textOnPrimary }

    // MARK: - Surface Colors

    static var surface: Color { DesignSystem.colors.surface }
    static var surfaceVariant: Color { DesignSystem.colors.surfaceVariant }
    static var border: Color { DesignSystem.colors.border }
    static var divider: Color { DesignSystem.colors.divider }

    // MARK: - Action Colors

    static var destructive: Color { DesignSystem.colors.error }
    static var link: Color { DesignSystem.colors.primary }

    // MARK: - Utility Colors

    static var textOnAccent: Color { .white }
    static var overlayBackground: Color { Color.black.opacity(0.5) }

    // MARK: - Hex Initializer

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let alpha, red, green, blue: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (alpha, red, green, blue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (alpha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (alpha, red, green, blue) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }
}
