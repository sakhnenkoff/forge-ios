import SwiftUI

/// Adds a fade-from-background gradient behind pinned bottom bars,
/// so scrolled content dissolves cleanly instead of being cut off.
public struct BottomFadeModifier: ViewModifier {
    let height: CGFloat

    public init(height: CGFloat = 100) {
        self.height = height
    }

    public func body(content: Content) -> some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [
                    Color.backgroundPrimary.opacity(0),
                    Color.backgroundPrimary
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: height)

            content
                .padding(.vertical, DSSpacing.sm)
                .frame(maxWidth: .infinity)
                .background(Color.backgroundPrimary)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

public extension View {
    /// Applies a fade-from-background gradient behind a pinned bottom bar.
    func bottomFade(height: CGFloat = 100) -> some View {
        modifier(BottomFadeModifier(height: height))
    }
}
