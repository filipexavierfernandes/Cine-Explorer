//
//  DetailsViewModelTests.swift
//  globoplay-desafio-ios-tests
//
//  Created by Filipe Xavier Fernandes on 27/01/25.
//

import XCTest
import Combine
@testable import globoplay_desafio_ios

class DetailsViewModelTests: XCTestCase {
    var viewModel: DetailViewModel!
    var mediaServiceMock: MediaServiceMock!
    var favoritesServiceMock: FavoritesServiceMock!
    var coordinatorMock: CoordinatorMock!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = Set<AnyCancellable>()
        mediaServiceMock = MediaServiceMock()
        favoritesServiceMock = FavoritesServiceMock()
        coordinatorMock = CoordinatorMock()
        
        viewModel = DetailViewModel(
            filmId: 1,
            mediaType: .movie,
            filmService: mediaServiceMock,
            favoritesService: favoritesServiceMock,
            coordinator: coordinatorMock
        )
    }

    override func tearDown() {
        cancellables = nil
        mediaServiceMock = nil
        favoritesServiceMock = nil
        coordinatorMock = nil
        viewModel = nil
        super.tearDown()
    }

    func testFetchMediaDetailsSuccess() {
        
        let expectedMedia = MediaDetails.movie(Movie.mock)
        mediaServiceMock.shouldFail = false
        
        let expectation = XCTestExpectation(description: "fetchData completes")
        
        viewModel.$mediaDetails
            .sink { media in
                if media == expectedMedia {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.fetchMediaDetails()
        
        wait(for: [expectation], timeout: 5.0)

        XCTAssertNotNil(viewModel.mediaDetails)
        XCTAssertNil(viewModel.error, "Não deveria ter ocorrido erro.")
    }

    func testFetchMediaDetailsFailure() {
        let expectedError = FilmServiceError.apiError(URLError(.badServerResponse))

        mediaServiceMock.shouldFail = true
        
        let expectation = XCTestExpectation(description: "fetchData completes with failure")
        
        viewModel.$error
            .sink { error in
                if error == expectedError {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Act
        
        viewModel.fetchMediaDetails()
        
        wait(for: [expectation], timeout: 5.0)

        XCTAssertEqual(viewModel.error, expectedError)
    }


    func testToggleFavorite() {
        viewModel.isFavorite = false
        
        viewModel.toggleFavorite()

        XCTAssertTrue(viewModel.isFavorite)

        viewModel.toggleFavorite()

        XCTAssertFalse(viewModel.isFavorite)
    }

    func testShowDetailsFromRelated() {
        let relatedMedia: [MediaDetails] = [.movie(Movie.mock), .tvShow(TVShow.mock)]
        viewModel.relatedMedia = relatedMedia

        viewModel.showDetailsFromRelated(for: relatedMedia.first!)

        XCTAssertEqual(coordinatorMock.navigateToDetailsCalled, true)
    }
}
