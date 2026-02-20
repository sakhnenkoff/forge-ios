//
//  AuthViewModelTests.swift
//  ForgeUnitTests
//
//  Unit tests for AuthViewModel covering sign-in flows, error handling, loading states, retry, and utilities.
//

import Testing
@testable import Forge
import CoreMock

@Suite("AuthViewModel")
@MainActor
struct AuthViewModelTests {

    // MARK: - Helpers

    private func makeContext() -> (AppServices, AppSession) {
        let services = AppServices(configuration: .mock(isSignedIn: false))
        let session = AppSession(keychain: MockKeychainCacheService())
        return (services, session)
    }

    // MARK: - Apple Sign In

    @Test("Sign in Apple sets loading state")
    func signInAppleSetsLoadingState() async throws {
        let (services, session) = makeContext()
        let viewModel = AuthViewModel()

        viewModel.signInApple(services: services, session: session)
        #expect(viewModel.isLoading == true)

        try await Task.sleep(for: .milliseconds(300))
        #expect(viewModel.isLoading == false)
    }

    @Test("Sign in Apple success clears error")
    func signInAppleSuccessClearsError() async throws {
        let (services, session) = makeContext()
        let viewModel = AuthViewModel()
        viewModel.errorMessage = "Previous error"

        viewModel.signInApple(services: services, session: session)
        // errorMessage is cleared immediately when signIn starts
        #expect(viewModel.errorMessage == nil)

        try await Task.sleep(for: .milliseconds(300))
        #expect(viewModel.errorMessage == nil)
    }

    @Test("Sign in Apple success updates session")
    func signInAppleSuccessUpdatesSession() async throws {
        let (services, session) = makeContext()
        let viewModel = AuthViewModel()

        viewModel.signInApple(services: services, session: session)
        try await Task.sleep(for: .milliseconds(300))

        #expect(session.auth != nil)
        #expect(session.hasDismissedAuth == true)
    }

    // MARK: - Anonymous Sign In

    @Test("Sign in anonymously succeeds")
    func signInAnonymouslySucceeds() async throws {
        let (services, session) = makeContext()
        let viewModel = AuthViewModel()

        viewModel.signInAnonymously(services: services, session: session)
        try await Task.sleep(for: .milliseconds(300))

        #expect(session.auth != nil)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }

    // MARK: - Loading Guard

    @Test("Sign in ignored while loading")
    func signInIgnoredWhileLoading() {
        let (services, session) = makeContext()
        let viewModel = AuthViewModel()
        viewModel.isLoading = true

        viewModel.signInApple(services: services, session: session)
        // Should return early without changing state
        #expect(viewModel.isLoading == true)
    }

    // MARK: - Retry

    @Test("Retry last sign-in retries Apple")
    func retryLastSignInRetriesApple() async throws {
        let (services, session) = makeContext()
        let viewModel = AuthViewModel()

        // First sign in to set lastProvider
        viewModel.signInApple(services: services, session: session)
        try await Task.sleep(for: .milliseconds(300))

        // Retry should work without crash
        viewModel.retryLastSignIn(services: services, session: session)
        try await Task.sleep(for: .milliseconds(300))

        #expect(viewModel.isLoading == false)
    }

    @Test("Retry with no last provider clears error")
    func retryWithNoLastProviderClearsError() {
        let (services, session) = makeContext()
        let viewModel = AuthViewModel()
        viewModel.errorMessage = "Some error"

        viewModel.retryLastSignIn(services: services, session: session)
        #expect(viewModel.errorMessage == nil)
    }

    // MARK: - Utility

    @Test("Clear error resets error message")
    func clearErrorResetsErrorMessage() {
        let viewModel = AuthViewModel()
        viewModel.errorMessage = "Some error"

        viewModel.clearError()
        #expect(viewModel.errorMessage == nil)
    }

    @Test("Refresh providers resets to all cases")
    func refreshProvidersResetsToAllCases() {
        let viewModel = AuthViewModel()
        viewModel.availableProviders = []

        viewModel.refreshProviders()
        #expect(viewModel.availableProviders.count == AuthViewModel.Provider.allCases.count)
    }

    @Test("Available providers defaults to all cases")
    func availableProvidersDefaultsToAllCases() {
        let viewModel = AuthViewModel()
        #expect(viewModel.availableProviders.count == 3)
    }

    // MARK: - Initial State

    @Test("Initial state is clean")
    func initialStateIsClean() {
        let viewModel = AuthViewModel()
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.availableProviders.count == 3)
    }
}
