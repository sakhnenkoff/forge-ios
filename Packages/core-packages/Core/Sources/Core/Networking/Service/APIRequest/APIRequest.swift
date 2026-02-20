import Foundation

public protocol APIRequest {
    associatedtype ResponseType: Decodable

    var endpoint: String { get }
    var method: HTTPMethod { get }
    var queryItems: [URLQueryItem] { get }
    var headers: [String: String] { get }
    var body: Data? { get }
    var cachePolicy: URLRequest.CachePolicy { get }
    var authorization: Authorization? { get set }

    func generateURLRequest(baseURL: String) -> URLRequest?
}

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

public extension APIRequest {
    var queryItems: [URLQueryItem] { [] }
    var headers: [String: String] { [:] }
    var body: Data? { nil }
    var cachePolicy: URLRequest.CachePolicy { .useProtocolCachePolicy }
    var authorization: Authorization? {
        get { nil }
        set { _ = newValue }
    }

    func generateURLRequest(baseURL: String) -> URLRequest? {
        var components = URLComponents(string: baseURL + endpoint)
        if !queryItems.isEmpty {
            components?.queryItems = queryItems
        }

        guard let url = components?.url else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.cachePolicy = cachePolicy

        // Set default headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // Set custom headers
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        // Set authorization
        if let auth = authorization {
            request.setValue(auth.headerValue, forHTTPHeaderField: auth.headerKey)
        }

        // Set body
        request.httpBody = body

        return request
    }
}
