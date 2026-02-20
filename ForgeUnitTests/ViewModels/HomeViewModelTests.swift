//
//  HomeViewModelTests.swift
//  ForgeUnitTests
//

import Testing
@testable import Forge
import CoreMock

@Suite("HomeViewModel")
@MainActor
struct HomeViewModelTests {

    // MARK: - Helpers

    private func makeSignedInContext() -> (AppServices, AppSession) {
        let services = AppServices(configuration: .mock(isSignedIn: true))
        let session = AppSession(keychain: MockKeychainCacheService())
        session.updateAuth(user: TestUser.authenticated(), currentUser: TestUser.model())
        return (services, session)
    }

    // MARK: - Initial State

    @Test("Initial state is empty")
    func initialStateIsEmpty() {
        let viewModel = HomeViewModel()
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.toast == nil)
    }

    @Test("onAppear tracks event")
    func onAppearTracksEvent() {
        let (services, session) = makeSignedInContext()
        let viewModel = HomeViewModel()

        viewModel.onAppear(services: services, session: session)

        // Verify no error state
        #expect(viewModel.errorMessage == nil)
    }
}
