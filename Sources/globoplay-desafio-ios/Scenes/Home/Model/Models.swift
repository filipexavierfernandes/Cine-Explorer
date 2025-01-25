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
    let popularity: Double? // Adicione campos comuns aqui
    let media_type: String? // Campo para identificar o tipo de media
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
