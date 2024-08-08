//
//  PhotoLibraryModel.swift
//  CombineAlbum
//
//  Created by SungWook Kim on 8/8/24.
//

import Foundation
import UIKit.UIImage
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

enum PhotoLibraryPermissionStatus {
    case authorized
    case partial
    case denied
    case notDetermined
}
