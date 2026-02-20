//
//  PaywallViewModelTests.swift
//  ForgeUnitTests
//
//  Unit tests for PaywallViewModel covering product loading, purchase flow, restore, entitlements, and edge cases.
//

import Testing
@testable import Forge
import CoreMock

@Suite("PaywallViewModel")
@MainActor
struct PaywallViewModelTests {

    // MARK: - Helpers

    private func makeContext() -> (AppServices, AppSession) {
        let services = AppServices(configuration: .mock(isSignedIn: true))
        let session = AppSession(keychain: MockKeychainCacheService())
        return (services, session)
    }

    // MARK: - Product Loading

    @Test("Load products populates product array")
    func loadProductsPopulatesProductArray() async {
        let (services, _) = makeContext()
        let viewModel = PaywallViewModel()

        await viewModel.loadProducts(services: services)

        #expect(!viewModel.products.isEmpty)
        #expect(viewModel.isLoadingProducts == false)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("Load products guards against double loading")
    func loadProductsGuardsAgainstDoubleLoading() async {
        let (services, _) = makeContext()
        let viewModel = PaywallViewModel()
        viewModel.isLoadingProducts = true

        await viewModel.loadProducts(services: services)
        // Should return early; products stay empty
        #expect(viewModel.products.isEmpty)
    }

    // MARK: - Purchase Flow

    @Test("Purchase updates entitlements and premium status")
    func purchaseUpdatesEntitlementsAndPremium() async {
        let (services, session) = makeContext()
        let viewModel = PaywallViewModel()

        // Load products first
        await viewModel.loadProducts(services: services)
        guard let productId = viewModel.products.first?.id else {
            Issue.record("No products loaded")
            return
        }

        await viewModel.purchase(productId: productId, services: services, session: session)

        #expect(viewModel.didUnlockPremium == true)
        #expect(session.isPremium == true)
        #expect(viewModel.isProcessingPurchase == false)
    }

    @Test("Purchase guards against double purchase")
    func purchaseGuardsAgainstDoublePurchase() async {
        let (services, session) = makeContext()
        let viewModel = PaywallViewModel()
        viewModel.isProcessingPurchase = true

        await viewModel.purchase(productId: "test", services: services, session: session)
        // Should return early
        #expect(viewModel.didUnlockPremium == false)
    }

    // MARK: - Restore Flow

    @Test("Restore purchases completes without error")
    func restorePurchasesReturnsEntitlements() async {
        let (services, session) = makeContext()
        let viewModel = PaywallViewModel()

        await viewModel.restorePurchases(services: services, session: session)

        #expect(viewModel.isProcessingPurchase == false)
        #expect(viewModel.toast != nil)
    }

    @Test("Restore guards against double restore")
    func restoreGuardsAgainstDoubleRestore() async {
        let (services, session) = makeContext()
        let viewModel = PaywallViewModel()
        viewModel.isProcessingPurchase = true

        await viewModel.restorePurchases(services: services, session: session)
        // Should return early, toast stays nil
        #expect(viewModel.toast == nil)
    }

    // MARK: - Entitlement Application

    @Test("Active entitlement unlocks premium via purchase")
    func activeEntitlementUnlocksPremium() async {
        let (services, session) = makeContext()
        let viewModel = PaywallViewModel()

        await viewModel.loadProducts(services: services)
        guard let productId = viewModel.products.first?.id else {
            Issue.record("No products loaded")
            return
        }

        // MockPurchaseService.purchase returns active entitlement
        await viewModel.purchase(productId: productId, services: services, session: session)
        #expect(viewModel.didUnlockPremium == true)
        #expect(session.isPremium == true)
    }

    @Test("Restore with no active entitlements does not unlock premium")
    func expiredEntitlementDoesNotUnlockPremium() async {
        let (services, session) = makeContext()
        let viewModel = PaywallViewModel()

        // MockPurchaseService returns empty entitlements by default for restore
        await viewModel.restorePurchases(services: services, session: session)
        #expect(viewModel.didUnlockPremium == false)
    }

    // MARK: - Error Handling

    @Test("Error message is nil on success path")
    func loadProductsWithSuccessClearsError() async {
        let (services, _) = makeContext()
        let viewModel = PaywallViewModel()

        await viewModel.loadProducts(services: services)
        #expect(viewModel.errorMessage == nil)
    }

    // MARK: - Edge Cases

    @Test("Initial state is clean")
    func initialStateIsClean() {
        let viewModel = PaywallViewModel()
        #expect(viewModel.products.isEmpty)
        #expect(viewModel.isLoadingProducts == false)
        #expect(viewModel.isProcessingPurchase == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.didUnlockPremium == false)
        #expect(viewModel.toast == nil)
    }

    @Test("Product IDs match EntitlementOption")
    func productIdsMatchEntitlementOptions() {
        let viewModel = PaywallViewModel()
        #expect(viewModel.productIds == EntitlementOption.allProductIds)
    }
}
