//
//  FavoritesModel.swift
//  globoplay-desafio-ios
//
//  Created by Filipe Xavier Fernandes on 23/01/25.
//

import Foundation


struct FavoriteItem: Codable, Equatable {
    let id: Int
    let mediaType: MediaType

    static func == (lhs: FavoriteItem, rhs: FavoriteItem) -> Bool {
        return lhs.id == rhs.id && lhs.mediaType == rhs.mediaType
    }
}
