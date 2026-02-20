import Foundation

struct DependencyResolver {

    /// Result of dependency resolution.
    struct Resolution {
        /// Features explicitly selected by the user.
        let selected: [String]
        /// Additional features required by selected features (not originally selected).
        let addedDependencies: [(feature: String, requiredBy: String)]
        /// Final ordered list (dependencies before dependents).
        let resolved: [String]
    }

    /// Resolve dependencies for the selected feature IDs.
    ///
    /// - Parameters:
    ///   - selected: Feature IDs the user selected.
    ///   - all: All available manifests.
    /// - Returns: Resolution containing added dependencies and the full ordered list.
    /// - Throws: `DependencyError.circularDependency` if a cycle is detected.
    static func resolve(
        selected: [String],
        all: [FeatureManifest]
    ) throws -> Resolution {
        let manifestById = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })
        var selectedSet = Set(selected)
        var addedDependencies: [(feature: String, requiredBy: String)] = []

        // Expand selection to include all transitive dependencies
        var toProcess = selected
        var processed = Set<String>()

        while !toProcess.isEmpty {
            let current = toProcess.removeFirst()
            guard !processed.contains(current) else { continue }
            processed.insert(current)

            guard let manifest = manifestById[current] else {
                throw DependencyError.unknownFeature(current)
            }

            for dep in manifest.dependencies where !selectedSet.contains(dep) {
                selectedSet.insert(dep)
                addedDependencies.append((feature: dep, requiredBy: current))
                toProcess.append(dep)
            }
        }

        // Topological sort (Kahn's algorithm) over final selection
        let sorted = try topologicalSort(ids: Array(selectedSet), manifestById: manifestById)

        return Resolution(
            selected: selected,
            addedDependencies: addedDependencies,
            resolved: sorted
        )
    }

    // MARK: - Private

    private static func topologicalSort(
        ids: [String],
        manifestById: [String: FeatureManifest]
    ) throws -> [String] {
        let idSet = Set(ids)
        // In-degree count for each node
        var inDegree = Dictionary(uniqueKeysWithValues: ids.map { ($0, 0) })
        // Adjacency list: id → [ids that depend on id]
        var dependents: [String: [String]] = [:]

        for id in ids {
            guard let manifest = manifestById[id] else { continue }
            for dep in manifest.dependencies where idSet.contains(dep) {
                inDegree[id, default: 0] += 1
                dependents[dep, default: []].append(id)
            }
        }

        var queue = ids.filter { (inDegree[$0] ?? 0) == 0 }.sorted()
        var result: [String] = []

        while !queue.isEmpty {
            let current = queue.removeFirst()
            result.append(current)

            for dependent in (dependents[current] ?? []).sorted() {
                inDegree[dependent, default: 1] -= 1
                if inDegree[dependent] == 0 {
                    queue.append(dependent)
                    queue.sort()
                }
            }
        }

        if result.count != ids.count {
            throw DependencyError.circularDependency
        }

        return result
    }
}

enum DependencyError: Error, CustomStringConvertible {
    case unknownFeature(String)
    case circularDependency

    var description: String {
        switch self {
        case .unknownFeature(let id):
            return "Unknown feature: '\(id)'. Available features are listed in --help."
        case .circularDependency:
            return "Circular dependency detected in feature manifests. This is a CLI bug."
        }
    }
}
