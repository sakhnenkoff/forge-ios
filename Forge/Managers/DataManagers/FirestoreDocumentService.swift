//
//  FirestoreDocumentService.swift
//  Forge
//

import Foundation
import FirebaseFirestore

enum FirestoreError: LocalizedError, CustomNSError {
    case missingDocument
    case encodingFailed(underlying: Error)
    case decodingFailed(underlying: Error)
    case networkError(underlying: Error)
    case unknown(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .missingDocument:
            return "Document not found"
        case .encodingFailed:
            return "Failed to encode document data"
        case .decodingFailed:
            return "Failed to decode document data"
        case .networkError:
            return "Network error occurred"
        case .unknown:
            return "An unknown error occurred"
        }
    }

    static var errorDomain: String { "FirestoreErrorDomain" }

    var errorCode: Int {
        switch self {
        case .missingDocument: return 2001
        case .encodingFailed: return 2002
        case .decodingFailed: return 2003
        case .networkError: return 2004
        case .unknown: return 2005
        }
    }

    var errorUserInfo: [String: Any] {
        var userInfo: [String: Any] = [NSLocalizedDescriptionKey: errorDescription ?? ""]
        if let underlying = underlyingError {
            userInfo[NSUnderlyingErrorKey] = underlying
        }
        return userInfo
    }

    var underlyingError: Error? {
        switch self {
        case .missingDocument:
            return nil
        case .encodingFailed(let error),
             .decodingFailed(let error),
             .networkError(let error),
             .unknown(let error):
            return error
        }
    }
}

final class FirestoreRemoteDocumentService<Model: Codable>: RemoteDocumentService {
    private let collectionPath: () -> String
    private let firestore: Firestore

    init(collectionPath: @escaping () -> String, firestore: Firestore = .firestore()) {
        self.collectionPath = collectionPath
        self.firestore = firestore
    }

    func fetch(documentId: String) async throws -> Model {
        let ref = firestore.collection(collectionPath()).document(documentId)
        let snapshot = try await ref.getDocument()
        guard let data = snapshot.data() else {
            throw FirestoreError.missingDocument
        }
        do {
            return try decodeModel(from: data)
        } catch {
            throw FirestoreError.decodingFailed(underlying: error)
        }
    }

    func save(document: Model, documentId: String) async throws {
        let ref = firestore.collection(collectionPath()).document(documentId)
        let data = try encodeModel(document)
        try await ref.setData(data, merge: true)
    }

    func update(documentId: String, data: [String: Any]) async throws {
        let ref = firestore.collection(collectionPath()).document(documentId)
        try await ref.updateData(data)
    }

    func delete(documentId: String) async throws {
        let ref = firestore.collection(collectionPath()).document(documentId)
        try await ref.delete()
    }

    func listen(documentId: String, onChange: @escaping (Result<Model, Error>) -> Void) -> any RemoteDocumentListener {
        let ref = firestore.collection(collectionPath()).document(documentId)
        let registration = ref.addSnapshotListener { snapshot, error in
            if let error {
                onChange(.failure(error))
                return
            }
            guard let snapshot, let data = snapshot.data() else {
                onChange(.failure(FirestoreError.missingDocument))
                return
            }
            do {
                let model = try self.decodeModel(from: data)
                onChange(.success(model))
            } catch {
                onChange(.failure(FirestoreError.decodingFailed(underlying: error)))
            }
        }
        return FirestoreDocumentListener(registration: registration)
    }

    private func encodeModel(_ model: Model) throws -> [String: Any] {
        do {
            let data = try JSONEncoder().encode(model)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            guard let dictionary = json as? [String: Any] else {
                throw FirestoreError.encodingFailed(underlying: NSError(domain: "Firestore", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to encode document"]))
            }
            let converted = FirestoreValueConverter.convertToFirestore(dictionary)
            guard let firestoreDict = converted as? [String: Any] else {
                throw FirestoreError.encodingFailed(underlying: NSError(domain: "Firestore", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to encode document"]))
            }
            return firestoreDict
        } catch let error as FirestoreError {
            throw error
        } catch {
            throw FirestoreError.encodingFailed(underlying: error)
        }
    }

    private func decodeModel(from data: [String: Any]) throws -> Model {
        do {
            let normalized = FirestoreValueConverter.convertFromFirestore(data)
            let jsonData = try JSONSerialization.data(withJSONObject: normalized, options: [])
            return try JSONDecoder().decode(Model.self, from: jsonData)
        } catch let error as FirestoreError {
            throw error
        } catch {
            throw FirestoreError.decodingFailed(underlying: error)
        }
    }
}

private final class FirestoreDocumentListener: RemoteDocumentListener {
    private let registration: ListenerRegistration

    init(registration: ListenerRegistration) {
        self.registration = registration
    }

    func remove() {
        registration.remove()
    }
}

private enum FirestoreValueConverter {
    static func convertToFirestore(_ value: Any) -> Any {
        switch value {
        case let date as Date:
            return Timestamp(date: date)
        case let dict as [String: Any]:
            var result: [String: Any] = [:]
            for (key, value) in dict {
                result[key] = convertToFirestore(value)
            }
            return result
        case let array as [Any]:
            return array.map { convertToFirestore($0) }
        default:
            return value
        }
    }

    static func convertFromFirestore(_ value: Any) -> Any {
        switch value {
        case let timestamp as Timestamp:
            return timestamp.dateValue()
        case let dict as [String: Any]:
            var result: [String: Any] = [:]
            for (key, value) in dict {
                result[key] = convertFromFirestore(value)
            }
            return result
        case let array as [Any]:
            return array.map { convertFromFirestore($0) }
        default:
            return value
        }
    }
}
