//
//  AppState.swift
//  CombineAlbum
//
//  Created by SungWook Kim on 8/8/24.
//

import Foundation

/// APP의 전체 상태 보관, 특히 모든 DI 컨테이너를 보관
/// 추후 ViewModel 생성시 DI 컨테이너의 추상화된 UseCase 전달해주기 위함
final class AppState: ObservableObject {
    public private(set) var photoLibraryDI: PhotoLibraryDIContainer
    
    init(photoLibraryDI: PhotoLibraryDIContainer) {
        self.photoLibraryDI = photoLibraryDI
    }
    
    static func createMock() -> AppState {
        let photoLibraryDI = PhotoLibraryDIContainer(photoLibraryRepository: MockPhotoRepository())
        return AppState(photoLibraryDI: photoLibraryDI)
    }
    
    static var isDebugMode: Bool {
#if DEBUG
        true
#else
        false
#endif
    }
}
