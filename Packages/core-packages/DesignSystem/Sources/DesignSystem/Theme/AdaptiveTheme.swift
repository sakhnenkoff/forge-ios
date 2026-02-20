import SwiftUI

/// Adaptive theme that derives all colors from a single brand color.
/// Pass any `brandColor` and the theme computes secondary, accent, and surface tones.
///
/// Usage:
///   DesignSystem.configure(theme: AdaptiveTheme(brandColor: .indigo))
///
public struct AdaptiveTheme: Theme, Sendable {
    public let tokens: DesignTokens

    public init(brandColor: Color = .indigo) {
        let colors = ColorPalette(
            primary: brandColor,
            secondary: brandColor.opacity(0.7),
            accent: brandColor,
            success: Color(light: Color(hex: "34C759"), dark: Color(hex: "30D158")),
            warning: Color(light: Color(hex: "FF9500"), dark: Color(hex: "FF9F0A")),
            error: Color(light: Color(hex: "FF3B30"), dark: Color(hex: "FF453A")),
            info: Color(light: Color(hex: "007AFF"), dark: Color(hex: "0A84FF")),
            backgroundPrimary: Color(light: Color(hex: "FFFFFF"), dark: Color(hex: "000000")),
            backgroundSecondary: Color(light: Color(hex: "F2F2F7"), dark: Color(hex: "1C1C1E")),
            backgroundTertiary: Color(light: Color(hex: "FFFFFF"), dark: Color(hex: "2C2C2E")),
            textPrimary: Color(light: Color(hex: "000000"), dark: Color(hex: "FFFFFF")),
            textSecondary: Color(light: Color(hex: "3C3C43").opacity(0.6), dark: Color(hex: "EBEBF5").opacity(0.6)),
            textTertiary: Color(light: Color(hex: "3C3C43").opacity(0.3), dark: Color(hex: "EBEBF5").opacity(0.3)),
            textOnPrimary: Color.white,
            surface: Color(light: Color(hex: "FFFFFF"), dark: Color(hex: "1C1C1E")),
            surfaceVariant: Color(light: Color(hex: "F2F2F7"), dark: Color(hex: "2C2C2E")),
            border: Color(light: Color(hex: "3C3C43").opacity(0.29), dark: Color(hex: "545458").opacity(0.65)),
            divider: Color(light: Color(hex: "3C3C43").opacity(0.18), dark: Color(hex: "545458").opacity(0.45))
        )

        let typography = TypographyScale(
            titleLarge:     TextStyle(size: 26, weight: .semibold, design: .default),
            titleMedium:    TextStyle(size: 22, weight: .semibold, design: .default),
            titleSmall:     TextStyle(size: 18, weight: .semibold, design: .default),
            headlineLarge:  TextStyle(size: 17, weight: .semibold, design: .default),
            headlineMedium: TextStyle(size: 15, weight: .semibold, design: .default),
            headlineSmall:  TextStyle(size: 13, weight: .semibold, design: .default),
            bodyLarge:      TextStyle(size: 15, weight: .regular,  design: .default),
            bodyMedium:     TextStyle(size: 13, weight: .regular,  design: .default),
            bodySmall:      TextStyle(size: 12, weight: .regular,  design: .default),
            captionLarge:   TextStyle(size: 11, weight: .regular,  design: .default),
            captionSmall:   TextStyle(size: 10, weight: .regular,  design: .default),
            buttonLarge:    TextStyle(size: 14, weight: .semibold, design: .default),
            buttonMedium:   TextStyle(size: 13, weight: .semibold, design: .default),
            buttonSmall:    TextStyle(size: 12, weight: .semibold, design: .default)
        )

        let radii = RadiiScale(
            xs: 8,
            sm: 12,
            md: 16,
            lg: 20,
            xl: 28,
            pill: 999
        )

        let shadows = ShadowScale(
            soft:   ShadowToken(color: .black.opacity(0.04), radius: 6,  y: 3),
            card:   ShadowToken(color: .black.opacity(0.08), radius: 12, y: 6),
            lifted: ShadowToken(color: .black.opacity(0.12), radius: 18, y: 9)
        )

        self.tokens = DesignTokens(
            colors: colors,
            typography: typography,
            spacing: ThemeFactory.spacing(),
            radii: radii,
            shadows: shadows,
            layout: ThemeFactory.layout()
        )
    }
}
