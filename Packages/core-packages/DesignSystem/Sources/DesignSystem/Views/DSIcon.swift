import SwiftUI

/// Standard icon sizes for the design system.
public enum DSIconSize {
    case small      // 12pt - toolbar close buttons, compact UI
    case medium     // 16pt - standard icons
    case large      // 20pt - prominent icons

    var fontSize: CGFloat {
        switch self {
        case .small: return 12
        case .medium: return 16
        case .large: return 20
        }
    }

    var weight: Font.Weight {
        switch self {
        case .small: return .semibold
        case .medium: return .medium
        case .large: return .medium
        }
    }
}

/// A standardized icon component for the design system.
/// Use for toolbar buttons, navigation, and UI elements that need consistent sizing.
public struct DSIcon: View {
    let systemName: String
    let size: DSIconSize
    let color: Color?

    public init(
        _ systemName: String,
        size: DSIconSize = .medium,
        color: Color? = nil
    ) {
        self.systemName = systemName
        self.size = size
        self.color = color
    }

    public var body: some View {
        Image(systemName: systemName)
            .font(.system(size: size.fontSize, weight: size.weight, design: .rounded))
            .foregroundStyle(color ?? Color.textSecondary)
    }
}

// MARK: - Convenience

public extension DSIcon {
    /// Close/dismiss icon for modals and sheets.
    static func close(size: DSIconSize = .small, color: Color? = nil) -> DSIcon {
        DSIcon("xmark", size: size, color: color)
    }

    /// Chevron for navigation.
    static func chevronRight(size: DSIconSize = .small, color: Color? = nil) -> DSIcon {
        DSIcon("chevron.right", size: size, color: color)
    }

    /// Back chevron for navigation.
    static func chevronLeft(size: DSIconSize = .small, color: Color? = nil) -> DSIcon {
        DSIcon("chevron.left", size: size, color: color)
    }
}

#Preview("DSIcon Sizes") {
    VStack(spacing: DSSpacing.md) {
        HStack(spacing: DSSpacing.lg) {
            DSIcon("xmark", size: .small)
            DSIcon("xmark", size: .medium)
            DSIcon("xmark", size: .large)
        }

        HStack(spacing: DSSpacing.lg) {
            DSIcon.close()
            DSIcon.chevronRight()
            DSIcon.chevronLeft()
        }

        HStack(spacing: DSSpacing.lg) {
            DSIcon("heart.fill", size: .small, color: .themePrimary)
            DSIcon("heart.fill", size: .medium, color: .themePrimary)
            DSIcon("heart.fill", size: .large, color: .themePrimary)
        }
    }
    .padding()
    .background(Color.backgroundPrimary)
}
