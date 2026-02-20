import SwiftUI

/// Main theme protocol that aggregates all design tokens
public protocol Theme: Sendable {
    var tokens: DesignTokens { get }
}

public extension Theme {
    var colors: ColorPalette { tokens.colors }
    var typography: TypographyScale { tokens.typography }
    var spacing: SpacingScale { tokens.spacing }
    var radii: RadiiScale { tokens.radii }
    var shadows: ShadowScale { tokens.shadows }
    var layout: LayoutScale { tokens.layout }
}
