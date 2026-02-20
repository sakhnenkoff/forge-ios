import SwiftUI

/// A view for displaying error states with optional retry functionality.
/// Use this when an operation fails and the user needs to take action.
public struct ErrorStateView: View {
    let icon: String
    let title: String
    let message: String?
    let retryTitle: String?
    let onRetry: (() -> Void)?
    let dismissTitle: String?
    let onDismiss: (() -> Void)?

    public init(
        icon: String = "exclamationmark.triangle.fill",
        title: String? = nil,
        message: String? = nil,
        retryTitle: String? = nil,
        onRetry: (() -> Void)? = nil,
        dismissTitle: String? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title ?? String(localized: "Something Went Wrong", bundle: .module)
        self.message = message
        self.retryTitle = retryTitle ?? String(localized: "Try Again", bundle: .module)
        self.onRetry = onRetry
        self.dismissTitle = dismissTitle
        self.onDismiss = onDismiss
    }

    /// Creates an ErrorStateView from an Error object.
    public init(
        error: Error,
        retryTitle: String? = nil,
        onRetry: (() -> Void)? = nil,
        dismissTitle: String? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.icon = "exclamationmark.triangle.fill"
        self.title = String(localized: "Something Went Wrong", bundle: .module)
        self.message = error.localizedDescription
        self.retryTitle = retryTitle ?? String(localized: "Try Again", bundle: .module)
        self.onRetry = onRetry
        self.dismissTitle = dismissTitle
        self.onDismiss = onDismiss
    }

    public var body: some View {
        VStack(spacing: DSSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(Color.error)
                .accessibilityHidden(true)

            VStack(spacing: DSSpacing.sm) {
                Text(title)
                    .font(.headlineMedium())
                    .foregroundStyle(Color.textPrimary)
                    .multilineTextAlignment(.center)

                if let message {
                    Text(message)
                        .font(.bodySmall())
                        .foregroundStyle(Color.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }

            VStack(spacing: DSSpacing.sm) {
                if let retryTitle, let onRetry {
                    DSButton(
                        title: retryTitle,
                        style: .primary,
                        size: .medium,
                        isFullWidth: true,
                        action: onRetry
                    )
                }

                if let dismissTitle, let onDismiss {
                    DSButton(
                        title: dismissTitle,
                        style: .tertiary,
                        size: .medium,
                        isFullWidth: true,
                        action: onDismiss
                    )
                }
            }
            .padding(.top, DSSpacing.sm)
        }
        .padding(DSSpacing.xl)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - View Modifier

public extension View {
    /// Overlays an error state when an error is present.
    /// - Parameters:
    ///   - error: The error to display, or nil to show normal content
    ///   - retryTitle: The retry button title
    ///   - onRetry: The retry action
    /// - Returns: The view with an error state overlay when an error exists.
    @ViewBuilder
    func errorState(
        _ error: Error?,
        retryTitle: String? = nil,
        onRetry: @escaping () -> Void
    ) -> some View {
        if let error {
            ErrorStateView(
                error: error,
                retryTitle: retryTitle,
                onRetry: onRetry
            )
        } else {
            self
        }
    }

    /// Overlays an error state with full customization.
    @ViewBuilder
    func errorState(
        _ error: Error?,
        title: String? = nil,
        retryTitle: String? = nil,
        onRetry: @escaping () -> Void,
        dismissTitle: String? = nil,
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        if error != nil {
            ErrorStateView(
                title: title,
                message: error?.localizedDescription,
                retryTitle: retryTitle,
                onRetry: onRetry,
                dismissTitle: dismissTitle,
                onDismiss: onDismiss
            )
        } else {
            self
        }
    }
}

// MARK: - Convenience Initializers

public extension ErrorStateView {
    /// Creates an error state for network/connection issues.
    static func networkError(
        onRetry: @escaping () -> Void
    ) -> ErrorStateView {
        ErrorStateView(
            icon: "wifi.exclamationmark",
            title: String(localized: "Connection Problem", bundle: .module),
            message: String(localized: "Please check your internet connection and try again.", bundle: .module),
            retryTitle: String(localized: "Try Again", bundle: .module),
            onRetry: onRetry
        )
    }

    /// Creates an error state for server errors.
    static func serverError(
        onRetry: @escaping () -> Void
    ) -> ErrorStateView {
        ErrorStateView(
            icon: "server.rack",
            title: String(localized: "Server Error", bundle: .module),
            message: String(localized: "We're having trouble connecting to our servers. Please try again later.", bundle: .module),
            retryTitle: String(localized: "Try Again", bundle: .module),
            onRetry: onRetry
        )
    }

    /// Creates an error state for permission issues.
    static func permissionDenied(
        feature: String,
        onOpenSettings: @escaping () -> Void
    ) -> ErrorStateView {
        ErrorStateView(
            icon: "lock.fill",
            title: String(localized: "Permission Required", bundle: .module),
            message: String(localized: "Please grant \(feature) permission in Settings to use this feature.", bundle: .module),
            retryTitle: String(localized: "Open Settings", bundle: .module),
            onRetry: onOpenSettings
        )
    }

    /// Creates an error state for content that failed to load.
    static func loadFailed(
        onRetry: @escaping () -> Void
    ) -> ErrorStateView {
        ErrorStateView(
            icon: "arrow.clockwise.circle",
            title: String(localized: "Failed to Load", bundle: .module),
            message: String(localized: "We couldn't load this content. Please try again.", bundle: .module),
            retryTitle: String(localized: "Retry", bundle: .module),
            onRetry: onRetry
        )
    }
}

// MARK: - Previews

#Preview("Default Error") {
    ErrorStateView(
        message: "An unexpected error occurred. Please try again.",
        onRetry: { print("Retry tapped") }
    )
    .background(Color.backgroundPrimary)
}

#Preview("With Dismiss") {
    ErrorStateView(
        title: "Upload Failed",
        message: "Your file could not be uploaded.",
        retryTitle: "Try Again",
        onRetry: { print("Retry tapped") },
        dismissTitle: "Cancel",
        onDismiss: { print("Dismiss tapped") }
    )
    .background(Color.backgroundPrimary)
}

#Preview("Network Error") {
    ErrorStateView.networkError(
        onRetry: { print("Retry network") }
    )
    .background(Color.backgroundPrimary)
}

#Preview("Server Error") {
    ErrorStateView.serverError(
        onRetry: { print("Retry server") }
    )
    .background(Color.backgroundPrimary)
}

#Preview("Permission Denied") {
    ErrorStateView.permissionDenied(
        feature: "camera",
        onOpenSettings: { print("Open settings") }
    )
    .background(Color.backgroundPrimary)
}

#Preview("View Modifier") {
    struct PreviewError: Error {
        var localizedDescription: String { "The operation failed." }
    }

    return Text("Content")
        .errorState(PreviewError(), onRetry: { print("Retry") })
}

#Preview("Dark Mode") {
    ErrorStateView(
        message: "Something went wrong",
        onRetry: { print("Retry") }
    )
    .background(Color.backgroundPrimary)
    .preferredColorScheme(.dark)
}
