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
                UIColor(hex: "#282828").cgColor
            ]
            layer.locations = [0.0, 1.0]
            return layer
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
        segmentedControl.tintColor = .clear // Remove o tint color
        
        // Customização visual do segmented control
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.gray], for: .normal)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)], for: .normal)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)], for: .selected)
        
        let underlineLayer = CALayer()
        underlineLayer.frame = CGRect(x: 0, y: 42, width: segmentedControl.bounds.width / CGFloat(segmentedControl.numberOfSegments), height: 2)
        underlineLayer.backgroundColor = UIColor.white.cgColor
        segmentedControl.layer.addSublayer(underlineLayer)
        return segmentedControl
    }()
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let containerView: UIView = {
        let view = UIView()
        return view
    }()
    private let detailsView = DetailsInfoView()
    private var relatedFilmsView = RelatedFilmsView()
    private var currentView: UIView?
    
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = contentView.bounds
        updateSegmentedControlUnderline()
    }
    
    private func updateSegmentedControlUnderline(){
        if let underlineLayer = segmentedControl.layer.sublayers?.first {
            UIView.animate(withDuration: 0.3) {
                underlineLayer.frame = CGRect(x: CGFloat(self.segmentedControl.selectedSegmentIndex) * self.segmentedControl.bounds.width / CGFloat(self.segmentedControl.numberOfSegments), y: 42, width: self.segmentedControl.bounds.width / CGFloat(self.segmentedControl.numberOfSegments), height: 2)
            }
        }
    }
    
    private func setupView() {
        view.backgroundColor = Colors.midGray

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(headerView)
        headerView.addSubview(headerImageView)
        headerImageView.layer.addSublayer(gradientLayer)
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

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
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
            headerImageView.heightAnchor.constraint(equalToConstant: 250),

            solidImageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: -50),
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

            segmentedControl.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 24),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            segmentedControl.heightAnchor.constraint(equalToConstant: 45),

            containerView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 0),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),
           
            detailsView.topAnchor.constraint(equalTo: containerView.topAnchor),
            detailsView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            detailsView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            detailsView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        headerImageView.backgroundColor = .gray
        solidImageView.backgroundColor = .lightGray
        detailsView.backgroundColor = Colors.darkGray
        currentView = detailsView
    }
    
    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        updateSegmentedControlUnderline()

        containerView.subviews.forEach { $0.removeFromSuperview() }

        if sender.selectedSegmentIndex == 0 {
            currentView = relatedFilmsView
        } else {
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
        viewModel.$film
            .compactMap { $0 }
            .sink { [weak self] film in
                let posterUrl = film.posterURL ?? String()
                DispatchQueue.main.async {
                    self?.titleLabel.text = film.title
                    self?.subtitleLabel.text = film.name
                    self?.descriptionLabel.text = film.overview
                    self?.headerImageView.sd_setImage(with: URL(string: posterUrl), placeholderImage: UIImage(named: "placeholder")) { image, error, cacheType, imageURL in
                        if let image = image {
                            let blurredImage = image.applyBlur(radius: 10)
                            self?.headerImageView.image = blurredImage
                        }
                    }
                    self?.solidImageView.sd_setImage(with: URL(string: posterUrl), completed: nil)
                    self?.detailsView.configure(with: film)
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
        }
        
    @objc private func favoriteTapped() {
        viewModel.toggleFavorite()
    }
}
