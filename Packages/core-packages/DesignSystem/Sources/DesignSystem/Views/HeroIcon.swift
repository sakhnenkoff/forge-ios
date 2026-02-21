import SwiftUI

public struct HeroIcon: View {
    let systemName: String
    let size: CGFloat
    let tint: Color
    let backgroundTint: Color
    let usesGlass: Bool

    public init(
        systemName: String,
        size: CGFloat = 48,
        tint: Color = Color.themePrimary,
        backgroundTint: Color = Color.surfaceVariant.opacity(0.5),
        usesGlass: Bool = false
    ) {
        self.systemName = systemName
        self.size = size
        self.tint = tint
        self.backgroundTint = backgroundTint
        self.usesGlass = usesGlass
    }

    public var body: some View {
        let shape = RoundedRectangle(cornerRadius: DSRadii.lg, style: .continuous)
        let base = SketchIcon(systemName: systemName, size: size, color: tint)
            .padding(DSSpacing.md)
            .background(shape.fill(backgroundTint))

        if usesGlass {
            base.glassSurface(
                cornerRadius: DSRadii.lg,
                tint: DesignSystem.tokens.glass.tint,
                borderColor: Color.border,
                shadow: DSShadows.soft,
                isInteractive: false
            )
        } else {
            base.shadow(color: DSShadows.soft.color, radius: DSShadows.soft.radius, x: 0, y: DSShadows.soft.y)
        }
    }
}

#Preview("Hero Icon") {
    HeroIcon(systemName: "doc")
        .padding()
        .background(Color.backgroundPrimary)
}
