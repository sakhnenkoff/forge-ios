import SwiftUI

public struct PickerPill: View {
    let title: String
    let isHighlighted: Bool
    let usesGlass: Bool
    let isInteractive: Bool

    public init(
        title: String,
        isHighlighted: Bool = true,
        usesGlass: Bool = false,
        isInteractive: Bool = false
    ) {
        self.title = title
        self.isHighlighted = isHighlighted
        self.usesGlass = usesGlass
        self.isInteractive = isInteractive
    }

    public var body: some View {
        let shape = RoundedRectangle(cornerRadius: DSRadii.pill, style: .continuous)
        let effectiveUsesGlass = usesGlass || isInteractive
        let base = Text(title)
            .font(.bodyMedium())
            .foregroundStyle(isHighlighted ? Color.textOnPrimary : Color.themePrimary)
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.smd)
            .background(
                shape.fill(effectiveUsesGlass ? Color.clear : (isHighlighted ? Color.themePrimary : Color.surface))
            )

        if effectiveUsesGlass {
            base.glassSurface(
                cornerRadius: DSRadii.pill,
                tint: isHighlighted ? Color.themePrimary.opacity(0.3) : DesignSystem.tokens.glass.tint,
                borderColor: isHighlighted ? Color.clear : Color.themePrimary.opacity(0.25),
                shadow: DSShadows.soft,
                isInteractive: isInteractive,
                shape: .capsule
            )
            .clipShape(shape)
        } else {
            base.overlay(
                shape.stroke(
                    isHighlighted ? Color.clear : Color.themePrimary.opacity(0.2),
                    lineWidth: 1
                )
            )
        }
    }
}

#Preview("Picker Pill") {
    VStack(spacing: DSSpacing.md) {
        PickerPill(title: "17:00")
        PickerPill(title: "Weekly", isHighlighted: false)
        PickerPill(title: "Daily", isHighlighted: true, usesGlass: true, isInteractive: true)
    }
    .padding()
    .background(Color.backgroundPrimary)
}
