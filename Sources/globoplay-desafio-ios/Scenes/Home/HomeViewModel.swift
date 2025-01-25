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
    @Published var error: FilmServiceError?
    private var cancellables = Set<AnyCancellable>()
    private let service: FilmServiceProtocol
    private let coordinator: HomeCoordinatorProtocol

    init(service: FilmServiceProtocol = FilmService(), coordinator: HomeCoordinatorProtocol) {
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

    func navigateToFavorites() {
        coordinator.navigateToFavorites()
    }
    
    func navigateToDetails(id: Int, mediaType: MediaType) {
        coordinator.navigateToDetails(id: id, mediaType: mediaType)
    }
}

