import Foundation

/// Defines the four axes that control visual personality.
public struct PresetConfiguration: Sendable {
    public enum SpacingRhythm: String, Sendable {
        case tight, balanced, airy
    }

    public enum CornerRadius: String, Sendable {
        case sharp, rounded, mixed
    }

    public enum TypographyWeight: String, Sendable {
        case heavy, light
    }

    public enum SurfaceTreatment: String, Sendable {
        case flat, elevated, glass
    }

    public let spacing: SpacingRhythm
    public let corners: CornerRadius
    public let weight: TypographyWeight
    public let surface: SurfaceTreatment

    public init(
        spacing: SpacingRhythm = .balanced,
        corners: CornerRadius = .mixed,
        weight: TypographyWeight = .light,
        surface: SurfaceTreatment = .elevated
    ) {
        self.spacing = spacing
        self.corners = corners
        self.weight = weight
        self.surface = surface
    }
}

// MARK: - Named Presets

extension PresetConfiguration {
    /// Dense, technical, dark — inspired by Linear
    public static let linear = PresetConfiguration(
        spacing: .tight, corners: .sharp, weight: .heavy, surface: .flat
    )

    /// Warm, spacious, friendly — inspired by Airbnb
    public static let airbnb = PresetConfiguration(
        spacing: .airy, corners: .rounded, weight: .light, surface: .elevated
    )

    /// Clean, precise, editorial — inspired by Stripe
    public static let stripe = PresetConfiguration(
        spacing: .balanced, corners: .mixed, weight: .light, surface: .flat
    )

    /// Native, premium, spacious — inspired by Apple
    public static let apple = PresetConfiguration(
        spacing: .airy, corners: .mixed, weight: .light, surface: .glass
    )

    /// The Forge template default
    public static let `default` = PresetConfiguration()
}
