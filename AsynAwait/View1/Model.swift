//
//  Model.swift
//  AsynAwait
//
//  Created by trungnghia on 11/03/2023.
//

import Foundation

struct Category: Codable, Hashable {
    var strCategory: String
}

struct CategoryResult: Codable {
    var drinks: [Category]
}

struct Drink: Codable {
    var strDrink: String
    var strDrinkThumb: String
    var idDrink: String
}

struct DrinkResult: Codable {
    var drinks: [Drink]
}
