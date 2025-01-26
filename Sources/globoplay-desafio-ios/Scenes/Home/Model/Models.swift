//
//  HomeModel.swift
//  globoplay-desafio-ios
//
//  Created by Filipe Xavier Fernandes on 23/01/25.
//

import Foundation

struct MediaResponse: Codable {
    let results: [Media]
}

struct Media: Codable {
    let id: Int?
    let poster_path: String?
    let overview: String?
    let popularity: Double?
    let media_type: String?
    let title: String?
    let name: String?
    let original_title: String?
    let original_name: String?
    let release_date: String?
    let first_air_date: String?
    let production_countries: [ProductionCountry]?
    let genres: [Genre]?
    let credits: Credits?

    enum CodingKeys: String, CodingKey {
        case id, poster_path, overview, popularity, media_type, title, name, original_title, original_name, release_date, first_air_date, production_countries, genres, credits
    }
}

//model pra filmes
struct Movie: Codable {
    let id: Int?
    let title: String?
    let original_title: String?
    let overview: String?
    let poster_path: String?
    let release_date: String?
    let production_countries: [ProductionCountry]?
    let genres: [Genre]?
    let runtime: Int?
    let credits: Credits?

    enum CodingKeys: String, CodingKey {
        case id, title, original_title, overview, poster_path, release_date, production_countries, genres, runtime, credits
    }
}

// model para Séries de TV
struct TVShow: Codable {
    let id: Int?
    let name: String?
    let original_name: String?
    let overview: String?
    let poster_path: String?
    let first_air_date: String?
    let production_countries: [ProductionCountry]?
    let genres: [Genre]?
    let number_of_episodes: Int?
    let number_of_seasons: Int?
    let created_by: [CreatedBy]?
    let networks: [Network]?
    let credits: Credits?

    enum CodingKeys: String, CodingKey {
        case id, name, original_name, overview, poster_path, first_air_date, production_countries, genres, number_of_episodes, number_of_seasons, created_by, networks, credits
    }
}

// Modelo para Gêneros
struct Genre: Codable {
    let id: Int?
    let name: String?
}

// Modelo para Países de Produção
struct ProductionCountry: Codable {
    let name: String?
}

// Modelo para Créditos
struct Credits: Codable {
    let cast: [Cast]?
    let crew: [Crew]?
}

// Modelo para Elenco
struct Cast: Codable {
    let name: String?
    let profile_path: String?
}

// Modelo para Equipe
struct Crew: Codable {
    let name: String?
    let job: String?
}

// Modelo para Criadores de Série
struct CreatedBy: Codable {
    let name: String?
}

// Modelo para Networks
struct Network: Codable {
    let name: String?
}

// Modelo para a estrutura da home
struct HomeSection {
    let title: String
    let media: [MediaDetails]
    let mediaType: MediaType
}

enum MediaType: String, Codable {
    case movie
    case tv
    case none
}

enum MediaDetails {
    case movie(Movie)
    case tvShow(TVShow)
}

struct Video: Decodable {
    let iso_639_1: String?
    let iso_3166_1: String?
    let name: String?
    let key: String?
    let published_at: String?
    let site: String?
    let size: Int?
    let type: String?
    let official: Bool?
    let id: String?
}

struct VideosResponse: Decodable {
    let id: Int?
    let results: [Video]?
}

struct MovieSearchResponse: Codable {
    let results: [Movie]
}

struct TVShowSearchResponse: Codable {
    let results: [TVShow]
}
