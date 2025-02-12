//
//  TrailerManager.swift
//  globoplay-desafio-ios
//
//  Created by Filipe Xavier Fernandes on 25/01/25.
//

import Foundation
import Combine
import UIKit

enum TrailerError: Error {
    case noTrailerAvailable
    case networkError(Error)
    case decodingError(Error)
    case playerItemError(Error)
}

class TrailerManager {
    private let mediaService: MediaService
    private var cancellables = Set<AnyCancellable>()

    private func presentTrailer(for videoId: String, from viewController: UIViewController) {
        let trailerViewController = TrailerViewController()
        trailerViewController.videoId = videoId
        let navigationController = UINavigationController(rootViewController: trailerViewController)
        viewController.present(navigationController, animated: true, completion: nil)
    }
    
    init(mediaService: MediaService, cancellables: Set<AnyCancellable> = Set<AnyCancellable>()) {
        self.mediaService = mediaService
        self.cancellables = cancellables
    }

    func playTrailer(for mediaID: Int, mediaType: MediaType, from viewController: UIViewController) {
        mediaService.fetchTrailerURL(for: mediaID, mediaType: mediaType)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self ]completion in
                guard let self = self else { return }
                switch completion {
                    case .failure(let error):
                        let errorMessage: String
                        switch error {
                        case .noTrailerAvailable:
                            errorMessage = "Trailer Indisponível."
                        case .networkError(let error):
                            errorMessage = "Erro de Rede: \(error.localizedDescription)"
                        case .decodingError(let error):
                            errorMessage = "Erro ao processar dados: \(error.localizedDescription)"
                        case .playerItemError(let error):
                            errorMessage = "Erro ao reproduzir trailer: \(error.localizedDescription)"
                        }
                        self.showErrorAlert(message: errorMessage, from: viewController)
                    case .finished: break
                }
            }, receiveValue: { [weak self] url in
                guard let self = self, let url = url, let videoId = self.extractVideoId(from: url) else {
                    let alert = UIAlertController(title: "Erro", message: "infelizmente não conseguimos obter informações suficientes para reproduzir o vídeo", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    viewController.present(alert, animated: true)
                    return
                }
                self.presentTrailer(for: videoId, from: viewController)
            })
            .store(in: &cancellables)
    }
    
    private func showErrorAlert(message: String, from viewController: UIViewController) {
        let alert = UIAlertController(title: "Erro", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        viewController.present(alert, animated: true)
    }

    private func extractVideoId(from url: URL) -> String? {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let queryItems = urlComponents.queryItems else {
            return nil
        }
        
        return queryItems.first(where: { $0.name == "v" })?.value
    }
}
