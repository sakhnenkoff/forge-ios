import XCTest
@testable import DesignSystem
import SwiftUI

final class PresetConfigurationTests: XCTestCase {

    // MARK: - Default Preset

    func testDefaultPresetProducesStandardTokenValues() {
        let theme = AdaptiveTheme(brandColor: .blue, preset: .default)
        let tokens = theme.tokens

        // Spacing should match ThemeFactory defaults (balanced)
        XCTAssertEqual(tokens.spacing.xs, 4)
        XCTAssertEqual(tokens.spacing.sm, 8)
        XCTAssertEqual(tokens.spacing.md, 16)
        XCTAssertEqual(tokens.spacing.lg, 24)
        XCTAssertEqual(tokens.spacing.xl, 32)
        XCTAssertEqual(tokens.spacing.xxlg, 40)
        XCTAssertEqual(tokens.spacing.xxl, 52)

        // Radii should match mixed defaults
        XCTAssertEqual(tokens.radii.xs, 8)
        XCTAssertEqual(tokens.radii.sm, 12)
        XCTAssertEqual(tokens.radii.md, 16)
        XCTAssertEqual(tokens.radii.lg, 20)
        XCTAssertEqual(tokens.radii.xl, 28)
        XCTAssertEqual(tokens.radii.pill, 999)
    }

    // MARK: - Spacing Axis

    func testTightSpacingUsesSmallerScale() {
        let theme = AdaptiveTheme(
            brandColor: .blue,
            preset: PresetConfiguration(spacing: .tight)
        )

        // Curated tight scale: xs=4, sm=4, smd=8, md=12, mlg=16, lg=20, xl=24, xxlg=32, xxl=40
        XCTAssertEqual(theme.tokens.spacing.md, 12)
        XCTAssertEqual(theme.tokens.spacing.lg, 20)
        XCTAssertLessThan(theme.tokens.spacing.md, 16) // less than balanced default
    }

    func testAirySpacingUsesLargerScale() {
        let theme = AdaptiveTheme(
            brandColor: .blue,
            preset: PresetConfiguration(spacing: .airy)
        )

        // Curated airy scale: xs=8, sm=12, smd=16, md=24, mlg=28, lg=32, xl=40, xxlg=52, xxl=64
        XCTAssertEqual(theme.tokens.spacing.md, 24)
        XCTAssertEqual(theme.tokens.spacing.lg, 32)
        XCTAssertGreaterThan(theme.tokens.spacing.md, 16) // more than balanced default
    }

    // MARK: - Corner Radius Axis

    func testSharpCornersUseSmallerRadii() {
        let theme = AdaptiveTheme(
            brandColor: .blue,
            preset: PresetConfiguration(corners: .sharp)
        )

        // Curated sharp scale: xs=4, sm=8, md=8, lg=12, xl=16
        XCTAssertEqual(theme.tokens.radii.md, 8)
        XCTAssertEqual(theme.tokens.radii.xl, 16)
    }

    func testRoundedCornersUseLargerRadii() {
        let theme = AdaptiveTheme(
            brandColor: .blue,
            preset: PresetConfiguration(corners: .rounded)
        )

        // Curated rounded scale: xs=12, sm=16, md=20, lg=28, xl=36
        XCTAssertEqual(theme.tokens.radii.md, 20)
        XCTAssertEqual(theme.tokens.radii.xl, 36)
    }

    // MARK: - Surface Treatment Axis

    func testFlatSurfaceZeroesAllShadowRadii() {
        let theme = AdaptiveTheme(
            brandColor: .blue,
            preset: PresetConfiguration(surface: .flat)
        )

        XCTAssertEqual(theme.tokens.shadows.soft.radius, 0)
        XCTAssertEqual(theme.tokens.shadows.card.radius, 0)
        XCTAssertEqual(theme.tokens.shadows.lifted.radius, 0)
    }

    func testElevatedSurfaceHasNonZeroShadows() {
        let theme = AdaptiveTheme(
            brandColor: .blue,
            preset: PresetConfiguration(surface: .elevated)
        )

        XCTAssertGreaterThan(theme.tokens.shadows.soft.radius, 0)
        XCTAssertGreaterThan(theme.tokens.shadows.card.radius, 0)
        XCTAssertGreaterThan(theme.tokens.shadows.lifted.radius, 0)
    }

    // MARK: - Typography Weight Axis

    func testHeavyWeightUsesBolderHeadings() {
        let heavy = AdaptiveTheme(
            brandColor: .blue,
            preset: PresetConfiguration(weight: .heavy)
        )
        let light = AdaptiveTheme(
            brandColor: .blue,
            preset: PresetConfiguration(weight: .light)
        )

        // Heavy display should be .black, light should be .bold
        XCTAssertEqual(heavy.tokens.typography.display.weight, .black)
        XCTAssertEqual(light.tokens.typography.display.weight, .bold)

        // Heavy headings should be .bold, light should be .semibold
        XCTAssertEqual(heavy.tokens.typography.titleLarge.weight, .bold)
        XCTAssertEqual(light.tokens.typography.titleLarge.weight, .semibold)
    }

    // MARK: - Named Presets

    func testNamedPresetsHaveExpectedAxisValues() {
        XCTAssertEqual(PresetConfiguration.linear.spacing, .tight)
        XCTAssertEqual(PresetConfiguration.linear.corners, .sharp)
        XCTAssertEqual(PresetConfiguration.linear.weight, .heavy)
        XCTAssertEqual(PresetConfiguration.linear.surface, .flat)

        XCTAssertEqual(PresetConfiguration.airbnb.spacing, .airy)
        XCTAssertEqual(PresetConfiguration.airbnb.corners, .rounded)

        XCTAssertEqual(PresetConfiguration.stripe.surface, .flat)
        XCTAssertEqual(PresetConfiguration.apple.surface, .glass)
    }

    // MARK: - No-Preset Backward Compatibility

    func testInitWithoutPresetMatchesDefault() {
        let withoutPreset = AdaptiveTheme(brandColor: .blue)
        let withDefault = AdaptiveTheme(brandColor: .blue, preset: .default)

        XCTAssertEqual(withoutPreset.tokens.spacing.md, withDefault.tokens.spacing.md)
        XCTAssertEqual(withoutPreset.tokens.radii.md, withDefault.tokens.radii.md)
        XCTAssertEqual(withoutPreset.tokens.shadows.card.radius, withDefault.tokens.shadows.card.radius)
    }
}
