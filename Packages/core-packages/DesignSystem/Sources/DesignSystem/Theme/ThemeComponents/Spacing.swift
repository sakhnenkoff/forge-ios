import SwiftUI

/// Spacing scale for consistent layout
public struct SpacingScale: Sendable {

    /// Extra small: 4pt default
    public let xs: CGFloat

    /// Small: 8pt default
    public let sm: CGFloat

    /// Small-Medium: 12pt default
    public let smd: CGFloat

    /// Medium: 16pt default
    public let md: CGFloat

    /// Medium-Large: 20pt default
    public let mlg: CGFloat

    /// Large: 24pt default
    public let lg: CGFloat

    /// Extra large: 32pt default
    public let xl: CGFloat

    /// 2X Large: 40pt default
    public let xxlg: CGFloat

    /// Extra extra large: 48pt default
    public let xxl: CGFloat

    public init(
        xs: CGFloat = 4,
        sm: CGFloat = 8,
        smd: CGFloat = 12,
        md: CGFloat = 16,
        mlg: CGFloat = 20,
        lg: CGFloat = 24,
        xl: CGFloat = 32,
        xxlg: CGFloat = 40,
        xxl: CGFloat = 48
    ) {
        self.xs = xs
        self.sm = sm
        self.smd = smd
        self.md = md
        self.mlg = mlg
        self.lg = lg
        self.xl = xl
        self.xxlg = xxlg
        self.xxl = xxl
    }
}
