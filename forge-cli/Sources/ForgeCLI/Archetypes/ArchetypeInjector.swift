import Foundation

/// Injects archetype-specific files and patches into a generated project.
struct ArchetypeInjector {

    let manifest: ArchetypeManifest
    let archetypeDir: URL
    let outputDir: URL
    let projectName: String

    /// Run all injection steps for this archetype.
    func inject() throws {
        // Skip injection for blank archetype (no files to copy)
        guard manifest.id != "blank" else { return }

        try copyScreenFiles()
        try copyModelFiles()
        try patchAppTab()
        try patchAppRoute()
        try patchAppSheet()
    }

    // MARK: - File Copying

    /// Copy screen files from archetype's `files/` into the generated project's `Features/`.
    private func copyScreenFiles() throws {
        let filesDir = archetypeDir.appendingPathComponent("files")
        for group in manifest.screens {
            let sourceDir = filesDir.appendingPathComponent(group.sourceDir)
            let destDir = outputDir
                .appendingPathComponent(projectName)
                .appendingPathComponent(group.sourceDir)

            try FileManager.default.createDirectory(at: destDir, withIntermediateDirectories: true)

            for file in group.files {
                let src = sourceDir.appendingPathComponent(file)
                let dst = destDir.appendingPathComponent(file)

                // Create intermediate directories if file is in a subdirectory
                let dstParent = dst.deletingLastPathComponent()
                if !FileManager.default.fileExists(atPath: dstParent.path) {
                    try FileManager.default.createDirectory(at: dstParent, withIntermediateDirectories: true)
                }

                if FileManager.default.fileExists(atPath: src.path) {
                    try FileManager.default.copyItem(at: src, to: dst)
                }
            }
        }
    }

    /// Copy model/manager files from archetype's `files/` into the generated project's `Managers/`.
    private func copyModelFiles() throws {
        let filesDir = archetypeDir.appendingPathComponent("files")
        for group in manifest.models {
            let sourceDir = filesDir.appendingPathComponent(group.sourceDir)
            let destDir = outputDir
                .appendingPathComponent(projectName)
                .appendingPathComponent(group.sourceDir)

            try FileManager.default.createDirectory(at: destDir, withIntermediateDirectories: true)

            for file in group.files {
                let src = sourceDir.appendingPathComponent(file)
                let dst = destDir.appendingPathComponent(file)

                let dstParent = dst.deletingLastPathComponent()
                if !FileManager.default.fileExists(atPath: dstParent.path) {
                    try FileManager.default.createDirectory(at: dstParent, withIntermediateDirectories: true)
                }

                if FileManager.default.fileExists(atPath: src.path) {
                    try FileManager.default.copyItem(at: src, to: dst)
                }
            }
        }
    }

    // MARK: - Code Patching

    /// Patch AppTab.swift to add archetype-specific tabs.
    private func patchAppTab() throws {
        guard !manifest.tabs.isEmpty else { return }

        let tabFile = outputDir
            .appendingPathComponent(projectName)
            .appendingPathComponent("App/Navigation/AppTab.swift")
        guard FileManager.default.fileExists(atPath: tabFile.path) else { return }

        var content = try String(contentsOf: tabFile, encoding: .utf8)

        // Add new cases before "case settings"
        let newCases = manifest.tabs.map { "    case \($0.id)" }.joined(separator: "\n")
        content = content.replacingOccurrences(
            of: "    case settings",
            with: "\(newCases)\n    case settings"
        )

        // Add icon cases
        let newIconCases = manifest.tabs.map {
            "        case .\($0.id):\n            return \"\($0.icon)\""
        }.joined(separator: "\n")
        content = content.replacingOccurrences(
            of: "        case .settings:\n            return \"gearshape\"",
            with: "\(newIconCases)\n        case .settings:\n            return \"gearshape\""
        )

        // Add title cases
        let newTitleCases = manifest.tabs.map {
            "        case .\($0.id):\n            return \"\($0.title)\""
        }.joined(separator: "\n")
        content = content.replacingOccurrences(
            of: "        case .settings:\n            return \"Settings\"",
            with: "\(newTitleCases)\n        case .settings:\n            return \"Settings\""
        )

        // Add view cases
        let newViewCases = manifest.tabs.map {
            "        case .\($0.id):\n            \($0.rootScreen)()"
        }.joined(separator: "\n")
        content = content.replacingOccurrences(
            of: "        case .settings:\n            SettingsView()",
            with: "\(newViewCases)\n        case .settings:\n            SettingsView()"
        )

        try content.write(to: tabFile, atomically: true, encoding: .utf8)
    }

    /// Patch AppRoute.swift to add archetype-specific routes.
    private func patchAppRoute() throws {
        guard !manifest.routes.isEmpty else { return }

        let routeFile = outputDir
            .appendingPathComponent(projectName)
            .appendingPathComponent("App/Navigation/AppRoute.swift")
        guard FileManager.default.fileExists(atPath: routeFile.path) else { return }

        var content = try String(contentsOf: routeFile, encoding: .utf8)

        // Add new cases before "case settingsDetail"
        let newCases = manifest.routes.map { route in
            if let values = route.associatedValues, !values.isEmpty {
                let params = values.map { "\($0)" }.joined(separator: ", ")
                return "    case \(route.id)(\(params))"
            } else {
                return "    case \(route.id)"
            }
        }.joined(separator: "\n")

        content = content.replacingOccurrences(
            of: "    case settingsDetail",
            with: "\(newCases)\n    case settingsDetail"
        )

        try content.write(to: routeFile, atomically: true, encoding: .utf8)
    }

    /// Patch AppSheet.swift to add archetype-specific sheets.
    private func patchAppSheet() throws {
        guard !manifest.sheets.isEmpty else { return }

        let sheetFile = outputDir
            .appendingPathComponent(projectName)
            .appendingPathComponent("App/Navigation/AppSheet.swift")
        guard FileManager.default.fileExists(atPath: sheetFile.path) else { return }

        var content = try String(contentsOf: sheetFile, encoding: .utf8)

        // Add new cases before "case paywall"
        let newCases = manifest.sheets.map { "    case \($0.id)" }.joined(separator: "\n")
        content = content.replacingOccurrences(
            of: "    case paywall",
            with: "\(newCases)\n    case paywall"
        )

        try content.write(to: sheetFile, atomically: true, encoding: .utf8)
    }
}
