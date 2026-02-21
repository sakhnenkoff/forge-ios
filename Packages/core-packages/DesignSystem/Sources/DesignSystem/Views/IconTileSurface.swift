import SwiftUI

public struct IconTileSurface<Content: View>: View {
    let size: CGFloat
    let cornerRadius: CGFloat
    let fill: Color
    let borderColor: Color
    let borderWidth: CGFloat
    let shadow: ShadowToken
    let glassTint: Color?
    let usesGlass: Bool
    let isInteractive: Bool
    let content: Content

    public init(
        size: CGFloat = 32,
        cornerRadius: CGFloat = DSRadii.md,
        fill: Color = Color.surfaceVariant.opacity(0.8),
        borderColor: Color = Color.border,
        borderWidth: CGFloat = 1,
        shadow: ShadowToken = DSShadows.soft,
        glassTint: Color? = DesignSystem.tokens.glass.tint,
        usesGlass: Bool = false,
        isInteractive: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.size = size
        self.cornerRadius = cornerRadius
        self.fill = fill
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.shadow = shadow
        self.glassTint = glassTint
        self.usesGlass = usesGlass
        self.isInteractive = isInteractive
        self.content = content()
    }

    private var isCircular: Bool {
        cornerRadius >= size / 2
    }

    public var body: some View {
        let tile = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        if usesGlass {
            let resolvedTint = glassTint ?? .clear
            if #available(iOS 26.0, *) {
                let glass = Glass.regular.tint(resolvedTint)
                let finalGlass = isInteractive ? glass.interactive() : glass
                if isCircular {
                    content
                        .frame(width: size, height: size)
                        .glassEffect(finalGlass, in: .capsule)
                } else {
                    content
                        .frame(width: size, height: size)
                        .glassEffect(finalGlass, in: .rect(cornerRadius: cornerRadius))
                }
            } else {
                content
                    .frame(width: size, height: size)
                    .background(tile.fill(fill))
                    .overlay(tile.stroke(borderColor.opacity(0.6), lineWidth: borderWidth))
                    .shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
            }
        } else {
            content
                .frame(width: size, height: size)
                .background(tile.fill(fill))
                .overlay(tile.stroke(borderColor.opacity(borderWidth == 0 ? 0 : 0.6), lineWidth: borderWidth))
                .shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
        }
    }
}
