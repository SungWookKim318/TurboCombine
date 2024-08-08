//
//  CombineAlbumApp.swift
//  CombineAlbum
//
//  Created by SungWook Kim on 8/8/24.
//

import SwiftUI

@main
struct CombineAlbumApp: App {
    static private var photoLibraryDIContainer: PhotoLibraryDIContainer = {
        PhotoLibraryDIContainer(photoLibraryRepository: SystemPhotoLibraryRepository())
    }()
    
    @StateObject private var appState: AppState = {
        AppState(photoLibraryDI: Self.photoLibraryDIContainer)
    }()
    
    init() {
        
    }
    
    var body: some Scene {
        WindowGroup {
            TabView {
                PhotoListView(viewModel: .init(photoLibraryUseCase: appState.photoLibraryDI.photoLibraryUseCase))
                    .environmentObject(appState)
                    .tabItem {
                        Label("All Photos", systemImage: "photo.fill.on.rectangle.fill")
                    }
                Text("For You")
                    .environmentObject(appState)
                    .tabItem {
                        Label("For You", systemImage: "heart.text.square")
                    }
                Text("Album")
                    .environmentObject(appState)
                    .tabItem {
                        Label("Album", systemImage: "square.stack")
                    }
                Text("Search")
                    .environmentObject(appState)
                    .tabItem {
                        Label("Setting", systemImage: "magnifyingglass")
                    }
            }
        }
    }
}
