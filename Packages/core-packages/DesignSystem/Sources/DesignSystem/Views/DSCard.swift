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
    /// No shadow. Blends into the background.
    case flat
    /// Soft shadow. Default.
    case raised
    /// Prominent shadow. For featured/elevated content.
    case elevated

    var shadowColor: Color {
        switch self {
        case .flat:     return .clear
        case .raised:   return DSShadows.card.color
        case .elevated: return DSShadows.lifted.color
        }
    }

    var shadowRadius: CGFloat {
        switch self {
        case .flat:     return 0
        case .raised:   return DSShadows.card.radius
        case .elevated: return DSShadows.lifted.radius
        }
    }

    var shadowY: CGFloat {
        switch self {
        case .flat:     return 0
        case .raised:   return DSShadows.card.y
        case .elevated: return DSShadows.lifted.y
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
