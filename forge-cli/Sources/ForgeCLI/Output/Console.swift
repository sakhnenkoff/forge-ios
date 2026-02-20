import Foundation

enum Console {
    // MARK: - ANSI escape codes
    private static let esc    = "\u{1B}"
    private static let reset  = "\u{1B}[0m"
    private static let boldC  = "\u{1B}[1m"
    private static let greenC = "\u{1B}[32m"
    private static let redC   = "\u{1B}[31m"
    private static let yellowC = "\u{1B}[33m"
    private static let grayC  = "\u{1B}[90m"
    private static let cyanC  = "\u{1B}[36m"

    // MARK: - Styled strings
    static func bold(_ s: String) -> String   { "\(boldC)\(s)\(reset)" }
    static func green(_ s: String) -> String  { "\(greenC)\(s)\(reset)" }
    static func red(_ s: String) -> String    { "\(redC)\(s)\(reset)" }
    static func yellow(_ s: String) -> String { "\(yellowC)\(s)\(reset)" }
    static func gray(_ s: String) -> String   { "\(grayC)\(s)\(reset)" }
    static func cyan(_ s: String) -> String   { "\(cyanC)\(s)\(reset)" }

    // MARK: - Compound helpers
    static let checkmark = "\u{1B}[32m✓\u{1B}[0m"
    static let cross     = "\u{1B}[31m✗\u{1B}[0m"
    static let arrow     = "\u{1B}[36m›\u{1B}[0m"

    /// Print a bold section header
    static func printHeader(_ text: String) {
        print("\n\(bold(text))")
        print(String(repeating: "─", count: text.count + 2))
    }

    /// Print a progress step indicator (before completion)
    static func printStep(_ text: String) {
        print("  \(cyan("◆")) \(text)...")
    }

    /// Overwrite the previous printStep line with a green checkmark
    static func printDone(_ text: String) {
        // Move cursor up one line, clear it, reprint with checkmark
        print("\u{1B}[1A\u{1B}[2K  \(checkmark) \(text)")
    }

    /// Print an error message to stderr
    static func printError(_ text: String) {
        fputs("\(cross) \(red(text))\n", stderr)
    }

    /// Print a warning
    static func printWarning(_ text: String) {
        print("  \(yellow("⚠")) \(yellow(text))")
    }

    /// Print inline validation error below a prompt
    static func printInlineError(_ text: String) {
        print("  \(red("→")) \(red(text))")
    }
}
