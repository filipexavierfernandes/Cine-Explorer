//
//  NewModels.swift
//  globoplay-desafio-ios
//
//  Created by Filipe Xavier Fernandes on 25/01/25.
//

import Foundation

// Modelo para Filmes
struct Movie: Codable {
    let id: Int?
    let title: String?
    let original_title: String?
    let overview: String?
    let poster_path: String?
    let release_date: String?
    let production_countries: [ProductionCountry]?
    let genres: [Genre]? // Gêneros específicos para filmes
    let runtime: Int? // Duração do filme
    let credits: Credits?

    enum CodingKeys: String, CodingKey {
        case id, title, original_title, overview, poster_path, release_date, production_countries, genres, runtime, credits
    }
}

// Modelo para Séries de TV
struct TVShow: Codable {
    let id: Int?
    let name: String?
    let original_name: String?
    let overview: String?
    let poster_path: String?
    let first_air_date: String? // Data do primeiro episódio
    let production_countries: [ProductionCountry]?
    let genres: [Genre]? // Gêneros específicos para séries
    let number_of_episodes: Int?
    let number_of_seasons: Int?
    let created_by: [CreatedBy]? // Criadores da série
    let networks: [Network]?
    let credits: Credits?

    enum CodingKeys: String, CodingKey {
        case id, name, original_name, overview, poster_path, first_air_date, production_countries, genres, number_of_episodes, number_of_seasons, created_by, networks, credits
    }
}

// Modelo para Gêneros (comum a filmes e séries)
struct Genre: Codable {
    let id: Int?
    let name: String?
}

// Modelo para Países de Produção (comum a filmes e séries)
struct ProductionCountry: Codable {
    let name: String?
}

// Modelo para Créditos (comum a filmes e séries)
struct Credits: Codable {
    let cast: [Cast]?
    let crew: [Crew]?
}

// Modelo para Elenco (comum a filmes e séries)
struct Cast: Codable {
    let name: String?
    let profile_path: String?
}

// Modelo para Equipe (comum a filmes e séries)
struct Crew: Codable {
    let name: String?
    let job: String?
}

// Modelo para Criadores de Série (específico para séries)
struct CreatedBy: Codable {
    let name: String?
}

// Modelo para Networks (específico para séries)
struct Network: Codable {
    let name: String?
}

struct HomeSection {
    let title: String
    let media: [MediaDetails]
    let mediaType: MediaType
}

enum MediaType: String, Codable {
    case movie
    case tvShow
    case none
}

enum MediaDetails {
    case movie(Movie)
    case tvShow(TVShow)
}
