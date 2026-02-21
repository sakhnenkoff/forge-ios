import SwiftUI

public struct GlassEffectModifier: ViewModifier {
    let cornerRadius: CGFloat
    let tint: Color?
    let isInteractive: Bool

    public init(
        cornerRadius: CGFloat = DSRadii.lg,
        tint: Color? = DesignSystem.tokens.glass.tint,
        isInteractive: Bool = false
    ) {
        self.cornerRadius = cornerRadius
        self.tint = tint
        self.isInteractive = isInteractive
    }

    public func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            let glass = Glass.regular
            let tintedGlass = tint.map { glass.tint($0) } ?? glass
            let interactiveGlass = isInteractive ? tintedGlass.interactive() : tintedGlass

            content
                .glassEffect(interactiveGlass, in: .rect(cornerRadius: cornerRadius))
        } else {
            content
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
        }
    }
}

public extension View {
    func glassBackground(
        cornerRadius: CGFloat = DSRadii.lg,
        tint: Color? = DesignSystem.tokens.glass.tint,
        isInteractive: Bool = false
    ) -> some View {
        modifier(GlassEffectModifier(cornerRadius: cornerRadius, tint: tint, isInteractive: isInteractive))
    }
}
