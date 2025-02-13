//
//  HomeViewModelMock.swift
//  globoplay-desafio-ios-tests
//
//  Created by Filipe Xavier Fernandes on 27/01/25.
//

import UIKit
@testable import globoplay_desafio_ios

class HomeViewModelMock: HomeViewModel {
    
    override func fetchData() {
        self.sections = [
            HomeSection(title: "Section 1", media: [.movie(Movie.mock)], mediaType: .movie),
            HomeSection(title: "Section 2", media: [.tvShow(TVShow.mock)], mediaType: .tv)
        ]
    }
    
    override func searchMovies(query: String) {
        self.isSearching = true
        self.filteredMedia = [.movie(Movie.mock)]
    }
    
    override func endSearch() {
        self.isSearching = false
        self.filteredMedia = []
    }
}
