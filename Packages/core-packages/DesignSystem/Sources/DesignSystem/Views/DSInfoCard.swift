import SwiftUI

public struct DSInfoCard: View {
    private let title: String
    private let message: String
    private let icon: String?
    private let tint: Color
    private let backgroundOpacity: Double
    private let borderOpacity: Double
    private let shadow: ShadowToken

    public init(
        title: String,
        message: String,
        icon: String? = nil,
        tint: Color = Color.info,
        backgroundOpacity: Double = 0.08,
        borderOpacity: Double = 0.18,
        shadow: ShadowToken = DSShadows.soft
    ) {
        self.title = title
        self.message = message
        self.icon = icon
        self.tint = tint
        self.backgroundOpacity = backgroundOpacity
        self.borderOpacity = borderOpacity
        self.shadow = shadow
    }

    public var body: some View {
        HStack(alignment: .top, spacing: DSSpacing.sm) {
            if let icon {
                HeroIcon(systemName: icon, size: DSLayout.iconSmall, tint: tint)
            }

            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                Text(title)
                    .font(.headlineSmall())
                    .foregroundStyle(Color.textPrimary)
                Text(message)
                    .font(.bodySmall())
                    .foregroundStyle(Color.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(DSSpacing.md)
        .cardSurface(
            cornerRadius: DSRadii.lg,
            tint: tint.opacity(backgroundOpacity),
            borderColor: tint.opacity(borderOpacity),
            shadowColor: shadow.color,
            shadowRadius: shadow.radius,
            shadowYOffset: shadow.y
        )
        .accessibilityElement(children: .combine)
    }
}
