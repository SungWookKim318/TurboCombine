//
//  PhotoLibraryUseCase.swift
//  CombineAlbum
//
//  Created by SungWook Kim on 8/8/24.
//

import Foundation
import UIKit.UIImage

enum PhotoLibraryUseCaseImplType {
    case applePhotoKit
    
    static var `default`: PhotoLibraryUseCaseImplType {
        return .applePhotoKit
    }
}

protocol PhotoLibraryUseCase {
    var type: PhotoLibraryUseCaseImplType { get }
    
    func checkPermission() async throws -> PhotoLibraryPermissionStatus
    func fetchMetadata() async throws -> [PhotoData]
    func getImageData()
    func fetchThumbnail(id: String, size: CGSize) async -> UIImage?
}

class DefaultPhotoLibraryUseCase: PhotoLibraryUseCase {
    let repository: PhotoLibraryRepository
    
    init(repository: PhotoLibraryRepository) {
        self.repository = repository
    }
    
    var type: PhotoLibraryUseCaseImplType {
        return .applePhotoKit
    }
    
    func checkPermission() async throws -> PhotoLibraryPermissionStatus {
        return try await repository.checkPermission()
    }
    
    func fetchMetadata() async throws -> [PhotoData] {
        return try await repository.fetchMetadata()
    }
    
    func fetchThumbnail(id: String, size: CGSize) async -> UIImage? {
        do {
            return try await repository.fetchThumbnail(id: id, size: size)
        } catch {
            print("exist error to fetch thumbnail image. - \(error)")
            return nil
        }
    }
    
    func getImageData() {
        print("getImageData")
    }
}
