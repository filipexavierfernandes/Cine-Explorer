//
//  FavoritesViewModel.swift
//  globoplay-desafio-ios
//
//  Created by Filipe Xavier Fernandes on 23/01/25.
//

import Foundation
import Combine

class FavoritesViewModel: ObservableObject {
    @Published var favoriteMedia: [MediaDetails] = []
    @Published var error: FilmServiceError?
    private let favoritesService: FavoritesService
    private let mediaService: MediaService
    private var cancellables = Set<AnyCancellable>()
    private var coordinator: Coordinator
    
    init(favoritesService: FavoritesService, filmService: MediaService, coordinator: Coordinator) {
        self.favoritesService = favoritesService
        self.mediaService = filmService
        self.coordinator = coordinator
    }

    func fetchFavorites() {
        let favoriteItems = favoritesService.getFavorites()
        favoriteMedia = []

        favoriteItems.forEach { item in
            mediaService.fetchDetails(id: item.id, type: item.mediaType)
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        self.error = error
                        print("Erro ao obter detalhes do favorito: \(error)")
                    case .finished:
                        break
                    }
                } receiveValue: { [weak self] media in
                    self?.favoriteMedia.append(media)
                }
                .store(in: &cancellables)
        }
    }
    
    func navigateToDetail(mediaDetails: MediaDetails) {
        var mediaType: MediaType = .movie
        switch mediaDetails {
        case .movie:
            mediaType = .movie
        case .tvShow:
            mediaType = .tvShow
        }
        coordinator.navigateToDetails(id: getMediaId(from: mediaDetails), mediaType: mediaType)
    }
    
    private func getMediaId(from mediaDetails: MediaDetails) -> Int {
        switch mediaDetails {
        case .movie(let movie):
            return movie.id ?? Int()
        case .tvShow(let tvShow):
            return tvShow.id ?? Int()
        }
    }
}
