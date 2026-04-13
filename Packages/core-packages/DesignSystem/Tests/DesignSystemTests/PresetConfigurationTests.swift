import XCTest
@testable import DesignSystem
import SwiftUI

final class PresetConfigurationTests: XCTestCase {

    private let testStory = ColorStory(brand: .blue, surface: .gray)

    /// Helper: compare two Colors by resolving to RGBA components
    private func assertColorsEqual(_ a: Color, _ b: Color, file: StaticString = #file, line: UInt = #line) {
        let env = EnvironmentValues()
        let ra = a.resolve(in: env)
        let rb = b.resolve(in: env)
        XCTAssertEqual(ra.red, rb.red, accuracy: 0.01, file: file, line: line)
        XCTAssertEqual(ra.green, rb.green, accuracy: 0.01, file: file, line: line)
        XCTAssertEqual(ra.blue, rb.blue, accuracy: 0.01, file: file, line: line)
        XCTAssertEqual(ra.opacity, rb.opacity, accuracy: 0.01, file: file, line: line)
    }

    // MARK: - Default Preset

    func testDefaultPresetProducesStandardTokenValues() {
        let theme = AdaptiveTheme(colorStory: testStory, preset: .default)
        let tokens = theme.tokens

        XCTAssertEqual(tokens.spacing.xs, 4)
        XCTAssertEqual(tokens.spacing.sm, 8)
        XCTAssertEqual(tokens.spacing.md, 16)
        XCTAssertEqual(tokens.spacing.lg, 24)
        XCTAssertEqual(tokens.spacing.xl, 32)
        XCTAssertEqual(tokens.spacing.xxlg, 40)
        XCTAssertEqual(tokens.spacing.xxl, 52)

        XCTAssertEqual(tokens.radii.xs, 8)
        XCTAssertEqual(tokens.radii.sm, 12)
        XCTAssertEqual(tokens.radii.md, 16)
        XCTAssertEqual(tokens.radii.lg, 20)
        XCTAssertEqual(tokens.radii.xl, 28)
        XCTAssertEqual(tokens.radii.pill, 999)
    }

    // MARK: - Spacing Axis

    func testTightSpacingUsesSmallerScale() {
        let theme = AdaptiveTheme(colorStory: testStory, preset: PresetConfiguration(spacing: .tight))
        XCTAssertEqual(theme.tokens.spacing.md, 12)
        XCTAssertEqual(theme.tokens.spacing.lg, 20)
        XCTAssertLessThan(theme.tokens.spacing.md, 16)
    }

    func testAirySpacingUsesLargerScale() {
        let theme = AdaptiveTheme(colorStory: testStory, preset: PresetConfiguration(spacing: .airy))
        XCTAssertEqual(theme.tokens.spacing.md, 24)
        XCTAssertEqual(theme.tokens.spacing.lg, 32)
        XCTAssertGreaterThan(theme.tokens.spacing.md, 16)
    }

    // MARK: - Corner Radius Axis

    func testSharpCornersUseSmallerRadii() {
        let theme = AdaptiveTheme(colorStory: testStory, preset: PresetConfiguration(corners: .sharp))
        XCTAssertEqual(theme.tokens.radii.md, 8)
        XCTAssertEqual(theme.tokens.radii.xl, 16)
    }

    func testRoundedCornersUseLargerRadii() {
        let theme = AdaptiveTheme(colorStory: testStory, preset: PresetConfiguration(corners: .rounded))
        XCTAssertEqual(theme.tokens.radii.md, 20)
        XCTAssertEqual(theme.tokens.radii.xl, 36)
    }

    // MARK: - Surface Treatment Axis

    func testFlatSurfaceZeroesAllShadowRadii() {
        let theme = AdaptiveTheme(colorStory: testStory, preset: PresetConfiguration(surface: .flat))
        XCTAssertEqual(theme.tokens.shadows.soft.radius, 0)
        XCTAssertEqual(theme.tokens.shadows.card.radius, 0)
        XCTAssertEqual(theme.tokens.shadows.lifted.radius, 0)
    }

    func testElevatedSurfaceHasNonZeroShadows() {
        let theme = AdaptiveTheme(colorStory: testStory, preset: PresetConfiguration(surface: .elevated))
        XCTAssertGreaterThan(theme.tokens.shadows.soft.radius, 0)
        XCTAssertGreaterThan(theme.tokens.shadows.card.radius, 0)
        XCTAssertGreaterThan(theme.tokens.shadows.lifted.radius, 0)
    }

    // MARK: - Typography Weight Axis

    func testHeavyWeightUsesBolderHeadings() {
        let heavy = AdaptiveTheme(colorStory: testStory, preset: PresetConfiguration(weight: .heavy))
        let light = AdaptiveTheme(colorStory: testStory, preset: PresetConfiguration(weight: .light))
        XCTAssertEqual(heavy.tokens.typography.display.weight, .black)
        XCTAssertEqual(light.tokens.typography.display.weight, .bold)
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

    // MARK: - ColorStory

    func testColorStoryDerivation() {
        let story = ColorStory(brand: .blue, contrast: .green, surprise: .orange, surface: .gray)
        let theme = AdaptiveTheme(colorStory: story, preset: .default)
        let colors = theme.tokens.colors

        assertColorsEqual(colors.primary, .blue)
        assertColorsEqual(colors.secondary, .green)
        assertColorsEqual(colors.info, .green)
        assertColorsEqual(colors.accent, .orange)
        assertColorsEqual(colors.surfaceVariant, .gray)
        assertColorsEqual(colors.backgroundSecondary, .gray)
    }

    func testColorStoryWithoutOptionals() {
        let story = ColorStory(brand: .blue, surface: .gray)
        let theme = AdaptiveTheme(colorStory: story, preset: .default)
        let colors = theme.tokens.colors

        assertColorsEqual(colors.primary, .blue)
        assertColorsEqual(colors.accent, .blue)
        // Verify derived contrast path
        let env = EnvironmentValues()
        let primaryResolved = colors.primary.resolve(in: env)
        let secondaryResolved = colors.secondary.resolve(in: env)
        XCTAssertEqual(secondaryResolved.opacity, 0.7, accuracy: 0.05,
                       "Derived contrast should have ~0.7 opacity")
        XCTAssertNotEqual(primaryResolved.opacity, secondaryResolved.opacity,
                          "Derived contrast should differ from brand")
    }

    func testInitWithoutColorStoryMatchesDefault() {
        let withoutStory = AdaptiveTheme()
        let withDefault = AdaptiveTheme(preset: .default)
        XCTAssertEqual(withoutStory.tokens.spacing.md, withDefault.tokens.spacing.md)
        XCTAssertEqual(withoutStory.tokens.radii.md, withDefault.tokens.radii.md)
        XCTAssertEqual(withoutStory.tokens.shadows.card.radius, withDefault.tokens.shadows.card.radius)
    }
}
