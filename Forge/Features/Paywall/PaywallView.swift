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
            DSScreen(title: "Forge Pro", background: { AmbientBackground(intensity: 0.18) }, content: {
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

                    if FeatureFlags.enablePurchases && !viewModel.products.isEmpty {
                        DSButton.link(title: "Restore purchase") {
                            Task {
                                await viewModel.restorePurchases(services: services, session: session)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }

                    Text("Cancel anytime. No questions asked.")
                        .font(.captionLarge())
                        .foregroundStyle(Color.textTertiary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            })
            .safeAreaInset(edge: .bottom) {
                if FeatureFlags.enablePurchases && !viewModel.products.isEmpty && viewModel.errorMessage == nil {
                    DSButton.cta(
                        title: "Start Pro",
                        isLoading: viewModel.isProcessingPurchase,
                        isEnabled: viewModel.selectedProduct != nil
                    ) {
                        if let product = viewModel.selectedProduct {
                            Task {
                                await viewModel.purchase(
                                    productId: product.id,
                                    services: services,
                                    session: session
                                )
                            }
                        }
                    }
                    .padding(.horizontal, DSSpacing.xl)
                    .bottomFade(height: 60)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    DSIconButton(icon: "xmark", style: .tertiary, size: .small, showsBackground: false, accessibilityLabel: "Close") {
                        if allowSkip {
                            session.markPaywallDismissed()
                        }
                        dismiss()
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
                selectedProductId: $viewModel.selectedProductId
            )
        }
    }

    private var heroCard: some View {
        DSHeroCard(usesGlass: true) {
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                HStack(alignment: .top) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(Color.themePrimary)
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
