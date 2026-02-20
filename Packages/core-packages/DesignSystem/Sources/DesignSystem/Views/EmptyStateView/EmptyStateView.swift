import SwiftUI

/// A view for displaying empty state messages when content is unavailable.
/// Use this for empty lists, search results with no matches, or when data hasn't been loaded yet.
public struct EmptyStateView: View {
    let icon: String?
    let title: String
    let message: String?
    let actionTitle: String?
    let action: (() -> Void)?

    public init(
        icon: String? = nil,
        title: String,
        message: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        VStack(spacing: DSSpacing.md) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 44, weight: .light))
                    .foregroundStyle(Color.textTertiary)
                    .accessibilityHidden(true)
            }

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

            if let actionTitle, let action {
                DSButton(title: actionTitle, size: .medium, action: action)
                    .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, DSSpacing.sm)
            }
        }
        .padding(DSSpacing.xl)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - View Modifier

public extension View {
    /// Overlays an empty state when the condition is true.
    /// - Parameters:
    ///   - isEmpty: Whether to show the empty state
    ///   - icon: Optional SF Symbol name
    ///   - title: The main title text
    ///   - message: Optional description message
    ///   - actionTitle: Optional button title
    ///   - action: Optional button action
    /// - Returns: The view with an empty state overlay when applicable.
    @ViewBuilder
    func emptyState(
        _ isEmpty: Bool,
        icon: String? = nil,
        title: String,
        message: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) -> some View {
        if isEmpty {
            EmptyStateView(
                icon: icon,
                title: title,
                message: message,
                actionTitle: actionTitle,
                action: action
            )
        } else {
            self
        }
    }
}

// MARK: - Convenience Initializers

public extension EmptyStateView {
    /// Creates an empty state for search results with no matches.
    static func noSearchResults(
        query: String? = nil,
        onClearSearch: (() -> Void)? = nil
    ) -> EmptyStateView {
        let message: String
        if let query {
            message = String(localized: "No results for \"\(query)\"", bundle: .module)
        } else {
            message = String(localized: "Try a different search term", bundle: .module)
        }
        return EmptyStateView(
            icon: "magnifyingglass",
            title: String(localized: "No Results Found", bundle: .module),
            message: message,
            actionTitle: onClearSearch != nil ? String(localized: "Clear Search", bundle: .module) : nil,
            action: onClearSearch
        )
    }

    /// Creates an empty state for an empty list.
    static func emptyList(
        title: String? = nil,
        message: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) -> EmptyStateView {
        EmptyStateView(
            icon: "tray",
            title: title ?? String(localized: "Nothing Here Yet", bundle: .module),
            message: message,
            actionTitle: actionTitle,
            action: action
        )
    }

    /// Creates an empty state for no favorites/bookmarks.
    static func noFavorites(
        onBrowse: (() -> Void)? = nil
    ) -> EmptyStateView {
        EmptyStateView(
            icon: "heart",
            title: String(localized: "No Favorites", bundle: .module),
            message: String(localized: "Items you favorite will appear here", bundle: .module),
            actionTitle: onBrowse != nil ? String(localized: "Browse Items", bundle: .module) : nil,
            action: onBrowse
        )
    }

    /// Creates an empty state for no notifications.
    static func noNotifications() -> EmptyStateView {
        EmptyStateView(
            icon: "bell",
            title: String(localized: "No Notifications", bundle: .module),
            message: String(localized: "You're all caught up!", bundle: .module)
        )
    }
}

// MARK: - Previews

#Preview("With Action") {
    EmptyStateView(
        icon: "folder",
        title: "No Documents",
        message: "Create your first document to get started",
        actionTitle: "Create Document",
        action: { print("Create tapped") }
    )
    .background(Color.backgroundPrimary)
}

#Preview("Without Action") {
    EmptyStateView(
        icon: "photo.on.rectangle.angled",
        title: "No Photos",
        message: "Photos you take will appear here"
    )
    .background(Color.backgroundPrimary)
}

#Preview("Minimal") {
    EmptyStateView(
        title: "No Data Available"
    )
    .background(Color.backgroundPrimary)
}

#Preview("Search Results") {
    EmptyStateView.noSearchResults(
        query: "Swift tutorials",
        onClearSearch: { print("Clear search") }
    )
    .background(Color.backgroundPrimary)
}

#Preview("Empty List") {
    EmptyStateView.emptyList(
        title: "No Tasks",
        message: "Add your first task to get started",
        actionTitle: "Add Task",
        action: { print("Add task") }
    )
    .background(Color.backgroundPrimary)
}

#Preview("View Modifier") {
    let isEmpty = true

    return List {
        Text("Item 1")
        Text("Item 2")
    }
    .emptyState(
        isEmpty,
        icon: "list.bullet",
        title: "No Items",
        message: "Add some items to see them here"
    )
}

#Preview("Dark Mode") {
    EmptyStateView(
        icon: "star",
        title: "No Favorites",
        message: "Items you star will appear here",
        actionTitle: "Browse",
        action: {}
    )
    .background(Color.backgroundPrimary)
    .preferredColorScheme(.dark)
}
