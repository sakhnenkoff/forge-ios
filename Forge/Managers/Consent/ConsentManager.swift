//
//  ConsentManager.swift
//  Forge
//
//
//

import AppTrackingTransparency
import Foundation

@MainActor
@Observable
final class ConsentManager {

    enum TrackingStatus: String {
        case notDetermined
        case restricted
        case denied
        case authorized
    }

    private enum Keys {
        static let analyticsOptIn = "consent.analytics_opt_in"
        static let trackingOptIn = "consent.tracking_opt_in"
        static let trackingStatus = "consent.tracking_status"
    }

    private let defaults: UserDefaults
    private let isMock: Bool

    var analyticsOptIn: Bool {
        didSet {
            defaults.set(analyticsOptIn, forKey: Keys.analyticsOptIn)
        }
    }

    var trackingOptIn: Bool {
        didSet {
            defaults.set(trackingOptIn, forKey: Keys.trackingOptIn)
        }
    }

    private(set) var trackingStatus: TrackingStatus {
        didSet {
            defaults.set(trackingStatus.rawValue, forKey: Keys.trackingStatus)
        }
    }

    init(defaults: UserDefaults = .standard, isMock: Bool) {
        self.defaults = defaults
        self.isMock = isMock

        let storedAnalytics = defaults.object(forKey: Keys.analyticsOptIn) as? Bool
        analyticsOptIn = storedAnalytics ?? true

        let storedTracking = defaults.object(forKey: Keys.trackingOptIn) as? Bool
        trackingOptIn = storedTracking ?? false

        let storedStatus = defaults.string(forKey: Keys.trackingStatus)
        trackingStatus = TrackingStatus(rawValue: storedStatus ?? "") ?? .notDetermined

        refreshTrackingStatus()
    }

    var shouldEnableAnalytics: Bool {
        analyticsOptIn && !isMock
    }

    var eventParameters: [String: Any] {
        [
            "consent_analytics": analyticsOptIn,
            "consent_tracking": trackingOptIn,
            "tracking_status": trackingStatus.rawValue
        ]
    }

    func refreshTrackingStatus() {
        guard !isMock else { return }
        trackingStatus = Self.systemTrackingStatus
    }

    func requestTrackingAuthorization() async -> TrackingStatus {
        guard !isMock else { return trackingStatus }
        guard trackingOptIn else { return trackingStatus }

        if #available(iOS 14, *) {
            if ATTrackingManager.trackingAuthorizationStatus != .notDetermined {
                trackingStatus = Self.mapAuthorizationStatus(ATTrackingManager.trackingAuthorizationStatus)
                return trackingStatus
            }

            let status = await withCheckedContinuation { continuation in
                ATTrackingManager.requestTrackingAuthorization { status in
                    continuation.resume(returning: Self.mapAuthorizationStatus(status))
                }
            }
            trackingStatus = status
            return status
        } else {
            trackingStatus = .authorized
            return trackingStatus
        }
    }

    @available(iOS 14, *)
    nonisolated private static func mapAuthorizationStatus(_ status: ATTrackingManager.AuthorizationStatus) -> TrackingStatus {
        switch status {
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .restricted
        case .denied:
            return .denied
        case .authorized:
            return .authorized
        @unknown default:
            return .notDetermined
        }
    }

    nonisolated private static var systemTrackingStatus: TrackingStatus {
        if #available(iOS 14, *) {
            return mapAuthorizationStatus(ATTrackingManager.trackingAuthorizationStatus)
        }

        return .authorized
    }
}
