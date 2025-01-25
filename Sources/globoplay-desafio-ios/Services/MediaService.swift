//
//  HomeService.swift
//  globoplay-desafio-ios
//
//  Created by Filipe Xavier Fernandes on 23/01/25.
//

import Foundation
import Combine

protocol MediaServiceProtocol {
    func fetchData() -> AnyPublisher<[HomeSection], FilmServiceError>
    func fetchDetails(id: Int, type: MediaType) -> AnyPublisher<MediaDetails, FilmServiceError>
}

final class MediaService: MediaServiceProtocol {
    
    func fetch(endpoint: String) -> AnyPublisher<(media: [MediaDetails], mediaType: MediaType), FilmServiceError> {
        let mediaType: MediaType = endpoint.contains("movie") ? .movie : .tvShow

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
            .decode(type: MediaResponse.self, decoder: JSONDecoder()) // Decode para MediaResponse
            .map { mediaResponse -> (media: [MediaDetails], mediaType: MediaType) in
                let mediaDetailsArray = mediaResponse.results.compactMap { media -> MediaDetails? in
                        switch mediaType {
                        case .movie:
                            let movie = Movie(id: media.id, title: media.title, original_title: media.original_title, overview: media.overview, poster_path: media.poster_path, release_date: media.release_date, production_countries: media.production_countries, genres: media.genres, runtime: nil, credits: media.credits)
                            return .movie(movie)
                        case .tvShow:
                            let tvShow = TVShow(id: media.id, name: media.name, original_name: media.original_name, overview: media.overview, poster_path: media.poster_path, first_air_date: media.first_air_date, production_countries: media.production_countries, genres: media.genres, number_of_episodes: nil, number_of_seasons: nil, created_by: nil, networks: nil, credits: media.credits)
                            return .tvShow(tvShow)
                        default:
                            return nil
                        }
                }
                return (media: mediaDetailsArray, mediaType: mediaType)
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
                HomeSection(title: "Filmes Populares", media: popularMovies, mediaType: popularMoviesType),
                HomeSection(title: "Séries Populares", media: popularSeries, mediaType: popularSeriesType),
                HomeSection(title: "Filmes em Cartaz", media: nowPlayingMovies, mediaType: nowPlayingMoviesType)
            ]
        }
        .eraseToAnyPublisher()
    }
    
    func fetchDetails(id: Int, type: MediaType) -> AnyPublisher<MediaDetails, FilmServiceError> {
        let endpoint: String
        switch type {
        case .movie:
            endpoint = "movie/\(id)"
        case .tvShow:
            endpoint = "tv/\(id)"
        case .none:
            return Fail(error: FilmServiceError.invalidURL).eraseToAnyPublisher()
        }

        guard let url = URL(string: "\(Constants.baseUrl)/\(endpoint)?api_key=\(Constants.apiToken)&language=pt-BR&append_to_response=credits") else {
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
            .decode(type: Media.self, decoder: JSONDecoder()) // Decodifica para Media
            .map { media -> MediaDetails in
                switch type {
                case .movie:
                    return MediaDetails.movie(Movie(id: media.id, title: media.title, original_title: media.original_title, overview: media.overview, poster_path: media.poster_path, release_date: media.release_date, production_countries: media.production_countries, genres: media.genres, runtime: nil, credits: media.credits))
                case .tvShow:
                    return MediaDetails.tvShow(TVShow(id: media.id, name: media.name, original_name: media.original_name, overview: media.overview, poster_path: media.poster_path, first_air_date: media.first_air_date, production_countries: media.production_countries, genres: media.genres, number_of_episodes: nil, number_of_seasons: nil, created_by: nil, networks: nil, credits: media.credits))
                case .none:
                    fatalError("Unexpected media type none")
                }
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
    
    func fetchRelated(id: Int, type: MediaType) -> AnyPublisher<[MediaDetails], FilmServiceError> {
        let endpoint: String
        switch type {
        case .movie:
            endpoint = "movie/\(id)/similar"
        case .tvShow:
            endpoint = "tv/\(id)/similar"
        case .none:
            return Just([]).setFailureType(to: FilmServiceError.self).eraseToAnyPublisher()
        }

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
            .decode(type: MediaResponse.self, decoder: JSONDecoder())
            .map { mediaResponse -> [MediaDetails] in
                mediaResponse.results.compactMap { media -> MediaDetails? in
                    switch type {
                    case .movie:
                        guard let movie = self.createMovieFromMedia(media) else { return nil }
                        return .movie(movie)
                    case .tvShow:
                        guard let tvShow = self.createTVShowFromMedia(media) else { return nil }
                        return .tvShow(tvShow)
                    case .none:
                        return nil
                    }
                }
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
    
    private func createMovieFromMedia(_ media: Media) -> Movie? {
        guard let id = media.id, let title = media.title ?? media.original_title, let overview = media.overview, let poster_path = media.poster_path, let release_date = media.release_date else { return nil }
        return Movie(id: id, title: title, original_title: media.original_title, overview: overview, poster_path: poster_path, release_date: release_date, production_countries: media.production_countries, genres: media.genres, runtime: nil, credits: media.credits)
    }

    private func createTVShowFromMedia(_ media: Media) -> TVShow? {
        guard let id = media.id, let name = media.name ?? media.original_name, let overview = media.overview, let poster_path = media.poster_path, let first_air_date = media.first_air_date else { return nil }
        return TVShow(id: id, name: name, original_name: media.original_name, overview: overview, poster_path: poster_path, first_air_date: first_air_date, production_countries: media.production_countries, genres: media.genres, number_of_episodes: nil, number_of_seasons: nil, created_by: nil, networks: nil, credits: media.credits)
    }
    
}
