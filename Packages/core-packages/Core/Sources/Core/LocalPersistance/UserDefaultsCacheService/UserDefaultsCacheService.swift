import Foundation

public protocol UserDefaultsCacheServiceProtocol: Sendable {
    func save<T: Encodable>(_ object: T, for key: String) throws
    func fetch<T: Decodable>(for key: String) throws -> T?
    func remove(for key: String)
    func removeAll(forDomain domain: String)
}

public struct UserDefaultsCacheService: UserDefaultsCacheServiceProtocol {
    // SAFETY: Access is delegated to UserDefaults, which is documented as thread-safe.
    // TODO(CONC-004): Revisit this annotation when Foundation's sendability coverage improves.
    private nonisolated(unsafe) let userDefaults: UserDefaults

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    public func save<T: Encodable>(_ object: T, for key: String) throws {
        let data = try JSONEncoder().encode(object)
        userDefaults.set(data, forKey: key)
    }

    public func fetch<T: Decodable>(for key: String) throws -> T? {
        guard let data = userDefaults.data(forKey: key) else { return nil }
        return try JSONDecoder().decode(T.self, from: data)
    }

    public func remove(for key: String) {
        userDefaults.removeObject(forKey: key)
    }

    public func removeAll(forDomain domain: String) {
        userDefaults.removePersistentDomain(forName: domain)
    }
}
