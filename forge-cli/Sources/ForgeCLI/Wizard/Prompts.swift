import Foundation
#if canImport(Darwin)
import Darwin
#endif

// MARK: - Result types

enum PromptResult<T> {
    case value(T)
    case back
}

// MARK: - Prompts

struct Prompts {

    // MARK: Text Input

    /// Prompt for a single text value with validation.
    /// Returns .back if user types "back".
    static func textInput(
        prompt: String,
        placeholder: String? = nil,
        validate: ((String) -> String?)? = nil
    ) -> PromptResult<String> {
        while true {
            if let placeholder {
                print("\(Console.bold(prompt)) \(Console.gray("(\(placeholder))"))")
            } else {
                print(Console.bold(prompt))
            }
            print(Console.gray("  (type 'back' to return to previous step)"))
            print(Console.cyan("› "), terminator: "")
            fflush(stdout)

            guard let input = readLine()?.trimmingCharacters(in: .whitespaces) else {
                // stdin closed (EOF) — exit to avoid busy-wait
                return .back
            }

            if input.lowercased() == "back" {
                return .back
            }

            if input.isEmpty, let placeholder {
                // Accept placeholder as default
                return .value(placeholder)
            }

            if let errorMsg = validate?(input) {
                Console.printInlineError(errorMsg)
                print()
                continue
            }

            if input.isEmpty {
                Console.printInlineError("This field is required.")
                print()
                continue
            }

            return .value(input)
        }
    }

    // MARK: Yes/No

    /// [Y/n] prompt. Returns .back if user types "back".
    static func yesNo(question: String, defaultYes: Bool = true) -> PromptResult<Bool> {
        let hint = defaultYes ? "[Y/n]" : "[y/N]"
        print("\(Console.bold(question)) \(Console.gray(hint))")
        print(Console.cyan("› "), terminator: "")
        fflush(stdout)

        guard let input = readLine()?.trimmingCharacters(in: .whitespaces).lowercased() else {
            return .value(defaultYes)
        }

        if input == "back" { return .back }
        if input.isEmpty { return .value(defaultYes) }
        return .value(input == "y" || input == "yes")
    }

    // MARK: Single Select (arrow keys)

    /// Present a list of options; user navigates with arrow keys, selects with Enter.
    /// Returns .back if user presses Escape or 'b'.
    static func singleSelect<T>(
        prompt: String,
        options: [(label: String, value: T)],
        hint: String = "↑↓ navigate  Enter select  Esc/b back"
    ) -> PromptResult<T> {
        var activeIndex = 0
        let saved = enableRawMode()
        defer { disableRawMode(saved) }

        renderSingleSelect(prompt: prompt, options: options.map(\.label), activeIndex: activeIndex, hint: hint)

        while true {
            let key = readKey()
            switch key {
            case .arrowUp:
                if activeIndex > 0 {
                    activeIndex -= 1
                    rerenderSingleSelect(options: options.map(\.label), activeIndex: activeIndex)
                }
            case .arrowDown:
                if activeIndex < options.count - 1 {
                    activeIndex += 1
                    rerenderSingleSelect(options: options.map(\.label), activeIndex: activeIndex)
                }
            case .enter:
                clearRenderedLines(count: options.count + 2)
                print("\(Console.bold(prompt)): \(Console.green(options[activeIndex].label))")
                return .value(options[activeIndex].value)
            case .escape, .charB, .eof:
                clearRenderedLines(count: options.count + 2)
                return .back
            default:
                break
            }
        }
    }

    // MARK: Multi Select (arrow keys + Space)

    /// Present options with checkboxes. Space toggles, Enter confirms, Esc/b = back.
    /// requiresAtLeastOne enforces minimum selection of one item.
    static func multiSelect(
        prompt: String,
        options: [String],
        preSelected: Set<Int> = [],
        requiresAtLeastOne: Bool = false,
        hint: String = "↑↓ navigate  Space toggle  Enter confirm  Esc/b back"
    ) -> PromptResult<Set<Int>> {
        var activeIndex = 0
        var selected = preSelected
        let saved = enableRawMode()
        defer { disableRawMode(saved) }

        renderMultiSelect(prompt: prompt, options: options, activeIndex: activeIndex, selected: selected, hint: hint)

        while true {
            let key = readKey()
            switch key {
            case .arrowUp:
                if activeIndex > 0 {
                    activeIndex -= 1
                    rerenderMultiSelect(options: options, activeIndex: activeIndex, selected: selected)
                }
            case .arrowDown:
                if activeIndex < options.count - 1 {
                    activeIndex += 1
                    rerenderMultiSelect(options: options, activeIndex: activeIndex, selected: selected)
                }
            case .space:
                if selected.contains(activeIndex) {
                    selected.remove(activeIndex)
                } else {
                    selected.insert(activeIndex)
                }
                rerenderMultiSelect(options: options, activeIndex: activeIndex, selected: selected)
            case .enter:
                if requiresAtLeastOne && selected.isEmpty {
                    // Show inline error, pause, then redraw
                    print("\u{1B}[2K\r  \(Console.red("→")) \(Console.red("Select at least one option."))", terminator: "")
                    fflush(stdout)
                    Thread.sleep(forTimeInterval: 1.5)
                    // Move back up to re-render options
                    print("\u{1B}[1A", terminator: "")
                    rerenderMultiSelect(options: options, activeIndex: activeIndex, selected: selected)
                    break
                }
                clearRenderedLines(count: options.count + 2)
                let selectedLabels = selected.sorted().map { options[$0] }.joined(separator: ", ")
                print("\(Console.bold(prompt)): \(Console.green(selectedLabels.isEmpty ? "none" : selectedLabels))")
                return .value(selected)
            case .escape, .charB, .eof:
                clearRenderedLines(count: options.count + 2)
                return .back
            default:
                break
            }
        }
    }

    // MARK: - Raw Terminal Mode

    static func enableRawMode() -> termios {
        var raw = termios()
        tcgetattr(STDIN_FILENO, &raw)
        let saved = raw
        // Disable canonical mode and echo
        raw.c_lflag &= ~(tcflag_t(ICANON) | tcflag_t(ECHO))
        // VMIN = 1, VTIME = 0 — read returns after 1 byte
        // c_cc is a fixed-size tuple in Swift; access VMIN (index 16) and VTIME (index 17)
        withUnsafeMutablePointer(to: &raw.c_cc) { ptr in
            ptr.withMemoryRebound(to: cc_t.self, capacity: Int(NCCS)) { bytes in
                bytes[Int(VMIN)]  = 1
                bytes[Int(VTIME)] = 0
            }
        }
        tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw)
        // Hide cursor during interaction
        print("\u{1B}[?25l", terminator: "")
        fflush(stdout)
        return saved
    }

    static func disableRawMode(_ saved: termios) {
        var s = saved
        tcsetattr(STDIN_FILENO, TCSAFLUSH, &s)
        // Restore cursor visibility
        print("\u{1B}[?25h", terminator: "")
        fflush(stdout)
    }

    // MARK: - Key Reading

    private enum Key {
        case arrowUp, arrowDown, enter, space, escape, charB, eof, other
    }

    private static func readKey() -> Key {
        var buf = [UInt8](repeating: 0, count: 3)
        let count = read(STDIN_FILENO, &buf, 3)
        guard count > 0 else { return .eof }

        if count == 1 {
            switch buf[0] {
            case 13, 10: return .enter   // CR or LF
            case 32:     return .space   // Space
            case 27:     return .escape  // ESC alone
            case 98:     return .charB   // 'b'
            default:     return .other
            }
        }

        // Escape sequences for arrow keys: ESC [ A/B
        if count >= 3 && buf[0] == 27 && buf[1] == 91 {
            switch buf[2] {
            case 65: return .arrowUp
            case 66: return .arrowDown
            default: return .other
            }
        }
        return .other
    }

    // MARK: - Rendering Helpers

    private static func renderSingleSelect(
        prompt: String, options: [String], activeIndex: Int, hint: String
    ) {
        print(Console.bold(prompt))
        print(Console.gray("  \(hint)"))
        for (i, option) in options.enumerated() {
            if i == activeIndex {
                print("  \(Console.green("●")) \(option)")
            } else {
                print("  \(Console.gray("○")) \(Console.gray(option))")
            }
        }
        fflush(stdout)
    }

    private static func rerenderSingleSelect(options: [String], activeIndex: Int) {
        for _ in 0..<options.count {
            print("\u{1B}[1A", terminator: "")
        }
        for (i, option) in options.enumerated() {
            print("\u{1B}[2K\r", terminator: "")
            if i == activeIndex {
                print("  \(Console.green("●")) \(option)")
            } else {
                print("  \(Console.gray("○")) \(Console.gray(option))")
            }
        }
        fflush(stdout)
    }

    private static func renderMultiSelect(
        prompt: String, options: [String], activeIndex: Int,
        selected: Set<Int>, hint: String
    ) {
        print(Console.bold(prompt))
        print(Console.gray("  \(hint)"))
        for (i, option) in options.enumerated() {
            let checkbox = selected.contains(i) ? Console.green("◉") : Console.gray("○")
            let label = i == activeIndex ? option : Console.gray(option)
            let cursor = i == activeIndex ? Console.cyan("›") : " "
            print("  \(cursor) \(checkbox) \(label)")
        }
        fflush(stdout)
    }

    private static func rerenderMultiSelect(
        options: [String], activeIndex: Int, selected: Set<Int>
    ) {
        for _ in 0..<options.count {
            print("\u{1B}[1A", terminator: "")
        }
        for (i, option) in options.enumerated() {
            print("\u{1B}[2K\r", terminator: "")
            let checkbox = selected.contains(i) ? Console.green("◉") : Console.gray("○")
            let label = i == activeIndex ? option : Console.gray(option)
            let cursor = i == activeIndex ? Console.cyan("›") : " "
            print("  \(cursor) \(checkbox) \(label)")
        }
        fflush(stdout)
    }

    private static func clearRenderedLines(count: Int) {
        for _ in 0..<count {
            print("\u{1B}[1A\u{1B}[2K", terminator: "")
        }
        print("\r", terminator: "")
        fflush(stdout)
    }
}
