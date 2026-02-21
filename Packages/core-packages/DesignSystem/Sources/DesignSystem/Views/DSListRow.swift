import SwiftUI

/// A compact list row with optional leading icon and trailing control.
public struct DSListRow<Trailing: View>: View {
    let title: String
    let subtitle: String?
    let leadingIcon: String?
    let leadingTint: Color
    let titleColor: Color
    let minHeight: CGFloat
    let trailing: Trailing
    let action: (() -> Void)?

    public init(
        title: String,
        subtitle: String? = nil,
        leadingIcon: String? = nil,
        leadingTint: Color = Color.textSecondary,
        titleColor: Color = Color.textPrimary,
        minHeight: CGFloat = DSLayout.listRowMinHeight,
        action: (() -> Void)? = nil
    ) where Trailing == EmptyView {
        self.title = title
        self.subtitle = subtitle
        self.leadingIcon = leadingIcon
        self.leadingTint = leadingTint
        self.titleColor = titleColor
        self.minHeight = minHeight
        self.trailing = EmptyView()
        self.action = action
    }

    public init(
        title: String,
        subtitle: String? = nil,
        leadingIcon: String? = nil,
        leadingTint: Color = Color.textSecondary,
        titleColor: Color = Color.textPrimary,
        minHeight: CGFloat = DSLayout.listRowMinHeight,
        action: (() -> Void)? = nil,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.subtitle = subtitle
        self.leadingIcon = leadingIcon
        self.leadingTint = leadingTint
        self.titleColor = titleColor
        self.minHeight = minHeight
        self.trailing = trailing()
        self.action = action
    }

    public var body: some View {
        let rowContent = HStack(spacing: DSSpacing.smd) {
            if let leadingIcon {
                SketchIcon(systemName: leadingIcon, size: DSLayout.iconSmall, color: leadingTint)
            }

            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                Text(title)
                    .font(.bodyMedium())
                    .foregroundStyle(titleColor)

                if let subtitle {
                    Text(subtitle)
                        .font(.captionLarge())
                        .foregroundStyle(Color.textSecondary)
                }
            }

            Spacer(minLength: DSSpacing.sm)

            trailing
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.smd)
        .frame(minHeight: minHeight)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())

        if let action {
            Button(action: action) {
                rowContent
            }
            .buttonStyle(.plain)
        } else {
            rowContent
        }
    }
}

#Preview("Rows") {
    VStack(spacing: 0) {
        DSListRow(
            title: "Notifications",
            subtitle: "Set a time for daily memories",
            leadingIcon: "bell"
        ) {
            TimePill(title: "17:00")
        }
        Divider()
        DSListRow(
            title: "Restore",
            subtitle: "Have full access?",
            leadingIcon: "arrow.counterclockwise"
        ) {
            IconTileButton(systemName: "tray.and.arrow.down")
        }
    }
    .cardSurface(cornerRadius: DSRadii.lg)
    .padding()
    .background(Color.backgroundPrimary)
}
