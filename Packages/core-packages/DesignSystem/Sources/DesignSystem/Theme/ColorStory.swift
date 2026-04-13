import SwiftUI

/// Defines the color story for an app — the intentional palette beyond a single brand color.
///
/// `brand` and `surface` are required. `contrast` and `surprise` are optional:
/// - `contrast`: Required for data viz / multi-color references. Derived from `brand` if nil.
/// - `surprise`: Used sparingly for craft moments. Omit for single-accent apps.
public struct ColorStory: Sendable {
    public let brand: Color
    public let contrast: Color
    public let surprise: Color?
    public let surface: Color

    public init(
        brand: Color,
        contrast: Color? = nil,
        surprise: Color? = nil,
        surface: Color
    ) {
        self.brand = brand
        // Naive fallback — specify explicit contrast for muted or desaturated brand colors
        self.contrast = contrast ?? brand.opacity(0.7)
        self.surprise = surprise
        self.surface = surface
    }
}
