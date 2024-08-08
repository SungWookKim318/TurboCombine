//
//  PhotoLibraryDIContainer.swift
//  CombineAlbum
//
//  Created by SungWook Kim on 8/8/24.
//

import Foundation

final class PhotoLibraryDIContainer {
    
    init(photoLibraryRepository: PhotoLibraryRepository) {
        self.photoLibraryRepository = photoLibraryRepository
    }
    
    private let photoLibraryRepository: PhotoLibraryRepository
    
    public private(set) lazy var photoLibraryUseCase: PhotoLibraryUseCase = {
        return DefaultPhotoLibraryUseCase(repository: photoLibraryRepository)
    }()
}
