import SwiftUI

public struct DSScreen<Content: View, Background: View>: View {
    private let title: String?
    private let titleDisplayMode: NavigationBarItem.TitleDisplayMode
    private let contentPadding: CGFloat
    private let topPadding: CGFloat
    private let showsIndicators: Bool
    private let bounceBehavior: ScrollBounceBehavior
    private let scrollDismissesKeyboard: ScrollDismissesKeyboardMode?
    private let background: Background
    private let content: Content

    public init(
        title: String? = nil,
        titleDisplayMode: NavigationBarItem.TitleDisplayMode = .inline,
        contentPadding: CGFloat = DSSpacing.md,
        topPadding: CGFloat = 0,
        showsIndicators: Bool = false,
        bounceBehavior: ScrollBounceBehavior = .basedOnSize,
        scrollDismissesKeyboard: ScrollDismissesKeyboardMode? = nil,
        @ViewBuilder background: () -> Background = { AmbientBackground() },
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.titleDisplayMode = titleDisplayMode
        self.contentPadding = contentPadding
        self.topPadding = topPadding
        self.showsIndicators = showsIndicators
        self.bounceBehavior = bounceBehavior
        self.scrollDismissesKeyboard = scrollDismissesKeyboard
        self.background = background()
        self.content = content()
    }

    public var body: some View {
        scrollContainer
            .background(background)
            .modifier(DSNavigationTitleModifier(title: title, displayMode: titleDisplayMode))
    }

    @ViewBuilder
    private var scrollContainer: some View {
        if let scrollDismissesKeyboard {
            ScrollView {
                content
                    .padding(contentPadding)
                    .padding(.top, topPadding)
            }
            .scrollIndicators(showsIndicators ? .visible : .hidden)
            .scrollBounceBehavior(bounceBehavior)
            .scrollDismissesKeyboard(scrollDismissesKeyboard)
        } else {
            ScrollView {
                content
                    .padding(contentPadding)
                    .padding(.top, topPadding)
            }
            .scrollIndicators(showsIndicators ? .visible : .hidden)
            .scrollBounceBehavior(bounceBehavior)
        }
    }
}

private struct DSNavigationTitleModifier: ViewModifier {
    let title: String?
    let displayMode: NavigationBarItem.TitleDisplayMode

    func body(content: Content) -> some View {
        if let title {
            content
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(displayMode)
        } else {
            content
        }
    }
}
