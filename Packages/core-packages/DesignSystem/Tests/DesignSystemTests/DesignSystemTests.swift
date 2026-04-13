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

    func testDefaultThemeIsAdaptiveTheme() {
        XCTAssertTrue(DesignSystem.theme is AdaptiveTheme)
    }

    func testDebugReconfigurePostsThemeDidChangeNotification() {
        let expectation = expectation(
            forNotification: DesignSystem.themeDidChangeNotification,
            object: nil
        )

        DesignSystem.reconfigureForDebug(theme: AdaptiveTheme(brandColor: .blue))

        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(DesignSystem.theme is AdaptiveTheme)
    }
}
