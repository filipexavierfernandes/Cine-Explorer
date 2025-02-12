//
//  MediaServiceMock.swift
//  globoplay-desafio-ios-tests
//
//  Created by Filipe Xavier Fernandes on 26/01/25.
//

import Combine
import Foundation
@testable import globoplay_desafio_ios

final class MediaServiceMock: MediaServiceProtocol {
    var shouldFail: Bool = false

    func fetchData() -> AnyPublisher<[HomeSection], FilmServiceError> {
        if shouldFail {
            return Fail(error: FilmServiceError.apiError(URLError(.badServerResponse)))
                .eraseToAnyPublisher()
        }

        let sections = [
            HomeSection(title: "Filmes Populares", media: [.movie(Movie.mock)], mediaType: .movie),
            HomeSection(title: "Séries Populares", media: [.tvShow(TVShow.mock)], mediaType: .tv),
            HomeSection(title: "Filmes em Cartaz", media: [.movie(Movie.mock)], mediaType: .movie)
        ]
        return Just(sections)
            .setFailureType(to: FilmServiceError.self)
            .eraseToAnyPublisher()
    }

    func fetchDetails(id: Int, type: MediaType) -> AnyPublisher<MediaDetails, FilmServiceError> {
        if shouldFail {
            return Fail(error: FilmServiceError.apiError(URLError(.badServerResponse)))
                .eraseToAnyPublisher()
        }

        let details: MediaDetails = type == .movie ? .movie(Movie.mock) : .tvShow(TVShow.mock)
        return Just(details)
            .setFailureType(to: FilmServiceError.self)
            .eraseToAnyPublisher()
    }

    func searchMedia(query: String) -> AnyPublisher<[MediaDetails], FilmServiceError> {
        if shouldFail {
            return Fail(error: FilmServiceError.apiError(URLError(.badServerResponse)))
                .eraseToAnyPublisher()
        }

        let results: [MediaDetails] = [.movie(Movie.mock), .tvShow(TVShow.mock)]
        return Just(results)
            .setFailureType(to: FilmServiceError.self)
            .eraseToAnyPublisher()
    }

    func fetchRelated(id: Int, type: MediaType) -> AnyPublisher<[MediaDetails], FilmServiceError> {
        if shouldFail {
            return Fail(error: FilmServiceError.apiError(URLError(.badServerResponse)))
                .eraseToAnyPublisher()
        }

        let related: [MediaDetails] = [.movie(Movie.mock), .tvShow(TVShow.mock)]
        return Just(related)
            .setFailureType(to: FilmServiceError.self)
            .eraseToAnyPublisher()
    }

    func fetchTrailerURL(for id: Int, mediaType: MediaType) -> AnyPublisher<URL?, TrailerError> {
        if shouldFail {
            return Fail(error: TrailerError.networkError(URLError(.badServerResponse)))
                .eraseToAnyPublisher()
        }

        let url = URL(string: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")
        return Just(url)
            .setFailureType(to: TrailerError.self)
            .eraseToAnyPublisher()
    }
}

extension Movie {
    static var mock: Movie {
        return Movie(
            id: 1,
            title: "Mock Movie",
            original_title: "Mock Original Title",
            overview: "A mock movie for testing.",
            poster_path: "/mockposter.jpg",
            release_date: "2023-01-01",
            production_countries: [],
            genres: [],
            runtime: 120,
            credits: nil
        )
    }
}

extension TVShow {
    static var mock: TVShow {
        return TVShow(
            id: 1,
            name: "Mock TV Show",
            original_name: "Mock Original Name",
            overview: "A mock TV show for testing.",
            poster_path: "/mockposter.jpg",
            first_air_date: "2023-01-01",
            production_countries: [],
            genres: [],
            number_of_episodes: 10,
            number_of_seasons: 1,
            created_by: nil,
            networks: nil,
            credits: nil
        )
    }
}
