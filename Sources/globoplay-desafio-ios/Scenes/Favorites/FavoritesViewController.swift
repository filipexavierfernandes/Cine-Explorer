//
//  FavoritesViewController.swift
//  globoplay-desafio-ios
//
//  Created by Filipe Xavier Fernandes on 23/01/25.
//

import UIKit
import Foundation
import Combine

class FavoritesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private let viewModel: FavoritesViewModel
    private var cancellables = Set<AnyCancellable>()
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.width / 2) - 16, height: 250)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(FilmCell.self, forCellWithReuseIdentifier: FilmCell.reuseIdentifier)
        collection.dataSource = self
        collection.delegate = self
        collection.backgroundColor = Colors.midGray
        return collection
    }()

    init(viewModel: FavoritesViewModel) {
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
        viewModel.fetchFavorites()
    }

    private func setupView() {
        view.backgroundColor = Colors.midGray
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func bindViewModel() {
        viewModel.$favoriteFilms
            .receive(on: DispatchQueue.main) // Garante que a atualização da UI ocorra na main thread
            .sink { [weak self] films in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$error.sink { error in
            guard let error = error else {return}
            print(error)
        }.store(in: &cancellables)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.favoriteFilms.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilmCell.reuseIdentifier, for: indexPath) as? FilmCell else {
            return UICollectionViewCell()
        }
        let film = viewModel.favoriteFilms[indexPath.row]
        cell.configure(with: film)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let film = viewModel.favoriteFilms[indexPath.row]
        let favoriteItems = FavoritesService().getFavorites()
        let mediaType = favoriteItems.first { $0.id == film.id }?.mediaType ?? .movie
        let detailViewModel = DetailViewModel(filmId: film.id ?? .zero, mediaType: mediaType, filmService: FilmService(), favoritesService: FavoritesService())
        let detailViewController = DetailViewController(viewModel: detailViewModel)
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}
