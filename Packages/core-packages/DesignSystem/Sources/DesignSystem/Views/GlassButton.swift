import SwiftUI

public enum GlassButtonStyle {
    case primary
    case secondary
    case destructive

    var backgroundColor: Color {
        switch self {
        case .primary:     return .themePrimary
        case .secondary:   return .clear
        case .destructive: return .error
        }
    }

    var foregroundColor: Color {
        switch self {
        case .primary:     return .textOnPrimary
        case .secondary:   return .themePrimary
        case .destructive: return .textOnPrimary
        }
    }

    var borderColor: Color {
        switch self {
        case .primary, .destructive: return .clear
        case .secondary:             return .themePrimary.opacity(0.35)
        }
    }

    var glassTint: Color {
        switch self {
        case .primary:     return .themePrimary.opacity(0.3)
        case .secondary:   return DesignSystem.tokens.glass.tint
        case .destructive: return .error.opacity(0.25)
        }
    }
}

/// A glass-styled button with minimal, tactile styling.
public struct GlassButton: View {
    let title: String
    let icon: String?
    let style: GlassButtonStyle
    let isEnabled: Bool
    let isFullWidth: Bool
    let action: () -> Void

    public init(
        title: String,
        icon: String? = nil,
        style: GlassButtonStyle = .primary,
        isEnabled: Bool = true,
        isFullWidth: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.isEnabled = isEnabled
        self.isFullWidth = isFullWidth
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: DSSpacing.smd) {
                if let icon {
                    SketchIcon(systemName: icon, size: 16, color: style.foregroundColor)
                }

                Text(title)
                    .font(.buttonMedium())
                    .foregroundStyle(style.foregroundColor)
            }
            .padding(.horizontal, DSSpacing.lg)
            .padding(.vertical, DSSpacing.smd)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .frame(minHeight: 48)
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.45)
        .background(buttonBackground)
        .clipShape(RoundedRectangle(cornerRadius: DSRadii.lg, style: .continuous))
    }

    private var buttonBackground: some View {
        RoundedRectangle(cornerRadius: DSRadii.lg, style: .continuous)
            .fill(style.backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: DSRadii.lg, style: .continuous)
                    .stroke(style.borderColor, lineWidth: 1)
            )
            .glassSurface(
                cornerRadius: DSRadii.lg,
                tint: style.glassTint,
                borderColor: style.borderColor,
                shadow: DSShadows.soft,
                isInteractive: true
            )
    }
}
