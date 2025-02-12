//
//  HomeViewModelTests.swift
//  globoplay-desafio-ios
//
//  Created by Filipe Xavier Fernandes on 26/01/25.
//

import XCTest
import Combine
@testable import globoplay_desafio_ios

class HomeViewModelTests: XCTestCase {
    
    var viewModel: HomeViewModel!
    var mockService: MediaServiceMock!
    var mockCoordinator: CoordinatorMock!
    private var cancellables = Set<AnyCancellable>()
    
    override func setUp() {
        super.setUp()
        mockService = MediaServiceMock()
        mockCoordinator = CoordinatorMock()
        viewModel = HomeViewModel(service: mockService, coordinator: mockCoordinator)
    }

    override func tearDown() {
        viewModel = nil
        mockService = nil
        mockCoordinator = nil
        super.tearDown()
    }

    func testFetchData_Success() {
        // Arrange
        let expectedSections = [
            HomeSection(title: "Filmes Populares", media: [.movie(Movie.mock)], mediaType: .movie),
            HomeSection(title: "Séries Populares", media: [.tvShow(TVShow.mock)], mediaType: .tv),
            HomeSection(title: "Filmes em Cartaz", media: [.movie(Movie.mock)], mediaType: .movie)
        ]
        mockService.shouldFail = false
        
        let expectation = XCTestExpectation(description: "fetchData completes")
        
        viewModel.$sections
            .sink { sections in
                if sections == expectedSections {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Act
        viewModel.fetchData()
        
        wait(for: [expectation], timeout: 5.0)
        
        // Assert
        XCTAssertEqual(viewModel.sections, expectedSections)
        XCTAssertNil(viewModel.error)
    }

    func testFetchData_Failure() {
        // Arrange
        let expectedError = FilmServiceError.apiError(URLError(.badServerResponse))
        mockService.shouldFail = true
        
        let expectation = XCTestExpectation(description: "fetchData completes with failure")
        
        viewModel.$error
            .sink { error in
                if error == expectedError {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Act
        viewModel.fetchData()
        
        wait(for: [expectation], timeout: 5.0)
        
        // Assert
        XCTAssertEqual(viewModel.error, expectedError)
    }

    func testSearchMovies_ValidQuery() {
        // Arrange
        let mediaDetails = MediaDetails.movie(.mock)
        let query = "Movie"
        let expectedMedia = [mediaDetails, mediaDetails]
        mockService.shouldFail = false
        
        let expectation = XCTestExpectation(description: "fetchData completes successfully")

        viewModel.$filteredMedia
            .dropFirst()
            .sink { filteredData in
                if filteredData.count == expectedMedia.count,
                   filteredData.first == expectedMedia.first {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Act
        viewModel.searchMovies(query: query)
        
        wait(for: [expectation], timeout: 5.0)
        
        // Assert
        XCTAssertTrue(viewModel.isSearching)
        XCTAssertEqual(viewModel.filteredMedia.count, expectedMedia.count)
    }

    func testSearchMovies_EmptyQuery() {
        // Act
        viewModel.searchMovies(query: "")
        
        // Assert
        XCTAssertFalse(viewModel.isSearching)
        XCTAssertTrue(viewModel.filteredMedia.isEmpty)
    }

    func testEndSearch() {
        // Act
        viewModel.endSearch()
        
        // Assert
        XCTAssertFalse(viewModel.isSearching)
        XCTAssertTrue(viewModel.filteredMedia.isEmpty)
    }

    func testNavigateToFavorites() {
        // Act
        viewModel.navigateToFavorites()
        
        // Assert
        XCTAssertTrue(mockCoordinator.navigateToFavoritesCalled)
    }

    func testNavigateToDetails() {
        // Arrange
        let mediaID = 1
        let mediaType = MediaType.movie
        
        // Act
        viewModel.navigateToDetails(id: mediaID, mediaType: mediaType)
        
        // Assert
        XCTAssertTrue(mockCoordinator.navigateToDetailsCalled)
        XCTAssertEqual(mockCoordinator.navigateToDetailsId, mediaID)
        XCTAssertEqual(mockCoordinator.navigateToDetailsMediaType, mediaType)
    }
}
