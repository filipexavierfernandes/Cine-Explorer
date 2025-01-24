//
//  FilmServiceError.swift
//  globoplay-desafio-ios
//
//  Created by Filipe Xavier Fernandes on 24/01/25.
//
import Foundation

enum FilmServiceError: Error, LocalizedError {
    case invalidURL
    case apiError(Error)
    case invalidData
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida."
        case .apiError(let error):
            return "Erro na API: \(error.localizedDescription)"
        case .invalidData:
            return "Dados inválidos recebidos da API."
        case .decodingError(let error):
            return "Erro ao decodificar os dados: \(error.localizedDescription)"
        }
    }
}
