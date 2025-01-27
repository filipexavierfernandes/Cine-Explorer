//
//  FavoritesViewControllerSnapshotTests.swift
//  globoplay-desafio-ios-tests
//
//  Created by Filipe Xavier Fernandes on 27/01/25.
//

import SnapshotTesting
import XCTest
@testable import globoplay_desafio_ios

class FavoritesViewControllerSnapshotTests: XCTestCase {

    func testFavoritesViewController() {
        // Criar um ViewModel simplificado
        let favoritesService = FavoritesServiceMock()
        let mediaService = MediaServiceMock()
        let coordinator = CoordinatorMock()
        
        // Mockar dados para a tela de favoritos
        let favoriteItem = FavoriteItem(id: 1, mediaType: .movie)
        favoritesService.favorites = [favoriteItem]
        let mediaDetails = MediaDetails.movie(Movie.mock)
        mediaService.shouldFail = false
        
        // Criar a ViewController com os mocks
        let viewModel = FavoritesViewModel(favoritesService: favoritesService,
                                           filmService: mediaService,
                                           coordinator: coordinator)
        let viewController = FavoritesViewController(viewModel: viewModel)

        // Configuração do snapshot
        isRecording = false
        viewController.loadViewIfNeeded()
        viewController.view.frame = CGRect(x: 0, y: 0, width: 1179, height: 2556)
        
        // Comparar o snapshot
        assertSnapshot(matching: viewController, as: .image)
    }
}
