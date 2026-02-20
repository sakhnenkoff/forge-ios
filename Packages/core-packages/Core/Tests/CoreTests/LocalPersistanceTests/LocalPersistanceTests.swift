import XCTest
@testable import Core
@testable import CoreMock

final class LocalPersistanceTests: XCTestCase {
    func testUserDefaultsCacheService_saveAndFetch() throws {
        let service = MockUserDefaultsCacheService()
        let testValue = "Hello, World!"

        try service.save(testValue, for: "testKey")
        let fetched: String? = try service.fetch(for: "testKey")

        XCTAssertEqual(fetched, testValue)
    }

    func testUserDefaultsCacheService_remove() throws {
        let service = MockUserDefaultsCacheService()
        let testValue = "Hello, World!"

        try service.save(testValue, for: "testKey")
        service.remove(for: "testKey")
        let fetched: String? = try service.fetch(for: "testKey")

        XCTAssertNil(fetched)
    }

    func testKeychainCacheService_saveAndFetch() throws {
        let service = MockKeychainCacheService()
        let testValue = "SecretToken"

        service.save(testValue, for: "tokenKey")
        let fetched = service.fetchString(for: "tokenKey")

        XCTAssertEqual(fetched, testValue)
    }

    func testKeychainCacheService_removeAll() throws {
        let service = MockKeychainCacheService()

        service.save("value1", for: "key1")
        service.save("value2", for: "key2")
        service.removeAll()

        XCTAssertNil(service.fetchString(for: "key1"))
        XCTAssertNil(service.fetchString(for: "key2"))
    }

    func testMockUserDefaultsCacheService_concurrentAccess() async throws {
        let service = MockUserDefaultsCacheService()
        let iterations = 200

        await withTaskGroup(of: Void.self) { group in
            for index in 0..<iterations {
                group.addTask {
                    try? service.save(index, for: "key-\(index)")
                    let _: Int? = try? service.fetch(for: "key-\(index)")
                }
            }
        }

        for index in 0..<iterations {
            let fetched: Int? = try service.fetch(for: "key-\(index)")
            XCTAssertEqual(fetched, index)
        }
    }

    func testMockKeychainCacheService_concurrentAccess() async {
        let service = MockKeychainCacheService()
        let iterations = 200

        await withTaskGroup(of: Void.self) { group in
            for index in 0..<iterations {
                group.addTask {
                    let key = "token-\(index)"
                    _ = service.save("value-\(index)", for: key)
                    _ = service.fetchString(for: key)
                }
            }
        }

        for index in 0..<iterations {
            let key = "token-\(index)"
            XCTAssertEqual(service.fetchString(for: key), "value-\(index)")
        }
    }
}
