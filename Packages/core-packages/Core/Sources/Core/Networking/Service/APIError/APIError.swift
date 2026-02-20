import Foundation

public enum APIError: Error, Equatable {
    case invalidURL
    case invalidResponse
    case notFound
    case unauthorized
    case serverError(statusCode: Int)
    case decoding(error: Error)
    case network(error: Error)
    case unknown

    public static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.invalidResponse, .invalidResponse),
             (.notFound, .notFound),
             (.unauthorized, .unauthorized),
             (.unknown, .unknown):
            return true
        case (.serverError(let lhsCode), .serverError(let rhsCode)):
            return lhsCode == rhsCode
        case (.decoding, .decoding),
             (.network, .network):
            return true
        default:
            return false
        }
    }
}

extension APIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .notFound:
            return "Resource not found"
        case .unauthorized:
            return "Unauthorized access"
        case .serverError(let statusCode):
            return "Server error: \(statusCode)"
        case .decoding(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .network(let error):
            return "Network error: \(error.localizedDescription)"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}
