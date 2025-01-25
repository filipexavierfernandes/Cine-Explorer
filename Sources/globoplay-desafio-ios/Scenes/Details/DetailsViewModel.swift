//
//  DetailsViewModel.swift
//  globoplay-desafio-ios
//
//  Created by Filipe Xavier Fernandes on 23/01/25.
//

import UIKit
import Combine

class DetailViewModel: ObservableObject {
    @Published var film: Film?
    @Published var isFavorite: Bool = false
    @Published var error: FilmServiceError?
    let filmId: Int
    let mediaType: MediaType
    private let filmService: FilmService
    private let favoritesService: FavoritesService
    private var cancellables = Set<AnyCancellable>()
    
    init(filmId: Int, mediaType: MediaType, filmService: FilmService, favoritesService: FavoritesService) {
        self.filmId = filmId
        self.mediaType = mediaType
        self.filmService = filmService
        self.favoritesService = favoritesService
        checkIfIsFavorite()
        fetchFilmDetails()
    }
    
    private func fetchFilmDetails() {
        filmService.fetchDetails(id: filmId, type: mediaType)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    self.error = error
                    print("Erro ao obter detalhes do filme: \(error)")
                case .finished:
                    break
                }
            } receiveValue: { movie in
                self.film = movie
            }.store(in: &cancellables)
    }

    func toggleFavorite() {
        if isFavorite {
            favoritesService.removeFavorite(itemId: filmId, mediaType: mediaType)
        } else {
            favoritesService.saveFavorite(itemId: filmId, mediaType: mediaType)
        }
        isFavorite.toggle()
    }
    
    private func checkIfIsFavorite(){
        isFavorite = favoritesService.isFavorite(itemId: filmId, mediaType: mediaType)
    }
}
