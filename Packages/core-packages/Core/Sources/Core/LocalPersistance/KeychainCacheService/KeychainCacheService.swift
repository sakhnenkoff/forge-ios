import Foundation
import SwiftKeychainWrapper

public protocol KeychainCacheServiceProtocol: Sendable {
    func save(_ string: String, for key: String) -> Bool
    func save(_ data: Data, for key: String) -> Bool
    func save<T: Encodable>(_ object: T, for key: String) throws -> Bool
    func fetchString(for key: String) -> String?
    func fetchData(for key: String) -> Data?
    func fetch<T: Decodable>(for key: String) throws -> T?
    func remove(for key: String) -> Bool
    func removeAll() -> Bool
}

public struct KeychainCacheService: KeychainCacheServiceProtocol {
    // SAFETY: Access is delegated to KeychainWrapper, which is internally synchronized.
    // TODO(CONC-005): Remove this annotation when SwiftKeychainWrapper exposes Sendable conformance.
    private nonisolated(unsafe) let keychain: KeychainWrapper

    public init(keychain: KeychainWrapper = .standard) {
        self.keychain = keychain
    }

    @discardableResult
    public func save(_ string: String, for key: String) -> Bool {
        keychain.set(string, forKey: key)
    }

    @discardableResult
    public func save(_ data: Data, for key: String) -> Bool {
        keychain.set(data, forKey: key)
    }

    @discardableResult
    public func save<T: Encodable>(_ object: T, for key: String) throws -> Bool {
        let data = try JSONEncoder().encode(object)
        return keychain.set(data, forKey: key)
    }

    public func fetchString(for key: String) -> String? {
        keychain.string(forKey: key)
    }

    public func fetchData(for key: String) -> Data? {
        keychain.data(forKey: key)
    }

    public func fetch<T: Decodable>(for key: String) throws -> T? {
        guard let data = keychain.data(forKey: key) else { return nil }
        return try JSONDecoder().decode(T.self, from: data)
    }

    @discardableResult
    public func remove(for key: String) -> Bool {
        keychain.removeObject(forKey: key)
    }

    @discardableResult
    public func removeAll() -> Bool {
        keychain.removeAllKeys()
    }
}
