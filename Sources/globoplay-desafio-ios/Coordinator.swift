//
//  HomeCoordinator.swift
//  globoplay-desafio-ios
//
//  Created by Filipe Xavier Fernandes on 23/01/25.
//

import Foundation
import UIKit

protocol CoordinatorProtocol: AnyObject {
    func navigateToFavorites()
    func navigateToDetails(id: Int, mediaType: MediaType)
    func popViewController()
    func presentErrorAlert(message: String)
}

class Coordinator: CoordinatorProtocol {
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
            let service = MediaService()
            let homeViewController = HomeViewController(service: service, coordinator: self)
            navigationController.pushViewController(homeViewController, animated: true)
        }

    func navigateToFavorites() {
        let viewModel = FavoritesViewModel(favoritesService: FavoritesService(), filmService: MediaService(), coordinator: self)
        let favoritesViewController = FavoritesViewController(viewModel: viewModel)
        navigationController.pushViewController(favoritesViewController, animated: true)
    }
    
    func navigateToDetails(id: Int, mediaType: MediaType) {
        let viewModel = DetailViewModel(filmId: id, mediaType: mediaType, filmService: MediaService(), favoritesService: FavoritesService(), coordinator: self)
        let detailViewController = DetailViewController(viewModel: viewModel)
        navigationController.pushViewController(detailViewController, animated: true)
    }
    
    func presentErrorAlert(message: String) {
        let alert = UIAlertController(title: "Erro", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        navigationController.present(alert, animated: true)
    }
    
    func popViewController() {
        navigationController.popViewController(animated: true)
    }

}
