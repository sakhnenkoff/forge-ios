import SwiftUI

public struct GlassCard<Content: View>: View {
    let cornerRadius: CGFloat
    let tint: Color
    let usesGlass: Bool
    let tilt: CGFloat
    let content: Content

    public init(
        cornerRadius: CGFloat = DSRadii.xl,
        tint: Color = Color.surfaceVariant.opacity(0.85),
        usesGlass: Bool = false,
        tilt: CGFloat = 0,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.tint = tint
        self.usesGlass = usesGlass
        self.tilt = tilt
        self.content = content()
    }

    public var body: some View {
        content
            .padding(DSSpacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .cardSurface(
                cornerRadius: cornerRadius,
                depth: .lifted,
                tint: tint,
                usesGlass: usesGlass
            )
            .rotation3DEffect(.degrees(tilt), axis: (x: 1, y: -0.2, z: 0))
    }
}
