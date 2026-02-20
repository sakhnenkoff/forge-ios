//
//  StoreKitPaywallView.swift
//  Forge
//
//
//

import SwiftUI
import StoreKit
import DesignSystem

struct StoreKitPaywallView: View {
    let productIds: [String] = EntitlementOption.allProductIds
    let onInAppPurchaseStart: ((Product) async -> Void)?
    let onInAppPurchaseCompletion: ((Product, Result<Product.PurchaseResult, any Error>) async -> Void)?

    var body: some View {
        SubscriptionStoreView(productIDs: productIds) {
            VStack(spacing: DSSpacing.sm) {
                Text("Premium")
                    .font(.titleLarge())
                    .foregroundStyle(Color.textPrimary)

                Text("Unlock premium templates and analytics.")
                    .font(.bodyMedium())
                    .foregroundStyle(Color.textSecondary)
            }
            .multilineTextAlignment(.center)
            .containerBackground(Color.backgroundSecondary, for: .subscriptionStore)
        }
        .storeButton(.hidden, for: .restorePurchases)
        .storeButton(.hidden, for: .policies)
        .subscriptionStoreControlStyle(.prominentPicker)
        .toolbar(.hidden, for: .navigationBar)
        .onInAppPurchaseStart(perform: onInAppPurchaseStart)
        .onInAppPurchaseCompletion(perform: onInAppPurchaseCompletion)
    }
}

#Preview {
    StoreKitPaywallView(
        onInAppPurchaseStart: nil,
        onInAppPurchaseCompletion: nil
    )
}
