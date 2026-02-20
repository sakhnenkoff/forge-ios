import SwiftUI

/// Calm minimal palette with warm neutrals and deep blue accents
public extension Color {

    // MARK: - Light Mode Brand Colors

    /// Primary accent (deep blue)
    static let yaleBlue = Color(hex: "2B2DEB")

    /// Secondary brand (ink)
    static let oxfordNavy = Color(hex: "1E1E1E")

    /// Brand accent (ink blue)
    static let prussianBlue = Color(hex: "2626D8")

    /// Info (blue)
    static let powderBlue = Color(hex: "2B2DEB")

    /// Tertiary background (soft lilac)
    static let mintCream = Color(hex: "E4E1EC")

    /// Neutral surface background
    static let cloudWhite = Color(hex: "F3F1EE")

    /// Off-white primary background
    static let canvasWhite = Color(hex: "E9E7E3")

    /// Subtle surface tint (warm neutral)
    static let surfaceTint = Color(hex: "EFECEA")

    /// Soft border
    static let borderLight = Color(hex: "D8D4CF")

    /// Divider gray
    static let dividerLight = Color(hex: "D2CEC9")

    /// Primary text
    static let textPrimaryLight = Color(hex: "1C1B1A")

    /// Secondary text
    static let textSecondaryLight = Color(hex: "5F5D5A")

    /// Tertiary text
    static let textTertiaryLight = Color(hex: "8C8A86")

    /// Success green
    static let sageGreen = Color(hex: "2F8F6A")

    /// Warning amber
    static let goldenrod = Color(hex: "B9852A")

    /// Error red
    static let coralRed = Color(hex: "B94B4B")

    // MARK: - Dark Mode Brand Colors (Lighter Variants)

    /// Primary for dark mode
    static let skyBlue = Color(hex: "8F95FF")

    /// Secondary for dark mode
    static let periwinkle = Color(hex: "D0CDC7")

    /// Accent for dark mode
    static let steelBlue = Color(hex: "9AA1FF")

    /// Info for dark mode
    static let lightPowderBlue = Color(hex: "9AA1FF")

    /// Tertiary background for dark mode
    static let paleMint = Color(hex: "1A1922")

    /// Dark primary background
    static let midnight = Color(hex: "0F0F12")

    /// Dark secondary background
    static let midnightSecondary = Color(hex: "15151B")

    /// Dark surface
    static let surfaceDark = Color(hex: "1C1C22")

    /// Dark surface variant
    static let surfaceVariantDark = Color(hex: "23232B")

    /// Dark border
    static let borderDark = Color(hex: "2A2A33")

    /// Dark divider
    static let dividerDark = Color(hex: "2D2D36")

    /// Primary text (dark)
    static let textPrimaryDark = Color(hex: "F1F0EE")

    /// Secondary text (dark)
    static let textSecondaryDark = Color(hex: "C6C2BC")

    /// Tertiary text (dark)
    static let textTertiaryDark = Color(hex: "9B9892")

    /// Success green (dark)
    static let lightSage = Color(hex: "54C38C")

    /// Warning amber (dark)
    static let lightGold = Color(hex: "D5A252")

    /// Error red (dark)
    static let lightCoral = Color(hex: "D87B7B")

    // MARK: - Adaptive Colors (Auto-switch based on color scheme)

    /// Adaptive primary color - mint (light) / bright mint (dark)
    static var adaptivePrimary: Color {
        Color(light: .yaleBlue, dark: .skyBlue)
    }

    /// Adaptive secondary color - ink (light) / soft slate (dark)
    static var adaptiveSecondary: Color {
        Color(light: .oxfordNavy, dark: .periwinkle)
    }

    /// Adaptive accent color - teal (light) / mint (dark)
    static var adaptiveAccent: Color {
        Color(light: .prussianBlue, dark: .steelBlue)
    }

    /// Adaptive info color - sky (light) / sky (dark)
    static var adaptiveInfo: Color {
        Color(light: .powderBlue, dark: .lightPowderBlue)
    }

    /// Adaptive success color - green (light) / green (dark)
    static var adaptiveSuccess: Color {
        Color(light: .sageGreen, dark: .lightSage)
    }

    /// Adaptive warning color - amber (light) / amber (dark)
    static var adaptiveWarning: Color {
        Color(light: .goldenrod, dark: .lightGold)
    }

    /// Adaptive error color - red (light) / red (dark)
    static var adaptiveError: Color {
        Color(light: .coralRed, dark: .lightCoral)
    }

    /// Adaptive primary background - off-white (light) / midnight (dark)
    static var adaptiveBackgroundPrimary: Color {
        Color(light: .canvasWhite, dark: .midnight)
    }

    /// Adaptive secondary background - white (light) / midnight secondary (dark)
    static var adaptiveBackgroundSecondary: Color {
        Color(light: .cloudWhite, dark: .midnightSecondary)
    }

    /// Adaptive tertiary background - mist (light) / deep slate (dark)
    static var adaptiveTertiaryBackground: Color {
        Color(light: .mintCream, dark: .paleMint)
    }

    /// Adaptive surface - white (light) / dark surface (dark)
    static var adaptiveSurface: Color {
        Color(light: .cloudWhite, dark: .surfaceDark)
    }

    /// Adaptive surface variant - tinted surface (light) / deep surface (dark)
    static var adaptiveSurfaceVariant: Color {
        Color(light: .surfaceTint, dark: .surfaceVariantDark)
    }

    /// Adaptive border color
    static var adaptiveBorder: Color {
        Color(light: .borderLight, dark: .borderDark)
    }

    /// Adaptive divider color
    static var adaptiveDivider: Color {
        Color(light: .dividerLight, dark: .dividerDark)
    }

    /// Adaptive primary text color
    static var adaptiveTextPrimary: Color {
        Color(light: .textPrimaryLight, dark: .textPrimaryDark)
    }

    /// Adaptive secondary text color
    static var adaptiveTextSecondary: Color {
        Color(light: .textSecondaryLight, dark: .textSecondaryDark)
    }

    /// Adaptive tertiary text color
    static var adaptiveTextTertiary: Color {
        Color(light: .textTertiaryLight, dark: .textTertiaryDark)
    }
}

// MARK: - Color Helper Extension

extension Color {
    /// Creates an adaptive color that changes based on light/dark mode
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor(dynamicProvider: { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        }))
    }
}
