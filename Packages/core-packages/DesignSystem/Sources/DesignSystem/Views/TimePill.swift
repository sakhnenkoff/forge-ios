import SwiftUI

/// A pill that displays a time value.
///
/// Supports two modes:
/// - Static: Display-only with a title string
/// - Interactive: Tappable with time picker sheet
public struct TimePill: View {
    private enum Mode {
        case staticTitle(String)
        case interactive(Binding<Date>)
    }

    private let mode: Mode
    let isHighlighted: Bool
    let usesGlass: Bool
    let showsAccessory: Bool
    let accessibilityLabel: String?
    @State private var isShowingPicker = false

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    /// Creates a static time pill for display only.
    public init(
        title: String,
        isHighlighted: Bool = true,
        usesGlass: Bool = false,
        showsAccessory: Bool = false,
        accessibilityLabel: String? = nil
    ) {
        self.mode = .staticTitle(title)
        self.isHighlighted = isHighlighted
        self.usesGlass = usesGlass
        self.showsAccessory = showsAccessory
        self.accessibilityLabel = accessibilityLabel
    }

    /// Creates an interactive time pill with time picker.
    public init(
        time: Binding<Date>,
        isHighlighted: Bool = true,
        usesGlass: Bool = false,
        showsAccessory: Bool = false,
        accessibilityLabel: String? = nil
    ) {
        self.mode = .interactive(time)
        self.isHighlighted = isHighlighted
        self.usesGlass = usesGlass
        self.showsAccessory = showsAccessory
        self.accessibilityLabel = accessibilityLabel
    }

    private var displayTitle: String {
        switch mode {
        case .staticTitle(let title):
            return title
        case .interactive(let binding):
            return Self.timeFormatter.string(from: binding.wrappedValue)
        }
    }

    private var isInteractive: Bool {
        if case .interactive = mode {
            return true
        }
        return false
    }

    public var body: some View {
        switch mode {
        case .staticTitle:
            pillContent
        case .interactive(let binding):
            Button {
                isShowingPicker = true
            } label: {
                pillContent
            }
            .buttonStyle(.plain)
            .contentShape(Capsule())
            .accessibilityLabel(accessibilityLabel ?? "Select time")
            .accessibilityValue(displayTitle)
            .sheet(isPresented: $isShowingPicker) {
                timePickerSheet(binding: binding)
            }
        }
    }

    private var pillContent: some View {
        let textContent = HStack(spacing: DSSpacing.xs) {
            Text(displayTitle)
                .font(.bodyMedium())
                .foregroundStyle(isHighlighted ? Color.themePrimary : Color.textSecondary)

            if showsAccessory {
                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color.textTertiary)
            }
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.smd)

        return Group {
            if usesGlass {
                let tint = isHighlighted ? Color.themePrimary.opacity(0.15) : DesignSystem.tokens.glass.tint

                if #available(iOS 26.0, *) {
                    let glass = Glass.regular.tint(tint)
                    let finalGlass = isInteractive ? glass.interactive() : glass

                    textContent
                        .glassEffect(finalGlass, in: .capsule)
                } else {
                    textContent
                        .background(Capsule().fill(Color.clear))
                        .glassSurface(
                            cornerRadius: DSRadii.pill,
                            tint: tint,
                            borderColor: .clear,
                            shadow: DSShadows.soft,
                            isInteractive: isInteractive,
                            shape: .capsule
                        )
                        .clipShape(Capsule())
                }
            } else {
                textContent
                    .background(Capsule().fill(isHighlighted ? Color.surface : Color.surfaceVariant))
                    .overlay(
                        Capsule().stroke(Color.themePrimary.opacity(0.2), lineWidth: 1)
                    )
            }
        }
    }

    private func timePickerSheet(binding: Binding<Date>) -> some View {
        NavigationStack {
            VStack(spacing: DSSpacing.xl) {
                DatePicker(
                    String(localized: "Time", bundle: .module),
                    selection: binding,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()

                DSButton(title: "Done", style: .primary) {
                    isShowingPicker = false
                }
            }
            .padding(DSSpacing.xl)
            .navigationTitle("Select Time")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

#Preview("Static TimePill") {
    VStack(spacing: DSSpacing.md) {
        TimePill(title: "17:00")
        TimePill(title: "08:30", isHighlighted: false)
        TimePill(title: "11:15", usesGlass: true)
        TimePill(title: "11:15", usesGlass: true, showsAccessory: true)
    }
    .padding()
    .background(Color.backgroundPrimary)
}

#Preview("Interactive TimePill") {
    struct PreviewWrapper: View {
        @State private var time = Date()

        var body: some View {
            VStack(spacing: DSSpacing.md) {
                TimePill(time: $time, accessibilityLabel: "Reminder time")
                TimePill(time: $time, usesGlass: true, accessibilityLabel: "Reminder time")
                TimePill(time: $time, usesGlass: true, showsAccessory: false, accessibilityLabel: "Reminder time")

                Text("Selected: \(time.formatted(date: .omitted, time: .shortened))")
                    .font(.bodySmall())
                    .foregroundStyle(Color.textSecondary)
            }
            .padding()
            .background(Color.backgroundPrimary)
        }
    }

    return PreviewWrapper()
}
