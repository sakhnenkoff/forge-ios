import SwiftUI

public struct DSSection<Content: View>: View {
    private let title: String
    private let subtitle: String?
    private let spacing: CGFloat
    private let content: Content

    public init(
        title: String,
        subtitle: String? = nil,
        spacing: CGFloat = DSSpacing.sm,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            DSSectionHeader(title: title, subtitle: subtitle)
            content
        }
    }
}
