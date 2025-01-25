//
//  HomeModel.swift
//  globoplay-desafio-ios
//
//  Created by Filipe Xavier Fernandes on 23/01/25.
//

import Foundation

struct HomeSection {
    let title: String
    let films: [Film?]
    let mediaType: MediaType
}

struct MovieResponse: Codable {
    let results: [Movie]
}

struct Movie: Codable {
    let id: Int?
    let title: String?
    let name: String?
    let poster_path: String?
    let overview: String?
    let original_title: String?
    let number_of_episodes: Int?
    let release_date: String?
    let production_countries: [ProductionCountry]?
    let credits: Credits?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case name
        case poster_path
        case overview
        case original_title
        case number_of_episodes
        case release_date
        case production_countries
        case credits
    }
}

struct Credits: Codable {
    let cast: [CastMember]?
    let crew: [CrewMember]?
}

struct CrewMember: Codable {
    let job: String
    let name: String
}

struct Film: Identifiable, Codable {
    let id: Int?
    let title: String?
    let posterURL: String?
    let name: String?
    let overview: String?
    let originalTitle: String?
    let numberOfEpisodes: Int?
    let releaseDate: String?
    let productionCountries: [ProductionCountry]?
    let director: String?
    let cast: [CastMember]?
}

struct ProductionCountry: Codable {
    let name: String
}

struct CastMember: Codable {
    let name: String
}

enum MediaType: String, Codable {
    case tv
    case movie
    case none
}
