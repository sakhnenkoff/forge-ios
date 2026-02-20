import Foundation

/// Discovers and loads archetype manifests from the `Archetypes/` directory.
struct ArchetypeRegistry {

    /// Load all available archetypes from `Archetypes/` within the template root.
    static func loadAll(templateRoot: URL) throws -> [ArchetypeManifest] {
        let archetypesDir = templateRoot.appendingPathComponent("Archetypes")
        guard FileManager.default.fileExists(atPath: archetypesDir.path) else {
            return []
        }

        let contents = try FileManager.default.contentsOfDirectory(
            at: archetypesDir,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        )

        var manifests: [ArchetypeManifest] = []
        for dir in contents {
            let isDir = (try? dir.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory ?? false
            guard isDir else { continue }

            let manifestFile = dir.appendingPathComponent("manifest.json")
            guard FileManager.default.fileExists(atPath: manifestFile.path) else { continue }

            let data = try Data(contentsOf: manifestFile)
            let manifest = try JSONDecoder().decode(ArchetypeManifest.self, from: data)
            manifests.append(manifest)
        }

        // Sort: blank first, then alphabetically
        return manifests.sorted { a, b in
            if a.id == "blank" { return true }
            if b.id == "blank" { return false }
            return a.displayName < b.displayName
        }
    }

    /// Find a specific archetype by ID.
    static func find(id: String, templateRoot: URL) throws -> ArchetypeManifest? {
        let archetypeDir = templateRoot
            .appendingPathComponent("Archetypes")
            .appendingPathComponent(id)
        let manifestFile = archetypeDir.appendingPathComponent("manifest.json")

        guard FileManager.default.fileExists(atPath: manifestFile.path) else {
            return nil
        }

        let data = try Data(contentsOf: manifestFile)
        return try JSONDecoder().decode(ArchetypeManifest.self, from: data)
    }
}
