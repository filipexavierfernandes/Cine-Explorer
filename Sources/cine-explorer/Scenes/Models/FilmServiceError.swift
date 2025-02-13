//
//  FilmServiceError.swift
//  globoplay-desafio-ios
//
//  Created by Filipe Xavier Fernandes on 24/01/25.
//

import Foundation

enum FilmServiceError: Error, LocalizedError, Equatable {
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

    static func == (lhs: FilmServiceError, rhs: FilmServiceError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL):
            return true
        case (.apiError(let lhsError), .apiError(let rhsError)):
            guard let lhsNSError = lhsError as? NSError, let rhsNSError = rhsError as? NSError else {
                return false
            }
            return lhsNSError.domain == rhsNSError.domain && lhsNSError.code == rhsNSError.code
        case (.invalidData, .invalidData):
            return true
        case (.decodingError(let lhsError), .decodingError(let rhsError)):
            guard let lhsNSError = lhsError as? NSError, let rhsNSError = rhsError as? NSError else {
                return false
            }
            return lhsNSError.domain == rhsNSError.domain && lhsNSError.code == rhsNSError.code
        default:
            return false
        }
    }
}
