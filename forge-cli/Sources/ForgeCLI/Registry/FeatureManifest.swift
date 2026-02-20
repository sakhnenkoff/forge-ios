import Foundation

/// A feature that can be selected during project generation.
struct FeatureManifest: Codable, Sendable, Identifiable {
    /// Unique identifier used in CLI flags and dependency references.
    let id: String
    /// Human-readable name shown in the wizard.
    let displayName: String
    /// One-line description shown in the wizard.
    let description: String
    /// The exact property name in `FeatureFlags.swift` that controls this feature.
    /// e.g. "enablePurchases", "enableMixpanel". Empty string if no flag controls it.
    let featureFlag: String
    /// IDs of other features this feature requires.
    let dependencies: [String]
    /// IDs of features this feature conflicts with (cannot be selected together).
    let conflicts: [String]
    /// xcconfig keys to add/set in the generated project's Secrets.xcconfig.local.example.
    let xcconfigs: [XCConfigEntry]
    /// Credentials the developer must supply before the app will work.
    let requiredCredentials: [CredentialInfo]
    /// Category grouping for display purposes.
    let category: FeatureCategory

    enum FeatureCategory: String, Codable, Sendable {
        case analytics
        case monetization
        case auth           // future use
        case module         // onboarding, imageupload, etc.
        case notifications
        case testing
    }
}

struct XCConfigEntry: Codable, Sendable {
    /// The xcconfig key (e.g. "REVENUECAT_API_KEY").
    let key: String
    /// Default value to use when no value provided (usually empty).
    let defaultValue: String
    /// Human-readable description for the Secrets file comment.
    let description: String
}

struct CredentialInfo: Codable, Sendable {
    /// Short name (e.g. "RevenueCat API Key").
    let name: String
    /// Where the developer finds this credential.
    let source: String
    /// The xcconfig key this maps to (if applicable).
    let xconfigKey: String?
}
