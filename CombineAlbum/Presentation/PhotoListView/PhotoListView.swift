//
//  PhotoListView.swift
//  CombineAlbum
//
//  Created by SungWook Kim on 8/8/24.
//

import SwiftUI
import Combine

struct PhotoListView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject private var viewModel: PhotoListViewModel
    
    init(viewModel: PhotoListViewModel) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }
    
    
    static let numberOfGrid = 3
    static let spacing: CGFloat = 5
    
    static let columns: [GridItem] = Array(repeating: .init(.flexible()), count: Self.numberOfGrid)
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    LazyVGrid(columns: Self.columns, spacing: Self.spacing) {
                        ForEach(viewModel.photos.reversed()) { item in
                            let itemWidth = (geometry.size.width - (Self.spacing * 3)) / CGFloat(Self.numberOfGrid)
                            
                            NavigationLink(destination: PhotoDetailView(id: item.id)) {
                                ZStack {
                                    Image(uiImage: item.thumbnail ?? UIImage())
                                        .resizable()
                                }
                                .task {
                                    if item.thumbnail == nil {
                                        await viewModel.fetchThumbnail(id: item.id, size: CGSize(width: itemWidth, height: itemWidth))
                                    }
                                }
                                .frame(width: itemWidth, height: itemWidth)
                                .background(Color.blue.opacity(0.5))
                            }
                        }
                    }
                    .task {
                        await viewModel.checkPhotoLibraryPermission()
                        await viewModel.fetchPhotos()
                    }
                    .padding(.horizontal, Self.spacing)
                }
            }
        }
        
        .navigationTitle("Photos")
    }
}

struct PhotoDetailView: View {
    let id: String
    var body: some View {
        Text("PhotoDetailView - \(id)")
    }
}

#Preview {
    PhotoListView(viewModel: .init(photoLibraryUseCase: AppState.createMock().photoLibraryDI.photoLibraryUseCase))
        .environmentObject(AppState.createMock())
}

