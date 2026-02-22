//
//  OnboardingHeader.swift
//  Forge
//
//

import SwiftUI
import DesignSystem

/// A reusable header for onboarding flows with progress bar and back button.
struct OnboardingHeader: View {
    let progress: Double
    let showBackButton: Bool
    let onBack: () -> Void

    init(
        progress: Double,
        showBackButton: Bool = true,
        onBack: @escaping () -> Void
    ) {
        self.progress = progress
        self.showBackButton = showBackButton
        self.onBack = onBack
    }

    var body: some View {
        HStack(spacing: DSSpacing.smd) {
            if showBackButton {
                DSIconButton(
                    icon: "chevron.left",
                    style: .tertiary,
                    size: .small,
                    accessibilityLabel: "Back",
                    action: onBack
                )
            }

            ProgressView(value: progress)
                .tint(Color.themePrimary)
                .progressViewStyle(.linear)
                .frame(height: 4)
                .background(Color.surfaceVariant.opacity(0.6))
                .clipShape(Capsule())
                .animation(.easeInOut(duration: 0.3), value: progress)
        }
        .padding(.horizontal, DSSpacing.lg)
        .padding(.vertical, DSSpacing.md)
    }
}

#Preview("Progress States") {
    VStack(spacing: DSSpacing.lg) {
        OnboardingHeader(progress: 0.33, showBackButton: false) {}
        OnboardingHeader(progress: 0.66, showBackButton: true) {}
        OnboardingHeader(progress: 1.0, showBackButton: true) {}
    }
    .background(Color.backgroundPrimary)
}

#Preview("Dark Mode") {
    VStack(spacing: DSSpacing.lg) {
        OnboardingHeader(progress: 0.5, showBackButton: true) {}
    }
    .background(Color.backgroundPrimary)
    .preferredColorScheme(.dark)
}
