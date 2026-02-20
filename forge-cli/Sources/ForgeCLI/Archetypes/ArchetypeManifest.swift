import Foundation

/// Describes a domain-specific app archetype (e.g. Finance Tracker, Fitness, etc.)
/// Loaded from `Archetypes/{id}/manifest.json`.
struct ArchetypeManifest: Codable, Sendable {
    let id: String
    let displayName: String
    let description: String
    let tabs: [TabDefinition]
    let routes: [RouteDefinition]
    let sheets: [SheetDefinition]
    let screens: [FileGroup]
    let models: [FileGroup]
    let onboarding: OnboardingDefinition?
    let paywallCopy: PaywallCopyDefinition?

    struct TabDefinition: Codable, Sendable {
        let id: String
        let title: String
        let icon: String
        let rootScreen: String
    }

    struct RouteDefinition: Codable, Sendable {
        let id: String
        let associatedValues: [String]?
    }

    struct SheetDefinition: Codable, Sendable {
        let id: String
    }

    struct FileGroup: Codable, Sendable {
        let sourceDir: String
        let files: [String]
    }

    struct OnboardingDefinition: Codable, Sendable {
        let steps: [OnboardingStepDef]
    }

    struct OnboardingStepDef: Codable, Sendable {
        let title: String
        let subtitle: String
        let icon: String
    }

    struct PaywallCopyDefinition: Codable, Sendable {
        let headline: String
        let valueProps: [String]
    }
}
