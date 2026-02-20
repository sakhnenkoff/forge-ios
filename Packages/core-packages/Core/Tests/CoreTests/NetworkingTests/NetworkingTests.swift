import XCTest
@testable import Core

final class NetworkingTests: XCTestCase {
    func testAPIErrorEquality() throws {
        XCTAssertEqual(APIError.notFound, APIError.notFound)
        XCTAssertEqual(APIError.serverError(statusCode: 500), APIError.serverError(statusCode: 500))
        XCTAssertNotEqual(APIError.serverError(statusCode: 500), APIError.serverError(statusCode: 404))
    }

    func testHTTPMethod() throws {
        XCTAssertEqual(HTTPMethod.get.rawValue, "GET")
        XCTAssertEqual(HTTPMethod.post.rawValue, "POST")
        XCTAssertEqual(HTTPMethod.put.rawValue, "PUT")
        XCTAssertEqual(HTTPMethod.delete.rawValue, "DELETE")
    }
}
