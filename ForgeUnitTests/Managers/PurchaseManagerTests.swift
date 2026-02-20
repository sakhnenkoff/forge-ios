//
//  PurchaseManagerTests.swift
//  ForgeUnitTests
//
//  Unit tests for PurchaseManager covering product fetch, purchase, restore, login, logout, and error handling.
//

import Testing
@testable import Forge

@Suite("PurchaseManager")
@MainActor
struct PurchaseManagerTests {

    // MARK: - Happy Paths

    @Test("Get products returns products for given IDs")
    func getProductsReturnsProducts() async throws {
        let service = MockPurchaseService()
        let manager = PurchaseManager(service: service)

        let products = try await manager.getProducts(productIds: ["mock.monthly", "mock.yearly"])
        #expect(products.count == 2)
        #expect(products[0].id == "mock.monthly")
        #expect(products[1].id == "mock.yearly")
    }

    @Test("Purchase product updates entitlements")
    func purchaseProductUpdatesEntitlements() async throws {
        let service = MockPurchaseService()
        let manager = PurchaseManager(service: service)

        let entitlements = try await manager.purchaseProduct(productId: "com.forge.monthly")
        #expect(entitlements.count == 1)
        #expect(entitlements[0].isActive == true)
        #expect(manager.entitlements.count == 1)
        #expect(manager.entitlements[0].productId == "com.forge.monthly")
    }

    @Test("Restore purchase returns entitlements")
    func restorePurchaseReturnsEntitlements() async throws {
        let activeEntitlement = TestEntitlement.active()
        let service = MockPurchaseService(entitlements: [activeEntitlement])
        let manager = PurchaseManager(service: service)

        let restored = try await manager.restorePurchase()
        #expect(restored.count == 1)
        #expect(restored[0].isActive == true)
        #expect(manager.entitlements.count == 1)
    }

    @Test("Log in returns entitlements")
    func logInReturnsEntitlements() async throws {
        let service = MockPurchaseService()
        let manager = PurchaseManager(service: service)

        let entitlements = try await manager.logIn(
            userId: "test-user",
            userAttributes: PurchaseProfileAttributes(email: "test@example.com", mixpanelDistinctId: nil, firebaseAppInstanceId: nil)
        )
        // MockPurchaseService returns empty entitlements for logIn
        #expect(entitlements.isEmpty)
    }

    @Test("Log out clears entitlements")
    func logOutClearsEntitlements() async throws {
        let activeEntitlement = TestEntitlement.active()
        let service = MockPurchaseService(entitlements: [activeEntitlement])
        let manager = PurchaseManager(service: service)

        #expect(manager.entitlements.count == 1)
        try await manager.logOut()
        #expect(manager.entitlements.isEmpty)
    }

    // MARK: - Error Paths

    @Test("Get products throws on service error")
    func getProductsThrowsOnServiceError() async {
        let service = ThrowingPurchaseService()
        let manager = PurchaseManager(service: service)

        await #expect(throws: Error.self) {
            try await manager.getProducts(productIds: ["mock.monthly"])
        }
    }

    @Test("Purchase product throws on service error")
    func purchaseProductThrowsOnServiceError() async {
        let service = ThrowingPurchaseService()
        let manager = PurchaseManager(service: service)

        await #expect(throws: Error.self) {
            try await manager.purchaseProduct(productId: "com.forge.monthly")
        }
    }

    @Test("Restore purchase throws on service error")
    func restorePurchaseThrowsOnServiceError() async {
        let service = ThrowingPurchaseService()
        let manager = PurchaseManager(service: service)

        await #expect(throws: Error.self) {
            try await manager.restorePurchase()
        }
    }

    // MARK: - Edge Cases

    @Test("Entitlements initialized from service on init")
    func entitlementsInitializedFromService() {
        let activeEntitlement = TestEntitlement.active()
        let service = MockPurchaseService(entitlements: [activeEntitlement])
        let manager = PurchaseManager(service: service)

        #expect(manager.entitlements.count == 1)
        #expect(manager.entitlements[0].isActive == true)
    }

    @Test("Empty product IDs returns empty array")
    func emptyProductIdsReturnsEmptyArray() async throws {
        let service = MockPurchaseService()
        let manager = PurchaseManager(service: service)

        let products = try await manager.getProducts(productIds: [])
        #expect(products.isEmpty)
    }

    @Test("Multiple entitlements tracked correctly after purchase")
    func multipleEntitlementsTrackedCorrectly() async throws {
        let service = MockPurchaseService()
        let manager = PurchaseManager(service: service)

        // Purchase sets entitlements
        _ = try await manager.purchaseProduct(productId: "com.forge.monthly")
        #expect(manager.entitlements.count == 1)

        // Restore overwrites with service entitlements (empty by default after purchase mock)
        let restored = try await manager.restorePurchase()
        #expect(restored.count == 1) // MockPurchaseService keeps entitlements from purchase
    }
}
