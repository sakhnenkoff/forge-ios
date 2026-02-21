import SwiftUI

public enum DSSurfaceDepth: Sendable {
    case flat
    case raised
    case lifted

    var shadowToken: ShadowToken {
        switch self {
        case .flat:
            ShadowToken(color: .clear, radius: 0, y: 0)
        case .raised:
            DSShadows.card
        case .lifted:
            DSShadows.lifted
        }
    }
}

public struct CardSurfaceModifier: ViewModifier {
    let cornerRadius: CGFloat
    let depth: DSSurfaceDepth
    let tint: Color
    let usesGlass: Bool
    let isInteractive: Bool
    let borderColor: Color
    let shadowColor: Color
    let shadowRadius: CGFloat
    let shadowYOffset: CGFloat

    public init(
        cornerRadius: CGFloat = DSRadii.lg,
        depth: DSSurfaceDepth = .raised,
        tint: Color = Color.surface,
        usesGlass: Bool = false,
        isInteractive: Bool = false,
        borderColor: Color = Color.border,
        shadowColor: Color? = nil,
        shadowRadius: CGFloat? = nil,
        shadowYOffset: CGFloat? = nil
    ) {
        let token = depth.shadowToken
        self.cornerRadius = cornerRadius
        self.depth = depth
        self.tint = tint
        self.usesGlass = usesGlass
        self.isInteractive = isInteractive
        self.borderColor = borderColor
        self.shadowColor = shadowColor ?? token.color
        self.shadowRadius = shadowRadius ?? token.radius
        self.shadowYOffset = shadowYOffset ?? token.y
    }

    public func body(content: Content) -> some View {
        let effectiveCornerRadius = min(cornerRadius, DSRadii.xl)
        let shape = RoundedRectangle(cornerRadius: effectiveCornerRadius, style: .continuous)

        if #available(iOS 26.0, *), usesGlass {
            let glass = Glass.regular.tint(tint)
            let finalGlass = isInteractive ? glass.interactive() : glass

            content
                .glassEffect(finalGlass, in: .rect(cornerRadius: effectiveCornerRadius))
        } else {
            content
                .background(shape.fill(tint))
                .overlay(shape.stroke(borderColor, lineWidth: 1))
                .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowYOffset)
        }
    }
}

public extension View {
    func cardSurface(
        cornerRadius: CGFloat = DSRadii.lg,
        depth: DSSurfaceDepth = .raised,
        tint: Color = Color.surface,
        usesGlass: Bool = false,
        isInteractive: Bool = false,
        borderColor: Color = Color.border,
        shadowColor: Color? = nil,
        shadowRadius: CGFloat? = nil,
        shadowYOffset: CGFloat? = nil
    ) -> some View {
        modifier(
            CardSurfaceModifier(
                cornerRadius: cornerRadius,
                depth: depth,
                tint: tint,
                usesGlass: usesGlass,
                isInteractive: isInteractive,
                borderColor: borderColor,
                shadowColor: shadowColor,
                shadowRadius: shadowRadius,
                shadowYOffset: shadowYOffset
            )
        )
    }
}
