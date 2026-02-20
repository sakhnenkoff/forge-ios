import Foundation
import SwiftUI

/// Central design system singleton for theme management
public enum DesignSystem {

    // MARK: - Private Storage

    // SAFETY: All mutable storage access is protected by `lock`.
    // TODO(CONC-006): Replace this with a fully compiler-verified synchronization primitive.
    private final class Storage: @unchecked Sendable {
        var theme: any Theme = AdaptiveTheme()
        var isConfigured = false
    }

    private static let storage = Storage()
    private static let lock = NSLock()

    // MARK: - Public API

    /// The current theme. Read-only after configuration.
    public static var theme: any Theme {
        withLock { $0.theme }
    }

    /// Convenience accessor for colors
    public static var colors: ColorPalette {
        withLock { $0.theme.colors }
    }

    /// Convenience accessor for typography
    public static var typography: TypographyScale {
        withLock { $0.theme.typography }
    }

    /// Convenience accessor for spacing
    public static var spacing: SpacingScale {
        withLock { $0.theme.spacing }
    }

    /// Convenience accessor for layout
    public static var layout: LayoutScale {
        withLock { $0.theme.layout }
    }

    /// Convenience accessor for tokens
    public static var tokens: DesignTokens {
        withLock { $0.theme.tokens }
    }

    /// Configure the design system with a custom theme.
    /// Must be called once at app launch, before any UI is rendered.
    /// - Parameter theme: The theme to use throughout the app
    /// - Warning: This should only be called once. Subsequent calls will be ignored.
    public static func configure(theme: any Theme) {
        let configuredTheme = withLock { state -> (any Theme)? in
            guard !state.isConfigured else { return nil }
            state.theme = theme
            state.isConfigured = true
            return state.theme
        }

        guard let configuredTheme else {
            #if DEBUG
            print("⚠️ DesignSystem.configure() called multiple times. Ignoring subsequent call.")
            #endif
            return
        }

        #if canImport(UIKit)
        DesignSystemAppearance.apply(using: configuredTheme.tokens)
        #endif
    }

    /// Configure with the default AdaptiveTheme
    public static func configureWithDefaults() {
        configure(theme: AdaptiveTheme())
    }

    /// Register custom fonts if needed
    public static func registerFonts() {
        // Add font registration logic here if using custom fonts
    }

    public static let themeDidChangeNotification = Notification.Name("DesignSystem.themeDidChange")

    /// Reconfigure theme during runtime for debug-only visual testing.
    public static func reconfigureForDebug(theme: any Theme) {
        let reconfiguredTheme = withLock { state -> (any Theme) in
            state.theme = theme
            state.isConfigured = true
            return state.theme
        }

        #if canImport(UIKit)
        DesignSystemAppearance.apply(using: reconfiguredTheme.tokens)
        #endif

        NotificationCenter.default.post(
            name: themeDidChangeNotification,
            object: nil
        )
    }

    // MARK: - Testing Support

    #if DEBUG
    /// Reset the design system for testing purposes only
    internal static func reset() {
        withLock { state in
            state.theme = AdaptiveTheme()
            state.isConfigured = false
        }
    }
    #endif

    private static func withLock<T>(_ operation: (Storage) throws -> T) rethrows -> T {
        lock.lock()
        defer { lock.unlock() }
        return try operation(storage)
    }
}
