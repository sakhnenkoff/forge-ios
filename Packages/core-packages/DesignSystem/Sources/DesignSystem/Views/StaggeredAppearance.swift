import SwiftUI

// MARK: - Staggered Appearance Modifier

/// A modifier that animates content appearing with a staggered delay.
/// Each child element fades in and slides up in sequence.
public struct StaggeredAppearanceModifier: ViewModifier {
    let index: Int
    let baseDelay: Double
    let staggerDelay: Double
    let duration: Double
    @State private var hasAppeared = false

    public init(
        index: Int,
        baseDelay: Double = 0.1,
        staggerDelay: Double = 0.08,
        duration: Double = 0.4
    ) {
        self.index = index
        self.baseDelay = baseDelay
        self.staggerDelay = staggerDelay
        self.duration = duration
    }

    public func body(content: Content) -> some View {
        content
            .opacity(hasAppeared ? 1 : 0)
            .offset(y: hasAppeared ? 0 : 16)
            .onAppear {
                let delay = baseDelay + (staggerDelay * Double(index))
                withAnimation(.easeOut(duration: duration).delay(delay)) {
                    hasAppeared = true
                }
            }
    }
}

// MARK: - Staggered Container

/// A container that automatically staggers the appearance of its children.
/// Wrap your content elements and they'll fade in one after another.
public struct StaggeredVStack<Content: View>: View {
    let alignment: HorizontalAlignment
    let spacing: CGFloat?
    let baseDelay: Double
    let staggerDelay: Double
    let content: Content
    @State private var isVisible = false

    public init(
        alignment: HorizontalAlignment = .center,
        spacing: CGFloat? = nil,
        baseDelay: Double = 0.1,
        staggerDelay: Double = 0.08,
        @ViewBuilder content: () -> Content
    ) {
        self.alignment = alignment
        self.spacing = spacing
        self.baseDelay = baseDelay
        self.staggerDelay = staggerDelay
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: alignment, spacing: spacing) {
            content
        }
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.01)) {
                isVisible = true
            }
        }
    }
}

// MARK: - View Extension

public extension View {
    /// Applies staggered appearance animation based on index.
    /// Use with multiple sibling views to create cascading fade-in effect.
    ///
    /// - Parameters:
    ///   - index: The order of this element (0, 1, 2, etc.)
    ///   - baseDelay: Initial delay before first element appears
    ///   - staggerDelay: Delay between each element
    func staggeredAppearance(
        index: Int,
        baseDelay: Double = 0.1,
        staggerDelay: Double = 0.08
    ) -> some View {
        modifier(StaggeredAppearanceModifier(
            index: index,
            baseDelay: baseDelay,
            staggerDelay: staggerDelay
        ))
    }
}

// MARK: - Preview

#Preview("Staggered Appearance") {
    struct PreviewWrapper: View {
        @State private var showContent = false

        var body: some View {
            VStack(spacing: DSSpacing.lg) {
                if showContent {
                    Text("Welcome")
                        .font(.titleLarge())
                        .staggeredAppearance(index: 0)

                    Text("This is a subtitle with more info")
                        .font(.bodyMedium())
                        .foregroundStyle(Color.textSecondary)
                        .staggeredAppearance(index: 1)

                    RoundedRectangle(cornerRadius: DSRadii.lg)
                        .fill(Color.surfaceVariant)
                        .frame(height: 200)
                        .staggeredAppearance(index: 2)

                    DSButton(title: "Continue", style: .primary) {}
                        .staggeredAppearance(index: 3)
                }

                Button(showContent ? "Reset" : "Show") {
                    if showContent {
                        showContent = false
                    } else {
                        showContent = true
                    }
                }
            }
            .padding()
            .background(Color.backgroundPrimary)
        }
    }

    return PreviewWrapper()
}
