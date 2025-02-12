//
//  HomeModel.swift
//  globoplay-desafio-ios
//
//  Created by Filipe Xavier Fernandes on 23/01/25.
//

import Foundation

struct MediaResponse: Codable, Equatable {
    let results: [Media]
}

struct Media: Codable, Equatable {
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
}

struct Movie: Codable, Equatable {
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
}

struct TVShow: Codable, Equatable {
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
}

struct Genre: Codable, Equatable {
    let id: Int?
    let name: String?
}

struct ProductionCountry: Codable, Equatable {
    let name: String?
}

struct Credits: Codable, Equatable {
    let cast: [Cast]?
    let crew: [Crew]?
}

struct Cast: Codable, Equatable {
    let name: String?
    let profile_path: String?
}

struct Crew: Codable, Equatable {
    let name: String?
    let job: String?
}

struct CreatedBy: Codable, Equatable {
    let name: String?
}

struct Network: Codable, Equatable {
    let name: String?
}

struct HomeSection: Equatable {
    let title: String
    let media: [MediaDetails]
    let mediaType: MediaType
}

enum MediaType: String, Codable, Equatable {
    case movie
    case tv
    case none
}

enum MediaDetails: Equatable {
    case movie(Movie)
    case tvShow(TVShow)
}

struct Video: Decodable, Equatable {
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

struct VideosResponse: Decodable, Equatable {
    let id: Int?
    let results: [Video]?
}

struct MovieSearchResponse: Codable, Equatable {
    let results: [Movie]
}

struct TVShowSearchResponse: Codable, Equatable {
    let results: [TVShow]
}
