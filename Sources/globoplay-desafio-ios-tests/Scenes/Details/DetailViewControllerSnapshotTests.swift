//
//  DetailViewControllerSnapshotTests.swift
//  globoplay-desafio-ios-tests
//
//  Created by Filipe Xavier Fernandes on 27/01/25.
//

import XCTest
import SnapshotTesting
@testable import globoplay_desafio_ios

class DetailViewControllerSnapshotTests: XCTestCase {

    var viewController: DetailViewController!
    var viewModel: DetailViewModel!
    
    override func setUp() {
        super.setUp()
        let service = MediaService()
        let coordinator = Coordinator(navigationController: UINavigationController())
        viewModel = DetailViewModel(filmId: 1, mediaType: .movie, filmService: service, favoritesService: FavoritesService(), coordinator: coordinator)
        
        viewController = DetailViewController(viewModel: viewModel)
        _ = viewController.view
    }

    override func tearDown() {
        viewController = nil
        viewModel = nil
        super.tearDown()
    }

    func testDetailViewController_snapshot() {
        isRecording = false
        
        viewController.view.layoutIfNeeded()

        assertSnapshot(matching: viewController, as: .image)
    }
}
