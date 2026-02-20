//
//  TestFactories.swift
//  ForgeUnitTests
//
//  Centralized factory methods for realistic test data.
//

import Foundation
import Testing
@testable import Forge
import CoreMock

// MARK: - User Factories

enum TestUser {
    static func authenticated(
        uid: String = "test-uid-123",
        email: String? = "test@example.com",
        isAnonymous: Bool = false,
        providers: [SignInOption] = [.apple],
        displayName: String? = "Test User"
    ) -> UserAuthInfo {
        UserAuthInfo(
            uid: uid,
            email: email,
            isAnonymous: isAnonymous,
            authProviders: providers,
            displayName: displayName,
            firstName: "Test",
            lastName: "User",
            phoneNumber: nil,
            photoURL: nil,
            creationDate: Date(),
            lastSignInDate: Date()
        )
    }

    static func anonymous() -> UserAuthInfo {
        authenticated(
            uid: "anon-uid-456",
            email: nil,
            isAnonymous: true,
            providers: [.anonymous],
            displayName: nil
        )
    }

    static func google(email: String = "google@example.com") -> UserAuthInfo {
        authenticated(
            uid: "google-uid-789",
            email: email,
            providers: [.google],
            displayName: "Google User"
        )
    }

    static func model(
        userId: String = "test-uid-123",
        email: String? = "test@example.com",
        isAnonymous: Bool? = false,
        didCompleteOnboarding: Bool? = true
    ) -> UserModel {
        UserModel(
            userId: userId,
            email: email,
            isAnonymous: isAnonymous,
            authProviders: ["apple.com"],
            displayName: "Test User",
            firstName: "Test",
            lastName: "User",
            creationDate: Date(),
            creationVersion: "1.0",
            lastSignInDate: Date(),
            didCompleteOnboarding: didCompleteOnboarding
        )
    }

    static func premiumModel() -> UserModel {
        model(didCompleteOnboarding: true)
    }
}

// MARK: - Product Factories

enum TestProduct {
    static func monthly(
        id: String = "com.forge.monthly",
        price: Decimal = 9.99
    ) -> AnyProduct {
        AnyProduct(
            id: id,
            title: "Monthly Premium",
            details: "Monthly premium access",
            price: price,
            currencyCode: "USD"
        )
    }

    static func yearly(
        id: String = "com.forge.yearly",
        price: Decimal = 59.99
    ) -> AnyProduct {
        AnyProduct(
            id: id,
            title: "Yearly Premium",
            details: "Yearly premium access",
            price: price,
            currencyCode: "USD"
        )
    }

    static func lifetime(
        id: String = "com.forge.lifetime",
        price: Decimal = 99.99
    ) -> AnyProduct {
        AnyProduct(
            id: id,
            title: "Lifetime Premium",
            details: "Lifetime premium access",
            price: price,
            currencyCode: "USD"
        )
    }
}

// MARK: - Entitlement Factories

enum TestEntitlement {
    static func active(
        id: String = "premium",
        productId: String = "com.forge.monthly"
    ) -> PurchasedEntitlement {
        PurchasedEntitlement(
            id: id,
            productId: productId,
            isActive: true,
            expirationDate: Date().addingTimeInterval(86400 * 30)
        )
    }

    static func expired(
        id: String = "premium",
        productId: String = "com.forge.monthly"
    ) -> PurchasedEntitlement {
        PurchasedEntitlement(
            id: id,
            productId: productId,
            isActive: false,
            expirationDate: Date().addingTimeInterval(-86400)
        )
    }

    static func none() -> [PurchasedEntitlement] {
        []
    }
}

// MARK: - Session Factory

enum TestSession {
    @MainActor
    static func make(keychain: MockKeychainCacheService = MockKeychainCacheService()) -> AppSession {
        AppSession(keychain: keychain)
    }
}
