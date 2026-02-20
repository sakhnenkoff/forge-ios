import Foundation

/// Loads all feature manifests from the bundled Resources/features/ directory.
struct FeatureRegistry {

    /// All available features, loaded from bundled JSON manifests.
    static func load() throws -> [FeatureManifest] {
        guard let featuresURL = Bundle.module.url(forResource: "features", withExtension: nil) else {
            throw RegistryError.resourceBundleMissing
        }

        let jsonFiles = try FileManager.default
            .contentsOfDirectory(at: featuresURL, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "json" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }

        guard !jsonFiles.isEmpty else {
            throw RegistryError.noManifestsFound
        }

        let decoder = JSONDecoder()
        return try jsonFiles.map { url in
            let data = try Data(contentsOf: url)
            do {
                return try decoder.decode(FeatureManifest.self, from: data)
            } catch {
                throw RegistryError.malformedManifest(url.lastPathComponent, error)
            }
        }
    }

    /// Look up a feature by ID.
    static func feature(id: String, from all: [FeatureManifest]) -> FeatureManifest? {
        all.first { $0.id == id }
    }
}

enum RegistryError: Error, CustomStringConvertible {
    case resourceBundleMissing
    case noManifestsFound
    case malformedManifest(String, Error)

    var description: String {
        switch self {
        case .resourceBundleMissing:
            return "Feature manifests bundle not found. This is a CLI bug — please report it."
        case .noManifestsFound:
            return "No feature manifest JSON files found in bundle."
        case .malformedManifest(let name, let error):
            return "Malformed manifest '\(name)': \(error)"
        }
    }
}
