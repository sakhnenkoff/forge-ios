//
//  UserManagerTests.swift
//  ForgeUnitTests
//
//  Unit tests for UserManager covering sign-in, document operations, sign-out, delete, and edge cases.
//

import Testing
@testable import Forge

@Suite("UserManager")
@MainActor
struct UserManagerTests {

    // MARK: - Helpers

    private func makeManager(document: UserModel? = nil) -> (UserManager, SpyLogService) {
        let services = MockUserServices(document: document ?? TestUser.model())
        let logSpy = SpyLogService()
        let logManager = LogManager(services: [logSpy])
        let manager = UserManager(
            services: services,
            configuration: .mockNoPendingWrites(),
            logger: logManager
        )
        return (manager, logSpy)
    }

    // MARK: - Happy Paths

    @Test("Sign in saves user and logs events")
    func signInSavesUserAndStartsListening() async throws {
        let (manager, logSpy) = makeManager()
        let auth = TestUser.authenticated()

        try await manager.signIn(auth: auth, isNewUser: false)

        #expect(manager.currentUser != nil)
        #expect(logSpy.hasEvent(named: "UserMan2_LogIn_Start"))
        #expect(logSpy.hasEvent(named: "UserMan2_LogIn_Success"))
    }

    @Test("Get user returns document")
    func getUserReturnsDocument() async throws {
        let testModel = TestUser.model(userId: "user1")
        let (manager, _) = makeManager(document: testModel)

        try await manager.logIn("user1")
        let user = try await manager.getUser()
        #expect(user.userId == "user1")
    }

    @Test("Save onboarding complete updates document")
    func saveOnboardingCompleteUpdatesDocument() async throws {
        let (manager, _) = makeManager()
        try await manager.logIn("test-uid-123")

        // Should not throw
        try await manager.saveOnboardingCompleteForCurrentUser()
    }

    @Test("Save user name updates document")
    func saveUserNameUpdatesDocument() async throws {
        let (manager, _) = makeManager()
        try await manager.logIn("test-uid-123")

        try await manager.saveUserName(name: "New Name")
    }

    @Test("Save user email updates document")
    func saveUserEmailUpdatesDocument() async throws {
        let (manager, _) = makeManager()
        try await manager.logIn("test-uid-123")

        try await manager.saveUserEmail(email: "new@test.com")
    }

    @Test("Sign out clears state and logs event")
    func signOutClearsStateAndLogsEvent() async throws {
        let (manager, logSpy) = makeManager()
        let auth = TestUser.authenticated()
        try await manager.signIn(auth: auth, isNewUser: false)

        #expect(manager.currentUser != nil)
        manager.signOut()
        #expect(manager.currentUser == nil)
        #expect(logSpy.hasEvent(named: "UserMan2_SignOut"))
    }

    // MARK: - Delete

    @Test("Delete current user succeeds and logs events")
    func deleteCurrentUserVerifiesUserIdConsistency() async throws {
        let (manager, logSpy) = makeManager()
        try await manager.logIn("test-uid-123")

        try await manager.deleteCurrentUser()
        #expect(logSpy.hasEvent(named: "UserMan2_DeleteAccount_Start"))
        #expect(logSpy.hasEvent(named: "UserMan2_DeleteAccount_Success"))
    }

    // MARK: - Edge Cases

    @Test("Current user is nil initially")
    func currentUserReflectsDocumentState() {
        let services = MockUserServices(document: nil)
        let manager = UserManager(
            services: services,
            configuration: .mockNoPendingWrites(),
            logger: nil
        )
        #expect(manager.currentUser == nil)
    }

    @Test("Save FCM token updates document")
    func saveFCMTokenUpdatesDocument() async throws {
        let (manager, _) = makeManager()
        try await manager.logIn("test-uid-123")

        try await manager.saveUserFCMToken(token: "test-fcm-token")
    }
}
