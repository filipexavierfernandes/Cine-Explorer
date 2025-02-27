//
//  HomeViewController.swift
//  globoplay-desafio-ios
//
//  Created by Filipe Xavier Fernandes on 22/01/25.
//

import UIKit
import Combine

class HomeViewController: UIViewController {
    
    var viewModel: HomeViewModel?
    var cancellables = Set<AnyCancellable>()
    var searchController: UISearchController?
    
    private lazy var collectionView: UICollectionView = {
        let layout = createCompositionalLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = Colors.midGray
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(HeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: HeaderView.reuseIdentifier)
        collectionView.register(FilmCell.self, forCellWithReuseIdentifier: FilmCell.reuseIdentifier)
        collectionView.register(SkeletonFilmCell.self, forCellWithReuseIdentifier: SkeletonFilmCell.reuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private var isLoading: Bool = true {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    init(service: MediaServiceProtocol, coordinator: CoordinatorProtocol) {
        self.viewModel = HomeViewModel(service: service, coordinator: coordinator)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel?.fetchData()
        
        searchController = UISearchController(searchResultsController: nil)
        searchController?.obscuresBackgroundDuringPresentation = false
        searchController?.searchBar.placeholder = "Buscar filmes"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController?.searchBar.delegate = self
        searchController?.searchBar.showsCancelButton = true

        navigationItem.title = "Cine Explorer"

        let favoriteButton = UIBarButtonItem(image: UIImage(systemName: "star"), style: .plain, target: self, action: #selector(favoritesButtonTapped))
        navigationItem.rightBarButtonItem = favoriteButton
    }
    
    func setViewModel(_ viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }
    
    private func setupUI() {
        view.backgroundColor = .darkGray
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func bindViewModel() {
        viewModel?.$sections
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.isLoading = false
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel?.$filteredMedia
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel?.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let error = error else { return }
                let alert = UIAlertController(title: "Erro", message: "Desculpe pelo incômodo", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
            .store(in: &cancellables)
    }
    
    @objc private func favoritesButtonTapped() {
        viewModel?.navigateToFavorites()
    }
    
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, environment -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(120),
                                                  heightDimension: .absolute(180))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .absolute(180))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            group.interItemSpacing = .fixed(8)
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.interGroupSpacing = 16
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                    heightDimension: .absolute(50))
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top)
            section.boundarySupplementaryItems = [sectionHeader]
            section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
            
            return section
        }
    }
}

// MARK: - UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if isLoading {
          return 3
        } else {
            return viewModel?.isSearching ?? false ? 1 : viewModel?.sections.count ?? 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isLoading {
            return 5
        } else {
            return viewModel?.isSearching ?? false ? viewModel?.filteredMedia.count ?? 0 : viewModel?.sections[section].media.count ?? 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isLoading {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SkeletonFilmCell.reuseIdentifier, for: indexPath) as? SkeletonFilmCell else {
                return UICollectionViewCell()
            }
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilmCell.reuseIdentifier, for: indexPath) as? FilmCell else {
                return UICollectionViewCell()
            }
            
            if viewModel?.isSearching ?? false {
                guard let mediaDetails = viewModel?.filteredMedia[indexPath.row] else {
                    return UICollectionViewCell()
                }
                switch mediaDetails {
                case .movie(let movie):
                    cell.configure(with: movie)
                case .tvShow(let tvShow):
                    cell.configure(with: tvShow)
                }
                return cell
            } else {
                
                guard let mediaDetails = viewModel?.sections[indexPath.section].media[indexPath.row] else {
                    return UICollectionViewCell()
                }
                switch mediaDetails {
                case .movie(let movie):
                    cell.configure(with: movie)
                case .tvShow(let tvShow):
                    cell.configure(with: tvShow)
                }
                return cell
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                            viewForSupplementaryElementOfKind kind: String,
                            at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }

        if isLoading {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderView.reuseIdentifier, for: indexPath)
            return header
        } else {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderView.reuseIdentifier, for: indexPath) as? HeaderView else {
                return UICollectionReusableView()
            }
            header.configure(with: viewModel?.sections[indexPath.section].title ?? String())
            return header
        }
    }
}

// MARK: - UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isLoading {
            if viewModel?.isSearching ?? false {
                guard let media = viewModel?.filteredMedia[indexPath.row] else { return }
                switch media {
                case .movie(let movie):
                    self.viewModel?.navigateToDetails(id: movie.id ?? .zero, mediaType: .movie)
                case .tvShow(let tvShow):
                    self.viewModel?.navigateToDetails(id: tvShow.id ?? .zero, mediaType: .tv)
                }
            } else {
                let section =  viewModel?.sections[indexPath.section]
                let selected = section?.media[indexPath.row]
                let mediaType = section?.mediaType ?? .none
                
                switch selected {
                case .movie(let movie):
                    self.viewModel?.navigateToDetails(id: movie.id ?? .zero, mediaType: mediaType)
                case .tvShow(let tvShow):
                    self.viewModel?.navigateToDetails(id: tvShow.id ?? .zero, mediaType: mediaType)
                case .none:
                    break
                }
            }
        }
    }
}

extension HomeViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        viewModel?.searchMovies(query: searchText)
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        viewModel?.endSearch()
        searchBar.resignFirstResponder()
    }
}

