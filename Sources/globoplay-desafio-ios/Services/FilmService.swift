//
//  HomeService.swift
//  globoplay-desafio-ios
//
//  Created by Filipe Xavier Fernandes on 23/01/25.
//

import Foundation
import Combine

protocol FilmServiceProtocol {
    func fetchData() -> AnyPublisher<[HomeSection], FilmServiceError>
    func fetchDetails(id: Int, type: MediaType) -> AnyPublisher<Film?, FilmServiceError>
}

final class FilmService: FilmServiceProtocol {
    
    func fetch(endpoint: String) -> AnyPublisher<([Film?], MediaType), FilmServiceError> {
        let mediaType: MediaType = endpoint.contains("movie") ? .movie : .tv

        guard let url = URL(string: "\(Constants.baseUrl)/\(endpoint)?api_key=\(Constants.apiToken)&language=pt-BR&page=1") else {
            return Fail(error: FilmServiceError.invalidURL).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse,
                      200..<300 ~= httpResponse.statusCode else {
                    throw FilmServiceError.apiError(URLError(.badServerResponse))
                }
                return data
            }
            .decode(type: MovieResponse.self, decoder: JSONDecoder())
            .compactMap { movieResponse in
                movieResponse.results.compactMap { movie in
                    let director = movie.credits?.crew?.first(where: {$0.job == "Director"})?.name ?? String()
                    return Film(id: movie.id,
                                title: movie.title ?? movie.name,
                                posterURL: Constants.imageBaseURL + (movie.poster_path ?? String()),
                                name: movie.title ?? movie.name,
                                overview: movie.overview,
                                originalTitle: movie.original_title,
                                numberOfEpisodes: movie.number_of_episodes,
                                releaseDate: movie.release_date,
                                productionCountries: movie.production_countries,
                                director: director,
                                cast: movie.credits?.cast)
                }
            }
            .map { (films) in (films, mediaType) }
            .mapError { error -> FilmServiceError in
                if let filmError = error as? FilmServiceError {
                    return filmError
                } else if error is DecodingError {
                    return FilmServiceError.decodingError(error)
                } else {
                    return FilmServiceError.apiError(error)
                }
            }
            .eraseToAnyPublisher()
    }

    func fetchData() -> AnyPublisher<[HomeSection], FilmServiceError> {
        Publishers.CombineLatest3(
            fetch(endpoint: "movie/popular"),
            fetch(endpoint: "tv/popular"),
            fetch(endpoint: "movie/now_playing")
        )
        .map { (popularMoviesTuple, popularSeriesTuple, nowPlayingMoviesTuple) in
            let (popularMovies, popularMoviesType) = popularMoviesTuple
            let (popularSeries, popularSeriesType) = popularSeriesTuple
            let (nowPlayingMovies, nowPlayingMoviesType) = nowPlayingMoviesTuple

            return [
                HomeSection(title: "Filmes Populares", films: popularMovies, mediaType: popularMoviesType),
                HomeSection(title: "Séries Populares", films: popularSeries, mediaType: popularSeriesType),
                HomeSection(title: "Filmes em Cartaz", films: nowPlayingMovies, mediaType: nowPlayingMoviesType)
            ]
        }
        .eraseToAnyPublisher()
    }
    
    func fetchDetails(id: Int, type: MediaType) -> AnyPublisher<Film?, FilmServiceError> {
        let endpoint: String
        switch type {
        case .movie:
            endpoint = "movie/\(id)"
        case .tv:
            endpoint = "tv/\(id)"
        case .none:
            endpoint = String()
        }

        guard let url = URL(string: "\(Constants.baseUrl)/\(endpoint)?api_key=\(Constants.apiToken)&language=pt-BR") else {
            return Fail(error: FilmServiceError.invalidURL).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse,
                      200..<300 ~= httpResponse.statusCode else {
                    throw FilmServiceError.apiError(URLError(.badServerResponse))
                }
                return data
            }
            .decode(type: Movie.self, decoder: JSONDecoder())
            .map { movie in
                let director = movie.credits?.crew?.first(where: {$0.job == "Director"})?.name
                return Film(
                    id: id,
                    title: movie.title,
                    posterURL: Constants.imageBaseURL + (movie.poster_path ?? String()),
                    name: movie.name ?? movie.title,
                    overview: movie.overview,
                    originalTitle: movie.original_title,
                    numberOfEpisodes: movie.number_of_episodes,
                    releaseDate: movie.release_date,
                    productionCountries: movie.production_countries,
                    director: director ?? String(),
                    cast: movie.credits?.cast
                )
            }
            .mapError { error -> FilmServiceError in
                if let filmError = error as? FilmServiceError {
                    return filmError
                } else if error is DecodingError {
                    return FilmServiceError.decodingError(error)
                } else {
                    return FilmServiceError.apiError(error)
                }
            }
            .eraseToAnyPublisher()
        }
}
