//
//  AccessibilityModifiers.swift
//  Forge
//
//  Standardized accessibility identifiers for UI testing.
//

import SwiftUI

// MARK: - Accessibility ID Generator

/// Generates consistent accessibility identifiers for UI testing.
/// Uses a standardized naming convention: `ScreenName_ElementType_ElementName`
enum AccessibilityID {

    /// Button identifier: `Screen_Button_Name`
    static func button(_ screen: String, _ name: String) -> String {
        "\(screen)_Button_\(name)"
    }

    /// Text/Label identifier: `Screen_Text_Name`
    static func text(_ screen: String, _ name: String) -> String {
        "\(screen)_Text_\(name)"
    }

    /// Input field identifier: `Screen_Input_Name`
    static func input(_ screen: String, _ name: String) -> String {
        "\(screen)_Input_\(name)"
    }

    /// Image identifier: `Screen_Image_Name`
    static func image(_ screen: String, _ name: String) -> String {
        "\(screen)_Image_\(name)"
    }

    /// List/ScrollView identifier: `Screen_List`
    static func list(_ screen: String) -> String {
        "\(screen)_List"
    }

    /// List cell identifier: `Screen_Cell_Index`
    static func cell(_ screen: String, index: Int) -> String {
        "\(screen)_Cell_\(index)"
    }

    /// List cell identifier with ID: `Screen_Cell_ID`
    static func cell(_ screen: String, id: String) -> String {
        "\(screen)_Cell_\(id)"
    }

    /// Toggle/Switch identifier: `Screen_Toggle_Name`
    static func toggle(_ screen: String, _ name: String) -> String {
        "\(screen)_Toggle_\(name)"
    }

    /// Tab identifier: `Screen_Tab_Name`
    static func tab(_ screen: String, _ name: String) -> String {
        "\(screen)_Tab_\(name)"
    }

    /// Navigation element identifier: `Screen_Nav_Name`
    static func navigation(_ screen: String, _ name: String) -> String {
        "\(screen)_Nav_\(name)"
    }

    /// Modal/Sheet identifier: `Screen_Modal_Name`
    static func modal(_ screen: String, _ name: String) -> String {
        "\(screen)_Modal_\(name)"
    }

    /// Generic element identifier: `Screen_Element`
    static func element(_ screen: String, _ element: String) -> String {
        "\(screen)_\(element)"
    }
}

// MARK: - View Extension

extension View {

    /// Adds an accessibility identifier using the standardized format.
    /// - Parameters:
    ///   - screen: The screen name (e.g., "Home", "Profile", "Settings")
    ///   - element: The element name (e.g., "SubmitButton", "TitleLabel")
    /// - Returns: The view with the accessibility identifier applied.
    ///
    /// Usage:
    /// ```swift
    /// DSButton(title: "Submit") { ... }
    ///     .testID("Home", "SubmitButton")
    /// ```
    func testID(_ screen: String, _ element: String) -> some View {
        self.accessibilityIdentifier("\(screen)_\(element)")
    }

    /// Adds an accessibility identifier for a button.
    /// - Parameters:
    ///   - screen: The screen name
    ///   - name: The button name
    /// - Returns: The view with the button accessibility identifier.
    ///
    /// Usage:
    /// ```swift
    /// DSButton(title: "Submit") { ... }
    ///     .buttonTestID("Home", "Submit")
    /// // Results in: "Home_Button_Submit"
    /// ```
    func buttonTestID(_ screen: String, _ name: String) -> some View {
        self.accessibilityIdentifier(AccessibilityID.button(screen, name))
    }

    /// Adds an accessibility identifier for an input field.
    /// - Parameters:
    ///   - screen: The screen name
    ///   - name: The input name
    /// - Returns: The view with the input accessibility identifier.
    func inputTestID(_ screen: String, _ name: String) -> some View {
        self.accessibilityIdentifier(AccessibilityID.input(screen, name))
    }

    /// Adds an accessibility identifier for a list cell.
    /// - Parameters:
    ///   - screen: The screen name
    ///   - index: The cell index
    /// - Returns: The view with the cell accessibility identifier.
    func cellTestID(_ screen: String, index: Int) -> some View {
        self.accessibilityIdentifier(AccessibilityID.cell(screen, index: index))
    }

    /// Adds an accessibility identifier for a list cell with string ID.
    /// - Parameters:
    ///   - screen: The screen name
    ///   - id: The cell ID
    /// - Returns: The view with the cell accessibility identifier.
    func cellTestID(_ screen: String, id: String) -> some View {
        self.accessibilityIdentifier(AccessibilityID.cell(screen, id: id))
    }
}

// MARK: - Usage Examples
/*
 // In Views:

 struct HomeView: View {
     var body: some View {
         VStack {
             Text("Welcome")
                 .testID("Home", "WelcomeText")

             DSButton(title: "Get Started") {
                 // action
             }
             .buttonTestID("Home", "GetStarted")

             TextField("Email", text: $email)
                 .inputTestID("Home", "Email")

             List {
                 ForEach(items.indices, id: \.self) { index in
                     ItemRow(item: items[index])
                         .cellTestID("Home", index: index)
                 }
             }
             .accessibilityIdentifier(AccessibilityID.list("Home"))
         }
     }
 }

 // In UI Tests:

 func testHomeView() {
     let app = XCUIApplication()
     app.launch()

     // Using AccessibilityID enum for consistency
     let getStartedButton = app.buttons[AccessibilityID.button("Home", "GetStarted")]
     XCTAssertTrue(getStartedButton.exists)

     let emailField = app.textFields[AccessibilityID.input("Home", "Email")]
     emailField.tap()
     emailField.typeText("test@example.com")

     getStartedButton.tap()
 }
 */
