import SwiftUI

/// A card container optimized for list content (rows with dividers).
public struct DSListCard<Content: View>: View {
    private let spacing: CGFloat
    private let content: Content

    public init(
        spacing: CGFloat = 0,
        @ViewBuilder content: () -> Content
    ) {
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        let shape = RoundedRectangle(cornerRadius: DSRadii.lg, style: .continuous)

        VStack(spacing: spacing) {
            content
        }
        .background(shape.fill(Color.surface))
        .overlay(shape.stroke(Color.border, lineWidth: 1))
        .shadow(
            color: DSShadows.card.color,
            radius: DSShadows.card.radius,
            x: 0,
            y: DSShadows.card.y
        )
    }
}
