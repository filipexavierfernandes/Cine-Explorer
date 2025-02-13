//
//  FavoritesServiceMock.swift
//  globoplay-desafio-ios-tests
//
//  Created by Filipe Xavier Fernandes on 27/01/25.
//

import Foundation
@testable import globoplay_desafio_ios

class FavoritesServiceMock: FavoritesService {
    var favorites = [FavoriteItem]()
    
    override func getFavorites() -> [FavoriteItem] {
        return favorites
    }
    
    override func saveFavorite(itemId: Int, mediaType: MediaType) {
        favorites.append(FavoriteItem(id: itemId, mediaType: mediaType))
    }
    
    override func removeFavorite(itemId: Int, mediaType: MediaType) {
        favorites.removeAll { $0.id == itemId && $0.mediaType == mediaType }
    }
    
    override func isFavorite(itemId: Int, mediaType: MediaType) -> Bool {
        return favorites.contains { $0.id == itemId && $0.mediaType == mediaType }
    }
}
