//
//  PhotoKitDataSource.swift
//  CombineAlbum
//
//  Created by SungWook Kim on 8/8/24.
//

import Foundation
import Photos
import UIKit

/// PHAsset 관련 래핑 하기
class PhotokitDataSource {
    var imageCache = NSCache<NSString, UIImage>()
    
    func checkPermission() async throws -> PhotoLibraryPermissionStatus {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        
        switch status {
        case .authorized:
            return .authorized
        case .limited:
            return .partial
        case .denied, .restricted:
            if status == .restricted {
                print("restricted!")
            }
            return .denied
        case .notDetermined:
            return .notDetermined
        @unknown default:
            throw PhotoLibraryError.notImplemented
        }
    }
    
    
    func fetchMetadata() async throws -> [String] {
        let asset = PHAsset.fetchAssets(with: .image, options: nil)
        
        return asset.objects(at: IndexSet(integersIn: 0..<asset.count)).map { $0.localIdentifier }
    }
    
    func getCacheImage(id: String) -> UIImage? {
        return imageCache.object(forKey: id as NSString)
    }
    
    func fetchImage(id: String, size: CGSize, isNeedCahce: Bool = false) async throws -> UIImage {
        if isNeedCahce {
            if let cachedImage = imageCache.object(forKey: id as NSString) {
                return cachedImage
            }
        }
        
        let queryAssets = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: nil)
        guard let asset = queryAssets.firstObject else {
            throw PhotoLibraryError.notFoundImage
        }
        
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        if isNeedCahce {
            options.deliveryMode = .opportunistic
        } else {
            options.deliveryMode = .highQualityFormat
        }
        let image = try await withCheckedThrowingContinuation { continuation in
            PHImageManager.default().requestImage(for: asset,
                                                  targetSize: size,
                                                  contentMode: .aspectFit,
                                                  options: options) { image, info in
                if let image = image {
                    continuation.resume(with: .success(image))
                } else {
                    continuation.resume(with: .failure(PhotoLibraryError.PhotoKitReturnError))
                }
            }
        }
        if isNeedCahce {
            imageCache.setObject(image, forKey: id as NSString)
        }
        return image
    }
}
