//
//  AlbumService.swift
//  AsynAwait
//
//  Created by trungnghia on 11/03/2023.
//

import Foundation

protocol AlbumService: AnyObject {
    /// Use API call following the old way
    /// - Parameter completion: including  your expected Data and Error
    func fetchAlbums(completion: @escaping (Result<[Album], Error>) -> Void)
    
    /// Using withCheckedThrowingContinuation to reuse the old implementation on new async way
    /// - Returns: return your expected data and throw the error
    func fetchAlbumWithContinuation() async throws -> [Album]
    
    /// Use new async/await syntax
    /// - Returns: return your expected data and throw the error
    func fetchAlbumWithAsyncURLSession() async throws -> [Album]
}

enum AlbumsFetcherError: Error {
    case invalidURL
    case missingData
}

class AlbumAPI: AlbumService {
    
    func fetchAlbums(completion: @escaping (Result<[Album], Error>) -> Void) {
        guard let url = URL(string: "https://itunes.apple.com/search?term=taylor+swift&entity=album") else {
            completion(.failure(AlbumsFetcherError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(AlbumsFetcherError.missingData))
                return
            }
            
            do {
                let iTunesResult = try JSONDecoder().decode(ITunesResult.self, from: data)
                completion(.success(iTunesResult.results))
            } catch {
                completion(.failure(error))
            }
            
        }.resume()
    }
    
    func fetchAlbumWithContinuation() async throws -> [Album] {
        try await withCheckedThrowingContinuation({ check in
            self.fetchAlbums { result in
                switch result {
                case .success(let albums):
                    check.resume(returning: albums)
                case .failure(let error):
                    check.resume(throwing: error)
                }
            }
        })
    }
    
    func fetchAlbumWithAsyncURLSession() async throws -> [Album] {
        guard let url = URL(string: "https://itunes.apple.com/search?term=taylor+swift&entity=album") else {
            throw AlbumsFetcherError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = try JSONDecoder().decode(ITunesResult.self, from: data)
        return decoder.results
    }
    
}


///'The CheckedContinuation' is mainly for bridging any asynchronous APIs that are yet to support the async/await syntax. If let’s say you are using a third-party networking library (such as Alamofire) that does not support the async/await syntax, then you can use CheckedContinuation to gradually migrate your existing code to support async/await while waiting for the third-party library to get updated.
