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

    @State private var selectedProductId: String?

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

    private var selectedProduct: AnyProduct? {
        guard let selectedProductId else { return subscriptionProducts.last }
        return subscriptionProducts.first { $0.id == selectedProductId }
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.lg) {
            if !subscriptionProducts.isEmpty {
                subscriptionSection
            }

            if let lifetimeProduct {
                lifetimeDivider
                lifetimeSection(lifetimeProduct)
            }

            Spacer()
                .frame(height: DSSpacing.sm)

            DSButton.cta(
                title: "Start Pro",
                isLoading: isProcessing,
                isEnabled: selectedProduct != nil
            ) {
                if let product = selectedProduct {
                    onPurchaseProductPressed(product)
                }
            }

            DSButton.link(title: "Restore purchase", action: onRestorePurchasePressed)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .onAppear {
            if selectedProductId == nil {
                selectedProductId = subscriptionProducts.first { $0.id == EntitlementOption.annual.productId }?.id
                    ?? subscriptionProducts.first?.id
            }
        }
    }

    // MARK: - Subscription Section

    private var subscriptionSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.smd) {
            Text("Choose your plan")
                .font(.headlineMedium())
                .foregroundStyle(Color.textPrimary)

            VStack(spacing: DSSpacing.sm) {
                ForEach(subscriptionProducts, id: \.id) { product in
                    let isSelected = selectedProduct?.id == product.id
                    let isAnnual = product.id == EntitlementOption.annual.productId
                    selectablePlanCard(product, isSelected: isSelected, isFeatured: isAnnual)
                }
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

    // MARK: - Selectable Plan Card

    private func selectablePlanCard(_ product: AnyProduct, isSelected: Bool, isFeatured: Bool) -> some View {
        Button {
            withAnimation(.smooth(duration: 0.25)) {
                selectedProductId = product.id
            }
        } label: {
            DSCard(
                tint: isSelected ? Color.themePrimary.opacity(0.06) : Color.surface,
                depth: .raised
            ) {
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
                            TagBadge(text: "Best value", tint: Color.themePrimary)
                        }
                    }

                    Text(product.priceStringWithDuration)
                        .font(.titleMedium())
                        .foregroundStyle(Color.themePrimary)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: DSRadii.xl, style: .continuous)
                    .stroke(isSelected ? Color.themePrimary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Plan Card (non-selectable, for lifetime)

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
                        TagBadge(text: "Best value", tint: Color.themePrimary)
                    }
                }

                Text(product.priceStringWithDuration)
                    .font(.titleMedium())
                    .foregroundStyle(Color.themePrimary)
            }
        }
    }
}

#Preview {
    CustomPaywallView(products: AnyProduct.mocks)
}
