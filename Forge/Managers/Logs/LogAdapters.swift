//
//  LogAdapters.swift
//  Forge
//
//  Local logging adapters.
//

import Foundation
import Dispatch
import FirebaseAnalytics
import FirebaseCrashlytics
import Mixpanel

enum LogType {
    case info
    case analytic
    case warning
    case severe
}

protocol LoggableEvent {
    var eventName: String { get }
    var parameters: [String: Any]? { get }
    var type: LogType { get }
}

protocol LogService {
    func trackEvent(name: String, parameters: [String: Any]?, type: LogType)
    func addUserProperties(_ properties: [String: Any], isHighPriority: Bool)
    func deleteUserProfile()
}

final class LogManager {
    private let services: [any LogService]
    private let stateQueue = DispatchQueue(label: "LogManager.state")
    private var userProperties: [String: Any] = [:]

    init(services: [any LogService]) {
        self.services = services
    }

    func trackEvent(event: any LoggableEvent) {
        trackEvent(eventName: event.eventName, parameters: event.parameters, type: event.type)
    }

    func trackEvent(eventName: String, parameters: [String: Any]? = nil, type: LogType = .analytic) {
        services.forEach { $0.trackEvent(name: eventName, parameters: parameters, type: type) }
    }

    func addUserProperties(dict: [String: Any], isHighPriority: Bool) {
        stateQueue.sync {
            if isHighPriority {
                userProperties.merge(dict) { _, new in new }
            } else {
                userProperties.merge(dict) { current, _ in current }
            }
        }
        services.forEach { $0.addUserProperties(dict, isHighPriority: isHighPriority) }
    }

    func deleteUserProfile() {
        stateQueue.sync {
            userProperties.removeAll()
        }
        services.forEach { $0.deleteUserProfile() }
    }
}

struct ConsoleService: LogService {
    enum System {
        case stdout
        case stderr
    }

    let printParameters: Bool
    let system: System

    init(printParameters: Bool = false, system: System = .stdout) {
        self.printParameters = printParameters
        self.system = system
    }

    func trackEvent(name: String, parameters: [String: Any]?, type: LogType) {
        let payload: String
        if printParameters, let parameters {
            payload = "\(name) \(type) \(parameters)"
        } else {
            payload = "\(name) \(type)"
        }

        switch system {
        case .stdout:
            print(payload)
        case .stderr:
            fputs(payload + "\n", stderr)
        }
    }

    func addUserProperties(_ properties: [String: Any], isHighPriority: Bool) {
        guard printParameters else { return }
        print("User properties updated: \(properties)")
    }

    func deleteUserProfile() {
        guard printParameters else { return }
        print("User properties cleared")
    }
}

struct FirebaseAnalyticsService: LogService {
    func trackEvent(name: String, parameters: [String: Any]?, type: LogType) {
        Analytics.logEvent(name, parameters: parameters)
    }

    func addUserProperties(_ properties: [String: Any], isHighPriority: Bool) {
        properties.forEach { key, value in
            Analytics.setUserProperty(String(describing: value), forName: key)
        }
    }

    func deleteUserProfile() {
        Analytics.resetAnalyticsData()
    }
}

struct FirebaseCrashlyticsService: LogService {
    func trackEvent(name: String, parameters: [String: Any]?, type: LogType) {
        let crashlytics = Crashlytics.crashlytics()
        crashlytics.log("\(name) [\(type)]")
        parameters?.forEach { key, value in
            crashlytics.setCustomValue(value, forKey: key)
        }
    }

    func addUserProperties(_ properties: [String: Any], isHighPriority: Bool) {
        let crashlytics = Crashlytics.crashlytics()
        properties.forEach { key, value in
            crashlytics.setCustomValue(value, forKey: key)
        }
    }

    func deleteUserProfile() {
        Crashlytics.crashlytics().setUserID("")
    }
}

final class MixpanelService: LogService {
    private let mixpanel: MixpanelInstance

    init(token: String) {
        self.mixpanel = Mixpanel.initialize(token: token, trackAutomaticEvents: true)
    }

    func trackEvent(name: String, parameters: [String: Any]?, type: LogType) {
        mixpanel.track(event: name, properties: parameters?.mixpanelProperties)
    }

    func addUserProperties(_ properties: [String: Any], isHighPriority: Bool) {
        mixpanel.registerSuperProperties(properties.mixpanelProperties)
        mixpanel.people.set(properties: properties.mixpanelProperties)
    }

    func deleteUserProfile() {
        mixpanel.reset()
    }
}

private extension Dictionary where Key == String, Value == Any {
    var mixpanelProperties: [String: MixpanelType] {
        var mapped: [String: MixpanelType] = [:]
        for (key, value) in self {
            if let value = value as? MixpanelType {
                mapped[key] = value
            } else if let value = value as? String {
                mapped[key] = value
            } else if let value = value as? Int {
                mapped[key] = value
            } else if let value = value as? Double {
                mapped[key] = value
            } else if let value = value as? Bool {
                mapped[key] = value
            } else if let value = value as? Date {
                mapped[key] = value
            } else {
                mapped[key] = String(describing: value)
            }
        }
        return mapped
    }
}
