//
//  DocumentPersistence.swift
//  Forge
//

import Foundation

final class FileManagerDocumentPersistence<Model: Codable>: LocalDocumentPersistence {
    private let cacheURL: URL

    init(managerKey: String = "Document") {
        let sanitized = managerKey.replacingOccurrences(of: " ", with: "_")
        let filename = "\(sanitized)_document_cache.json"
        let baseURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        self.cacheURL = baseURL.appendingPathComponent(filename)
    }

    func loadCache() throws -> DocumentCache<Model>? {
        guard FileManager.default.fileExists(atPath: cacheURL.path) else { return nil }
        let data = try Data(contentsOf: cacheURL)
        return try JSONDecoder().decode(DocumentCache<Model>.self, from: data)
    }

    func saveCache(_ cache: DocumentCache<Model>) throws {
        let data = try JSONEncoder().encode(cache)
        try data.write(to: cacheURL, options: [.atomic])
    }

    func clearCache() throws {
        guard FileManager.default.fileExists(atPath: cacheURL.path) else { return }
        try FileManager.default.removeItem(at: cacheURL)
    }
}

final class InMemoryDocumentPersistence<Model: Codable>: LocalDocumentPersistence {
    private var cache: DocumentCache<Model>?

    func loadCache() throws -> DocumentCache<Model>? {
        cache
    }

    func saveCache(_ cache: DocumentCache<Model>) throws {
        self.cache = cache
    }

    func clearCache() throws {
        cache = nil
    }
}
