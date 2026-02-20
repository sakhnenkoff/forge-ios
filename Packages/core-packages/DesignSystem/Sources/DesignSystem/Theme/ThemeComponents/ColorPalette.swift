import SwiftUI

/// Defines all color tokens for the design system
public struct ColorPalette: Sendable {

    // MARK: - Brand Colors

    public let primary: Color
    public let secondary: Color
    public let accent: Color

    // MARK: - Semantic Colors

    public let success: Color
    public let warning: Color
    public let error: Color
    public let info: Color

    // MARK: - Background Colors

    public let backgroundPrimary: Color
    public let backgroundSecondary: Color
    public let backgroundTertiary: Color

    // MARK: - Text Colors

    public let textPrimary: Color
    public let textSecondary: Color
    public let textTertiary: Color
    public let textOnPrimary: Color

    // MARK: - Surface Colors

    public let surface: Color
    public let surfaceVariant: Color
    public let border: Color
    public let divider: Color

    // MARK: - Init

    public init(
        primary: Color,
        secondary: Color,
        accent: Color,
        success: Color,
        warning: Color,
        error: Color,
        info: Color,
        backgroundPrimary: Color,
        backgroundSecondary: Color,
        backgroundTertiary: Color,
        textPrimary: Color,
        textSecondary: Color,
        textTertiary: Color,
        textOnPrimary: Color,
        surface: Color,
        surfaceVariant: Color,
        border: Color,
        divider: Color
    ) {
        self.primary = primary
        self.secondary = secondary
        self.accent = accent
        self.success = success
        self.warning = warning
        self.error = error
        self.info = info
        self.backgroundPrimary = backgroundPrimary
        self.backgroundSecondary = backgroundSecondary
        self.backgroundTertiary = backgroundTertiary
        self.textPrimary = textPrimary
        self.textSecondary = textSecondary
        self.textTertiary = textTertiary
        self.textOnPrimary = textOnPrimary
        self.surface = surface
        self.surfaceVariant = surfaceVariant
        self.border = border
        self.divider = divider
    }
}
