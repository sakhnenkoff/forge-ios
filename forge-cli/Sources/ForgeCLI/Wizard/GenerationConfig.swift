import Foundation

/// The complete, resolved configuration for project generation.
/// Produced by WizardFlow, consumed by ProjectGenerator.
struct GenerationConfig: Sendable {
    let projectName: String
    let bundleId: String
    let authProviders: [AuthProvider]
    let monetizationModel: MonetizationModel
    let analyticsFeatureIds: [String]   // IDs from registry: "firebase-analytics", "mixpanel", "crashlytics"
    let featureModuleIds: [String]      // IDs from registry: "onboarding", "push-notifications", etc.
    let resolvedFeatureIds: [String]    // All features in dependency order (from DependencyResolver)
    let archetypeId: String             // Archetype to inject (e.g. "blank", "finance")
    let outputDir: URL

    enum AuthProvider: String, CaseIterable, Sendable {
        case apple, google, email, anonymous

        var displayName: String {
            switch self {
            case .apple:     return "Sign in with Apple"
            case .google:    return "Google Sign-In"
            case .email:     return "Email/Password"
            case .anonymous: return "Anonymous"
            }
        }
    }

    enum MonetizationModel: String, CaseIterable, Sendable {
        case subscription, onetime, free

        var displayName: String {
            switch self {
            case .subscription: return "Subscription"
            case .onetime:      return "One-Time Purchase (Lifetime)"
            case .free:         return "Free (no monetization)"
            }
        }

        /// Whether RevenueCat/purchases feature is needed
        var requiresPurchases: Bool {
            self == .subscription || self == .onetime
        }
    }
}
