import SwiftUI

public enum GlassSurfaceShape: Sendable, Equatable {
    case rect(cornerRadius: CGFloat)
    case capsule
}

public struct GlassSurfaceModifier: ViewModifier {
    let tint: Color
    let borderColor: Color
    let shadow: ShadowToken
    let isInteractive: Bool
    let shape: GlassSurfaceShape

    public init(
        cornerRadius: CGFloat = DSRadii.lg,
        tint: Color = DesignSystem.tokens.glass.tint,
        borderColor: Color = DesignSystem.tokens.glass.border,
        shadow: ShadowToken = DesignSystem.tokens.glass.shadow,
        isInteractive: Bool = false,
        shape: GlassSurfaceShape? = nil
    ) {
        self.tint = tint
        self.borderColor = borderColor
        self.shadow = shadow
        self.isInteractive = isInteractive
        self.shape = shape ?? .rect(cornerRadius: cornerRadius)
    }

    public func body(content: Content) -> some View {
        let hasBorder = borderColor != .clear

        switch shape {
        case .rect(let cornerRadius):
            let rectShape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

            if #available(iOS 26.0, *) {
                let glass = Glass.regular.tint(tint)
                let finalGlass = isInteractive ? glass.interactive() : glass
                content
                    .glassEffect(finalGlass, in: .rect(cornerRadius: cornerRadius))
            } else {
                content
                    .background(.ultraThinMaterial, in: rectShape)
                    .overlay {
                        if hasBorder {
                            rectShape.stroke(borderColor, lineWidth: 1)
                        }
                    }
                    .shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
            }
        case .capsule:
            let capsuleShape = Capsule()

            if #available(iOS 26.0, *) {
                let glass = Glass.regular.tint(tint)
                let finalGlass = isInteractive ? glass.interactive() : glass
                content
                    .glassEffect(finalGlass, in: .capsule)
            } else {
                content
                    .background(.ultraThinMaterial, in: capsuleShape)
                    .overlay {
                        if hasBorder {
                            capsuleShape.stroke(borderColor, lineWidth: 1)
                        }
                    }
                    .shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
            }
        }
    }
}

public extension View {
    func glassSurface(
        cornerRadius: CGFloat = DSRadii.lg,
        tint: Color = DesignSystem.tokens.glass.tint,
        borderColor: Color = DesignSystem.tokens.glass.border,
        shadow: ShadowToken = DesignSystem.tokens.glass.shadow,
        isInteractive: Bool = false,
        shape: GlassSurfaceShape? = nil
    ) -> some View {
        modifier(
            GlassSurfaceModifier(
                cornerRadius: cornerRadius,
                tint: tint,
                borderColor: borderColor,
                shadow: shadow,
                isInteractive: isInteractive,
                shape: shape
            )
        )
    }
}
