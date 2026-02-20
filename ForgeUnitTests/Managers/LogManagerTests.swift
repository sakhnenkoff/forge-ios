//
//  LogManagerTests.swift
//  ForgeUnitTests
//
//  Unit tests for LogManager covering event routing, user properties, profile deletion, and edge cases.
//

import Testing
@testable import Forge

@Suite("LogManager")
@MainActor
struct LogManagerTests {

    // MARK: - Event Routing

    @Test("Track event routes to all services")
    func trackEventRoutesToAllServices() {
        let spy1 = SpyLogService()
        let spy2 = SpyLogService()
        let manager = LogManager(services: [spy1, spy2])

        manager.trackEvent(eventName: "test_event")

        #expect(spy1.hasEvent(named: "test_event"))
        #expect(spy2.hasEvent(named: "test_event"))
    }

    @Test("Track event with LoggableEvent protocol routes to all services")
    func trackEventWithLoggableEventRoutesToAllServices() {
        let spy1 = SpyLogService()
        let spy2 = SpyLogService()
        let manager = LogManager(services: [spy1, spy2])

        manager.trackEvent(event: TestEvent.simple)

        #expect(spy1.hasEvent(named: "Test_Simple"))
        #expect(spy2.hasEvent(named: "Test_Simple"))
    }

    @Test("Track event passes parameters through")
    func trackEventWithParametersPassesParametersThrough() {
        let spy = SpyLogService()
        let manager = LogManager(services: [spy])

        manager.trackEvent(eventName: "param_event", parameters: ["key": "value"])

        #expect(spy.trackedEvents.count == 1)
        let event = spy.trackedEvents[0]
        #expect(event.name == "param_event")
        #expect(event.parameters?["key"] as? String == "value")
    }

    @Test("Track event passes type correctly")
    func trackEventWithTypePassesTypeCorrectly() {
        let spy = SpyLogService()
        let manager = LogManager(services: [spy])

        manager.trackEvent(eventName: "severe_event", type: .severe)

        #expect(spy.trackedEvents.count == 1)
        let event = spy.trackedEvents[0]
        #expect(event.type == .severe)
    }

    @Test("Track event defaults to analytic type")
    func trackEventDefaultsToAnalyticType() {
        let spy = SpyLogService()
        let manager = LogManager(services: [spy])

        manager.trackEvent(eventName: "default_type_event")

        #expect(spy.trackedEvents[0].type == .analytic)
    }

    // MARK: - User Properties

    @Test("Add user properties distributes to all services")
    func addUserPropertiesDistributesToAllServices() {
        let spy1 = SpyLogService()
        let spy2 = SpyLogService()
        let manager = LogManager(services: [spy1, spy2])

        manager.addUserProperties(dict: ["role": "admin"], isHighPriority: true)

        #expect(spy1.userPropertiesUpdates.count == 1)
        #expect(spy2.userPropertiesUpdates.count == 1)
        #expect(spy1.userPropertiesUpdates[0].properties["role"] as? String == "admin")
        #expect(spy1.userPropertiesUpdates[0].isHighPriority == true)
    }

    @Test("Add user properties with low priority passes correct flag")
    func addUserPropertiesLowPriorityKeepsExisting() {
        let spy = SpyLogService()
        let manager = LogManager(services: [spy])

        manager.addUserProperties(dict: ["key": "value"], isHighPriority: false)

        #expect(spy.userPropertiesUpdates[0].isHighPriority == false)
    }

    // MARK: - Profile Deletion

    @Test("Delete user profile calls all services")
    func deleteUserProfileCallsAllServices() {
        let spy1 = SpyLogService()
        let spy2 = SpyLogService()
        let manager = LogManager(services: [spy1, spy2])

        manager.deleteUserProfile()

        #expect(spy1.deleteProfileCallCount == 1)
        #expect(spy2.deleteProfileCallCount == 1)
    }

    // MARK: - Edge Cases

    @Test("No services does not crash")
    func noServicesDoesNotCrash() {
        let manager = LogManager(services: [])

        // These should not crash
        manager.trackEvent(eventName: "orphan_event")
        manager.addUserProperties(dict: ["key": "value"], isHighPriority: true)
        manager.deleteUserProfile()
    }

    @Test("Single service routing works correctly")
    func singleServiceRouting() {
        let spy = SpyLogService()
        let manager = LogManager(services: [spy])

        manager.trackEvent(eventName: "solo_event", parameters: ["count": 1], type: .info)

        #expect(spy.trackedEvents.count == 1)
        #expect(spy.trackedEvents[0].name == "solo_event")
        #expect(spy.trackedEvents[0].parameters?["count"] as? Int == 1)
        #expect(spy.trackedEvents[0].type == .info)
    }

    @Test("Multiple events tracked in order")
    func multipleEventsTrackedInOrder() {
        let spy = SpyLogService()
        let manager = LogManager(services: [spy])

        manager.trackEvent(eventName: "first")
        manager.trackEvent(eventName: "second")
        manager.trackEvent(eventName: "third")

        #expect(spy.trackedEvents.count == 3)
        #expect(spy.trackedEvents[0].name == "first")
        #expect(spy.trackedEvents[1].name == "second")
        #expect(spy.trackedEvents[2].name == "third")
    }

    @Test("Event count helper returns correct count")
    func eventCountHelperReturnsCorrectCount() {
        let spy = SpyLogService()
        let manager = LogManager(services: [spy])

        manager.trackEvent(eventName: "repeated")
        manager.trackEvent(eventName: "unique")
        manager.trackEvent(eventName: "repeated")

        #expect(spy.eventCount(named: "repeated") == 2)
        #expect(spy.eventCount(named: "unique") == 1)
        #expect(spy.eventCount(named: "missing") == 0)
    }

    @Test("Last event helper returns most recent event")
    func lastEventHelperReturnsMostRecentEvent() {
        let spy = SpyLogService()
        let manager = LogManager(services: [spy])

        manager.trackEvent(eventName: "first")
        manager.trackEvent(eventName: "last")

        let last = spy.lastEvent()
        #expect(last?.name == "last")
    }

    @Test("LoggableEvent with parameters routes correctly")
    func loggableEventWithParametersRoutesCorrectly() {
        let spy = SpyLogService()
        let manager = LogManager(services: [spy])

        manager.trackEvent(event: TestEvent.withParams)

        #expect(spy.trackedEvents.count == 1)
        #expect(spy.trackedEvents[0].name == "Test_WithParams")
        #expect(spy.trackedEvents[0].parameters?["source"] as? String == "test")
    }

    @Test("LoggableEvent with severe type routes correctly")
    func loggableEventWithSevereTypeRoutesCorrectly() {
        let spy = SpyLogService()
        let manager = LogManager(services: [spy])

        manager.trackEvent(event: TestEvent.error)

        #expect(spy.trackedEvents[0].type == .severe)
        #expect(spy.trackedEvents[0].name == "Test_Error")
    }
}

// MARK: - Test LoggableEvent

private enum TestEvent: LoggableEvent {
    case simple
    case withParams
    case error

    var eventName: String {
        switch self {
        case .simple: return "Test_Simple"
        case .withParams: return "Test_WithParams"
        case .error: return "Test_Error"
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .withParams: return ["source": "test"]
        default: return nil
        }
    }

    var type: LogType {
        switch self {
        case .error: return .severe
        default: return .analytic
        }
    }
}
