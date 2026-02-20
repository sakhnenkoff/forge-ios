import SwiftUI

/// A clean card container for grouping content.
/// Replaces glass cards with a simple surface + border + shadow approach.
public struct DSCard<Content: View>: View {
    let cornerRadius: CGFloat
    let tint: Color
    let content: Content

    public init(
        cornerRadius: CGFloat = DSRadii.xl,
        tint: Color = Color.surface,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.tint = tint
        self.content = content()
    }

    public var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        content
            .padding(DSSpacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(shape.fill(tint))
            .overlay(shape.stroke(Color.border, lineWidth: 1))
            .shadow(
                color: DSShadows.card.color,
                radius: DSShadows.card.radius,
                x: 0,
                y: DSShadows.card.y
            )
    }
}

#Preview("DSCard") {
    DSCard {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Card Title")
                .font(.headlineMedium())
                .foregroundStyle(Color.textPrimary)
            Text("Card content goes here.")
                .font(.bodyMedium())
                .foregroundStyle(Color.textSecondary)
        }
    }
    .padding()
    .background(Color.backgroundPrimary)
}
