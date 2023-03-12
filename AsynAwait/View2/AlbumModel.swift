//
//  AlbumModel.swift
//  AsynAwait
//
//  Created by trungnghia on 11/03/2023.
//

import Foundation

struct ITunesResult: Codable {
    let results: [Album]
}

struct Album: Codable, Hashable {
    let collectionId: Int
    let collectionName: String
    let collectionPrice: Double
}
