//
//  FirebaseImageUploadService.swift
//  AIChatCourse
//
//  Created by Matvii Sakhnenko on 10/16/24.
//
import FirebaseStorage
import SwiftUI

protocol ImageUploadService {
    @concurrent func uploadImage(image: UIImage, path: String) async throws -> URL
}

struct FirebaseImageUploadService {
    
    @concurrent
    func uploadImage(image: UIImage, path: String) async throws -> URL {
        guard let data = image.jpegData(compressionQuality: 1) else {
            throw URLError(.dataNotAllowed)
        }
        
        // Upload image
        _ = try await saveImage(data: data, path: path)
        
        // Get download url
        return try await imageReference(path: path).downloadURL()
    }
    
    nonisolated private func imageReference(path: String) -> StorageReference {
        let name = "\(path).jpg"
        return Storage.storage().reference(withPath: name)
    }
    
    @concurrent
    private func saveImage(data: Data, path: String) async throws -> URL {
        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"
        
        let returnedMeta = try await imageReference(path: path).putDataAsync(data, metadata: meta)
        
        guard let returnedPath = returnedMeta.path, let url = URL(string: returnedPath) else {
            throw URLError(.badServerResponse)
        }
        
        return url
    }
}
