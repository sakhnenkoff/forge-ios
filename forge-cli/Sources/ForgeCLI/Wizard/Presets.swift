import Foundation

struct Preset: Sendable {
    let id: String
    let displayName: String
    let description: String
    let authProviders: [GenerationConfig.AuthProvider]
    let monetizationModel: GenerationConfig.MonetizationModel
    let analyticsFeatureIds: [String]
    let featureModuleIds: [String]

    static let minimal = Preset(
        id: "minimal",
        displayName: "Minimal",
        description: "Apple auth only, no monetization, no analytics",
        authProviders: [.apple],
        monetizationModel: .free,
        analyticsFeatureIds: [],
        featureModuleIds: ["onboarding"]
    )

    static let standard = Preset(
        id: "standard",
        displayName: "Standard",
        description: "Apple + Google auth, subscriptions, Firebase Analytics, onboarding",
        authProviders: [.apple, .google],
        monetizationModel: .subscription,
        analyticsFeatureIds: ["firebase-analytics"],
        featureModuleIds: ["onboarding"]
    )

    static let full = Preset(
        id: "full",
        displayName: "Full",
        description: "All auth providers, subscriptions, all analytics, all modules",
        authProviders: GenerationConfig.AuthProvider.allCases,
        monetizationModel: .subscription,
        analyticsFeatureIds: ["firebase-analytics", "mixpanel", "crashlytics"],
        featureModuleIds: ["onboarding", "push-notifications", "ab-testing", "image-upload"]
    )

    static let all: [Preset] = [.minimal, .standard, .full]

    static func byId(_ id: String) -> Preset? {
        all.first { $0.id == id }
    }
}
