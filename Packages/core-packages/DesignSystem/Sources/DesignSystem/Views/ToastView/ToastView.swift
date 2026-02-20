import SwiftUI

public struct Toast: Equatable, Sendable {
    public let id: UUID
    public let style: ToastStyle
    public let message: String
    public let duration: Double

    public init(
        id: UUID = UUID(),
        style: ToastStyle,
        message: String,
        duration: Double = 3.0
    ) {
        self.id = id
        self.style = style
        self.message = message
        self.duration = duration
    }

    public static func error(_ message: String, duration: Double = 3.0) -> Toast {
        Toast(style: .error, message: message, duration: duration)
    }

    public static func success(_ message: String, duration: Double = 3.0) -> Toast {
        Toast(style: .success, message: message, duration: duration)
    }

    public static func warning(_ message: String, duration: Double = 3.0) -> Toast {
        Toast(style: .warning, message: message, duration: duration)
    }

    public static func info(_ message: String, duration: Double = 3.0) -> Toast {
        Toast(style: .info, message: message, duration: duration)
    }
}

public enum ToastStyle: Sendable {
    case error
    case warning
    case success
    case info

    /// Solid background color from palette
    public var backgroundColor: Color {
        switch self {
        case .error: return .adaptiveError
        case .warning: return .adaptiveWarning
        case .success: return .adaptiveSuccess
        case .info: return .adaptiveInfo
        }
    }

    public var icon: String {
        switch self {
        case .error: return "xmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .success: return "checkmark.circle.fill"
        case .info: return "info.circle.fill"
        }
    }
}

public struct ToastView: View {
    let toast: Toast
    let onDismiss: () -> Void

    public init(toast: Toast, onDismiss: @escaping () -> Void) {
        self.toast = toast
        self.onDismiss = onDismiss
    }

    public var body: some View {
        HStack(alignment: .center, spacing: DSSpacing.sm) {
            Image(systemName: toast.style.icon)
                .foregroundStyle(toast.style.backgroundColor)
                .font(.system(size: 18, weight: .medium))
                .accessibilityHidden(true)

            Text(toast.message)
                .font(.bodySmall())
                .foregroundStyle(Color.textPrimary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .foregroundStyle(Color.textTertiary)
                    .font(.system(size: 12, weight: .medium))
            }
            .accessibilityLabel(Text(String(localized: "Dismiss", bundle: .module)))
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.md)
        .contentShape(.rect)
        .allowsHitTesting(true)
        .background(
            RoundedRectangle(cornerRadius: DSRadii.md, style: .continuous)
                .fill(Color.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DSRadii.md, style: .continuous)
                .stroke(toast.style.backgroundColor.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: DSShadows.card.color, radius: DSShadows.card.radius, x: 0, y: DSShadows.card.y)
        .padding(.horizontal, DSSpacing.md)
    }
}

#Preview("All Toasts - Light") {
    VStack(spacing: DSSpacing.md) {
        ToastView(toast: .success("Your changes have been saved.")) {}
        ToastView(toast: .error("Something went wrong. Please try again.")) {}
        ToastView(toast: .warning("Your session will expire soon.")) {}
        ToastView(toast: .info("New features are available!")) {}
    }
    .padding(.vertical, DSSpacing.mlg)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.backgroundPrimary)
    .preferredColorScheme(.light)
}

#Preview("All Toasts - Dark") {
    VStack(spacing: DSSpacing.md) {
        ToastView(toast: .success("Your changes have been saved.")) {}
        ToastView(toast: .error("Something went wrong. Please try again.")) {}
        ToastView(toast: .warning("Your session will expire soon.")) {}
        ToastView(toast: .info("New features are available!")) {}
    }
    .padding(.vertical, DSSpacing.mlg)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.backgroundPrimary)
    .preferredColorScheme(.dark)
}
