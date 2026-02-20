import Foundation

/// Provides access to environment configuration values defined in xcconfig files.
///
/// Configuration values are injected via Info.plist at build time.
/// Use the static properties to access configuration values at runtime.
///
/// Example:
/// ```swift
/// let baseURL = Configuration.apiBaseURL
/// let environment = Configuration.environment
/// ```
enum Configuration {
    enum Error: Swift.Error {
        case missingKey
        case invalidValue
    }

    /// Retrieves a value from Info.plist for the given key.
    /// - Parameter key: The Info.plist key to look up
    /// - Returns: The value cast to the specified type
    /// - Throws: `Error.missingKey` if key doesn't exist, `Error.invalidValue` if conversion fails
    static func value<T>(for key: String) throws -> T where T: LosslessStringConvertible {
        guard let object = Bundle.main.object(forInfoDictionaryKey: key) else {
            throw Error.missingKey
        }

        switch object {
        case let value as T:
            return value
        case let string as String:
            guard let value = T(string) else { fallthrough }
            return value
        default:
            throw Error.invalidValue
        }
    }

    // MARK: - Configuration Values

    /// The base URL for API requests.
    /// Returns empty string if not configured (e.g., Mock builds).
    static var apiBaseURL: String {
        (try? value(for: "API_BASE_URL")) ?? ""
    }

    /// The API key for authentication.
    /// Returns empty string if not configured (e.g., Mock builds).
    static var apiKey: String {
        (try? value(for: "API_KEY")) ?? ""
    }

    /// The current environment identifier (mock, dev, prod).
    static var environment: String {
        (try? value(for: "ENVIRONMENT")) ?? "mock"
    }

    /// Whether the app is running in Mock configuration.
    static var isMock: Bool {
        environment == "mock"
    }

    /// Whether the app is running in Development configuration.
    static var isDevelopment: Bool {
        environment == "dev"
    }

    /// Whether the app is running in Production configuration.
    static var isProduction: Bool {
        environment == "prod"
    }
}
