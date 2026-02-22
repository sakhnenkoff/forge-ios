import SwiftUI

/// Adds a fade-from-background gradient behind pinned bottom bars,
/// so scrolled content dissolves cleanly instead of being cut off.
public struct BottomFadeModifier: ViewModifier {
    let height: CGFloat

    public init(height: CGFloat = 100) {
        self.height = height
    }

    public func body(content: Content) -> some View {
        content
            .background(alignment: .bottom) {
                LinearGradient(
                    colors: [
                        Color.backgroundPrimary,
                        Color.backgroundPrimary.opacity(0)
                    ],
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(height: height)
                .ignoresSafeArea()
            }
    }
}

public extension View {
    /// Applies a fade-from-background gradient behind a pinned bottom bar.
    func bottomFade(height: CGFloat = 100) -> some View {
        modifier(BottomFadeModifier(height: height))
    }
}
