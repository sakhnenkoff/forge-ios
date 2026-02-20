import XCTest
@testable import DesignSystem

final class DesignSystemTests: XCTestCase {
    override func setUp() {
        super.setUp()
        DesignSystem.reset()
    }

    func testToastCreation() throws {
        let errorToast = Toast.error("Error message")
        XCTAssertEqual(errorToast.style, .error)
        XCTAssertEqual(errorToast.message, "Error message")

        let successToast = Toast.success("Success message")
        XCTAssertEqual(successToast.style, .success)

        let warningToast = Toast.warning("Warning message")
        XCTAssertEqual(warningToast.style, .warning)

        let infoToast = Toast.info("Info message")
        XCTAssertEqual(infoToast.style, .info)
    }

    func testToastEquality() throws {
        let id = UUID()
        let toast1 = Toast(id: id, style: .error, message: "Test")
        let toast2 = Toast(id: id, style: .error, message: "Test")

        XCTAssertEqual(toast1, toast2)
    }

    func testThemePresetResolvesToExpectedThemes() {
        XCTAssertTrue(ThemePreset.defaultTheme.makeTheme() is CloudPetalTheme)
        XCTAssertTrue(ThemePreset.classicMono.makeTheme() is DefaultTheme)
        XCTAssertTrue(ThemePreset.editorialGarden.makeTheme() is EditorialGardenTheme)
        XCTAssertTrue(ThemePreset.porcelainTech.makeTheme() is PorcelainTechTheme)
        XCTAssertTrue(ThemePreset.botanicalLuxe.makeTheme() is BotanicalLuxeTheme)
    }

    func testConfigureWithThemePresetSetsCurrentPreset() {
        DesignSystem.configure(themePreset: .porcelainTech)

        XCTAssertEqual(DesignSystem.currentThemePreset, .porcelainTech)
        XCTAssertTrue(DesignSystem.theme is PorcelainTechTheme)
    }

    func testDirectionalThemesUseHybridTypographyRoles() {
        let themes: [any Theme] = [
            CloudPetalTheme(),
            EditorialGardenTheme(),
            PorcelainTechTheme(),
            BotanicalLuxeTheme()
        ]

        for theme in themes {
            XCTAssertNotEqual(theme.typography.titleLarge.design, .monospaced)
            XCTAssertNotEqual(theme.typography.headlineMedium.design, .monospaced)
            XCTAssertNotEqual(theme.typography.bodyLarge.design, .monospaced)
            XCTAssertEqual(theme.typography.captionLarge.design, .monospaced)
            XCTAssertEqual(theme.typography.buttonMedium.design, .monospaced)
        }
    }

    func testDebugReconfigurePostsThemeDidChangeNotification() {
        DesignSystem.configure(themePreset: .defaultTheme)

        let expectation = expectation(
            forNotification: DesignSystem.themeDidChangeNotification,
            object: nil
        ) { notification in
            let preset = notification.userInfo?["preset"] as? String
            return preset == ThemePreset.botanicalLuxe.rawValue
        }

        DesignSystem.reconfigureForDebug(themePreset: .botanicalLuxe)

        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(DesignSystem.currentThemePreset, .botanicalLuxe)
        XCTAssertTrue(DesignSystem.theme is BotanicalLuxeTheme)
    }
}
