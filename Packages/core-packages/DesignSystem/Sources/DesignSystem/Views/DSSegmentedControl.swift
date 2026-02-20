import SwiftUI

/// A SwiftUI-native segmented control with animated selection indicator.
public struct DSSegmentedControl<T: Hashable>: View {
    let items: [T]
    @Binding var selection: T
    let labelProvider: (T) -> String

    @Namespace private var namespace

    public init(
        items: [T],
        selection: Binding<T>,
        labelProvider: @escaping (T) -> String
    ) {
        self.items = items
        self._selection = selection
        self.labelProvider = labelProvider
    }

    public var body: some View {
        let outerRadius = DSRadii.lg
        let shape = RoundedRectangle(cornerRadius: outerRadius, style: .continuous)

        HStack(spacing: 0) {
            ForEach(items, id: \.self) { item in
                segmentButton(for: item)
            }
        }
        .padding(DSSpacing.sm)
        .background(shape.fill(Color.surface))
        .overlay(shape.stroke(Color.border, lineWidth: 1))
        .clipShape(shape)
        .sensoryFeedback(.selection, trigger: selection)
    }

    private func segmentButton(for item: T) -> some View {
        let isSelected = selection == item

        return Button {
            guard selection != item else { return }
            withAnimation(.spring(duration: 0.3, bounce: 0.15)) {
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
                        RoundedRectangle(cornerRadius: DSRadii.md)
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
    init(items: [String], selection: Binding<String>) {
        self.init(items: items, selection: selection) { $0 }
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
            }
            .padding()
            .background(Color.backgroundPrimary)
        }
    }

    return PreviewWrapper()
}
