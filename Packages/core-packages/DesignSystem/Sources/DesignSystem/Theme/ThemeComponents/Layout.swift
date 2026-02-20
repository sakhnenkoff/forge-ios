import SwiftUI

/// Layout scale for consistent sizing across screens
public struct LayoutScale: Sendable {
    public let cardMaxWidth: CGFloat
    public let cardCompactWidth: CGFloat
    public let textMaxWidth: CGFloat
    public let mediaHeight: CGFloat
    public let avatarLarge: CGFloat
    public let avatarSmall: CGFloat
    public let iconSmall: CGFloat
    public let iconMedium: CGFloat
    public let iconLarge: CGFloat
    public let listRowMinHeight: CGFloat

    public init(
        cardMaxWidth: CGFloat = 360,
        cardCompactWidth: CGFloat = 340,
        textMaxWidth: CGFloat = 260,
        mediaHeight: CGFloat = 160,
        avatarLarge: CGFloat = 68,
        avatarSmall: CGFloat = 44,
        iconSmall: CGFloat = 20,
        iconMedium: CGFloat = 22,
        iconLarge: CGFloat = 28,
        listRowMinHeight: CGFloat = 52
    ) {
        self.cardMaxWidth = cardMaxWidth
        self.cardCompactWidth = cardCompactWidth
        self.textMaxWidth = textMaxWidth
        self.mediaHeight = mediaHeight
        self.avatarLarge = avatarLarge
        self.avatarSmall = avatarSmall
        self.iconSmall = iconSmall
        self.iconMedium = iconMedium
        self.iconLarge = iconLarge
        self.listRowMinHeight = listRowMinHeight
    }
}
