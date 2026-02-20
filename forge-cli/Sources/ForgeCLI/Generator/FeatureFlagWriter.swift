import Foundation

struct FeatureFlagWriter {

    /// Apply selected feature flags to FeatureFlags.swift in the generated project.
    ///
    /// Sets flags for selected features to `true`, unselected features to `false`.
    ///
    /// - Parameters:
    ///   - selectedFeatureIds: The resolved set of selected feature IDs.
    ///   - allManifests: All available feature manifests (to know which flags exist).
    ///   - projectDir: Root of the generated project (post-rename).
    ///   - projectName: The new project name (for locating the FeatureFlags.swift path).
    static func apply(
        selectedFeatureIds: Set<String>,
        allManifests: [FeatureManifest],
        in projectDir: URL,
        projectName: String
    ) throws {
        let flagsPath = projectDir
            .appendingPathComponent(projectName)
            .appendingPathComponent("Utilities")
            .appendingPathComponent("FeatureFlags.swift")

        guard FileManager.default.fileExists(atPath: flagsPath.path) else {
            throw FeatureFlagError.fileNotFound(flagsPath.path)
        }

        var content = try String(contentsOf: flagsPath, encoding: .utf8)

        for manifest in allManifests {
            let flag = manifest.featureFlag
            guard !flag.isEmpty else { continue }

            let isEnabled = selectedFeatureIds.contains(manifest.id)
            let enabledStr = isEnabled ? "true" : "false"

            // Replace "= true" variant
            content = content.replacingOccurrences(
                of: "static let \(flag) = true",
                with: "static let \(flag) = \(enabledStr)"
            )
            // Replace "= false" variant
            content = content.replacingOccurrences(
                of: "static let \(flag) = false",
                with: "static let \(flag) = \(enabledStr)"
            )
        }

        try content.write(to: flagsPath, atomically: true, encoding: .utf8)
    }
}

enum FeatureFlagError: Error, CustomStringConvertible {
    case fileNotFound(String)

    var description: String {
        switch self {
        case .fileNotFound(let path):
            return "FeatureFlags.swift not found at: \(path)"
        }
    }
}
