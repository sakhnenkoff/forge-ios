import SwiftUI

public struct DesignTokens: Sendable {
    public let colors: ColorPalette
    public let typography: TypographyScale
    public let spacing: SpacingScale
    public let radii: RadiiScale
    public let shadows: ShadowScale
    public let glass: GlassTokens
    public let layout: LayoutScale

    public init(
        colors: ColorPalette,
        typography: TypographyScale,
        spacing: SpacingScale,
        radii: RadiiScale,
        shadows: ShadowScale,
        glass: GlassTokens = GlassTokens(),
        layout: LayoutScale = LayoutScale()
    ) {
        self.colors = colors
        self.typography = typography
        self.spacing = spacing
        self.radii = radii
        self.shadows = shadows
        self.glass = glass
        self.layout = layout
    }
}

public struct GlassTokens: Sendable {
    public let tint: Color
    public let strongTint: Color
    public let border: Color
    public let shadow: ShadowToken

    public init(
        tint: Color = Color.white.opacity(0.10),
        strongTint: Color = Color.white.opacity(0.18),
        border: Color = Color.white.opacity(0.40),
        shadow: ShadowToken = ShadowToken(color: .black.opacity(0.08), radius: 10, y: 4)
    ) {
        self.tint = tint
        self.strongTint = strongTint
        self.border = border
        self.shadow = shadow
    }
}

public struct RadiiScale: Sendable {
    public let xs: CGFloat
    public let sm: CGFloat
    public let md: CGFloat
    public let lg: CGFloat
    public let xl: CGFloat
    public let pill: CGFloat

    public init(
        xs: CGFloat,
        sm: CGFloat,
        md: CGFloat,
        lg: CGFloat,
        xl: CGFloat,
        pill: CGFloat
    ) {
        self.xs = xs
        self.sm = sm
        self.md = md
        self.lg = lg
        self.xl = xl
        self.pill = pill
    }
}

public struct ShadowScale: Sendable {
    public let soft: ShadowToken
    public let card: ShadowToken
    public let lifted: ShadowToken

    public init(
        soft: ShadowToken,
        card: ShadowToken,
        lifted: ShadowToken
    ) {
        self.soft = soft
        self.card = card
        self.lifted = lifted
    }
}

public struct ShadowToken: Sendable {
    public let color: Color
    public let radius: CGFloat
    public let x: CGFloat
    public let y: CGFloat

    public init(
        color: Color,
        radius: CGFloat,
        x: CGFloat = 0,
        y: CGFloat = 0
    ) {
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
    }
}
