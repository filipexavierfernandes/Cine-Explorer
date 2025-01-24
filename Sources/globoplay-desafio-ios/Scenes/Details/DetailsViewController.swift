//
//  DetailsViewController.swift
//  globoplay-desafio-ios
//
//  Created by Filipe Xavier Fernandes on 23/01/25.
//

import Foundation
import UIKit
import Combine

class DetailViewController: UIViewController {
    private let viewModel: DetailViewModel
    private var cancellables = Set<AnyCancellable>()
    private let favoriteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.addTarget(DetailViewController.self, action: #selector(favoriteTapped), for: .touchUpInside)
        return button
    }()
    private let filmImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let filmTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindViewModel()
    }
    
    private func setupView(){
        view.backgroundColor = .systemBackground
        view.addSubview(filmImageView)
        view.addSubview(filmTitleLabel)
        view.addSubview(favoriteButton)
        filmImageView.translatesAutoresizingMaskIntoConstraints = false
        filmTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            filmImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            filmImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filmImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            filmImageView.heightAnchor.constraint(equalToConstant: 300),
            
            filmTitleLabel.topAnchor.constraint(equalTo: filmImageView.bottomAnchor, constant: 16),
            filmTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filmTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            favoriteButton.topAnchor.constraint(equalTo: filmTitleLabel.bottomAnchor, constant: 16),
            favoriteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func bindViewModel() {
        viewModel.$film
            .compactMap { $0 }
            .sink { [weak self] film in
                DispatchQueue.main.async {
                    self?.filmTitleLabel.text = film.title
                    self?.filmImageView.sd_setImage(with: URL(string: film.posterURL ?? ""), placeholderImage: UIImage(named: "placeholder"))
                
                }
            }
            .store(in: &cancellables)
        
        viewModel.$isFavorite.sink { [weak self] isFavorite in
            let imageName = isFavorite ? "heart.fill" : "heart"
            DispatchQueue.main.async {
                self?.favoriteButton.setImage(UIImage(systemName: imageName), for: .normal)
            }
        }.store(in: &cancellables)
    }
    
    @objc private func favoriteTapped() {
        viewModel.toggleFavorite()
    }
}
