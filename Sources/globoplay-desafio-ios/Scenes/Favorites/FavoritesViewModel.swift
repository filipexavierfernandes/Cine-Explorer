//
//  FavoritesViewModel.swift
//  globoplay-desafio-ios
//
//  Created by Filipe Xavier Fernandes on 23/01/25.
//

import Foundation
import Combine

class FavoritesViewModel: ObservableObject {
    @Published var favoriteFilms: [Film] = []
    @Published var error: FilmServiceError?
    private let favoritesService: FavoritesService
    private let filmService: FilmService
    private var cancellables = Set<AnyCancellable>()
    
    init(favoritesService: FavoritesService, filmService: FilmService) {
        self.favoritesService = favoritesService
        self.filmService = filmService
    }

    func fetchFavorites() {
        let favoriteItems = favoritesService.getFavorites()
        favoriteFilms = []
        
        favoriteItems.forEach { item in
            filmService.fetchDetails(id: item.id, type: item.mediaType)
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        self.error = error
                        print("Erro ao obter filme favorito: \(error)")
                    case .finished:
                        break
                    }
                } receiveValue: { [weak self] film in
                    guard let favFilm = film else { return }
                    self?.favoriteFilms.append(favFilm)
                }.store(in: &cancellables)
        }
    }
}
