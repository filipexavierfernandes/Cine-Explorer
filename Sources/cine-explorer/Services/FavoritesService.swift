//
//  FavoritesService.swift
//  globoplay-desafio-ios
//
//  Created by Filipe Xavier Fernandes on 23/01/25.
//

import Foundation

class FavoritesService {
    private let userDefaults = UserDefaults.standard
    private let favoritesKey = "favorites"

    func getFavorites() -> [FavoriteItem] {
        guard let data = userDefaults.data(forKey: favoritesKey),
              let favorites = try? JSONDecoder().decode([FavoriteItem].self, from: data) else {
            return []
        }
        return favorites
    }

    func saveFavorite(itemId: Int, mediaType: MediaType) {
        var favorites = getFavorites()
        let newItem = FavoriteItem(id: itemId, mediaType: mediaType)
        if !favorites.contains(newItem) {
            favorites.append(newItem)
            save(favorites: favorites)
        }
    }

    func removeFavorite(itemId: Int, mediaType: MediaType) {
        var favorites = getFavorites()
        favorites.removeAll(where: { $0.id == itemId && $0.mediaType == mediaType})
        save(favorites: favorites)
    }

    func isFavorite(itemId: Int, mediaType: MediaType) -> Bool {
        return getFavorites().contains(where: { $0.id == itemId && $0.mediaType == mediaType })
    }

    private func save(favorites: [FavoriteItem]) {
        if let data = try? JSONEncoder().encode(favorites) {
            userDefaults.set(data, forKey: favoritesKey)
        }
    }
}
