//
//  PremiumUnlockedView.swift
//  Forge
//
//

import SwiftUI
import DesignSystem

struct PremiumUnlockedView: View {
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: DSSpacing.xl) {
            Spacer()

            // Hero icon
            Image(systemName: "sparkles")
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(Color.themePrimary)

            // Confirmation text
            VStack(spacing: DSSpacing.sm) {
                Text("Welcome to Premium")
                    .font(.titleMedium())
                    .foregroundStyle(Color.textPrimary)
                    .multilineTextAlignment(.center)

                // TODO: Replace with your app's post-purchase message
                Text("Everything is unlocked. Enjoy the full experience.")
                    .font(.bodyMedium())
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: DSLayout.textMaxWidth)
            }

            Spacer()

            DSButton.cta(title: "Get started") {
                onDismiss()
            }
            .padding(.horizontal, DSSpacing.xl)
            .padding(.bottom, DSSpacing.lg)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundPrimary)
        // Auto-dismiss after 3 seconds if user doesn't tap "Get started"
        // TODO: Change to require explicit tap if you prefer user-controlled dismiss
        .task {
            try? await Task.sleep(for: .seconds(3))
            onDismiss()
        }
    }
}

#Preview {
    PremiumUnlockedView { }
}
