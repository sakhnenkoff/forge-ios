import SwiftUI

/// A selectable choice button for onboarding flows, surveys, and multi-select interfaces.
/// Displays a title, optional icon, and selection state with sketch-style aesthetics.
public struct DSChoiceButton: View {
    let title: String
    let icon: String?
    let isSelected: Bool
    let action: () -> Void

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
                // Leading icon with sketch style
                if let icon {
                    SketchIcon(
                        systemName: icon,
                        size: 18,
                        color: isSelected ? Color.themePrimary : Color.textSecondary
                    )
                    .frame(width: 24)
                }

                // Title
                Text(title)
                    .font(.bodyMedium())
                    .foregroundStyle(isSelected ? Color.textPrimary : Color.textSecondary)

                Spacer(minLength: DSSpacing.sm)

                // Selection indicator - simple dot
                Circle()
                    .fill(isSelected ? Color.themePrimary : Color.border)
                    .frame(width: 8, height: 8)
            }
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.smd)
            .frame(minHeight: DSLayout.listRowMinHeight)
            .background(isSelected ? Color.themePrimary.opacity(0.08) : Color.surface)
            .overlay(
                shape.stroke(
                    isSelected ? Color.themePrimary.opacity(0.3) : Color.border,
                    lineWidth: 1
                )
            )
            .clipShape(shape)
        }
        .buttonStyle(.plain)
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
