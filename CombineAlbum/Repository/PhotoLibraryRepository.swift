//
//  PhotoLibraryRepository.swift
//  CombineAlbum
//
//  Created by SungWook Kim on 8/8/24.
//

import Foundation
import Combine
import UIKit

enum PhotoLibraryError: Error {
    case notImplemented
    case photoKitReturnError
    case notFoundImage
}
/*
 struct PhotoData: Identifiable, Equatable {
 let id: String
 var thumbnail: UIImage? // Data보다는 좋을듯.
 
 public init(id: String, thumbnail: UIImage? = nil) {
 self.id = id
 self.thumbnail = thumbnail
 }
 
 static func ==(lhs: PhotoData, rhs: PhotoData) -> Bool {
 lhs.id == rhs.id && lhs.thumbnail == rhs.thumbnail
 }
 }
 */
protocol PhotoLibraryRepository {
    //    func checkPermission() async throws -> PhotoLibraryPermissionStatus
    //    func fetchMetadata() async throws -> [PhotoData]
    //    func fetchThumbnail(id: String, size: CGSize) async throws -> UIImage
    func checkPermission() -> AnyPublisher<PhotoLibraryPermissionStatus, Error>
    func fetchMetadata() -> AnyPublisher<[PhotoData], Error>
    func fetchThumbnail(id: String, size: CGSize) -> AnyPublisher<UIImage, Error>
}

class SystemPhotoLibraryRepository: PhotoLibraryRepository {
    private let photoKitSource: PhotokitDataSource = .init()
    func checkPermission() -> AnyPublisher<PhotoLibraryPermissionStatus, any Error> {
        Future { promise in
            Task {
                do {
                    let status = try await self.photoKitSource.checkPermission()
                    promise(.success(status))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func fetchMetadata() -> AnyPublisher<[PhotoData], any Error> {
        Future { promise in
            Task {
                do {
                    let ids = try await self.photoKitSource.fetchMetadata()
                    let photoData = ids.map { PhotoData(id: $0, thumbnail: self.photoKitSource.getCacheImage(id: $0)) }
                    promise(.success(photoData))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func fetchThumbnail(id: String, size: CGSize) -> AnyPublisher<UIImage, any Error> {
        Future { promise in
            Task {
                do {
                    let image = try await self.photoKitSource.fetchImage(id: id, size: size, isNeedCahce: true)
                    promise(.success(image))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    
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
    let mockStatus = PhotoLibraryPermissionStatus.authorized
    let mockImage: UIImage = {
        guard let image = UIImage(named: "mockThumbnail") else {
            print("exist error to get image")
            fatalError("exist error to get image")
        }
        return image
    }()
    
    func checkPermission() -> AnyPublisher<PhotoLibraryPermissionStatus, any Error> {
        Just(mockStatus)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func fetchMetadata() -> AnyPublisher<[PhotoData], any Error> {
        Just((0...99).map { index in
            PhotoData(id: "mock-\(index)", thumbnail: nil)
        })
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
    }
    
    func fetchThumbnail(id: String, size: CGSize) -> AnyPublisher<UIImage, any Error> {
        Just(mockImage)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    
    func checkPermission() async throws -> PhotoLibraryPermissionStatus {
        return mockStatus
    }
    func fetchThumbnail(id: String, size: CGSize) async throws -> UIImage {
        try await Task.sleep(nanoseconds: 100)
        return mockImage
    }
    
    
    func fetchMetadata() async throws -> [PhotoData] {
        return (0...99).map { index in
            PhotoData(id: "mock-\(index)", thumbnail: nil)
        }
    }
}
