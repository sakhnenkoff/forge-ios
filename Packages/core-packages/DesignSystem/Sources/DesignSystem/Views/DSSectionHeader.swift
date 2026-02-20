import SwiftUI

public struct DSSectionHeader: View {
    private let title: String
    private let subtitle: String?
    private let titleColor: Color
    private let subtitleColor: Color

    public init(
        title: String,
        subtitle: String? = nil,
        titleColor: Color = Color.textPrimary,
        subtitleColor: Color = Color.textSecondary
    ) {
        self.title = title
        self.subtitle = subtitle
        self.titleColor = titleColor
        self.subtitleColor = subtitleColor
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: subtitle == nil ? 0 : DSSpacing.xs) {
            Text(title)
                .font(.titleSmall())
                .foregroundStyle(titleColor)

            if let subtitle {
                Text(subtitle)
                    .font(.bodySmall())
                    .foregroundStyle(subtitleColor)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
