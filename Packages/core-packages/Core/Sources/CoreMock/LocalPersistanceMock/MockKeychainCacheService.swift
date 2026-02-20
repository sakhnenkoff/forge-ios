import Foundation
import Core

// SAFETY: All mutable state is accessed under `lock`.
// TODO(CONC-001): Replace with an actor-based mock when protocols move to async APIs.
public final class MockKeychainCacheService: KeychainCacheServiceProtocol, @unchecked Sendable {
    private var stringStorage: [String: String] = [:]
    private var dataStorage: [String: Data] = [:]
    private let lock = NSLock()

    public init() {}

    @discardableResult
    public func save(_ string: String, for key: String) -> Bool {
        withLock {
            stringStorage[key] = string
        }
        return true
    }

    @discardableResult
    public func save(_ data: Data, for key: String) -> Bool {
        withLock {
            dataStorage[key] = data
        }
        return true
    }

    @discardableResult
    public func save<T: Encodable>(_ object: T, for key: String) throws -> Bool {
        let data = try JSONEncoder().encode(object)
        withLock {
            dataStorage[key] = data
        }
        return true
    }

    public func fetchString(for key: String) -> String? {
        withLock { stringStorage[key] }
    }

    public func fetchData(for key: String) -> Data? {
        withLock { dataStorage[key] }
    }

    public func fetch<T: Decodable>(for key: String) throws -> T? {
        let data = withLock { dataStorage[key] }
        guard let data else { return nil }
        return try JSONDecoder().decode(T.self, from: data)
    }

    @discardableResult
    public func remove(for key: String) -> Bool {
        withLock {
            _ = stringStorage.removeValue(forKey: key)
            _ = dataStorage.removeValue(forKey: key)
        }
        return true
    }

    @discardableResult
    public func removeAll() -> Bool {
        withLock {
            stringStorage.removeAll()
            dataStorage.removeAll()
        }
        return true
    }

    private func withLock<T>(_ operation: () throws -> T) rethrows -> T {
        lock.lock()
        defer { lock.unlock() }
        return try operation()
    }
}
