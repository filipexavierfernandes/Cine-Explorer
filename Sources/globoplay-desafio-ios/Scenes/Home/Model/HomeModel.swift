//
//  HomeModel.swift
//  globoplay-desafio-ios
//
//  Created by Filipe Xavier Fernandes on 23/01/25.
//

import Foundation

struct HomeSection {
    let title: String
    let films: [Film]
}

struct MovieResponse: Codable {
    let results: [Movie]
}

struct Movie: Codable {
    let id: Int?
    let title: String?
    let name: String?
    let poster_path: String?

    // Mapeamento para conversão de snake_case para camelCase
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case name
        case poster_path
    }
}

struct Film: Identifiable, Codable {
    let id: Int?
    let title: String?
    let posterURL: String?
    let name: String?
}
