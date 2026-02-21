import SwiftUI

public struct GlassToggle: View {
    @Binding var isOn: Bool
    let onTint: Color
    let accessibilityLabel: String?

    public init(
        isOn: Binding<Bool>,
        onTint: Color = Color.themePrimary,
        accessibilityLabel: String? = nil
    ) {
        self._isOn = isOn
        self.onTint = onTint
        self.accessibilityLabel = accessibilityLabel
    }

    public var body: some View {
        let toggle = Toggle("", isOn: $isOn)
            .labelsHidden()
            .toggleStyle(.switch)
            .tint(onTint)
            .accessibilityValue(isOn ? "On" : "Off")

        if let accessibilityLabel {
            toggle.accessibilityLabel(accessibilityLabel)
        } else {
            toggle
        }
    }
}

#Preview("Glass Toggle") {
    VStack(spacing: DSSpacing.md) {
        GlassToggle(isOn: .constant(true))
        GlassToggle(isOn: .constant(false))
    }
    .padding()
    .background(Color.backgroundPrimary)
}
