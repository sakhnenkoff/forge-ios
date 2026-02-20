//
//  SettingsDetailViewModel.swift
//  Forge
//
//
//

import SwiftUI

@MainActor
@Observable
final class SettingsDetailViewModel {
    var analyticsOptIn = true
    var trackingOptIn = false
    var trackingStatus: ConsentManager.TrackingStatus = .notDetermined
    var isProcessing = false
    var errorMessage: String?
    var needsRestart = false

    func onAppear(services: AppServices) {
        let consent = services.consentManager
        consent.refreshTrackingStatus()
        analyticsOptIn = consent.analyticsOptIn
        trackingOptIn = consent.trackingOptIn
        trackingStatus = consent.trackingStatus
        needsRestart = false
        errorMessage = nil

        services.logManager.trackEvent(event: Event.viewAppear)
    }

    func setAnalyticsOptIn(_ isOn: Bool, services: AppServices) {
        services.consentManager.analyticsOptIn = isOn
        analyticsOptIn = isOn
        needsRestart = true
        services.logManager.addUserProperties(dict: services.consentManager.eventParameters, isHighPriority: false)
        services.logManager.trackEvent(event: Event.analyticsOptInChanged(isOn: isOn))
    }

    func setTrackingOptIn(_ isOn: Bool, services: AppServices) {
        services.consentManager.trackingOptIn = isOn
        trackingOptIn = isOn
        services.consentManager.refreshTrackingStatus()
        trackingStatus = services.consentManager.trackingStatus
        services.logManager.addUserProperties(dict: services.consentManager.eventParameters, isHighPriority: false)
        services.logManager.trackEvent(event: Event.trackingOptInChanged(isOn: isOn))
    }

    func requestTrackingAuthorization(services: AppServices) {
        guard !isProcessing else { return }
        guard trackingOptIn else {
            errorMessage = "Enable tracking to request authorization."
            return
        }

        isProcessing = true
        errorMessage = nil
        services.logManager.trackEvent(event: Event.trackingRequestStart)

        Task {
            let status = await services.consentManager.requestTrackingAuthorization()
            trackingStatus = status
            services.logManager.addUserProperties(dict: services.consentManager.eventParameters, isHighPriority: false)
            services.logManager.trackEvent(event: Event.trackingRequestFinish(status: status))
            isProcessing = false
        }
    }

    func clearError() {
        errorMessage = nil
    }

    var trackingStatusLabel: String {
        switch trackingStatus {
        case .notDetermined:
            return "Not determined"
        case .restricted:
            return "Restricted"
        case .denied:
            return "Denied"
        case .authorized:
            return "Authorized"
        }
    }
}

extension SettingsDetailViewModel {
    enum Event: LoggableEvent {
        case viewAppear
        case analyticsOptInChanged(isOn: Bool)
        case trackingOptInChanged(isOn: Bool)
        case trackingRequestStart
        case trackingRequestFinish(status: ConsentManager.TrackingStatus)

        var eventName: String {
            switch self {
            case .viewAppear:
                return "SettingsDetail_Appear"
            case .analyticsOptInChanged:
                return "SettingsDetail_Analytics_Toggle"
            case .trackingOptInChanged:
                return "SettingsDetail_Tracking_Toggle"
            case .trackingRequestStart:
                return "SettingsDetail_Tracking_Request_Start"
            case .trackingRequestFinish:
                return "SettingsDetail_Tracking_Request_Finish"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .analyticsOptInChanged(let isOn):
                return ["enabled": isOn]
            case .trackingOptInChanged(let isOn):
                return ["enabled": isOn]
            case .trackingRequestFinish(let status):
                return ["status": status.rawValue]
            default:
                return nil
            }
        }
    }
}
