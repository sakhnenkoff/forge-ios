//
//  DataManagerServices.swift
//  Forge
//
//  Local data manager adapters.
//

import Foundation

struct ProductionUserServices: @MainActor DMDocumentServices {
    let remote: any RemoteDocumentService<UserModel>
    let local: any LocalDocumentPersistence<UserModel>

    init() {
        self.remote = FirestoreRemoteDocumentService<UserModel>(collectionPath: {
            "users"
        })
        self.local = FileManagerDocumentPersistence<UserModel>(managerKey: "User")
    }
}

struct MockUserServices: @MainActor DMDocumentServices {
    let remote: any RemoteDocumentService<UserModel>
    let local: any LocalDocumentPersistence<UserModel>

    init(document: UserModel? = nil) {
        let inMemory = InMemoryDocumentPersistence<UserModel>()
        if let document {
            try? inMemory.saveCache(DocumentCache(document: document))
        }
        self.local = inMemory
        self.remote = MockRemoteDocumentService(initial: document)
    }
}

final class MockRemoteDocumentService<Model: StringIdentifiable & Codable>: RemoteDocumentService {
    private var document: Model?

    init(initial: Model?) {
        self.document = initial
    }

    func fetch(documentId: String) async throws -> Model {
        if let document {
            return document
        }
        throw MockRemoteError.documentNotFound
    }

    func save(document: Model, documentId: String) async throws {
        self.document = document
    }

    func update(documentId: String, data: [String: Any]) async throws {
        guard let current = document else { throw MockRemoteError.documentNotFound }
        guard let encoded = try? JSONEncoder().encode(current) else { return }
        guard var json = try? JSONSerialization.jsonObject(with: encoded) as? [String: Any] else { return }
        data.forEach { key, value in
            json[key] = value
        }
        guard let updatedData = try? JSONSerialization.data(withJSONObject: json) else { return }
        self.document = try? JSONDecoder().decode(Model.self, from: updatedData)
    }

    func delete(documentId: String) async throws {
        document = nil
    }

    func listen(documentId: String, onChange: @escaping (Result<Model, Error>) -> Void) -> any RemoteDocumentListener {
        if let document {
            onChange(.success(document))
        } else {
            onChange(.failure(MockRemoteError.documentNotFound))
        }
        return MockRemoteListener()
    }

    enum MockRemoteError: LocalizedError {
        case documentNotFound

        var errorDescription: String? {
            "Mock document not found"
        }
    }
}

private struct MockRemoteListener: RemoteDocumentListener {
    func remove() {}
}

extension DataLogType {
    var type: LogType {
        switch self {
        case .info:
            return .info
        case .analytic:
            return .analytic
        case .warning:
            return .warning
        case .severe:
            return .severe
        }
    }
}

extension LogManager: DataLogger {
    public func trackEvent(event: any DataLogEvent) {
        trackEvent(eventName: event.eventName, parameters: event.parameters, type: event.type.type)
    }
}
