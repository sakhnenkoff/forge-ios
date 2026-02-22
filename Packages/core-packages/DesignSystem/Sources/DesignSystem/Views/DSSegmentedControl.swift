import SwiftUI

/// A custom segmented control that matches the design system.
///
/// Features an underline indicator that animates between segments.
public struct DSSegmentedControl<T: Hashable>: View {
    let items: [T]
    @Binding var selection: T
    let labelProvider: (T) -> String
    let usesGlass: Bool

    @Namespace private var namespace

    public init(
        items: [T],
        selection: Binding<T>,
        usesGlass: Bool = true,
        labelProvider: @escaping (T) -> String
    ) {
        self.items = items
        self._selection = selection
        self.usesGlass = usesGlass
        self.labelProvider = labelProvider
    }

    /// Concentric inner radius: outerRadius - padding between outer edge and inner pill.
    private static var innerRadius: CGFloat {
        max(DSRadii.lg - DSSpacing.sm, 0)
    }

    public var body: some View {
        let outerRadius = DSRadii.lg
        let shape = RoundedRectangle(cornerRadius: outerRadius, style: .continuous)
        let base = HStack(spacing: 0) {
            ForEach(items, id: \.self) { item in
                segmentButton(for: item)
            }
        }
        .padding(DSSpacing.sm)
        .background(shape.fill(usesGlass ? Color.clear : Color.surface))
        .clipShape(shape)

        Group {
            if usesGlass {
                if #available(iOS 26.0, *) {
                    let glass = Glass.regular.tint(DesignSystem.tokens.glass.tint).interactive()
                    base.glassEffect(glass, in: .rect(cornerRadius: outerRadius))
                } else {
                    base
                        .background(shape.fill(Color.surface))
                        .overlay(shape.stroke(Color.border, lineWidth: 1))
                        .shadow(color: DSShadows.soft.color, radius: DSShadows.soft.radius, x: 0, y: DSShadows.soft.y)
                }
            } else {
                base
                    .overlay(shape.stroke(Color.border, lineWidth: 1))
            }
        }
        .sensoryFeedback(.selection, trigger: selection)
    }

    private func segmentButton(for item: T) -> some View {
        let isSelected = selection == item
        let pillShape = RoundedRectangle(cornerRadius: Self.innerRadius, style: .continuous)

        return Button {
            guard selection != item else { return }
            withAnimation(.smooth(duration: 0.35)) {
                selection = item
            }
        } label: {
            Text(labelProvider(item))
                .font(.bodySmall())
                .foregroundStyle(isSelected ? Color.textOnPrimary : Color.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DSSpacing.smd)
                .background {
                    if isSelected {
                        pillShape
                            .fill(Color.themePrimary)
                            .matchedGeometryEffect(id: "indicator", in: namespace)
                    }
                }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - String Convenience

public extension DSSegmentedControl where T == String {
    init(items: [String], selection: Binding<String>, usesGlass: Bool = true) {
        self.init(items: items, selection: selection, usesGlass: usesGlass) { $0 }
    }
}

#Preview("DSSegmentedControl") {
    struct PreviewWrapper: View {
        @State private var selection = "Daily"

        var body: some View {
            VStack(spacing: DSSpacing.xl) {
                DSSegmentedControl(
                    items: ["Daily", "Weekly", "Monthly"],
                    selection: $selection
                )
                Text("Selected: \(selection)")
                    .font(.bodyMedium())
                    .foregroundStyle(Color.textSecondary)
            }
            .padding()
            .background(Color.backgroundPrimary)
        }
    }

    return PreviewWrapper()
}
