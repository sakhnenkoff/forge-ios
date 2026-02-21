//
//  PaywallViewModel.swift
//  Forge
//
//
//

import SwiftUI
import StoreKit
import DesignSystem

@MainActor
@Observable
final class PaywallViewModel {
    let productIds = EntitlementOption.allProductIds

    var products: [AnyProduct] = []
    var isLoadingProducts = false
    var isProcessingPurchase = false
    var errorMessage: String?
    var didUnlockPremium = false
    var toast: Toast?

    func loadProducts(services: AppServices) async {
        guard FeatureFlags.enablePurchases else { return }
        guard let purchaseManager = services.purchaseManager else {
            errorMessage = "Purchases are disabled."
            return
        }

        guard !isLoadingProducts else { return }
        isLoadingProducts = true
        errorMessage = nil
        services.logManager.trackEvent(event: Event.loadProductsStart)
        do {
            products = try await purchaseManager.getProducts(productIds: productIds)
        } catch {
            errorMessage = error.localizedDescription
            services.logManager.trackEvent(event: Event.loadProductsFail(error: error))
        }
        isLoadingProducts = false
    }

    func restorePurchases(services: AppServices, session: AppSession) async {
        guard let purchaseManager = services.purchaseManager else {
            errorMessage = "Purchases are disabled."
            return
        }
        guard !isProcessingPurchase else { return }

        isProcessingPurchase = true
        errorMessage = nil
        services.logManager.trackEvent(event: Event.restoreStart)
        do {
            let entitlements = try await purchaseManager.restorePurchase()
            applyEntitlements(entitlements, session: session)
            services.logManager.trackEvent(event: Event.restoreSuccess)
            toast = .success("Restored your subscription.")
        } catch {
            toast = .error(error.localizedDescription)
            services.logManager.trackEvent(event: Event.restoreFail(error: error))
        }
        isProcessingPurchase = false
    }

    func purchase(productId: String, services: AppServices, session: AppSession) async {
        guard let purchaseManager = services.purchaseManager else {
            errorMessage = "Purchases are disabled."
            return
        }
        guard !isProcessingPurchase else { return }

        isProcessingPurchase = true
        errorMessage = nil
        services.logManager.trackEvent(event: Event.purchaseStart(productId: productId))
        do {
            let entitlements = try await purchaseManager.purchaseProduct(productId: productId)
            applyEntitlements(entitlements, session: session)
            services.logManager.trackEvent(event: Event.purchaseSuccess(productId: productId))
            toast = .success("You're all set! Premium is unlocked.")
        } catch {
            toast = .error(error.localizedDescription)
            services.logManager.trackEvent(event: Event.purchaseFail(productId: productId, error: error))
        }
        isProcessingPurchase = false
    }

    func onStoreKitPurchaseStart(product: StoreKit.Product, services: AppServices) {
        isProcessingPurchase = true
        let anyProduct = AnyProduct(storeKitProduct: product)
        services.logManager.trackEvent(event: Event.storeKitStart(product: anyProduct))
    }

    func onStoreKitPurchaseComplete(
        product: StoreKit.Product,
        result: Result<Product.PurchaseResult, any Error>,
        services: AppServices,
        session: AppSession
    ) {
        let anyProduct = AnyProduct(storeKitProduct: product)

        switch result {
        case .success(let value):
            switch value {
            case .success:
                didUnlockPremium = true
                session.updatePremiumStatus(entitlements: services.purchaseManager?.entitlements ?? [])
                services.logManager.trackEvent(event: Event.storeKitSuccess(product: anyProduct))
                toast = .success("You're all set! Premium is unlocked.")
            case .pending:
                services.logManager.trackEvent(event: Event.storeKitPending(product: anyProduct))
                toast = .info("Purchase pending approval.")
            case .userCancelled:
                services.logManager.trackEvent(event: Event.storeKitCancelled(product: anyProduct))
                toast = .info("Purchase cancelled.")
            default:
                services.logManager.trackEvent(event: Event.storeKitUnknown(product: anyProduct))
            }
        case .failure(let error):
            toast = .error(error.localizedDescription)
            services.logManager.trackEvent(event: Event.storeKitFail(product: anyProduct, error: error))
        }
        isProcessingPurchase = false
    }

    private func applyEntitlements(_ entitlements: [PurchasedEntitlement], session: AppSession) {
        session.updatePremiumStatus(entitlements: entitlements)
        if entitlements.hasActiveEntitlement {
            didUnlockPremium = true
        }
    }
}

extension PaywallViewModel {
    enum Event: LoggableEvent {
        case loadProductsStart
        case loadProductsFail(error: Error)
        case restoreStart
        case restoreSuccess
        case restoreFail(error: Error)
        case purchaseStart(productId: String)
        case purchaseSuccess(productId: String)
        case purchaseFail(productId: String, error: Error)
        case storeKitStart(product: AnyProduct)
        case storeKitSuccess(product: AnyProduct)
        case storeKitPending(product: AnyProduct)
        case storeKitCancelled(product: AnyProduct)
        case storeKitUnknown(product: AnyProduct)
        case storeKitFail(product: AnyProduct, error: Error)

        var eventName: String {
            switch self {
            case .loadProductsStart:
                return "Paywall_Load_Start"
            case .loadProductsFail:
                return "Paywall_Load_Fail"
            case .restoreStart:
                return "Paywall_Restore_Start"
            case .restoreSuccess:
                return "Paywall_Restore_Success"
            case .restoreFail:
                return "Paywall_Restore_Fail"
            case .purchaseStart:
                return "Paywall_Purchase_Start"
            case .purchaseSuccess:
                return "Paywall_Purchase_Success"
            case .purchaseFail:
                return "Paywall_Purchase_Fail"
            case .storeKitStart:
                return "Paywall_StoreKit_Start"
            case .storeKitSuccess:
                return "Paywall_StoreKit_Success"
            case .storeKitPending:
                return "Paywall_StoreKit_Pending"
            case .storeKitCancelled:
                return "Paywall_StoreKit_Cancelled"
            case .storeKitUnknown:
                return "Paywall_StoreKit_Unknown"
            case .storeKitFail:
                return "Paywall_StoreKit_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .purchaseStart(let productId),
                 .purchaseSuccess(let productId):
                return ["product_id": productId as Any]
            case .purchaseFail(let productId, let error):
                var params: [String: Any] = ["product_id": productId]
                params.merge(error.eventParameters) { _, new in new }
                return params
            case .storeKitStart(let product),
                 .storeKitSuccess(let product),
                 .storeKitPending(let product),
                 .storeKitCancelled(let product),
                 .storeKitUnknown(let product):
                return product.eventParameters
            case .storeKitFail(let product, let error):
                var params = product.eventParameters
                params.merge(error.eventParameters) { _, new in new }
                return params
            case .loadProductsFail(let error),
                 .restoreFail(let error):
                return error.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .loadProductsFail, .restoreFail, .purchaseFail, .storeKitFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
