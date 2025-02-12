//
//  DetailsViewController.swift
//  globoplay-desafio-ios
//
//  Created by Filipe Xavier Fernandes on 23/01/25.
//

import UIKit
import Combine
import SDWebImage

class DetailViewController: UIViewController {
    private let viewModel: DetailViewModel
    private let mediaService = MediaService()
    private lazy var trailerManager = TrailerManager(mediaService: mediaService)
    private var cancellables = Set<AnyCancellable>()
    
    // UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let containerView: UIView = {
        let view = UIView()
        return view
    }()
    private var detailsView: DetailsInfoView?
    private var relatedFilmsView: RelatedFilmsView?
    private var currentView: UIView?
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let headerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        return view
    }()
    
    private let headerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let contentAboveView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let solidImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 24)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 3.0
        label.layer.shadowOpacity = 0.5
        label.layer.shadowOffset = CGSize(width: 1, height: 1)
        label.layer.masksToBounds = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.textColor = .white
        label.textAlignment = .center
        
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 3.0
        label.layer.shadowOpacity = 0.5
        label.layer.shadowOffset = CGSize(width: 1, height: 1)
        label.layer.masksToBounds = false
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    private let watchButton: UIButton = createButton(title: "Assistir Trailer", imageName: "play.fill")
    private let favoriteButton: UIButton = createButton(title: "Favoritos", imageName: "star")
    
    private let segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Assista Também", "Detalhes"])
        segmentedControl.selectedSegmentIndex = 1
        segmentedControl.backgroundColor = Colors.midGray
        segmentedControl.tintColor = .clear
        
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.gray], for: .normal)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)], for: .normal)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)], for: .selected)
        segmentedControl.isUserInteractionEnabled = true

        return segmentedControl
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
        setBackButton()
        setupActivityIndicator()
        bindViewModel()
        showDetailsView()
    }
    
    private func setupActivityIndicator() {
       view.addSubview(activityIndicator)
       activityIndicator.translatesAutoresizingMaskIntoConstraints = false
       NSLayoutConstraint.activate([
           activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
           activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
       ])
       activityIndicator.startAnimating()
   }
    
    private func setupColors() {
        headerImageView.backgroundColor = .black
        solidImageView.backgroundColor = .lightGray
        detailsView?.backgroundColor = Colors.midGray
    }
    
    private func setBackButton() {
        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func getHeaderSize() -> CGFloat {
        var size: CGFloat
        size = view.frame.height * 0.60
        return size
    }
    
    private func setupView() {
        view.backgroundColor = Colors.midGray
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(headerView)
        headerView.addSubview(headerImageView)
        headerView.addSubview(contentAboveView)
        
        contentAboveView.addSubview(solidImageView)
        contentAboveView.addSubview(titleLabel)
        contentAboveView.addSubview(subtitleLabel)
        contentAboveView.addSubview(descriptionLabel)
        contentAboveView.addSubview(watchButton)
        contentAboveView.addSubview(favoriteButton)
        
        contentView.addSubview(segmentedControl)
        contentView.addSubview(containerView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerImageView.translatesAutoresizingMaskIntoConstraints = false
        solidImageView.translatesAutoresizingMaskIntoConstraints = false
        contentAboveView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        watchButton.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false

        let horizontalPadding: CGFloat = 16
        let buttonHeight: CGFloat = 50
        let imageSize: CGFloat = 180
        let topSpacing: CGFloat = 16

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            headerImageView.topAnchor.constraint(equalTo: headerView.topAnchor),
            headerImageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            headerImageView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            headerImageView.bottomAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 8),
            headerImageView.heightAnchor.constraint(equalTo: headerImageView.widthAnchor, multiplier: 1),

            solidImageView.centerYAnchor.constraint(equalTo: headerImageView.centerYAnchor),
            solidImageView.centerXAnchor.constraint(equalTo: contentAboveView.centerXAnchor),
            solidImageView.heightAnchor.constraint(equalToConstant: imageSize),
            solidImageView.widthAnchor.constraint(equalToConstant: imageSize * 0.70),

            titleLabel.topAnchor.constraint(equalTo: solidImageView.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: horizontalPadding),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -horizontalPadding),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentAboveView.leadingAnchor, constant: horizontalPadding),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentAboveView.trailingAnchor, constant: -horizontalPadding),

            descriptionLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: topSpacing),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentAboveView.leadingAnchor, constant: horizontalPadding),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentAboveView.trailingAnchor, constant: -horizontalPadding),

            watchButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: topSpacing),
            watchButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: horizontalPadding),
            watchButton.widthAnchor.constraint(equalTo: headerView.widthAnchor, multiplier: 0.45),
            watchButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            watchButton.bottomAnchor.constraint(lessThanOrEqualTo: headerView.bottomAnchor, constant: -topSpacing),

            favoriteButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: topSpacing),
            favoriteButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -horizontalPadding),
            favoriteButton.widthAnchor.constraint(equalTo: headerView.widthAnchor, multiplier: 0.45),
            favoriteButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            
            contentAboveView.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentAboveView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentAboveView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentAboveView.bottomAnchor.constraint(equalTo: segmentedControl.topAnchor),

            segmentedControl.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 24),
            segmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            segmentedControl.heightAnchor.constraint(equalToConstant: 45),
            
            containerView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 0),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)
        ])
        
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        watchButton.addTarget(self, action: #selector(watchButtonTapped), for: .touchUpInside)
        favoriteButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
        setupColors()
        view.layoutIfNeeded()
    }
    
    @objc private func backButtonTapped() {
        viewModel.tapBackButton()
    }
    
    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        updateCurrentView()
    }
    
    private func showDetailsView() {
         guard let mediaDetails = viewModel.mediaDetails else {
            showLoadingIndicator()
            return
        }
        hideLoadingIndicator()

        if detailsView == nil {
            detailsView = DetailsInfoView()
        }
        currentView?.removeFromSuperview()
        currentView = detailsView
        guard let current = currentView else { return }
        containerView.addSubview(current)
        setupConstraints(for: current)
        configureDetailsView(with: mediaDetails)
        segmentedControl.selectedSegmentIndex = 1
    }
    
    private func updateCurrentView() {
        guard let mediaDetails = viewModel.mediaDetails else {
            showLoadingIndicator()
            return
        }
        hideLoadingIndicator()

        switch segmentedControl.selectedSegmentIndex {
        case 0:
            if relatedFilmsView == nil {
                relatedFilmsView = RelatedFilmsView()
                relatedFilmsView?.delegate = self
                currentView?.removeFromSuperview()
                currentView = relatedFilmsView
                addCurrentToContainer()
                viewModel.fetchRelatedMedia()
                relatedFilmsView?.configure(with: [], hasRelatedVideos: false, isLoading: true)
            } else {
                currentView?.removeFromSuperview()
                currentView = relatedFilmsView
                addCurrentToContainer()
            }
        case 1:
            if detailsView == nil {
                detailsView = DetailsInfoView()
                currentView?.removeFromSuperview()
                currentView = detailsView
                addCurrentToContainer()
            } else if currentView !== detailsView {
                currentView?.removeFromSuperview()
                currentView = detailsView
                addCurrentToContainer()
            }
            configureDetailsView(with: mediaDetails)
        default:
            break
        }
    }
    
    private func configureDetailsView(with mediaDetails: MediaDetails) {
        switch mediaDetails {
        case .movie(let movie):
            detailsView?.configure(with: movie)
        case .tvShow(let tvShow):
            detailsView?.configure(with: tvShow)
        }
    }
    
    private func addCurrentToContainer() {
        guard let current = currentView else { return }
        containerView.addSubview(current)
        setupConstraints(for: current)
        view.layoutIfNeeded()
    }

    private func setupConstraints(for view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: containerView.topAnchor),
            view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        containerView.isHidden = true
    }

    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        containerView.isHidden = false
    }
    
    private static func createButton(title: String, imageName: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(white: 0.3, alpha: 1)
        button.layer.cornerRadius = 8
        button.setImage(UIImage(systemName: imageName), for: .normal)
        button.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        return button
    }
    
    private func populateLabel(for movie: Movie) {
        let posterUrl = Constants.imageBaseURL + (movie.poster_path ?? String())
        DispatchQueue.main.async {
            self.titleLabel.text = movie.title
            self.subtitleLabel.text = movie.original_title
            self.descriptionLabel.text = movie.overview
            self.headerImageView.image = UIImage(named: "placeholder")?.applyBlur(radius: 10)
            self.headerImageView.sd_setImage(with: URL(string: posterUrl), completed: { image, error, cacheType, imageURL in
                if let image = image {
                    self.headerImageView.image = image.applyBlur(radius: 10)
                }
            })
            self.solidImageView.sd_setImage(with: URL(string: posterUrl), completed: nil)
            self.detailsView?.configure(with: movie)
        }
    }
    
    private func bindViewModel() {
        viewModel.$mediaDetails
            .compactMap { $0 }
            .sink { [weak self] mediaDetails in
                guard let self = self else { return }
                switch mediaDetails {
                case .movie(let movie):
                    populateLabel(for: movie)
                case .tvShow(let tvShow):
                    let posterUrl = Constants.imageBaseURL + (tvShow.poster_path ?? String())
                    DispatchQueue.main.async {
                        self.titleLabel.text = tvShow.name
                        self.subtitleLabel.text = tvShow.original_name
                        self.descriptionLabel.text = tvShow.overview
                        self.headerImageView.image = UIImage(named: "placeholder")?.applyBlur(radius: 10)
                        self.headerImageView.sd_setImage(with: URL(string: posterUrl), completed: { image, error, cacheType, imageURL in
                            if let image = image {
                                self.headerImageView.image = image.applyBlur(radius: 10)
                            }
                        })
                        self.solidImageView.sd_setImage(with: URL(string: posterUrl), completed: nil)
                        self.detailsView?.configure(with: tvShow)
                    }
                }
            }
            .store(in: &cancellables)

        viewModel.$isFavorite
            .sink { [weak self] isFavorite in
                DispatchQueue.main.async {
                    
                    let imageName = isFavorite ? "star_fill" : "star_empty"
                    self?.favoriteButton.setImage(UIImage(named: imageName), for: .normal)
                    self?.favoriteButton.backgroundColor = .clear
                    self?.favoriteButton.tintColor = .white
                }
            }
            .store(in: &cancellables)
        
        viewModel.$mediaDetails
            .receive(on: DispatchQueue.main)
            .sink { [weak self] mediaDetails in
                guard let self = self else { return }
                self.updateCurrentView()
            }
            .store(in: &cancellables)

        viewModel.$relatedMedia
            .receive(on: DispatchQueue.main)
            .sink { [weak self] relatedMedia in
                guard let self = self else { return }
                self.relatedFilmsView?.configure(with: relatedMedia, hasRelatedVideos: !relatedMedia.isEmpty, isLoading: false)
                self.updateCurrentView()
            }
            .store(in: &cancellables)

        viewModel.$relatedMediaError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let self = self, let error = error else {return}
                print("erro: \(error)")
            }.store(in: &cancellables)
    }
    
    @objc private func watchButtonTapped() {
        guard let mediaDetails = viewModel.mediaDetails else { return }
            switch mediaDetails {
            case .movie(let movie):
                trailerManager.playTrailer(for: movie.id ?? Int(), mediaType: .movie, from: self)
            case .tvShow(let tvShow):
                trailerManager.playTrailer(for: tvShow.id ?? Int(), mediaType: .tv, from: self)
        }
    }
        
    @objc private func favoriteTapped() {
        viewModel.toggleFavorite()
    }
}

extension DetailViewController: RelatedFilmsViewDelegate {
    func didSelectMedia(mediaDetails: MediaDetails) {
        viewModel.showDetailsFromRelated(for: mediaDetails)
    }
}
