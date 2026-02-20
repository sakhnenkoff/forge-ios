//
//  Keys.swift
//  Forge
//
//  API keys are now read from Info.plist (populated by xcconfig).
//
//  To add your keys:
//  1. Copy Configurations/Secrets.xcconfig.local.example to Secrets.xcconfig.local
//  2. Fill in your real API keys
//  3. The .local file is gitignored, keeping your secrets safe
//

struct Keys {
    /// Mixpanel analytics token - reads from Info.plist
    static var mixpanelToken: String {
        AppConfiguration.mixpanelToken
    }

    /// RevenueCat API key for in-app purchases - reads from Info.plist
    static var revenueCatAPIKey: String {
        AppConfiguration.revenueCatAPIKey
    }
}
