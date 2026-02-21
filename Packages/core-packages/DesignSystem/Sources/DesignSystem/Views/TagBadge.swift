import SwiftUI

public struct TagBadge: View {
    let text: String
    let tint: Color
    let usesGlass: Bool

    public init(
        text: String,
        tint: Color = Color.textSecondary,
        usesGlass: Bool = false
    ) {
        self.text = text
        self.tint = tint
        self.usesGlass = usesGlass
    }

    public var body: some View {
        let shape = Capsule()
        let base = Text(text)
            .font(.captionSmall())
            .foregroundStyle(tint)
            .padding(.horizontal, DSSpacing.sm)
            .padding(.vertical, DSSpacing.xs)
            .background(
                shape.fill(tint.opacity(0.08))
            )

        if usesGlass {
            base.glassSurface(
                cornerRadius: DSRadii.pill,
                tint: tint.opacity(0.15),
                borderColor: tint.opacity(0.25),
                shadow: DSShadows.soft,
                isInteractive: false
            )
        } else {
            base.overlay(
                shape.stroke(tint.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

#Preview("Tag Badge") {
    VStack(spacing: DSSpacing.md) {
        TagBadge(text: "Featured")
        TagBadge(text: "New", usesGlass: true)
        TagBadge(text: "Disabled", tint: .textSecondary)
    }
    .padding()
    .background(Color.backgroundPrimary)
}
