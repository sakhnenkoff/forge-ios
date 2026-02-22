//
//  ABTestManagerTests.swift
//  ForgeUnitTests
//
//  Unit tests for ABTestManager covering init, fetch, override, error handling, and edge cases.
//

import Testing
@testable import Forge

@Suite("ABTestManager")
@MainActor
struct ABTestManagerTests {

    // MARK: - Happy Paths

    @Test("Init fetches remote config and updates activeTests")
    func initFetchesRemoteConfig() async throws {
        let service = MockABTestService(boolTest: true, enumTest: .beta)
        let manager = ABTestManager(service: service)

        // Wait for configure() Task to complete
        try await Task.sleep(for: .milliseconds(100))

        #expect(manager.activeTests.boolTest == true)
        #expect(manager.activeTests.enumTest == .beta)
    }

    @Test("Active tests reflects service state")
    func activeTestsReflectsServiceState() {
        let service = MockABTestService(boolTest: false, enumTest: .alpha)
        let manager = ABTestManager(service: service)

        // Immediately after init (before async fetch), activeTests should have service defaults
        #expect(manager.activeTests.boolTest == false)
        #expect(manager.activeTests.enumTest == .alpha)
    }

    @Test("Override saves and refetches config")
    func overrideSavesAndRefetchesConfig() async throws {
        let service = MockABTestService(boolTest: false, enumTest: .alpha)
        let manager = ABTestManager(service: service)

        let updated = ActiveABTests(boolTest: true, enumTest: .beta)
        try manager.override(updateTests: updated)

        // Wait for configure() Task to complete
        try await Task.sleep(for: .milliseconds(100))

        #expect(manager.activeTests.boolTest == true)
        #expect(manager.activeTests.enumTest == .beta)
    }

    // MARK: - Error Paths

    @Test("Fetch failure logs error event")
    func fetchFailureLogsError() async throws {
        let logSpy = SpyLogService()
        let logManager = LogManager(services: [logSpy])
        let service = ThrowingABTestService()
        _ = ABTestManager(service: service, logManager: logManager)

        // Wait for configure() Task to fail
        try await Task.sleep(for: .milliseconds(100))

        #expect(logSpy.hasEvent(named: "ABMan_FetchRemote_Fail"))
    }

    // MARK: - Edge Cases

    @Test("Default values used before async fetch completes")
    func defaultValuesUsedBeforeFetch() {
        let service = MockABTestService(boolTest: true, enumTest: .beta)
        let manager = ABTestManager(service: service)

        // Before async fetch, activeTests should have service defaults
        #expect(manager.activeTests.boolTest == true)
        #expect(manager.activeTests.enumTest == .beta)
    }

    @Test("Init with nil logManager does not crash")
    func initWithNilLogManagerDoesNotCrash() async throws {
        let service = MockABTestService()
        let manager = ABTestManager(service: service, logManager: nil)

        // Wait for configure() Task
        try await Task.sleep(for: .milliseconds(100))

        // Should not crash
        #expect(manager.activeTests.boolTest == false)
    }
}
