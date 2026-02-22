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
    @Binding var selectedProductId: String?

    init(
        products: [AnyProduct] = [],
        isProcessing: Bool = false,
        selectedProductId: Binding<String?>
    ) {
        self.products = products
        self.isProcessing = isProcessing
        self._selectedProductId = selectedProductId
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

            // Lifetime section hidden for now
            // if let lifetimeProduct {
            //     lifetimeDivider
            //     lifetimeSection(lifetimeProduct)
            // }
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
                depth: isSelected ? .elevated : .raised
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
                        .font(.titleLarge())
                        .foregroundStyle(Color.themePrimary)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: DSRadii.xl, style: .continuous)
                    .stroke(isSelected ? Color.themePrimary : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .opacity(isSelected ? 1.0 : 0.7)
            .animation(.smooth(duration: 0.25), value: isSelected)
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
    @Previewable @State var selectedId: String?
    CustomPaywallView(products: AnyProduct.mocks, selectedProductId: $selectedId)
}
