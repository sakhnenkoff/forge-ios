//
//  DataManagerTypes.swift
//  Forge
//
//  Local data manager primitives.
//

import Foundation

struct DataManagerSyncConfiguration {
    let managerKey: String
    let enablePendingWrites: Bool

    static func mockNoPendingWrites() -> DataManagerSyncConfiguration {
        DataManagerSyncConfiguration(managerKey: "MockManager", enablePendingWrites: false)
    }
}

enum DataLogType {
    case info
    case analytic
    case warning
    case severe
}

protocol DataLogEvent {
    var eventName: String { get }
    var parameters: [String: Any]? { get }
    var type: DataLogType { get }
}

protocol DataLogger {
    func trackEvent(event: any DataLogEvent)
}

protocol RemoteDocumentListener {
    func remove()
}

@MainActor
protocol RemoteDocumentService<Model> {
    associatedtype Model: Codable

    func fetch(documentId: String) async throws -> Model
    func save(document: Model, documentId: String) async throws
    func update(documentId: String, data: [String: Any]) async throws
    func delete(documentId: String) async throws
    func listen(documentId: String, onChange: @escaping (Result<Model, Error>) -> Void) -> any RemoteDocumentListener
}

@MainActor
protocol LocalDocumentPersistence<Model> {
    associatedtype Model: Codable

    func loadCache() throws -> DocumentCache<Model>?
    func saveCache(_ cache: DocumentCache<Model>) throws
    func clearCache() throws
}

@MainActor
protocol DMDocumentServices<Model> {
    associatedtype Model: Codable
    var remote: any RemoteDocumentService<Model> { get }
    var local: any LocalDocumentPersistence<Model> { get }
}

struct DocumentCache<Model: Codable>: Codable {
    // Semantic versioning: MAJOR.MINOR (no PATCH for cache schemas)
    // MAJOR: Breaking changes (field removed, type changed)
    // MINOR: Additive changes (new optional field)
    static var currentVersion: String { "1.0" }

    let version: String
    var document: Model?
    var pendingWrites: [PendingWrite<Model>]

    init(document: Model?, pendingWrites: [PendingWrite<Model>] = []) {
        self.version = Self.currentVersion
        self.document = document
        self.pendingWrites = pendingWrites
    }

    // Strict equality check - any version mismatch requires migration
    var isCompatible: Bool {
        version == Self.currentVersion
    }
}

struct PendingWrite<Model: Codable>: Codable {
    enum Kind: String, Codable {
        case save
        case update
        case delete
    }

    let kind: Kind
    let document: Model?
    let updateData: [String: CodableValue]?

    static func save(_ document: Model) -> PendingWrite<Model> {
        PendingWrite(kind: .save, document: document, updateData: nil)
    }

    static func update(_ data: [String: CodableValue]) -> PendingWrite<Model> {
        PendingWrite(kind: .update, document: nil, updateData: data)
    }

    static func delete() -> PendingWrite<Model> {
        PendingWrite(kind: .delete, document: nil, updateData: nil)
    }
}

enum CodableValue: Codable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case date(Date)

    init?(any: Any) {
        if let value = any as? String {
            self = .string(value)
        } else if let value = any as? Int {
            self = .int(value)
        } else if let value = any as? Double {
            self = .double(value)
        } else if let value = any as? Bool {
            self = .bool(value)
        } else if let value = any as? Date {
            self = .date(value)
        } else {
            return nil
        }
    }

    var anyValue: Any {
        switch self {
        case .string(let value): return value
        case .int(let value): return value
        case .double(let value): return value
        case .bool(let value): return value
        case .date(let value): return value
        }
    }
}

extension Dictionary where Key == String, Value == CodableValue {
    var anyDictionary: [String: Any] {
        var output: [String: Any] = [:]
        for (key, value) in self {
            output[key] = value.anyValue
        }
        return output
    }
}
