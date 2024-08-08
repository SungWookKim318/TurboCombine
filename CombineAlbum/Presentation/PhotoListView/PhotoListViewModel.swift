//
//  PhotoListViewModel.swift
//  CombineAlbum
//
//  Created by SungWook Kim on 8/8/24.
//

import Foundation
import UIKit
// Need DTO?
//struct PhotoItemViewData {
//    let title: String
//    let image: Data?
//    let date: Date
//}

public enum PhotoListViewModelState {
    case idle
    case loading
    case loaded
    case panic
}

class PhotoListViewModel: ObservableObject {
    @Published var photos: [PhotoData] = []
    @Published var viewState: PhotoListViewModelState = .idle
    @Published var permissionState: PhotoLibraryPermissionStatus = .notDetermined
    private var photoLibraryUseCase: PhotoLibraryUseCase
    
    public var selectedPhotos: Set<String> = []
    
    init(photoLibraryUseCase: PhotoLibraryUseCase) {
        self.photoLibraryUseCase = photoLibraryUseCase
    }
    
    @MainActor
    func checkPhotoLibraryPermission() async {
        do {
            self.permissionState = try await photoLibraryUseCase.checkPermission()
            
        } catch {
            print("exist error to get permission of photo library. - \(error)")
            self.permissionState = .denied
            self.viewState = .panic
        }
    }
    
    @MainActor
    func fetchPhotos() async {
        do {
            photos = try await photoLibraryUseCase.fetchMetadata()
        } catch {
            print("exist error to fetch photo data. - \(error)")
            photos = []
            self.viewState = .panic
        }
    }
    
    @MainActor
    func fetchThumbnail(id: String, size: CGSize) async {
        guard let index = self.photos.firstIndex(where: { $0.id == id }) else {
            print("exist error to get index of photo data. - \(id)")
            return
        }
        guard let image = await photoLibraryUseCase.fetchThumbnail(id: id, size: size) else {
            print("exist error to get image.")
            return
        }
        
        photos[index] = .init(id: id, thumbnail: image)
    }
    
    func selectPhoto(id: String) {
        print("selected photo id: \(id)")
    }
}

