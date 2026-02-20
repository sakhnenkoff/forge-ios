import SwiftUI

/// Spacing namespace for consistent layout values
public enum DSSpacing {
    /// Extra small spacing (default: 4pt)
    public static var xs: CGFloat { DesignSystem.spacing.xs }
    /// Small spacing (default: 8pt)
    public static var sm: CGFloat { DesignSystem.spacing.sm }
    /// Small-Medium spacing (default: 12pt)
    public static var smd: CGFloat { DesignSystem.spacing.smd }
    /// Medium spacing (default: 16pt)
    public static var md: CGFloat { DesignSystem.spacing.md }
    /// Medium-Large spacing (default: 20pt)
    public static var mlg: CGFloat { DesignSystem.spacing.mlg }
    /// Large spacing (default: 24pt)
    public static var lg: CGFloat { DesignSystem.spacing.lg }
    /// Extra large spacing (default: 32pt)
    public static var xl: CGFloat { DesignSystem.spacing.xl }
    /// 2X Large spacing (default: 40pt)
    public static var xxlg: CGFloat { DesignSystem.spacing.xxlg }
    /// Extra extra large spacing (default: 48pt)
    public static var xxl: CGFloat { DesignSystem.spacing.xxl }
}
