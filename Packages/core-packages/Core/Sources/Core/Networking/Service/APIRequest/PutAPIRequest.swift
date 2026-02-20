import Foundation

public protocol PutAPIRequest: APIRequest {
    associatedtype RequestBody: Encodable
    var requestBody: RequestBody { get }
}

public extension PutAPIRequest {
    var method: HTTPMethod { .put }

    var body: Data? {
        try? JSONEncoder().encode(requestBody)
    }
}
