import Foundation

struct TemplateEngine {

    /// Text file extensions to process for content replacement.
    /// Mirrors the extension list in rename_project.sh.
    static let textExtensions: Set<String> = [
        "swift", "pbxproj", "xcscheme", "xcconfig", "plist",
        "md", "entitlements", "storyboard", "xib", "strings",
        "xcstrings", "sh", "txt", "json", "yml", "yaml"
    ]

    /// Files/directories to exclude from all operations.
    static let excludedPaths: Set<String> = [
        ".git", ".swiftpm", "DerivedData", "build",
        "xcuserdata", ".build", "forge-cli"
    ]

    /// Apply project renaming: replace `oldName` with `newName` in all text file contents
    /// and rename files/directories containing `oldName`.
    ///
    /// - Parameters:
    ///   - directory: Root directory to process (the copied template).
    ///   - oldName: Source project name (always "Forge").
    ///   - newName: Target project name.
    ///   - bundleId: New bundle ID to substitute (replaces the template bundle ID pattern).
    static func apply(
        in directory: URL,
        oldName: String = "Forge",
        newName: String,
        bundleId: String
    ) throws {
        // Step 1: Replace content in text files (handles most occurrences of oldName)
        try replaceContentInTextFiles(in: directory, oldName: oldName, newName: newName)

        // Step 2: Update bundle IDs in xcconfig files (replaces com.organization.Forge* pattern)
        try updateBundleIdsInXcconfigs(in: directory, newName: newName, bundleId: bundleId)

        // Step 3: Update display names in xcconfig files
        try updateDisplayNamesInXcconfigs(in: directory, oldName: oldName, newName: newName)

        // Step 4: Rename files containing oldName (deepest first via recursion)
        try renameFilesRecursive(in: directory, oldName: oldName, newName: newName)

        // Step 5: Rename directories containing oldName (deepest first)
        try renameDirectories(in: directory, oldName: oldName, newName: newName)
    }

    // MARK: - Content Replacement

    private static func replaceContentInTextFiles(
        in directory: URL, oldName: String, newName: String
    ) throws {
        let enumerator = FileManager.default.enumerator(
            at: directory,
            includingPropertiesForKeys: [.isRegularFileKey, .isDirectoryKey],
            options: [.skipsHiddenFiles]
        )
        guard let enumerator else {
            throw TemplateError.enumerationFailed(directory.path)
        }

        for case let fileURL as URL in enumerator {
            // Skip excluded paths
            if fileURL.pathComponents.contains(where: { excludedPaths.contains($0) }) {
                enumerator.skipDescendants()
                continue
            }

            let ext = fileURL.pathExtension.lowercased()
            guard textExtensions.contains(ext) else { continue }
            guard let vals = try? fileURL.resourceValues(forKeys: [.isRegularFileKey]),
                  vals.isRegularFile == true else { continue }

            let content: String
            do {
                content = try String(contentsOf: fileURL, encoding: .utf8)
            } catch {
                // Non-UTF8 or binary file — skip silently
                continue
            }

            guard content.contains(oldName) else { continue }

            let updated = content.replacingOccurrences(of: oldName, with: newName)
            try updated.write(to: fileURL, atomically: true, encoding: .utf8)
        }
    }

    // MARK: - Bundle ID Updates in xcconfig files

    private static func updateBundleIdsInXcconfigs(
        in directory: URL, newName: String, bundleId: String
    ) throws {
        // At this point in the flow, the old directory "Forge" has been content-replaced
        // but NOT yet renamed to newName (renaming happens after this step).
        // We search for any Configurations/ directory recursively.
        let configurationsDir = findConfigurationsDir(in: directory)

        guard let configurationsDir else { return }

        let xcconfigs = try FileManager.default.contentsOfDirectory(
            at: configurationsDir,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ).filter { $0.pathExtension == "xcconfig" }

        for xcconfig in xcconfigs {
            let filename = xcconfig.lastPathComponent.lowercased()
            var content = try String(contentsOf: xcconfig, encoding: .utf8)

            let newBundleId: String
            if filename.contains("mock") {
                newBundleId = "\(bundleId).mock"
            } else if filename.contains("development") || filename.contains("dev") {
                newBundleId = "\(bundleId).dev"
            } else {
                newBundleId = bundleId
            }

            // Replace PRODUCT_BUNDLE_IDENTIFIER line
            let lines = content.components(separatedBy: "\n")
            let updatedLines = lines.map { line -> String in
                guard line.hasPrefix("PRODUCT_BUNDLE_IDENTIFIER") else { return line }
                // Split at '=' and replace the value
                let parts = line.split(separator: "=", maxSplits: 1)
                guard parts.count == 2 else { return line }
                return "PRODUCT_BUNDLE_IDENTIFIER = \(newBundleId)"
            }
            content = updatedLines.joined(separator: "\n")
            try content.write(to: xcconfig, atomically: true, encoding: .utf8)
        }
    }

    // MARK: - Display Name Updates in xcconfig files

    private static func updateDisplayNamesInXcconfigs(
        in directory: URL, oldName: String, newName: String
    ) throws {
        // Display names are already updated by replaceContentInTextFiles since
        // "Forge - Mock" becomes "NewApp - Mock" etc. No extra action needed.
        // This hook is available for future customization.
    }

    // MARK: - File Renaming (deepest first via recursion)

    static func renameFilesRecursive(
        in directory: URL, oldName: String, newName: String
    ) throws {
        let contents = try FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.isDirectoryKey, .isRegularFileKey],
            options: [.skipsHiddenFiles]
        )

        for url in contents {
            let name = url.lastPathComponent
            guard !excludedPaths.contains(name) else { continue }

            let isDir = (try? url.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory ?? false

            if isDir {
                // Recurse first (depth-first)
                try renameFilesRecursive(in: url, oldName: oldName, newName: newName)
            } else if name.contains(oldName) {
                let newFileName = name.replacingOccurrences(of: oldName, with: newName)
                let newURL = url.deletingLastPathComponent().appendingPathComponent(newFileName)
                try FileManager.default.moveItem(at: url, to: newURL)
            }
        }
    }

    // MARK: - Directory Renaming (deepest first)

    static func renameDirectories(in directory: URL, oldName: String, newName: String) throws {
        var dirsToRename: [(depth: Int, url: URL)] = []
        collectDirs(in: directory, oldName: oldName, currentDepth: 0, result: &dirsToRename)

        // Sort deepest first to avoid path invalidation
        let sorted = dirsToRename.sorted { $0.depth > $1.depth }
        for item in sorted {
            let name = item.url.lastPathComponent
            let newDirName = name.replacingOccurrences(of: oldName, with: newName)
            let newURL = item.url.deletingLastPathComponent().appendingPathComponent(newDirName)
            try FileManager.default.moveItem(at: item.url, to: newURL)
        }
    }

    private static func findConfigurationsDir(in directory: URL) -> URL? {
        // Search for Configurations/ directory within the copied template
        let enumerator = FileManager.default.enumerator(
            at: directory, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles]
        )
        for case let url as URL in enumerator ?? .init() {
            if url.lastPathComponent == "Configurations",
               (try? url.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true {
                return url
            }
        }
        return nil
    }

    private static func collectDirs(
        in directory: URL, oldName: String, currentDepth: Int,
        result: inout [(depth: Int, url: URL)]
    ) {
        guard let contents = try? FileManager.default.contentsOfDirectory(
            at: directory, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles]
        ) else { return }

        for url in contents {
            let name = url.lastPathComponent
            guard !excludedPaths.contains(name) else { continue }
            let isDir = (try? url.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory ?? false
            guard isDir else { continue }

            if name.contains(oldName) {
                result.append((depth: currentDepth, url: url))
            }
            collectDirs(in: url, oldName: oldName, currentDepth: currentDepth + 1, result: &result)
        }
    }
}

enum TemplateError: Error, CustomStringConvertible {
    case enumerationFailed(String)
    case templateRootNotFound
    case corePackagesNotFound

    var description: String {
        switch self {
        case .enumerationFailed(let path):
            return "Failed to enumerate directory: \(path)"
        case .templateRootNotFound:
            return "Template root not found. Run the CLI from within the Forge template repository."
        case .corePackagesNotFound:
            return "Core packages not found at Packages/core-packages within the template root."
        }
    }
}
