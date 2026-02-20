import SwiftUI

/// A custom boolean toggle with two side-by-side pills.
///
/// On state (right pill) displays a filled icon, off state (left pill) displays a dot indicator.
/// Both pills are contained in a single rounded container with a subtle border.
public struct DSPillToggle: View {
    @Binding var isOn: Bool
    let icon: String
    let accessibilityLabel: String?

    public init(
        isOn: Binding<Bool>,
        icon: String = "checkmark",
        usesGlass: Bool = false,
        accessibilityLabel: String? = nil
    ) {
        self._isOn = isOn
        self.icon = icon
        self.accessibilityLabel = accessibilityLabel
    }

    public var body: some View {
        let pillSize: CGFloat = 44
        let iconSize: CGFloat = 18
        let dotSize: CGFloat = 10
        let padding = DSSpacing.sm
        let outerRadius = (pillSize + padding * 2) / 2
        let shape = RoundedRectangle(cornerRadius: outerRadius, style: .continuous)
        let selectionShape = RoundedRectangle(cornerRadius: DSRadii.md, style: .continuous)

        HStack(spacing: 0) {
            // Off pill (dot) — left
            Button {
                guard isOn else { return }
                withAnimation(.spring(duration: 0.35, bounce: 0.2)) { isOn = false }
            } label: {
                Circle()
                    .fill(isOn ? Color.textSecondary : Color.themePrimary)
                    .frame(width: dotSize, height: dotSize)
                    .frame(width: pillSize, height: pillSize)
            }
            .buttonStyle(.plain)
            .accessibilityHidden(true)

            // On pill (icon) — right
            Button {
                guard !isOn else { return }
                withAnimation(.spring(duration: 0.35, bounce: 0.2)) { isOn = true }
            } label: {
                Image(systemName: icon)
                    .font(.system(size: iconSize, weight: .medium))
                    .foregroundStyle(isOn ? Color.textOnPrimary : Color.textTertiary)
                    .frame(width: pillSize, height: pillSize)
            }
            .buttonStyle(.plain)
            .accessibilityHidden(true)
        }
        .background(alignment: .leading) {
            selectionShape
                .fill(isOn ? Color.themePrimary : Color.surfaceVariant.opacity(0.5))
                .frame(width: pillSize, height: pillSize)
                .offset(x: isOn ? pillSize : 0)
        }
        .padding(padding)
        .background(shape.fill(Color.surface))
        .overlay(shape.stroke(Color.border, lineWidth: 1))
        .sensoryFeedback(.selection, trigger: isOn)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(resolvedAccessibilityLabel)
        .accessibilityValue(isOn ? "On" : "Off")
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { isOn.toggle() }
    }

    private var resolvedAccessibilityLabel: String {
        if let accessibilityLabel {
            return accessibilityLabel
        }

        var label = icon
        if label.hasSuffix(".fill") {
            label = String(label.dropLast(5))
        }
        label = label.replacingOccurrences(of: ".", with: " ")
        return label.capitalized
    }
}

#Preview("DSPillToggle") {
    struct PreviewWrapper: View {
        @State private var isOn = true

        var body: some View {
            VStack(spacing: DSSpacing.md) {
                DSPillToggle(isOn: $isOn, icon: "leaf.fill", accessibilityLabel: "Environment mode")
                DSPillToggle(isOn: .constant(false), icon: "bell.fill")
                DSPillToggle(isOn: .constant(true), icon: "heart.fill")
            }
            .padding()
            .background(Color.backgroundPrimary)
        }
    }

    return PreviewWrapper()
}
