//
//  ViewModel.swift
//  AsynAwait
//
//  Created by trungnghia on 11/03/2023.
//

import Foundation
import Combine


class ViewModel {
    
    private var drinks = [Category]()
    private var drinks2 = [[Drink]]()
    
    private let urlString = "https://www.thecocktaildb.com/api/json/v1/1/list.php?c=list"
    private let urls = [URL(string: "https://www.thecocktaildb.com/api/json/v1/1/filter.php?c=Ordinary_Drink")!,
                        URL(string: "https://www.thecocktaildb.com/api/json/v1/1/filter.php?c=Cocktail")!,
                        URL(string: "https://www.thecocktaildb.com/api/json/v1/1/filter.php?c=Cocoa")!]
    
    private let onErrorSubject = PassthroughSubject<Error, Never>()
    private let onFetchSubject = PassthroughSubject<Void, Never>()
    
    var onError: AnyPublisher<Error, Never> {
        return onErrorSubject.eraseToAnyPublisher()
    }
    
    var onFetch: AnyPublisher<Void, Never> {
        return onFetchSubject.eraseToAnyPublisher()
    }
    
    private let service: ApiService
    
    init(service: ApiService = ApiService()) {
        self.service = service
    }
    
    func fetch1() {
        let url = URL(string: urlString)!
        service.fetchAPI(url: url) { (result: Result<CategoryResult, Error>) in
            switch result {
            case .success(let result):
                self.drinks = result.drinks
                self.onFetchSubject.send()
            case .failure(let error):
                self.onErrorSubject.send(error)
            }
        }
    }
    
    func fetch2() {
        Task {
            do {
                let url = URL(string: urlString)!
                let result: CategoryResult = try await service.fetchAPI(url: url)
                
                drinks.append(contentsOf: result.drinks)
                onFetchSubject.send()
            } catch {
                onErrorSubject.send(error)
            }
        }
    }
    
    func fetch3() {
        Task {
            do {
                let url = URL(string: urlString)!
                let result: [Category] = try await service.fetchAPI(url: url)
                
                drinks.append(contentsOf: result)
                onFetchSubject.send()
            } catch {
                onErrorSubject.send(error)
            }
        }
    }
    
    func fetch4() {
        Task {
            do {
                print(" --- API WITH ASYNC GROUP ---")
                let results: [DrinkResult] = try await service.fetchAPIs(urls: urls)
                
                for result in results {
                    let items = result.drinks
                    drinks2.append(items)
                }
                onFetchSubject.send()
                
            } catch {
                print("Error: \(error.localizedDescription)")
                onErrorSubject.send(error)
            }
        }
    }
    
    // MARK: For 1 section
    func getNumberOfDrinks() -> Int {
        return drinks.count
    }
    
    func getDrinkAt(indexPath: IndexPath) -> String {
        return drinks[indexPath.row].strCategory
    }
    
    // MARK: For many sections
    func getNumberOfSection() -> Int {
        return drinks2.count
    }
    
    func getNumberOfRowsInSection(section: Int) -> Int {
        return drinks2[section].count
    }
    
    func getDrinkForRowAt(indexPath: IndexPath) -> String {
        return drinks2[indexPath.section][indexPath.row].strDrink
    }
    
    func getSectionName(section: Int) -> String {
        switch section {
        case 0: return "Drink"
        case 1: return "Cocktail"
        case 2: return "Cocoa"
        default: return ""
        }
    }
}
