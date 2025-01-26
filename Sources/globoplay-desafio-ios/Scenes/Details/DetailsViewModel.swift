//
//  DetailsViewModel.swift
//  globoplay-desafio-ios
//
//  Created by Filipe Xavier Fernandes on 23/01/25.
//

import UIKit
import Combine

class DetailViewModel: ObservableObject {
    @Published var mediaDetails: MediaDetails?
    @Published var mediaType: MediaType
    @Published var isFavorite: Bool = false
    @Published var error: FilmServiceError?
    @Published var relatedMedia: [MediaDetails] = []
    @Published var relatedMediaError: FilmServiceError?
    
    let filmId: Int
    private let mediaService: MediaService
    private let favoritesService: FavoritesService
    private var cancellables = Set<AnyCancellable>()
    private let coordinator: CoordinatorProtocol

    init(filmId: Int, mediaType: MediaType, filmService: MediaService, favoritesService: FavoritesService, coordinator: CoordinatorProtocol) {
        self.filmId = filmId
        self.mediaType = mediaType
        self.mediaService = filmService
        self.favoritesService = favoritesService
        self.coordinator = coordinator
        checkIfIsFavorite()
        fetchMediaDetails()
    }

    func fetchMediaDetails() {
        mediaService.fetchDetails(id: filmId, type: mediaType)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Erro ao buscar detalhes: \(error)")
                    self.error = error
                case .finished:
                    print("Fetch details finished")
                }
            }, receiveValue: { mediaDetails in
                self.mediaDetails = mediaDetails
            })
            .store(in: &cancellables)
    }
    
    func fetchRelatedMedia() {
        guard let mediaDetails = self.mediaDetails else { return }
        let mediaId = getMediaId(from: mediaDetails)
        let mediaType = self.mediaType

        mediaService.fetchRelated(id: mediaId, type: mediaType)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("Erro ao buscar relacionados: \(error)")
                    self.relatedMediaError = error
                case .finished:
                    print("Busca de relacionados finalizada")
                }
            } receiveValue: { relatedMedia in
                self.relatedMedia = relatedMedia
            }
            .store(in: &cancellables)
    }
    
    private func getMediaId(from mediaDetails: MediaDetails) -> Int {
        switch mediaDetails {
        case .movie(let movie):
            return movie.id ?? 0
        case .tvShow(let tvShow):
            return tvShow.id ?? 0
        }
    }
    
    func showDetailsFromRelated(for mediaDetails: MediaDetails) {
        let id = getMediaId(from: mediaDetails)
        coordinator.navigateToDetails(id: id, mediaType: self.mediaType)
    }

    func toggleFavorite() {
        if isFavorite {
            favoritesService.removeFavorite(itemId: filmId, mediaType: mediaType)
        } else {
            favoritesService.saveFavorite(itemId: filmId, mediaType: mediaType)
        }
        isFavorite.toggle()
    }

    func tapBackButton() {
        coordinator.popViewController()
    }

    private func checkIfIsFavorite() {
        isFavorite = favoritesService.isFavorite(itemId: filmId, mediaType: mediaType)
    }
}
