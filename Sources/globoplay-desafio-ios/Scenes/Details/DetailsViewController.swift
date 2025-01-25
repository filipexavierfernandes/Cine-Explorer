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
    private var cancellables = Set<AnyCancellable>()
    
    // UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let containerView: UIView = {
        let view = UIView()
        return view
    }()
    private let detailsView = DetailsInfoView()
    private var relatedFilmsView = RelatedFilmsView()
    private var currentView: UIView?
    
    private let headerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        return view
    }()

    private let headerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor.clear.cgColor,
            Colors.darkGray.cgColor
        ]
        layer.locations = [0.0, 1.0]
        return layer
    }()
    
    private let gradientView: UIView = {
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
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .gray
        label.textAlignment = .center
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
        segmentedControl.backgroundColor = UIColor(hex: "#282828")
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
        bindViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: segmentedControl.frame.origin.y)
    }
    
    private func setupColors() {
        headerImageView.backgroundColor = .gray
        solidImageView.backgroundColor = .lightGray
        detailsView.backgroundColor = Colors.darkGray
    }
    
    private func setBackButton() {
        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func setupView() {
        view.backgroundColor = Colors.midGray
        
        edgesForExtendedLayout = .top
        extendedLayoutIncludesOpaqueBars = true
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(gradientView)
        contentView.addSubview(headerView)
        headerView.addSubview(headerImageView)
        headerView.addSubview(solidImageView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(subtitleLabel)
        headerView.addSubview(descriptionLabel)
        headerView.addSubview(watchButton)
        headerView.addSubview(favoriteButton)
        contentView.addSubview(segmentedControl)
        contentView.addSubview(containerView)
        containerView.addSubview(detailsView)

        // Configurando constraints
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerImageView.translatesAutoresizingMaskIntoConstraints = false
        solidImageView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        watchButton.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        detailsView.translatesAutoresizingMaskIntoConstraints = false

        let buttonHeight: CGFloat = 50
        let imageSize: CGFloat = 180
        let topSpacing: CGFloat = 150

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
            
            gradientView.topAnchor.constraint(equalTo: contentView.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: segmentedControl.topAnchor),
            
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            headerImageView.topAnchor.constraint(equalTo: headerView.topAnchor),
            headerImageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            headerImageView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            headerImageView.heightAnchor.constraint(equalToConstant: 250),

            solidImageView.centerYAnchor.constraint(equalTo: contentView.topAnchor, constant: topSpacing),
            solidImageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            solidImageView.heightAnchor.constraint(equalToConstant: imageSize),
            solidImageView.widthAnchor.constraint(equalToConstant: imageSize * 0.70),

            titleLabel.topAnchor.constraint(equalTo: solidImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),

            descriptionLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),

            watchButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            watchButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            watchButton.widthAnchor.constraint(equalTo: headerView.widthAnchor, multiplier: 0.45),
            watchButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            watchButton.bottomAnchor.constraint(lessThanOrEqualTo: headerView.bottomAnchor, constant: -16),

            favoriteButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            favoriteButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            favoriteButton.widthAnchor.constraint(equalTo: headerView.widthAnchor, multiplier: 0.45),
            favoriteButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            
            gradientView.topAnchor.constraint(equalTo: contentView.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: segmentedControl.topAnchor),

            segmentedControl.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 24),
            segmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            segmentedControl.heightAnchor.constraint(equalToConstant: 45),
            
            containerView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 0),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0),
           
            detailsView.topAnchor.constraint(equalTo: containerView.topAnchor),
            detailsView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            detailsView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            detailsView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        favoriteButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
        setupColors()
        currentView = detailsView
        
        view.layoutIfNeeded()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: segmentedControl.frame.origin.y)
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    @objc private func backButtonTapped() {
        viewModel.tapBackButton()
    }
    
    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        containerView.subviews.forEach { $0.removeFromSuperview() }

        if sender.selectedSegmentIndex == 0 {
            viewModel.fetchRelatedMedia()
            detailsView.removeFromSuperview()
        } else {
            relatedFilmsView.removeFromSuperview()
            guard let mediaDetails = viewModel.mediaDetails else { return }
            currentView = detailsView
        }
        
        guard let currentView = currentView else{return}
        
        containerView.addSubview(currentView)
        currentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            currentView.topAnchor.constraint(equalTo: containerView.topAnchor),
            currentView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            currentView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            currentView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
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
    
    private func bindViewModel() {
        viewModel.$mediaDetails
            .compactMap { $0 }
            .sink { [weak self] mediaDetails in
                guard let self = self else { return }
                switch mediaDetails {
                case .movie(let movie):
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
                        self.detailsView.configure(with: movie)
                    }
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
                        self.detailsView.configure(with: tvShow)
                    }
                }
            }
            .store(in: &cancellables)

        viewModel.$isFavorite
            .sink { [weak self] isFavorite in
                DispatchQueue.main.async {
                    let imageName = isFavorite ? "star.fill" : "star"
                    self?.favoriteButton.setImage(UIImage(named: imageName), for: .normal)
                    self?.favoriteButton.backgroundColor = isFavorite ? .yellow : .clear
                }
            }
            .store(in: &cancellables)
        
        viewModel.$relatedMedia
            .receive(on: DispatchQueue.main)
            .sink { [weak self] relatedMedia in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.currentView = self.detailsView
                }
            }
            .store(in: &cancellables)

        viewModel.$relatedMediaError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let self = self, let error = error else {return}
                print("erro: \(error)")
            }.store(in: &cancellables)
    }
        
    @objc private func favoriteTapped() {
        viewModel.toggleFavorite()
    }
}
