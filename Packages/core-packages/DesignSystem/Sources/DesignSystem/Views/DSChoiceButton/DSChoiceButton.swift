import SwiftUI

/// A selectable choice button for onboarding flows, surveys, and multi-select interfaces.
/// Displays a title, optional icon, and selection state with sketch-style aesthetics.
public struct DSChoiceButton: View {
    let title: String
    let icon: String?
    let isSelected: Bool
    let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled
    @State private var tapCount = 0

    public init(
        title: String,
        icon: String? = nil,
        isSelected: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        Button {
            tapCount += 1
            action()
        } label: {
            let shape = RoundedRectangle(cornerRadius: DSRadii.md, style: .continuous)

            HStack(spacing: DSSpacing.smd) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(isSelected ? Color.themePrimary : Color.textSecondary)
                        .frame(width: 36, height: 36)
                        .background(
                            (isSelected ? Color.themePrimary.opacity(0.12) : Color.surfaceVariant)
                        , in: RoundedRectangle(cornerRadius: DSRadii.xs, style: .continuous))
                }

                Text(title)
                    .font(.bodyMedium())
                    .foregroundStyle(isSelected ? Color.textPrimary : Color.textSecondary)

                Spacer(minLength: DSSpacing.sm)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(isSelected ? Color.themePrimary : Color.border)
            }
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.smd)
            .frame(minHeight: DSLayout.listRowMinHeight)
            .background(isSelected ? Color.themePrimary.opacity(0.05) : Color.surface)
            .clipShape(shape)
            .shadow(
                color: isSelected ? DSShadows.soft.color : .clear,
                radius: DSShadows.soft.radius,
                x: 0,
                y: DSShadows.soft.y
            )
        }
        .buttonStyle(.plain)
        .opacity(isEnabled ? 1.0 : 0.4)
        .accessibilityValue(Text(String(localized: isSelected ? "Selected" : "Not selected", bundle: .module)))
        .sensoryFeedback(.selection, trigger: tapCount)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Previews

#Preview("Choice Buttons") {
    VStack(spacing: DSSpacing.sm) {
        DSChoiceButton(
            title: "Launch fast",
            icon: "paperplane.fill",
            isSelected: true
        ) {}

        DSChoiceButton(
            title: "Monetize",
            icon: "creditcard.fill",
            isSelected: false
        ) {}

        DSChoiceButton(
            title: "Measure growth",
            icon: "chart.line.uptrend.xyaxis",
            isSelected: true
        ) {}

        DSChoiceButton(
            title: "Simple option",
            isSelected: false
        ) {}
    }
    .padding()
    .background(Color.backgroundPrimary)
}

#Preview("Dark Mode") {
    VStack(spacing: DSSpacing.sm) {
        DSChoiceButton(
            title: "Selected Option",
            icon: "star.fill",
            isSelected: true
        ) {}

        DSChoiceButton(
            title: "Unselected Option",
            icon: "heart.fill",
            isSelected: false
        ) {}
    }
    .padding()
    .background(Color.backgroundPrimary)
    .preferredColorScheme(.dark)
}
