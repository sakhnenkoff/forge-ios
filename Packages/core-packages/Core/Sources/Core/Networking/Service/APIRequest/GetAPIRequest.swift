import Foundation

public protocol GetAPIRequest: APIRequest {}

public extension GetAPIRequest {
    var method: HTTPMethod { .get }
    var body: Data? { nil }
}
