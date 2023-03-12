//
//  Service.swift
//  AsynAwait
//
//  Created by trungnghia on 11/03/2023.
//

import Foundation

protocol Service: AnyObject {
    func fetchAPI<T: Decodable>(url: URL, completion: @escaping (Result<T, Error>) -> ())
    func fetchAPI<T: Decodable>(url: URL) async throws -> T
    func fetchAPI(url: URL) async throws -> [Category]
    func fetchAPIs<T: Decodable>(urls: [URL]) async throws -> [T]
}

enum APIError: Error {
    case error(String)
    
    var localizedDescription: String {
        switch self {
        case .error(let string):
            return string
        }
    }
}


class ApiService: Service {
    
    func fetchAPI<T: Decodable>(url: URL, completion: @escaping (Result<T, Error>) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data else {
                completion(.failure(APIError.error("Bad HTTP Response")))
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(error))
            }
        }
        .resume()
    }
    
    func fetchAPI<T: Decodable>(url: URL) async throws -> T  {
        let data = try await URLSession.shared.data(url: url)
        let decodeData = try JSONDecoder().decode(T.self, from: data)
        return decodeData
    }
    
    
    ///  Fetch API async  using fetchAPI<T: Decodable>(url: URL, completion: @escaping (Result<T, Error>) -> ())
    /// - Parameter url: What you need to call
    /// - Returns: [Category]
    func fetchAPI(url: URL) async throws -> [Category] {
        try await withCheckedThrowingContinuation({ check in
            self.fetchAPI(url: url) { (result: Result<CategoryResult, Error>) in
                switch result {
                case .success(let result):
                    check.resume(returning: result.drinks)
                case .failure(let error):
                    check.resume(throwing: error)
                }
            }
        })
    }
    
    func fetchAPIs<T: Decodable>(urls: [URL]) async throws -> [T] {
        try await withThrowingTaskGroup(of: T.self, body: { group in
            for url in urls {
                group.addTask {
                    try await self.fetchAPI(url: url)
                }
            }
            
            var results = [T]()
            for try await result in group {
                results.append(result)
            }
            
            return results
        })
    }
}


extension URLSession {
    
    /// Custom aysn func for URLSession
    func data(url: URL) async throws -> Data {
        try await withCheckedThrowingContinuation({ check in
            dataTask(with: url) { data, _, error in
                if let error = error {
                    check.resume(throwing: APIError.error(error.localizedDescription))
                } else {
                    if let data = data {
                        check.resume(returning: data)
                    } else {
                        check.resume(throwing: APIError.error("Bad response"))
                    }
                }
            }.resume()
        })
    }
}

///The CheckedContinuation is mainly for bridging any asynchronous APIs that are yet to support the async/await syntax. If let’s say you are using a third-party networking library (such as Alamofire) that does not support the async/await syntax, then you can use CheckedContinuation to gradually migrate your existing code to support async/await while waiting for the third-party library to get updated.
