import SwiftUI

/// Adaptive theme that derives all design tokens from a ColorStory.
///
/// Usage:
///   let story = ColorStory(brand: .indigo, contrast: .teal, surface: Color(hex: "F4F3F1"))
///   DesignSystem.configure(theme: AdaptiveTheme(colorStory: story))
///
public struct AdaptiveTheme: Theme, Sendable {
    public let tokens: DesignTokens

    public init(
        colorStory: ColorStory = ColorStory(
            brand: Color(light: Color(hex: "6B3FA0"), dark: Color(hex: "8B5CF6")),
            surface: Color(light: Color(hex: "F4F3F1"), dark: Color(hex: "161618"))
        ),
        preset: PresetConfiguration = .default
    ) {
        // TODO: Derive text colors from surface luminance (currently hardcoded)
        let colors = ColorPalette(
            primary: colorStory.brand,
            secondary: colorStory.contrast,
            accent: colorStory.surprise ?? colorStory.brand,
            success: Color(light: Color(hex: "34C759"), dark: Color(hex: "30D158")),
            warning: Color(light: Color(hex: "FF9500"), dark: Color(hex: "FF9F0A")),
            error: Color(light: Color(hex: "FF3B30"), dark: Color(hex: "FF453A")),
            info: colorStory.contrast,
            backgroundPrimary: Color(light: Color(hex: "FAFAFA"), dark: Color(hex: "0A0A0C")),
            backgroundSecondary: colorStory.surface,
            backgroundTertiary: Color(light: Color(hex: "FFFFFF"), dark: Color(hex: "1E1E22")),
            textPrimary: Color(light: Color(hex: "000000"), dark: Color(hex: "FFFFFF")),
            textSecondary: Color(light: Color(hex: "3C3C43").opacity(0.6), dark: Color(hex: "EBEBF5").opacity(0.6)),
            textTertiary: Color(light: Color(hex: "3C3C43").opacity(0.3), dark: Color(hex: "EBEBF5").opacity(0.3)),
            textOnPrimary: Color.white,
            surface: Color(light: Color(hex: "FFFFFF"), dark: Color(hex: "1A1A1E")),
            surfaceVariant: colorStory.surface,
            border: Color(light: Color(hex: "3C3C43").opacity(0.29), dark: Color(hex: "545458").opacity(0.65)),
            divider: Color(light: Color(hex: "3C3C43").opacity(0.18), dark: Color(hex: "545458").opacity(0.45))
        )

        let headingWeight: Font.Weight = preset.weight == .heavy ? .bold : .semibold
        let displayWeight: Font.Weight = preset.weight == .heavy ? .black : .bold

        let typography = TypographyScale(
            display:        TextStyle(size: 34, weight: displayWeight, design: .rounded),
            titleLarge:     TextStyle(size: 28, weight: headingWeight, design: .rounded),
            titleMedium:    TextStyle(size: 22, weight: headingWeight, design: .rounded),
            titleSmall:     TextStyle(size: 20, weight: headingWeight, design: .default),
            headlineLarge:  TextStyle(size: 17, weight: headingWeight, design: .default),
            headlineMedium: TextStyle(size: 15, weight: headingWeight, design: .default),
            headlineSmall:  TextStyle(size: 13, weight: headingWeight, design: .default),
            bodyLarge:      TextStyle(size: 17, weight: .regular,      design: .default),
            bodyMedium:     TextStyle(size: 15, weight: .regular,      design: .default),
            bodySmall:      TextStyle(size: 13, weight: .regular,      design: .default),
            captionLarge:   TextStyle(size: 12, weight: .regular,      design: .default),
            captionSmall:   TextStyle(size: 11, weight: .regular,      design: .default),
            buttonLarge:    TextStyle(size: 17, weight: headingWeight,  design: .default),
            buttonMedium:   TextStyle(size: 15, weight: headingWeight,  design: .default),
            buttonSmall:    TextStyle(size: 13, weight: headingWeight,  design: .default)
        )

        let spacing: SpacingScale = switch preset.spacing {
        case .tight:
            SpacingScale(xs: 4, sm: 4, smd: 8, md: 12, mlg: 16, lg: 20, xl: 24, xxlg: 32, xxl: 40)
        case .balanced:
            ThemeFactory.spacing()
        case .airy:
            SpacingScale(xs: 8, sm: 12, smd: 16, md: 24, mlg: 28, lg: 32, xl: 40, xxlg: 52, xxl: 64)
        }

        let radii: RadiiScale = switch preset.corners {
        case .sharp:
            RadiiScale(xs: 4, sm: 8, md: 8, lg: 12, xl: 16, pill: 999)
        case .mixed:
            RadiiScale(xs: 8, sm: 12, md: 16, lg: 20, xl: 28, pill: 999)
        case .rounded:
            RadiiScale(xs: 12, sm: 16, md: 20, lg: 28, xl: 36, pill: 999)
        }

        // Shadows tinted with brand color for warmth
        let shadows: ShadowScale = switch preset.surface {
        case .flat:
            ShadowScale(
                soft:   ShadowToken(color: .clear, radius: 0, y: 0),
                card:   ShadowToken(color: .clear, radius: 0, y: 0),
                lifted: ShadowToken(color: .clear, radius: 0, y: 0)
            )
        case .elevated, .glass:
            ShadowScale(
                soft:   ShadowToken(color: colorStory.brand.opacity(0.06), radius: 8,  y: 3),
                card:   ShadowToken(color: colorStory.brand.opacity(0.08), radius: 10, y: 5),
                lifted: ShadowToken(color: colorStory.brand.opacity(0.14), radius: 20, y: 8)
            )
        }

        let glass = GlassTokens(
            tint:       Color.white.opacity(0.10),
            strongTint: Color.white.opacity(0.18),
            border:     Color.white.opacity(0.40),
            shadow:     ShadowToken(color: .black.opacity(0.08), radius: 10, y: 4)
        )

        self.tokens = DesignTokens(
            colors: colors,
            typography: typography,
            spacing: spacing,
            radii: radii,
            shadows: shadows,
            glass: glass,
            layout: ThemeFactory.layout()
        )
    }
}
