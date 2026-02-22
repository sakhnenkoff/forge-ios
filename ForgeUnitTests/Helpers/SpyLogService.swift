//
//  SpyLogService.swift
//  ForgeUnitTests
//
//  Spy implementation of LogService for verifying event routing.
//

import Testing
@testable import Forge

struct TrackedEvent {
    let name: String
    let parameters: [String: Any]?
    let type: LogType
}

@MainActor
final class SpyLogService: LogService {
    var trackedEvents: [TrackedEvent] = []
    var userPropertiesUpdates: [(properties: [String: Any], isHighPriority: Bool)] = []
    var deleteProfileCallCount = 0

    func trackEvent(name: String, parameters: [String: Any]?, type: LogType) {
        trackedEvents.append(TrackedEvent(name: name, parameters: parameters, type: type))
    }

    func addUserProperties(_ properties: [String: Any], isHighPriority: Bool) {
        userPropertiesUpdates.append((properties: properties, isHighPriority: isHighPriority))
    }

    func deleteUserProfile() {
        deleteProfileCallCount += 1
    }

    // MARK: - Helper Methods

    func hasEvent(named name: String) -> Bool {
        trackedEvents.contains { $0.name == name }
    }

    func eventCount(named name: String) -> Int {
        trackedEvents.filter { $0.name == name }.count
    }

    func lastEvent() -> TrackedEvent? {
        trackedEvents.last
    }
}
