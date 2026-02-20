import Foundation

public protocol PostAPIRequest: APIRequest {
    associatedtype RequestBody: Encodable
    var requestBody: RequestBody { get }
}

public extension PostAPIRequest {
    var method: HTTPMethod { .post }

    var body: Data? {
        try? JSONEncoder().encode(requestBody)
    }
}
