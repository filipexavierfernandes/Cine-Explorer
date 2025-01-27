//
//  FavoritesViewModelTests.swift
//  globoplay-desafio-ios-tests
//
//  Created by Filipe Xavier Fernandes on 27/01/25.
//

import XCTest
import Combine
@testable import globoplay_desafio_ios

class FavoritesViewModelTests: XCTestCase {
    var viewModel: FavoritesViewModel!
    var mockFavoritesService: FavoritesServiceMock!
    var mockMediaService: MediaServiceMock!
    var mockCoordinator: CoordinatorMock!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        
        mockFavoritesService = FavoritesServiceMock()
        mockMediaService = MediaServiceMock()
        mockCoordinator = CoordinatorMock()
        viewModel = FavoritesViewModel(favoritesService: mockFavoritesService,
                                       filmService: mockMediaService,
                                       coordinator: mockCoordinator)
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        mockFavoritesService = nil
        mockMediaService = nil
        mockCoordinator = nil
        cancellables = nil
        super.tearDown()
    }

    func testFetchFavorites() {
        let favoriteItem = FavoriteItem(id: 1, mediaType: .movie)
        mockFavoritesService.favorites = [favoriteItem]
        let mediaDetails = MediaDetails.movie(Movie.mock)
        mockMediaService.shouldFail = false
        
        let expectation = XCTestExpectation(description: "fetchData completes")
        
        viewModel.$favoriteMedia
            .sink { favorites in
                if favorites.first == mediaDetails {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.fetchFavorites()
        
        wait(for: [expectation], timeout: 5.0)
        
        XCTAssertEqual(viewModel.favoriteMedia.count, 1)
    }
    
    func testFetchFavorites_WithError() {
        let favoriteItem = FavoriteItem(id: 1, mediaType: .movie)
        mockFavoritesService.favorites = [favoriteItem]
        mockMediaService.shouldFail = true
        
        viewModel.fetchFavorites()
        
        XCTAssertNotNil(viewModel.error)
    }
    
    func testNavigateToDetail() {
        let mediaDetails = MediaDetails.movie(Movie.mock)
        
        viewModel.navigateToDetail(mediaDetails: mediaDetails)
        
        XCTAssertTrue(mockCoordinator.navigateToDetailsCalled)
    }
}
