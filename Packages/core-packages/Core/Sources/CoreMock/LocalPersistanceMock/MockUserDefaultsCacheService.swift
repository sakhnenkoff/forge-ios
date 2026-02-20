import Foundation
import Core

// SAFETY: All mutable state is accessed under `lock`.
// TODO(CONC-003): Replace with an actor-based mock when protocols move to async APIs.
public final class MockUserDefaultsCacheService: UserDefaultsCacheServiceProtocol, @unchecked Sendable {
    private var storage: [String: Data] = [:]
    private let lock = NSLock()

    public init() {}

    public func save<T: Encodable>(_ object: T, for key: String) throws {
        let data = try JSONEncoder().encode(object)
        withLock {
            storage[key] = data
        }
    }

    public func fetch<T: Decodable>(for key: String) throws -> T? {
        let data = withLock { storage[key] }
        guard let data else { return nil }
        return try JSONDecoder().decode(T.self, from: data)
    }

    public func remove(for key: String) {
        withLock {
            _ = storage.removeValue(forKey: key)
        }
    }

    public func removeAll(forDomain domain: String) {
        withLock {
            storage.removeAll()
        }
    }

    private func withLock<T>(_ operation: () throws -> T) rethrows -> T {
        lock.lock()
        defer { lock.unlock() }
        return try operation()
    }
}
