import SwiftUI

/// A section container with title header and optional trailing action.
public struct DSSection<Content: View, Trailing: View>: View {
    private let title: String
    private let subtitle: String?
    private let spacing: CGFloat
    private let trailing: Trailing
    private let content: Content

    public init(
        title: String,
        subtitle: String? = nil,
        spacing: CGFloat = DSSpacing.sm,
        @ViewBuilder content: () -> Content
    ) where Trailing == EmptyView {
        self.title = title
        self.subtitle = subtitle
        self.spacing = spacing
        self.trailing = EmptyView()
        self.content = content()
    }

    public init(
        title: String,
        subtitle: String? = nil,
        spacing: CGFloat = DSSpacing.sm,
        @ViewBuilder trailing: () -> Trailing,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.spacing = spacing
        self.trailing = trailing()
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: subtitle == nil ? 0 : DSSpacing.xs) {
                    Text(title)
                        .font(.titleSmall())
                        .foregroundStyle(Color.textPrimary)

                    if let subtitle {
                        Text(subtitle)
                            .font(.bodySmall())
                            .foregroundStyle(Color.textSecondary)
                    }
                }

                Spacer(minLength: DSSpacing.sm)

                trailing
            }

            content
        }
    }
}
