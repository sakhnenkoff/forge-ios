import SwiftUI

public struct DSHeroCard<Content: View>: View {
    private let tint: Color
    private let usesGlass: Bool
    private let tilt: CGFloat
    private let maxWidth: CGFloat
    private let content: Content

    public init(
        tint: Color = Color.surfaceVariant.opacity(0.7),
        usesGlass: Bool = false,
        tilt: CGFloat = 0,
        maxWidth: CGFloat = DSLayout.cardMaxWidth,
        @ViewBuilder content: () -> Content
    ) {
        self.tint = tint
        self.usesGlass = usesGlass
        self.tilt = tilt
        self.maxWidth = maxWidth
        self.content = content()
    }

    public var body: some View {
        GlassCard(tint: tint, usesGlass: usesGlass, tilt: tilt) {
            content
        }
        .frame(maxWidth: maxWidth)
        .frame(maxWidth: .infinity)
    }
}
