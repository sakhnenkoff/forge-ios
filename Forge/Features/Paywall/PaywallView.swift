//
//  PaywallView.swift
//  Forge
//
//
//

import SwiftUI
import DesignSystem

struct PaywallView: View {
    @Environment(AppServices.self) private var services
    @Environment(AppSession.self) private var session
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = PaywallViewModel()

    let showCloseButton: Bool
    let allowSkip: Bool

    init(showCloseButton: Bool = false, allowSkip: Bool? = nil) {
        self.showCloseButton = showCloseButton
        self.allowSkip = allowSkip ?? !showCloseButton
    }

    var body: some View {
        NavigationStack {
            DSScreen(title: "Forge Pro", background: { AmbientBackground(intensity: 0.18) }) {
                VStack(spacing: DSSpacing.lg) {
                    heroCard

                    if FeatureFlags.enablePurchases {
                        paywallContent
                    } else {
                        EmptyStateView(
                            icon: "lock.slash",
                            title: "Purchases disabled",
                            message: "Enable purchases in FeatureFlags to preview the paywall.",
                            actionTitle: "Close",
                            action: { dismiss() }
                        )
                    }

                    if allowSkip {
                        DSButton(title: "Not now", style: .secondary, isFullWidth: true) {
                            session.markPaywallDismissed()
                        }
                    }

                    Text("Cancel anytime. No questions asked.")
                        .font(.captionLarge())
                        .foregroundStyle(Color.textTertiary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .toolbar {
                if showCloseButton {
                    ToolbarItem(placement: .topBarLeading) {
                        DSIconButton(icon: "xmark", style: .tertiary, size: .small, showsBackground: false, accessibilityLabel: "Close") {
                            dismiss()
                        }
                    }
                }
            }
            .toast($viewModel.toast)
            .task {
                await viewModel.loadProducts(services: services)
            }
            .onChange(of: viewModel.didUnlockPremium) { _, unlocked in
                if unlocked, showCloseButton {
                    dismiss()
                }
            }
        }
    }

    @ViewBuilder
    private var paywallContent: some View {
        if let errorMessage = viewModel.errorMessage {
            ErrorStateView(
                title: "Unable to load offers",
                message: errorMessage,
                retryTitle: "Try again",
                onRetry: {
                    Task {
                        await viewModel.loadProducts(services: services)
                    }
                }
            )
        } else if viewModel.isLoadingProducts {
            paywallSkeleton
        } else if viewModel.products.isEmpty {
            EmptyStateView(
                icon: "cart",
                title: "No offers available",
                message: "We couldn't load subscription options right now.",
                actionTitle: "Refresh",
                action: {
                    Task {
                        await viewModel.loadProducts(services: services)
                    }
                }
            )
        } else {
            CustomPaywallView(
                products: viewModel.products,
                isProcessing: viewModel.isProcessingPurchase,
                onRestorePurchasePressed: {
                    Task {
                        await viewModel.restorePurchases(services: services, session: session)
                    }
                },
                onPurchaseProductPressed: { product in
                    Task {
                        await viewModel.purchase(
                            productId: product.id,
                            services: services,
                            session: session
                        )
                    }
                }
            )
        }
    }

    private var heroCard: some View {
        DSHeroCard(usesGlass: true) {
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                HStack(alignment: .top) {
                    HeroIcon(systemName: "sparkles", size: DSLayout.avatarSmall, tint: Color.themePrimary, usesGlass: true)
                    Spacer()
                    TagBadge(text: "Pro", tint: Color.themePrimary)
                }

                Text("Forge Pro")
                    .font(.display())
                    .foregroundStyle(Color.themePrimary)

                Text("Unlock unlimited budgets, advanced analytics, and priority support.")
                    .font(.bodyMedium())
                    .foregroundStyle(Color.textSecondary)

                VStack(alignment: .leading, spacing: DSSpacing.md) {
                    featureBullet(icon: "infinity", text: "Unlimited budgets & categories")
                    featureBullet(icon: "chart.bar.xaxis", text: "Advanced spending analytics")
                    featureBullet(icon: "headphones", text: "Priority support")
                    featureBullet(icon: "bell.badge.fill", text: "Smart bill reminders")
                }
                .padding(.top, DSSpacing.sm)
            }
        }
    }

    private func featureBullet(icon: String, text: String) -> some View {
        HStack(spacing: DSSpacing.smd) {
            DSIconBadge(
                systemName: icon,
                size: 36,
                cornerRadius: 9,
                backgroundColor: Color.themePrimary.opacity(0.10),
                foregroundColor: Color.themePrimary,
                font: .system(size: 15, weight: .medium)
            )
            Text(text)
                .font(.bodyMedium())
                .foregroundStyle(Color.textSecondary)
            Spacer()
        }
    }

    private var paywallSkeleton: some View {
        VStack(spacing: DSSpacing.sm) {
            ForEach(0..<3, id: \.self) { _ in
                RoundedRectangle(cornerRadius: DSRadii.lg)
                    .fill(Color.surfaceVariant)
                    .frame(height: 80)
            }
        }
    }
}

#Preview {
    PaywallView(showCloseButton: true)
        .environment(AppServices(configuration: .mock(isSignedIn: true)))
        .environment(AppSession())
}
