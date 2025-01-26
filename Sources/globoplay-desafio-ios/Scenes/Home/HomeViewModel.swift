//
//  HomeViewModel.swift
//  globoplay-desafio-ios
//
//  Created by Filipe Xavier Fernandes on 23/01/25.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var sections: [HomeSection] = []
    @Published var filteredMedia: [MediaDetails] = []
    @Published var isSearching: Bool = false
    @Published var error: FilmServiceError?
    private var cancellables = Set<AnyCancellable>()
    private let service: MediaServiceProtocol
    private let coordinator: CoordinatorProtocol

    init(service: MediaServiceProtocol = MediaService(), coordinator: CoordinatorProtocol) {
        self.service = service
        self.coordinator = coordinator
    }

    func fetchData() {
        service.fetchData()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    self.error = error
                    print("Failed to fetch sections: \(error.localizedDescription)")
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] sections in
                DispatchQueue.main.async {
                    self?.sections = sections
                }
            })
            .store(in: &cancellables)
    }
    
    func searchMovies(query: String) {
        isSearching = !query.isEmpty
        if query.isEmpty {
            filteredMedia = []
            return
        }

        service.searchMedia(query: query)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Erro na busca: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] media in
                self?.filteredMedia = media
            })
            .store(in: &cancellables)
    }
    
    func endSearch() {
        isSearching = false
        filteredMedia = []
    }
    
    func navigateToFavorites() {
        coordinator.navigateToFavorites()
    }
    
    func navigateToDetails(id: Int, mediaType: MediaType) {
        coordinator.navigateToDetails(id: id, mediaType: mediaType)
    }
}

