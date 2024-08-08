//
//  PhotoLibraryRepository.swift
//  CombineAlbum
//
//  Created by SungWook Kim on 8/8/24.
//

import Foundation
import UIKit

enum PhotoLibraryError: Error {
    case notImplemented
    case PhotoKitReturnError
    case notFoundImage
}

protocol PhotoLibraryRepository {
    func checkPermission() async throws -> PhotoLibraryPermissionStatus
    func fetchMetadata() async throws -> [PhotoData]
    func fetchThumbnail(id: String, size: CGSize) async throws -> UIImage
}

class SystemPhotoLibraryRepository: PhotoLibraryRepository {
    private let photoKitSource: PhotokitDataSource = .init()
    
    func checkPermission() async throws -> PhotoLibraryPermissionStatus {
        return try await photoKitSource.checkPermission()
    }
    
    func fetchMetadata() async throws -> [PhotoData] {
        let ids = try await photoKitSource.fetchMetadata()
        return ids.map { PhotoData(id: $0, thumbnail: photoKitSource.getCacheImage(id: $0)) }
    }
    
    func fetchThumbnail(id: String, size: CGSize) async throws -> UIImage {
        return try await photoKitSource.fetchImage(id: id, size: size, isNeedCahce: true)
    }
}

class MockPhotoRepository: PhotoLibraryRepository {
    
    let status = PhotoLibraryPermissionStatus.authorized
    let thumbnailImage: UIImage = {
        guard let image = UIImage(named: "mockThumbnail") else {
            print("exist error to get image")
            fatalError("exist error to get image")
        }
        return image
    }()
    func checkPermission() async throws -> PhotoLibraryPermissionStatus {
        return status
    }
    func fetchThumbnail(id: String, size: CGSize) async throws -> UIImage {
        try await Task.sleep(nanoseconds: 100)
        return thumbnailImage
    }
    
    
    func fetchMetadata() async throws -> [PhotoData] {
        return (0...99).map { index in
            PhotoData(id: "mock-\(index)", thumbnail: nil)
        }
    }
}
