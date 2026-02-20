//
//  AuthManagerTests.swift
//  ForgeUnitTests
//
//  Unit tests for AuthManager covering sign-in, sign-out, error handling, and edge cases.
//

import Testing
@testable import Forge
import CoreMock

@Suite("AuthManager")
@MainActor
struct AuthManagerTests {

    // MARK: - Happy Paths

    @Test("Sign in with Apple returns valid user")
    func signInAppleReturnsUser() async throws {
        let service = MockAuthService()
        let manager = AuthManager(service: service)

        let result = try await manager.signInApple()
        #expect(result.user.email == "demo@example.com")
        #expect(result.user.isAnonymous == false)
        #expect(result.isNewUser == false)
    }

    @Test("Sign in with Google returns valid user")
    func signInGoogleReturnsUser() async throws {
        let service = MockAuthService()
        let manager = AuthManager(service: service)

        let result = try await manager.signInGoogle(GIDClientID: "test-client-id")
        #expect(result.user.email == "demo@example.com")
        #expect(result.user.isAnonymous == false)
        #expect(result.isNewUser == false)
    }

    @Test("Sign in anonymously returns anonymous user")
    func signInAnonymouslyReturnsAnonymousUser() async throws {
        let service = MockAuthService()
        let manager = AuthManager(service: service)

        let result = try await manager.signInAnonymously()
        #expect(result.user.isAnonymous == true)
        #expect(result.user.email == nil)
        #expect(result.isNewUser == false)
    }

    @Test("Sign out clears current user")
    func signOutClearsCurrentUser() async throws {
        let service = MockAuthService()
        let manager = AuthManager(service: service)

        // Sign in first
        _ = try await manager.signInApple()
        #expect(manager.auth != nil)

        // Sign out
        try manager.signOut()
        #expect(manager.auth == nil)
    }

    @Test("Current user reflects service state after sign-in")
    func currentUserReflectsServiceState() async throws {
        let service = MockAuthService()
        let manager = AuthManager(service: service)

        let result = try await manager.signInApple()
        #expect(manager.auth != nil)
        #expect(manager.auth?.uid == result.user.uid)
        #expect(manager.auth?.email == result.user.email)
    }

    // MARK: - Error Paths

    @Test("Sign in Apple throws on service error")
    func signInAppleThrowsOnServiceError() async {
        let service = ThrowingAuthService()
        let manager = AuthManager(service: service)

        await #expect(throws: Error.self) {
            try await manager.signInApple()
        }
    }

    @Test("Sign in Google throws on service error")
    func signInGoogleThrowsOnServiceError() async {
        let service = ThrowingAuthService()
        let manager = AuthManager(service: service)

        await #expect(throws: Error.self) {
            try await manager.signInGoogle(GIDClientID: "test-client-id")
        }
    }

    @Test("Sign out throws on service error")
    func signOutThrowsOnServiceError() {
        let service = ThrowingAuthService()
        let manager = AuthManager(service: service)

        #expect(throws: Error.self) {
            try manager.signOut()
        }
    }

    // MARK: - Edge Cases

    @Test("Delete account calls onDelete closure")
    func deleteAccountCallsOnDeleteClosure() async throws {
        let service = MockAuthService()
        let manager = AuthManager(service: service)

        // Sign in first so there's a user to delete
        _ = try await manager.signInApple()

        var onDeleteCalled = false
        try await manager.deleteAccountWithReauthentication(
            option: .apple,
            revokeToken: false,
            onDelete: {
                onDeleteCalled = true
            }
        )
        #expect(onDeleteCalled)
        #expect(manager.auth == nil)
    }

    @Test("Auth is nil before any sign-in")
    func authIsNilBeforeAnySignIn() {
        let service = MockAuthService()
        let manager = AuthManager(service: service)

        #expect(manager.auth == nil)
    }

    @Test("Sign in anonymous then sign out resets to nil")
    func signInAnonymousThenSignOutResetsToNil() async throws {
        let service = MockAuthService()
        let manager = AuthManager(service: service)

        _ = try await manager.signInAnonymously()
        #expect(manager.auth != nil)

        try manager.signOut()
        #expect(manager.auth == nil)
    }
}
