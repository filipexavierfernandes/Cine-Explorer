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
    func fetchMovie(id: Int) -> AnyPublisher<Film, FilmServiceError>
}

final class FilmService: FilmServiceProtocol {

    func fetch(endpoint: String) -> AnyPublisher<[Film], FilmServiceError> {
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
            .map { response in
                response.results.map { movie in
                    guard let id = movie.id,
                          let title = movie.title ?? movie.name,
                          let posterPath = movie.poster_path else {
                        return Film(id: nil, title: nil, posterURL: nil, name: nil)
                    }
                    return Film(id: id, title: title, posterURL: Constants.imageBaseURL + posterPath, name: title)
                }
            }
            .mapError { error in
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
        .map { movies, series, cinemas in
            [
                HomeSection(title: "Filmes Populares", films: movies),
                HomeSection(title: "Séries Populares", films: series),
                HomeSection(title: "Filmes em Cartaz", films: cinemas)
            ]
        }
        .eraseToAnyPublisher()
    }
    
    func fetchMovie(id: Int) -> AnyPublisher<Film, FilmServiceError> {
        guard let url = URL(string: "\(Constants.baseUrl)/movie/\(id)?api_key=\(Constants.apiToken)&language=pt-BR") else {
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
                .decode(type: Film.self, decoder: JSONDecoder())
                .compactMap { movie in
                    guard let id = movie.id,
                          let title = movie.title ?? movie.name,
                          let posterPath = movie.posterURL else {
                        return nil
                    }
                    return Film(id: id, title: title, posterURL: Constants.imageBaseURL + posterPath, name: title)
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
