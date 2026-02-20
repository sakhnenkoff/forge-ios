//
//  ThrowingServices.swift
//  ForgeUnitTests
//
//  Error-throwing mock services for testing failure paths.
//

import Foundation
import Testing
@testable import Forge

// MARK: - Throwing Auth Service

@MainActor
final class ThrowingAuthService: AuthService {
    var error: Error
    var currentUser: UserAuthInfo?

    init(error: Error = NSError(domain: "TestAuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Test auth error"]),
         currentUser: UserAuthInfo? = nil) {
        self.error = error
        self.currentUser = currentUser
    }

    func signInApple() async throws -> AuthResult {
        throw error
    }

    func signInGoogle(GIDClientID: String) async throws -> AuthResult {
        throw error
    }

    func signInAnonymously() async throws -> AuthResult {
        throw error
    }

    func signOut() throws {
        throw error
    }

    func deleteAccountWithReauthentication(
        option: SignInOption,
        revokeToken: Bool,
        onDelete: @escaping @isolated(any) () async throws -> Void
    ) async throws {
        throw error
    }
}

// MARK: - Throwing Purchase Service

@MainActor
final class ThrowingPurchaseService: PurchaseService {
    var error: Error
    var entitlements: [PurchasedEntitlement]

    init(error: Error = NSError(domain: "TestPurchaseError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Test purchase error"]),
         entitlements: [PurchasedEntitlement] = []) {
        self.error = error
        self.entitlements = entitlements
    }

    func getProducts(productIds: [String]) async throws -> [AnyProduct] {
        throw error
    }

    func purchase(productId: String) async throws -> [PurchasedEntitlement] {
        throw error
    }

    func restore() async throws -> [PurchasedEntitlement] {
        throw error
    }

    func logIn(userId: String, attributes: PurchaseProfileAttributes?) async throws -> [PurchasedEntitlement] {
        throw error
    }

    func logOut() async throws {
        throw error
    }
}

// MARK: - Throwing AB Test Service

@MainActor
final class ThrowingABTestService: ABTestService {
    var error: Error
    var activeTests: ActiveABTests

    init(error: Error = NSError(domain: "TestABTestError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Test AB test error"]),
         activeTests: ActiveABTests = ActiveABTests(boolTest: false, enumTest: .default)) {
        self.error = error
        self.activeTests = activeTests
    }

    func saveUpdatedConfig(updatedTests: ActiveABTests) throws {
        throw error
    }

    func fetchUpdatedConfig() async throws -> ActiveABTests {
        throw error
    }
}
