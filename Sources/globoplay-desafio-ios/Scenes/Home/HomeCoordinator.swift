//
//  HomeCoordinator.swift
//  globoplay-desafio-ios
//
//  Created by Filipe Xavier Fernandes on 23/01/25.
//

import Foundation
import UIKit

protocol HomeCoordinatorProtocol: AnyObject {
    func navigateToFavorites()
    func navigateToDetails(id: Int, mediaType: MediaType)
}

class HomeCoordinator: HomeCoordinatorProtocol {
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
            let service = FilmService()
            let homeViewController = HomeViewController(service: service, coordinator: self)
            navigationController.pushViewController(homeViewController, animated: true)
        }

    func navigateToFavorites() {
        let viewModel = FavoritesViewModel(favoritesService: FavoritesService(), filmService: FilmService())
        let favoritesViewController = FavoritesViewController(viewModel: viewModel)
        navigationController.pushViewController(favoritesViewController, animated: true)
    }
    
    func navigateToDetails(id: Int, mediaType: MediaType) {
        let viewModel = DetailViewModel(filmId: id, mediaType: mediaType, filmService: FilmService(), favoritesService: FavoritesService())
        let detailViewController = DetailViewController(viewModel: viewModel)
        navigationController.pushViewController(detailViewController, animated: true)
    }
}
