//
//  AppUtilities.swift
//  Forge
//
//  Local utilities.
//

import UIKit

/// Device and app information utilities for analytics and debugging.
@MainActor
enum AppUtilities {
    // MARK: - App Info

    static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
    }

    static var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"
    }

    static var bundleIdentifier: String {
        Bundle.main.bundleIdentifier ?? ""
    }

    static var appName: String {
        Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
    }

    // MARK: - Device Info

    static var deviceModel: String {
        UIDevice.current.model
    }

    static var systemVersion: String {
        UIDevice.current.systemVersion
    }

    static var systemName: String {
        UIDevice.current.systemName
    }

    static var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }

    // MARK: - Locale Info

    static var languageCode: String {
        Locale.current.language.languageCode?.identifier ?? "en"
    }

    static var regionCode: String {
        Locale.current.region?.identifier ?? "US"
    }

    static var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }

    static var timeZone: String {
        TimeZone.current.identifier
    }

    // MARK: - Analytics Event Parameters

    /// Common event parameters for analytics tracking.
    static var eventParameters: [String: Any] {
        [
            "app_version": appVersion,
            "build_number": buildNumber,
            "device_model": deviceModel,
            "os_version": systemVersion,
            "os_name": systemName,
            "language": languageCode,
            "region": regionCode,
            "timezone": timeZone,
            "is_simulator": isSimulator
        ]
    }
}
