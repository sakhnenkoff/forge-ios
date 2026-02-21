import SwiftUI

/// A small icon badge used for feature rows and compact callouts.
public struct DSIconBadge: View {
    let systemName: String
    let size: CGFloat
    let cornerRadius: CGFloat
    let backgroundColor: Color
    let foregroundColor: Color
    let font: Font

    public init(
        systemName: String,
        size: CGFloat = 32,
        cornerRadius: CGFloat = 10,
        backgroundColor: Color = Color.textPrimary.opacity(0.08),
        foregroundColor: Color = Color.textPrimary,
        font: Font = .headlineSmall()
    ) {
        self.systemName = systemName
        self.size = size
        self.cornerRadius = cornerRadius
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.font = font
    }

    public var body: some View {
        IconTileSurface(
            size: size,
            cornerRadius: cornerRadius,
            fill: backgroundColor,
            borderColor: .clear,
            borderWidth: 0,
            shadow: ShadowToken(color: .clear, radius: 0),
            usesGlass: false
        ) {
            Image(systemName: systemName)
                .font(font)
                .foregroundStyle(foregroundColor)
        }
    }
}

#Preview("Default") {
    DSIconBadge(systemName: "sparkles")
        .padding()
        .background(Color.backgroundPrimary)
}

#Preview("Warning") {
    DSIconBadge(
        systemName: "exclamationmark.triangle.fill",
        backgroundColor: Color.warning.opacity(0.15),
        foregroundColor: Color.warning
    )
    .padding()
    .background(Color.backgroundPrimary)
}
