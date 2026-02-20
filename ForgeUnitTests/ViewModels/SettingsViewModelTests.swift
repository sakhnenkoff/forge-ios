//
//  SettingsViewModelTests.swift
//  ForgeUnitTests
//
//  Unit tests for SettingsViewModel covering sign-out, delete account, push authorization, reset actions, and edge cases.
//

import Testing
@testable import Forge
import CoreMock

@Suite("SettingsViewModel")
@MainActor
struct SettingsViewModelTests {

    // MARK: - Helpers

    private func makeContext(isSignedIn: Bool = true) -> (AppServices, AppSession) {
        let services = AppServices(configuration: .mock(isSignedIn: isSignedIn))
        let session = AppSession(keychain: MockKeychainCacheService())
        if isSignedIn {
            session.updateAuth(user: TestUser.authenticated(), currentUser: TestUser.model())
        }
        return (services, session)
    }

    // MARK: - Sign Out

    @Test("Sign out clears session")
    func signOutClearsSession() async throws {
        let (services, session) = makeContext()
        let viewModel = SettingsViewModel()

        #expect(session.auth != nil)
        viewModel.signOut(services: services, session: session)
        try await Task.sleep(for: .milliseconds(300))

        #expect(session.auth == nil)
        #expect(session.isPremium == false)
    }

    @Test("Sign out sets processing state")
    func signOutSetsProcessingState() async throws {
        let (services, session) = makeContext()
        let viewModel = SettingsViewModel()

        viewModel.signOut(services: services, session: session)
        #expect(viewModel.isProcessing == true)

        try await Task.sleep(for: .milliseconds(300))
        #expect(viewModel.isProcessing == false)
    }

    @Test("Sign out guards against double tap")
    func signOutGuardsAgainstDoubleTap() {
        let (services, session) = makeContext()
        let viewModel = SettingsViewModel()
        viewModel.isProcessing = true

        viewModel.signOut(services: services, session: session)
        // Should return early
        #expect(viewModel.isProcessing == true)
    }

    // MARK: - Delete Account

    @Test("Delete account requires auth")
    func deleteAccountRequiresAuth() {
        let (services, session) = makeContext(isSignedIn: false)
        let viewModel = SettingsViewModel()

        viewModel.deleteAccount(services: services, session: session)
        #expect(viewModel.errorMessage == "No active session.")
    }

    @Test("Delete account guards against double tap")
    func deleteAccountGuardsAgainstDoubleTap() {
        let (services, session) = makeContext()
        let viewModel = SettingsViewModel()
        viewModel.isProcessing = true

        viewModel.deleteAccount(services: services, session: session)
        // Should return early
        #expect(viewModel.isProcessing == true)
    }

    @Test("Delete account with auth succeeds")
    func deleteAccountWithAuthSucceeds() async throws {
        let (services, session) = makeContext()
        let viewModel = SettingsViewModel()

        viewModel.deleteAccount(services: services, session: session)
        try await Task.sleep(for: .milliseconds(300))

        #expect(session.auth == nil)
        #expect(viewModel.isProcessing == false)
    }

    // MARK: - Push Authorization

    @Test("Push guard against double tap")
    func pushGuardsAgainstDoubleTap() {
        let (services, _) = makeContext()
        let viewModel = SettingsViewModel()
        viewModel.isProcessing = true

        viewModel.requestPushAuthorization(services: services)
        // Should return early
        #expect(viewModel.isProcessing == true)
    }

    // MARK: - Reset Actions (Synchronous)

    @Test("Reset onboarding updates session")
    func resetOnboardingUpdatesSession() {
        let (services, session) = makeContext()
        session.setOnboardingComplete()
        #expect(session.isOnboardingComplete == true)

        let viewModel = SettingsViewModel()
        viewModel.resetOnboarding(services: services, session: session)

        #expect(session.isOnboardingComplete == false)
    }

    @Test("Reset onboarding sets toast")
    func resetOnboardingSetsToast() {
        let (services, session) = makeContext()
        let viewModel = SettingsViewModel()

        viewModel.resetOnboarding(services: services, session: session)
        #expect(viewModel.toast != nil)
    }

    @Test("Reset paywall updates session")
    func resetPaywallUpdatesSession() {
        let (services, session) = makeContext()
        session.markPaywallDismissed()
        #expect(session.hasDismissedPaywall == true)

        let viewModel = SettingsViewModel()
        viewModel.resetPaywall(services: services, session: session)

        #expect(session.hasDismissedPaywall == false)
    }

    @Test("Reset paywall sets toast")
    func resetPaywallSetsToast() {
        let (services, session) = makeContext()
        let viewModel = SettingsViewModel()

        viewModel.resetPaywall(services: services, session: session)
        #expect(viewModel.toast != nil)
    }

    // MARK: - Show Auth Screen

    @Test("Show auth screen resets auth dismissal")
    func showAuthScreenResetsAuthDismissal() async throws {
        let (services, session) = makeContext()
        session.markAuthDismissed()
        let viewModel = SettingsViewModel()

        viewModel.showAuthScreen(services: services, session: session)
        try await Task.sleep(for: .milliseconds(300))

        #expect(session.hasDismissedAuth == false)
    }

    @Test("Show auth screen guards against double tap")
    func showAuthScreenGuardsAgainstDoubleTap() {
        let (services, session) = makeContext()
        let viewModel = SettingsViewModel()
        viewModel.isProcessing = true

        viewModel.showAuthScreen(services: services, session: session)
        #expect(viewModel.isProcessing == true)
    }

    // MARK: - Utility

    @Test("Clear error resets error message")
    func clearErrorResetsErrorMessage() {
        let viewModel = SettingsViewModel()
        viewModel.errorMessage = "Some error"

        viewModel.clearError()
        #expect(viewModel.errorMessage == nil)
    }

    @Test("Initial state is clean")
    func initialStateIsClean() {
        let viewModel = SettingsViewModel()
        #expect(viewModel.isProcessing == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.toast == nil)
    }
}
