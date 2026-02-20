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
            DSScreen(title: "Premium") {
                VStack(spacing: DSSpacing.lg) {
                    heroCard

                    if FeatureFlags.enablePurchases {
                        paywallContent

                        if viewModel.isProcessingPurchase {
                            ProgressView("Updating your access...")
                                .font(.bodySmall())
                                .foregroundStyle(Color.textSecondary)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
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

                    Text("Cancel anytime in Settings.")
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
            .fullScreenCover(isPresented: $viewModel.showPremiumUnlocked) {
                PremiumUnlockedView {
                    viewModel.showPremiumUnlocked = false
                    if showCloseButton {
                        dismiss()
                    }
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
        DSCard(tint: Color.surfaceVariant.opacity(0.7)) {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                HStack(alignment: .top) {
                    Image(systemName: "sparkles")
                        .font(.system(size: DSLayout.iconMedium, weight: .medium))
                        .foregroundStyle(Color.themePrimary)
                    Spacer()
                    Text("Premium")
                        .font(.captionLarge())
                        .foregroundStyle(Color.themePrimary)
                        .padding(.horizontal, DSSpacing.sm)
                        .padding(.vertical, DSSpacing.xs)
                        .background(Color.themePrimary.opacity(0.12), in: Capsule())
                }

                Text("Premium Studio")
                    .font(.headlineMedium())
                    .foregroundStyle(Color.themePrimary)

                Text("Unlock all features and take your app to the next level.")
                    .font(.bodySmall())
                    .foregroundStyle(Color.textSecondary)

                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    featureBullet(icon: "infinity", text: "Unlimited access")
                    featureBullet(icon: "arrow.triangle.2.circlepath", text: "Sync across devices")
                    featureBullet(icon: "headphones", text: "Priority support")
                }
                .padding(.top, DSSpacing.sm)
            }
        }
    }

    private func featureBullet(icon: String, text: String) -> some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: icon)
                .foregroundStyle(Color.themePrimary)
                .frame(width: DSLayout.iconSmall)
                .font(.system(size: 13))
            Text(text)
                .font(.bodySmall())
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
