import SwiftUI

/// A standardized button component following the design system.
/// Supports multiple styles, sizes, and loading states.
public struct DSButton: View {
    let title: String
    let icon: String?
    let style: DSButtonStyle
    let size: DSButtonSize
    let isLoading: Bool
    let isEnabled: Bool
    let isFullWidth: Bool
    let action: () -> Void

    @State private var tapCount = 0

    public init(
        title: String,
        icon: String? = nil,
        style: DSButtonStyle = .primary,
        size: DSButtonSize = .medium,
        isLoading: Bool = false,
        isEnabled: Bool = true,
        isFullWidth: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.size = size
        self.isLoading = isLoading
        self.isEnabled = isEnabled
        self.isFullWidth = isFullWidth
        self.action = action
    }

    private var shouldProvideHaptics: Bool {
        style == .primary || style == .destructive
    }

    public var body: some View {
        Button(action: {
            if !isLoading && isEnabled {
                tapCount += 1
                action()
            }
        }) {
            buttonLabel
        }
        .buttonStyle(DSButtonPressStyle(style: style, cornerRadius: size.cornerRadius))
        .disabled(!isEnabled || isLoading)
        .opacity(isEnabled ? 1.0 : 0.5)
        .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.6), trigger: tapCount) { _, _ in
            shouldProvideHaptics
        }
    }

    @ViewBuilder
    private var buttonLabel: some View {
        let shape = RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous)

        HStack(spacing: DSSpacing.sm) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .tint(style.foregroundColor)
                    .scaleEffect(0.8)
            } else {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: size.iconSize, weight: .medium))
                }

                Text(title)
                    .font(size.font)
            }
        }
        .foregroundStyle(style.foregroundColor)
        .padding(.horizontal, size.horizontalPadding)
        .padding(.vertical, size.verticalPadding)
        .frame(maxWidth: isFullWidth ? .infinity : nil)
        .frame(minHeight: size.height)
        .background(shape.fill(style.backgroundStyle))
        .overlay(
            shape.strokeBorder(style.borderColor, lineWidth: style.borderWidth)
        )
        .shadow(color: style.glowColor, radius: style.glowRadius, x: 0, y: style.glowYOffset)
    }
}

// MARK: - Button Style

public enum DSButtonStyle {
    /// Filled button with primary theme color
    case primary

    /// Outlined button with primary theme color border
    case secondary

    /// Text-only button without background
    case tertiary

    /// Filled button with error color for destructive actions
    case destructive

    var foregroundColor: Color {
        switch self {
        case .primary:     return .textOnPrimary
        case .secondary:   return .themePrimary
        case .tertiary:    return .textSecondary
        case .destructive: return .textOnPrimary
        }
    }

    var borderColor: Color {
        switch self {
        case .secondary: return .themePrimary.opacity(0.35)
        default:         return .clear
        }
    }

    var borderWidth: CGFloat {
        switch self {
        case .secondary: return 1
        default:         return 0
        }
    }

    var backgroundStyle: AnyShapeStyle {
        switch self {
        case .primary:     return AnyShapeStyle(Color.themePrimary)
        case .secondary:   return AnyShapeStyle(Color.surface)
        case .tertiary:    return AnyShapeStyle(Color.clear)
        case .destructive: return AnyShapeStyle(Color.error)
        }
    }

    var glowColor: Color {
        switch self {
        case .primary:     return Color.black.opacity(0.06)
        case .destructive: return Color.black.opacity(0.08)
        default:           return Color.clear
        }
    }

    var glowRadius: CGFloat {
        switch self {
        case .primary, .destructive: return 4
        default:                     return 0
        }
    }

    var glowYOffset: CGFloat {
        switch self {
        case .primary, .destructive: return 2
        default:                     return 0
        }
    }
}

// MARK: - Button Press Style

private struct DSButtonPressStyle: ButtonStyle {
    let style: DSButtonStyle
    let cornerRadius: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        configuration.label
            .scaleEffect(pressScale(isPressed: configuration.isPressed))
            .overlay(
                Group {
                    if style == .secondary || style == .destructive {
                        shape.fill(pressFill(isPressed: configuration.isPressed))
                    }
                }
            )
            .overlay(
                Group {
                    if style == .secondary {
                        shape.strokeBorder(
                            pressBorder(isPressed: configuration.isPressed),
                            lineWidth: configuration.isPressed ? 1.0 : 0
                        )
                    }
                }
            )
            .animation(.spring(response: 0.22, dampingFraction: 0.72), value: configuration.isPressed)
    }

    private func pressScale(isPressed: Bool) -> CGFloat {
        guard isPressed else { return 1.0 }
        switch style {
        case .primary:               return 1.02
        case .secondary, .destructive: return 0.99
        case .tertiary:              return 0.98
        }
    }

    private func pressFill(isPressed: Bool) -> Color {
        guard isPressed else { return .clear }
        switch style {
        case .secondary:   return Color.themePrimary.opacity(0.10)
        case .destructive: return Color.white.opacity(0.06)
        default:           return .clear
        }
    }

    private func pressBorder(isPressed: Bool) -> Color {
        guard isPressed, style == .secondary else { return .clear }
        return Color.themePrimary.opacity(0.55)
    }
}

// MARK: - Button Size

public enum DSButtonSize {
    case small
    case medium
    case large

    var iconSize: CGFloat {
        switch self {
        case .small: return 12
        case .medium: return 14
        case .large: return 16
        }
    }

    var horizontalPadding: CGFloat {
        switch self {
        case .small: return DSSpacing.smd
        case .medium: return DSSpacing.md
        case .large: return DSSpacing.lg
        }
    }

    var verticalPadding: CGFloat {
        switch self {
        case .small: return DSSpacing.sm
        case .medium: return DSSpacing.smd
        case .large: return DSSpacing.md
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .small: return DSRadii.sm
        case .medium: return DSRadii.lg
        case .large: return DSRadii.xl
        }
    }

    var font: Font {
        switch self {
        case .small:  return .buttonSmall()
        case .medium: return .buttonMedium()
        case .large:  return .buttonLarge()
        }
    }

    var height: CGFloat {
        switch self {
        case .small:  return 40
        case .medium: return 48
        case .large:  return 56
        }
    }
}

// MARK: - Convenience Initializers

public extension DSButton {
    /// Creates a primary full-width CTA button.
    static func cta(
        title: String,
        icon: String? = nil,
        isLoading: Bool = false,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) -> DSButton {
        DSButton(
            title: title,
            icon: icon,
            style: .primary,
            size: .medium,
            isLoading: isLoading,
            isEnabled: isEnabled,
            isFullWidth: true,
            action: action
        )
    }

    /// Creates a destructive action button.
    static func destructive(
        title: String,
        icon: String? = "trash",
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) -> DSButton {
        DSButton(
            title: title,
            icon: icon,
            style: .destructive,
            size: .medium,
            isLoading: isLoading,
            action: action
        )
    }

    /// Creates a text-only link-style button.
    static func link(
        title: String,
        action: @escaping () -> Void
    ) -> DSButton {
        DSButton(
            title: title,
            style: .tertiary,
            size: .medium,
            action: action
        )
    }
}

// MARK: - Icon-Only Button

/// A button that displays only an icon without text.
public struct DSIconButton: View {
    let icon: String
    let style: DSButtonStyle
    let size: DSIconButtonSize
    let showsBackground: Bool
    let accessibilityLabel: String?
    let action: (() -> Void)?

    public init(
        icon: String,
        style: DSButtonStyle = .tertiary,
        size: DSIconButtonSize = .medium,
        usesGlass: Bool = false,
        showsBackground: Bool = true,
        glassTint: Color? = nil,
        accessibilityLabel: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.style = style
        self.size = size
        self.showsBackground = showsBackground
        self.accessibilityLabel = accessibilityLabel
        self.action = action
    }

    public var body: some View {
        let content = iconContent

        if let action {
            Button(action: action) {
                content
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text(accessibilityLabel ?? icon))
        } else {
            content
                .accessibilityHidden(true)
        }
    }

    private var iconTint: Color {
        switch style {
        case .destructive: return .error
        case .tertiary:    return .textSecondary
        default:           return .themePrimary
        }
    }

    private var iconBackground: Color {
        switch style {
        case .destructive: return Color.error.opacity(0.12)
        case .tertiary:    return Color.surfaceVariant.opacity(0.6)
        default:           return Color.surfaceVariant.opacity(0.8)
        }
    }

    @ViewBuilder
    private var iconContent: some View {
        if showsBackground {
            Image(systemName: icon)
                .font(.system(size: size.iconSize, weight: .medium))
                .foregroundStyle(iconTint)
                .frame(width: size.dimension, height: size.dimension)
                .background(
                    RoundedRectangle(cornerRadius: DSRadii.lg, style: .continuous)
                        .fill(iconBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: DSRadii.lg, style: .continuous)
                        .stroke(style == .tertiary ? Color.clear : Color.border.opacity(0.6), lineWidth: 1)
                )
                .shadow(color: DSShadows.soft.color, radius: DSShadows.soft.radius, x: 0, y: DSShadows.soft.y)
        } else {
            Image(systemName: icon)
                .font(.system(size: size.iconSize, weight: .medium))
                .foregroundStyle(iconTint)
                .frame(width: size.dimension, height: size.dimension)
                .contentShape(.rect)
        }
    }
}

public enum DSIconButtonSize {
    case small
    case medium
    case large

    var iconSize: CGFloat {
        switch self {
        case .small: return 16
        case .medium: return 18
        case .large: return 22
        }
    }

    var dimension: CGFloat {
        switch self {
        case .small: return 44
        case .medium: return 48
        case .large: return 56
        }
    }
}

// MARK: - Previews

#Preview("Buttons") {
    VStack(spacing: DSSpacing.md) {
        DSButton(title: "Primary") {}
        DSButton(title: "Secondary", style: .secondary) {}
        DSButton(title: "Tertiary", style: .tertiary) {}
        DSButton.cta(title: "Get Started") {}
        DSButton.destructive(title: "Delete", action: {})
    }
    .padding()
    .background(Color.backgroundPrimary)
}

#Preview("Icon Buttons") {
    HStack(spacing: DSSpacing.md) {
        DSIconButton(icon: "heart.fill", style: .primary, size: .small) {}
        DSIconButton(icon: "plus", style: .secondary) {}
        DSIconButton(icon: "xmark", style: .tertiary) {}
    }
    .padding()
    .background(Color.backgroundPrimary)
}
