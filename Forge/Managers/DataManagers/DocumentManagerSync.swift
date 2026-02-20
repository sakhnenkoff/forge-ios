//
//  DocumentManagerSync.swift
//  Forge
//
//  Minimal document manager with cache + optional pending writes.
//

import Foundation
import UIKit

@MainActor
class DocumentManagerSync<Model: StringIdentifiable & Codable> {
    private let remote: any RemoteDocumentService<Model>
    private let local: any LocalDocumentPersistence<Model>
    private let configuration: DataManagerSyncConfiguration
    let logger: DataLogger?

    private var documentId: String?
    private var listener: (any RemoteDocumentListener)?
    private var cache: DocumentCache<Model> {
        didSet { persistCache() }
    }

    var currentDocument: Model? {
        cache.document
    }

    init<S: DMDocumentServices>(
        services: S,
        configuration: DataManagerSyncConfiguration = .mockNoPendingWrites(),
        logger: DataLogger? = nil
    ) where S.Model == Model {
        self.remote = services.remote
        self.local = services.local
        self.configuration = configuration
        self.logger = logger

        // Load cache with version compatibility check (DEBT-02)
        let loadedCache = (try? services.local.loadCache()) ?? DocumentCache(document: nil)

        // Silent migration: delete cache if version mismatch
        if !loadedCache.isCompatible {
            try? services.local.clearCache()
            self.cache = DocumentCache(document: nil)
        } else {
            self.cache = loadedCache
        }

        // Lifecycle-aware listener management (DEBT-08)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    func logIn(_ documentId: String) async throws {
        self.documentId = documentId
        startListening(documentId: documentId)
        await flushPendingWritesIfNeeded()
        _ = try await getDocumentAsync()
    }

    func logOut() {
        listener?.remove()
        listener = nil
        documentId = nil
        cache = DocumentCache(document: nil)
    }

    func getDocumentAsync() async throws -> Model {
        let documentId = try requireDocumentId()
        do {
            let document = try await remote.fetch(documentId: documentId)
            updateCache(document)
            return document
        } catch {
            if let cached = cache.document {
                return cached
            }
            throw error
        }
    }

    func saveDocument(_ document: Model) async throws {
        let documentId = document.id
        self.documentId = documentId
        do {
            try await remote.save(document: document, documentId: documentId)
            updateCache(document)
        } catch {
            handlePendingWrite(.save(document), error: error)
        }
    }

    func updateDocument(data: [String: Any]) async throws {
        let documentId = try requireDocumentId()
        do {
            try await remote.update(documentId: documentId, data: data)
            if let updated = applyLocalUpdate(data) {
                updateCache(updated)
            } else {
                let refreshed = try await remote.fetch(documentId: documentId)
                updateCache(refreshed)
            }
        } catch {
            if let codableData = codableUpdateData(data) {
                handlePendingWrite(.update(codableData), error: error)
                if let updated = applyLocalUpdate(data) {
                    updateCache(updated)
                }
                return
            }
            throw error
        }
    }

    func deleteDocument() async throws {
        let documentId = try requireDocumentId()
        do {
            try await remote.delete(documentId: documentId)
            updateCache(nil)
        } catch {
            handlePendingWrite(.delete(), error: error)
        }
    }

    func getDocumentId() throws -> String {
        try requireDocumentId()
    }

    private func requireDocumentId() throws -> String {
        if let documentId {
            return documentId
        }
        if let cachedId = cache.document?.id {
            return cachedId
        }
        throw DocumentManagerError.missingDocumentId
    }

    private func updateCache(_ document: Model?) {
        cache.document = document
    }

    private func persistCache() {
        do {
            try local.saveCache(cache)
        } catch {
            logger?.trackEvent(event: DataManagerEvent.cacheSaveFailed(error: error))
        }
    }

    private func startListening(documentId: String) {
        listener?.remove()
        listener = remote.listen(documentId: documentId) { [weak self] result in
            Task { @MainActor in
                guard let self else { return }
                switch result {
                case .success(let document):
                    self.updateCache(document)
                case .failure(let error):
                    self.logger?.trackEvent(event: DataManagerEvent.remoteListenFailed(error: error))
                }
            }
        }
    }

    private func handlePendingWrite(_ write: PendingWrite<Model>, error: Error) {
        if configuration.enablePendingWrites {
            cache.pendingWrites.append(write)
            logger?.trackEvent(event: DataManagerEvent.pendingWriteQueued(error: error))
        } else {
            logger?.trackEvent(event: DataManagerEvent.remoteWriteFailed(error: error))
        }
    }

    private func flushPendingWritesIfNeeded() async {
        guard configuration.enablePendingWrites else { return }
        guard !cache.pendingWrites.isEmpty else { return }
        let documentId = documentId ?? cache.document?.id
        guard let documentId else { return }

        var remainingWrites: [PendingWrite<Model>] = []
        for pending in cache.pendingWrites {
            do {
                switch pending.kind {
                case .save:
                    if let document = pending.document {
                        try await remote.save(document: document, documentId: documentId)
                    }
                case .update:
                    if let updateData = pending.updateData {
                        try await remote.update(documentId: documentId, data: updateData.anyDictionary)
                    }
                case .delete:
                    try await remote.delete(documentId: documentId)
                }
            } catch {
                remainingWrites.append(pending)
                logger?.trackEvent(event: DataManagerEvent.pendingWriteFailed(error: error))
            }
        }

        cache.pendingWrites = remainingWrites
    }

    private func applyLocalUpdate(_ update: [String: Any]) -> Model? {
        guard let current = cache.document else { return nil }
        guard let data = try? JSONEncoder().encode(current) else { return nil }
        guard var json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        update.forEach { key, value in
            json[key] = value
        }
        guard let updatedData = try? JSONSerialization.data(withJSONObject: json) else { return nil }
        return try? JSONDecoder().decode(Model.self, from: updatedData)
    }

    private func codableUpdateData(_ data: [String: Any]) -> [String: CodableValue]? {
        var output: [String: CodableValue] = [:]
        for (key, value) in data {
            guard let codable = CodableValue(any: value) else { return nil }
            output[key] = codable
        }
        return output
    }

    enum DocumentManagerError: LocalizedError {
        case missingDocumentId

        var errorDescription: String? {
            switch self {
            case .missingDocumentId:
                return "Missing document id"
            }
        }
    }

    // MARK: - Lifecycle Management

    deinit {
        // Listener cleanup is handled by logOut() and appDidEnterBackground().
        // The listener closure captures [weak self], so if deinit is reached
        // with an active listener, callbacks safely no-op.
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func appDidEnterBackground() {
        // Remove listener to prevent missed updates when app resumes
        listener?.remove()
        listener = nil
    }

    @objc private func appWillEnterForeground() {
        // Restart listener if we have a documentId
        if let documentId = documentId {
            startListening(documentId: documentId)
        }
    }

    enum DataManagerEvent: DataLogEvent {
        case cacheSaveFailed(error: Error)
        case remoteListenFailed(error: Error)
        case remoteWriteFailed(error: Error)
        case pendingWriteQueued(error: Error)
        case pendingWriteFailed(error: Error)

        var eventName: String {
            switch self {
            case .cacheSaveFailed:
                return "DataManager_Cache_Save_Failed"
            case .remoteListenFailed:
                return "DataManager_Remote_Listen_Failed"
            case .remoteWriteFailed:
                return "DataManager_Remote_Write_Failed"
            case .pendingWriteQueued:
                return "DataManager_Pending_Write_Queued"
            case .pendingWriteFailed:
                return "DataManager_Pending_Write_Failed"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .cacheSaveFailed(let error),
                 .remoteListenFailed(let error),
                 .remoteWriteFailed(let error),
                 .pendingWriteQueued(let error),
                 .pendingWriteFailed(let error):
                return error.eventParameters
            }
        }

        var type: DataLogType {
            switch self {
            case .cacheSaveFailed, .remoteListenFailed, .remoteWriteFailed, .pendingWriteFailed:
                return .severe
            case .pendingWriteQueued:
                return .warning
            }
        }
    }
}
