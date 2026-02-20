import Foundation

struct ProjectGenerator {

    /// Locate the template repository root by walking up from the current working directory.
    /// Looks for `Forge.xcodeproj` within 5 levels.
    static func findTemplateRoot() throws -> URL {
        let cwd = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        var candidate = cwd
        for _ in 0..<6 {
            if FileManager.default.fileExists(
                atPath: candidate.appendingPathComponent("Forge.xcodeproj").path
            ) {
                return candidate
            }
            candidate = candidate.deletingLastPathComponent()
        }
        throw TemplateError.templateRootNotFound
    }

    /// Copy the template files from source to destination, excluding build artifacts.
    func copyTemplateFiles(from source: URL, to destination: URL) throws {
        let excludedNames: Set<String> = [
            ".git", ".swiftpm", "DerivedData", "build",
            "xcuserdata", ".build", "forge-cli",
            ".planning", "scripts", "docs", "Archetypes"
        ]

        let contents = try FileManager.default.contentsOfDirectory(
            at: source,
            includingPropertiesForKeys: [.isDirectoryKey, .isRegularFileKey],
            options: []  // include hidden files like .gitignore
        )

        for item in contents {
            let name = item.lastPathComponent
            // Skip excluded paths and hidden files except .gitignore
            if excludedNames.contains(name) { continue }
            if name.hasPrefix(".") && name != ".gitignore" { continue }

            let destItem = destination.appendingPathComponent(name)
            try FileManager.default.copyItem(at: item, to: destItem)
        }
    }

    /// Write the .template-version file to the output directory using the bundled version.txt.
    func writeTemplateVersionFile(to outputDir: URL) throws {
        let versionFile = outputDir.appendingPathComponent(".template-version")

        if let versionURL = Bundle.module.url(forResource: "version", withExtension: "txt"),
           let version = try? String(contentsOf: versionURL, encoding: .utf8)
               .trimmingCharacters(in: .whitespacesAndNewlines) {
            try version.write(to: versionFile, atomically: true, encoding: .utf8)
        } else {
            // Fallback: write "unknown" rather than fail generation
            try "unknown".write(to: versionFile, atomically: true, encoding: .utf8)
        }
    }

    /// Copy the local core packages (DesignSystem, Core, CoreMock) into the generated project.
    /// Makes the project fully self-contained — no external path dependencies.
    func copyCorePackages(templateRoot: URL, to outputDir: URL) throws {
        // Core packages live at Packages/core-packages within the template root (monorepo)
        let coreSource = templateRoot
            .appendingPathComponent("Packages")
            .appendingPathComponent("core-packages")

        guard FileManager.default.fileExists(atPath: coreSource.path) else {
            throw TemplateError.corePackagesNotFound
        }

        let packagesDir = outputDir.appendingPathComponent("Packages")
        let coreDest = packagesDir.appendingPathComponent("core-packages")

        try FileManager.default.createDirectory(at: packagesDir, withIntermediateDirectories: true)
        try FileManager.default.copyItem(at: coreSource, to: coreDest)

        // Remove build artifacts from the copy
        for artifact in [".git", ".build", ".swiftpm", "DerivedData", "xcuserdata"] {
            let path = coreDest.appendingPathComponent(artifact)
            try? FileManager.default.removeItem(at: path)
        }
    }

    /// Update the local package reference in pbxproj from the template's relative path
    /// to the embedded Packages/core-packages path.
    func updateLocalPackageReference(in outputDir: URL, projectName: String) throws {
        let pbxprojPath = outputDir
            .appendingPathComponent("\(projectName).xcodeproj")
            .appendingPathComponent("project.pbxproj")

        guard FileManager.default.fileExists(atPath: pbxprojPath.path) else { return }

        var content = try String(contentsOf: pbxprojPath, encoding: .utf8)
        content = content.replacingOccurrences(
            of: "../../Packages/forge-core-packages",
            with: "Packages/core-packages"
        )
        try content.write(to: pbxprojPath, atomically: true, encoding: .utf8)
    }

    /// Remove stale Package.resolved so Xcode re-resolves packages fresh.
    func removeStalePackageResolved(in outputDir: URL, projectName: String) throws {
        let resolvedPath = outputDir
            .appendingPathComponent("\(projectName).xcodeproj")
            .appendingPathComponent("project.xcworkspace")
            .appendingPathComponent("xcshareddata")
            .appendingPathComponent("swiftpm")
            .appendingPathComponent("Package.resolved")
        try? FileManager.default.removeItem(at: resolvedPath)
    }

    /// Generate a new project from the Forge template.
    ///
    /// Copies template, embeds core packages, renames everything, applies feature flags,
    /// writes .template-version. Cleans up the output directory on any failure.
    ///
    /// - Parameters:
    ///   - config: User's generation config from the wizard.
    ///   - allManifests: All feature manifests (for flag writing).
    func generate(config: GenerationConfig, allManifests: [FeatureManifest]) throws {
        let templateRoot = try Self.findTemplateRoot()
        let outputDir = config.outputDir

        // Fail fast if output already exists
        if FileManager.default.fileExists(atPath: outputDir.path) {
            throw GeneratorError.outputDirectoryExists(outputDir.path)
        }

        // Create output directory
        try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)

        // Cleanup on any failure (locked user decision: clean up partial output)
        var succeeded = false
        defer {
            if !succeeded {
                try? FileManager.default.removeItem(at: outputDir)
            }
        }

        // Step 1: Copy template files
        try copyTemplateFiles(from: templateRoot, to: outputDir)

        // Step 2: Embed core packages (DesignSystem, Core, CoreMock)
        try copyCorePackages(templateRoot: templateRoot, to: outputDir)

        // Step 3: Apply name substitution + bundle ID
        try TemplateEngine.apply(
            in: outputDir,
            oldName: "Forge",
            newName: config.projectName,
            bundleId: config.bundleId
        )

        // Step 4: Fix local package reference path in pbxproj
        try updateLocalPackageReference(in: outputDir, projectName: config.projectName)

        // Step 5: Remove stale Package.resolved
        try removeStalePackageResolved(in: outputDir, projectName: config.projectName)

        // Step 6: Apply feature flags
        try FeatureFlagWriter.apply(
            selectedFeatureIds: Set(config.resolvedFeatureIds),
            allManifests: allManifests,
            in: outputDir,
            projectName: config.projectName
        )

        // Step 7: Write .template-version
        try writeTemplateVersionFile(to: outputDir)

        succeeded = true
    }
}

enum GeneratorError: Error, CustomStringConvertible {
    case outputDirectoryExists(String)

    var description: String {
        switch self {
        case .outputDirectoryExists(let path):
            return "Output directory already exists: \(path)\nChoose a different path or remove the existing directory."
        }
    }
}
