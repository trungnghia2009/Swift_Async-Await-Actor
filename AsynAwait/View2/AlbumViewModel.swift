//
//  AlbumViewModel.swift
//  AsynAwait
//
//  Created by trungnghia on 11/03/2023.
//

import Foundation
import Combine

class AlbumViewModel {

    private let service: AlbumService
    private var albums = [Album]()
    
    let onError = PassthroughSubject<Error, Never>()
    let onFetchAlbums = PassthroughSubject<Void, Never>()
    
    init(service: AlbumService = AlbumAPI()) {
        self.service = service
    }
    
    func fetchAlbums1() {
        service.fetchAlbums { [weak self] result in
            switch result {
            case .success(let albums):
                self?.albums = albums
                self?.onFetchAlbums.send()
            case .failure(let error):
                self?.onError.send(error)
            }
        }
    }
    
    func fetchAlbums2() {
        Task {
            do {
                let albums = try await service.fetchAlbumWithContinuation()
                self.albums = albums
                self.onFetchAlbums.send()
            } catch {
                onError.send(error)
            }
        }
    }
    
    func fetchAlbums3() {
        Task {
            do {
                let albums = try await service.fetchAlbumWithAsyncURLSession()
                self.albums = albums
                self.onFetchAlbums.send()
            } catch {
                onError.send(error)
            }
        }
    }
    
    // For TableView
    func getNumberOfSection() -> Int {
        return albums.count
    }
    
    func getAlbumForRowAt(indexPath: IndexPath) -> String {
        return albums[indexPath.row].collectionName
    }
}
