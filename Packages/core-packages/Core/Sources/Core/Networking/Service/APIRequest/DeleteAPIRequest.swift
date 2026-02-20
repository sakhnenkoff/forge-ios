import Foundation

public protocol DeleteAPIRequest: APIRequest {}

public extension DeleteAPIRequest {
    var method: HTTPMethod { .delete }
    var body: Data? { nil }
}
