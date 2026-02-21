//
//  CustomPaywallView.swift
//  Forge
//
//

import SwiftUI
import DesignSystem

struct CustomPaywallView: View {
    let products: [AnyProduct]
    let isProcessing: Bool
    let onRestorePurchasePressed: () -> Void
    let onPurchaseProductPressed: (AnyProduct) -> Void

    @State private var selectedInterval: String = "Annual"

    private static let intervals = ["Monthly", "Annual"]

    init(
        products: [AnyProduct] = [],
        isProcessing: Bool = false,
        onRestorePurchasePressed: @escaping () -> Void = { },
        onPurchaseProductPressed: @escaping (AnyProduct) -> Void = { _ in }
    ) {
        self.products = products
        self.isProcessing = isProcessing
        self.onRestorePurchasePressed = onRestorePurchasePressed
        self.onPurchaseProductPressed = onPurchaseProductPressed
    }

    // MARK: - Computed Product Grouping

    private var subscriptionProducts: [AnyProduct] {
        products.filter { product in
            product.id == EntitlementOption.monthly.productId
                || product.id == EntitlementOption.annual.productId
        }
    }

    private var lifetimeProduct: AnyProduct? {
        products.first { $0.id == EntitlementOption.lifetime.productId }
    }

    private var selectedSubscriptionProduct: AnyProduct? {
        let targetId = selectedInterval == "Annual"
            ? EntitlementOption.annual.productId
            : EntitlementOption.monthly.productId
        return subscriptionProducts.first { $0.id == targetId }
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.lg) {
            // Subscription zone
            if !subscriptionProducts.isEmpty {
                subscriptionSection
            }

            // Lifetime zone (only if product exists)
            if let lifetimeProduct {
                lifetimeDivider
                lifetimeSection(lifetimeProduct)
            }

            // CTA purchases the selected subscription
            DSButton.cta(
                title: "Start Pro",
                isLoading: isProcessing,
                isEnabled: selectedSubscriptionProduct != nil
            ) {
                if let product = selectedSubscriptionProduct {
                    onPurchaseProductPressed(product)
                }
            }

            DSButton.link(title: "Restore purchase", action: onRestorePurchasePressed)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    // MARK: - Subscription Section

    private var subscriptionSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Choose your plan")
                .font(.headlineMedium())
                .foregroundStyle(Color.textPrimary)

            // Monthly / Annual toggle
            DSSegmentedControl(
                items: Self.intervals,
                selection: $selectedInterval
            )

            // Selected subscription card
            if let product = selectedSubscriptionProduct {
                planCard(product, isFeatured: selectedInterval == "Annual")
            }
        }
        .disabled(isProcessing)
    }

    // MARK: - Lifetime Section

    private var lifetimeDivider: some View {
        HStack(spacing: DSSpacing.sm) {
            Rectangle()
                .fill(Color.divider)
                .frame(height: 1)
            Text("Or pay once, own forever")
                .font(.captionLarge())
                .foregroundStyle(Color.textTertiary)
                .fixedSize()
            Rectangle()
                .fill(Color.divider)
                .frame(height: 1)
        }
    }

    private func lifetimeSection(_ product: AnyProduct) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            planCard(product, isFeatured: false)

            DSButton.cta(
                title: "Get lifetime access",
                isLoading: isProcessing,
                isEnabled: !isProcessing
            ) {
                onPurchaseProductPressed(product)
            }
        }
        .disabled(isProcessing)
    }

    // MARK: - Plan Card

    private func planCard(_ product: AnyProduct, isFeatured: Bool) -> some View {
        DSCard(tint: Color.surfaceVariant.opacity(0.7), depth: .raised) {
            VStack(alignment: .leading, spacing: DSSpacing.smd) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                        Text(product.title)
                            .font(.headlineMedium())
                            .foregroundStyle(Color.textPrimary)
                        Text(product.subtitle)
                            .font(.bodySmall())
                            .foregroundStyle(Color.textSecondary)
                    }
                    Spacer()
                    if isFeatured {
                        Text("Best value")
                            .font(.captionLarge())
                            .foregroundStyle(Color.themePrimary)
                            .padding(.horizontal, DSSpacing.sm)
                            .padding(.vertical, DSSpacing.xs)
                            .background(Color.themePrimary.opacity(0.12), in: Capsule())
                    }
                }

                Text(product.priceStringWithDuration)
                    .font(.headlineSmall())
                    .foregroundStyle(Color.themePrimary)
                    .padding(.horizontal, DSSpacing.md)
                    .padding(.vertical, DSSpacing.sm)
                    .background(Color.themePrimary.opacity(0.08), in: Capsule())
                    .overlay(Capsule().stroke(Color.themePrimary.opacity(0.15), lineWidth: 1))
            }
        }
    }
}

#Preview {
    CustomPaywallView(products: AnyProduct.mocks)
}
