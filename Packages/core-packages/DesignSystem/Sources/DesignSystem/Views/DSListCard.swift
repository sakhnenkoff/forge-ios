import SwiftUI

public struct DSListCard<Content: View>: View {
    private let spacing: CGFloat
    private let depth: DSSurfaceDepth
    private let content: Content

    public init(
        spacing: CGFloat = 0,
        depth: DSSurfaceDepth = .raised,
        @ViewBuilder content: () -> Content
    ) {
        self.spacing = spacing
        self.depth = depth
        self.content = content()
    }

    public var body: some View {
        VStack(spacing: spacing) {
            content
        }
        .cardSurface(cornerRadius: DSRadii.lg, depth: depth)
    }
}
