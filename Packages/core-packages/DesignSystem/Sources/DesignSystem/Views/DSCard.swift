import SwiftUI

/// A surface container for grouping content with consistent styling.
public struct DSCard<Content: View>: View {
    let cornerRadius: CGFloat
    let tint: Color
    let depth: DSCardDepth
    let content: Content

    public init(
        cornerRadius: CGFloat = DSRadii.xl,
        tint: Color = Color.surface,
        depth: DSCardDepth = .raised,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.tint = tint
        self.depth = depth
        self.content = content()
    }

    public var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        content
            .padding(DSSpacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(shape.fill(tint))
            .overlay(
                shape.stroke(Color.border.opacity(depth.borderOpacity), lineWidth: 1)
            )
            .shadow(
                color: depth.shadowColor,
                radius: depth.shadowRadius,
                x: 0,
                y: depth.shadowY
            )
    }
}

/// Controls the visual elevation of a DSCard.
public enum DSCardDepth {
    /// No shadow or border. Blends into the background.
    case flat
    /// Soft shadow, subtle border. Default.
    case raised
    /// Prominent shadow. For featured/elevated content.
    case elevated

    var shadowColor: Color {
        switch self {
        case .flat:     return .black.opacity(0.03)
        case .raised:   return DSShadows.soft.color
        case .elevated: return DSShadows.lifted.color
        }
    }

    var shadowRadius: CGFloat {
        switch self {
        case .flat:     return 4
        case .raised:   return DSShadows.soft.radius
        case .elevated: return DSShadows.lifted.radius
        }
    }

    var shadowY: CGFloat {
        switch self {
        case .flat:     return 2
        case .raised:   return DSShadows.soft.y
        case .elevated: return DSShadows.lifted.y
        }
    }

    var borderOpacity: Double {
        switch self {
        case .flat:     return 0.25
        case .raised:   return 0.4
        case .elevated: return 0.6
        }
    }
}

#Preview("DSCard Depths") {
    VStack(spacing: DSSpacing.lg) {
        DSCard(depth: .flat) {
            Text("Flat — no shadow").font(.bodyMedium()).foregroundStyle(Color.textPrimary)
        }
        DSCard(depth: .raised) {
            Text("Raised — default").font(.bodyMedium()).foregroundStyle(Color.textPrimary)
        }
        DSCard(depth: .elevated) {
            Text("Elevated — prominent").font(.bodyMedium()).foregroundStyle(Color.textPrimary)
        }
    }
    .padding()
    .background(Color.backgroundPrimary)
}
