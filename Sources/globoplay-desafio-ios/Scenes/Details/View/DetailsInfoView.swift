//
//  DetailsInfoView.swift
//  globoplay-desafio-ios
//
//  Created by Filipe Xavier Fernandes on 24/01/25.
//

import Foundation
import UIKit

class DetailsInfoView: UIView {
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()

    private let titleHeader: UILabel = {
        let label = UILabel()
        label.text = "Ficha técnica"
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        addSubview(titleHeader)
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleHeader.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            titleHeader.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            titleHeader.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),

            stackView.topAnchor.constraint(equalTo: titleHeader.bottomAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -16)
        ])
    }

    func configure(with movie: Movie) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let directorName = getDirectorName(from: movie)
        addLabel(withTitle: "Direção", value: directorName)

        let castNames = getCastNames(from: movie)
        addLabel(withTitle: "Elenco", value: castNames)

        addLabel(withTitle: "Título Original", value: movie.original_title)
        addLabel(withTitle: "Ano de Produção", value: movie.release_date?.prefix(4).description)
        addLabel(withTitle: "País", value: movie.production_countries?.map { $0.name ?? String() }.joined(separator: ", "))
        addLabel(withTitle: "Duração", value: movie.runtime != nil ? "\(movie.runtime!) minutos" : nil)
        addLabel(withTitle: "Gêneros", value: movie.genres?.map({$0.name ?? String()}).joined(separator: ", "))
        addLabel(withTitle: "Sinopse", value: movie.overview)

    }

    func configure(with tvShow: TVShow) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if let createdBy = tvShow.created_by?.map({ $0.name ?? String() }).joined(separator: ", ") {
            addLabel(withTitle: "Criado por", value: createdBy)
        } else {
            addLabel(withTitle: "Criado por", value: "Não disponível")
        }

        addLabel(withTitle: "Título Original", value: tvShow.original_name)
        addLabel(withTitle: "Número de Episódios", value: tvShow.number_of_episodes != nil ? String(tvShow.number_of_episodes!) : nil)
        addLabel(withTitle: "Número de Temporadas", value: tvShow.number_of_seasons != nil ? String(tvShow.number_of_seasons!) : nil)
        addLabel(withTitle: "País", value: tvShow.production_countries?.map { $0.name ?? String() }.joined(separator: ", "))
        addLabel(withTitle: "Gêneros", value: tvShow.genres?.map({$0.name ?? String()}).joined(separator: ", "))
        addLabel(withTitle: "Sinopse", value: tvShow.overview)
    }

    private func addLabel(withTitle title: String, value: String?) {
        guard let value = value else { return }

        let titleLabel = UILabel()
        titleLabel.font = .boldSystemFont(ofSize: 17)
        titleLabel.textColor = UIColor(hex: "#D3D3D3")
        titleLabel.text = "\(title):"
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        let valueLabel = UILabel()
        valueLabel.font = .systemFont(ofSize: 16)
        valueLabel.textColor = UIColor(hex: "#D3D3D3")
        valueLabel.text = "\(value)"
        valueLabel.numberOfLines = 0
        valueLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        valueLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        let horizontalStackView = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        horizontalStackView.axis = .horizontal
        horizontalStackView.spacing = 4
        horizontalStackView.alignment = .top
        horizontalStackView.distribution = .fill

        stackView.addArrangedSubview(horizontalStackView)
    }
    
    func getCastNames(from movie: Movie) -> String {
        guard let credits = movie.credits,
              let cast = credits.cast else {
            return "Não disponível"
        }
        let castNames = cast.map { $0.name ?? String() }.joined(separator: ", ")
        return castNames
    }
    
    func getDirectorName(from movie: Movie) -> String {
        guard let credits = movie.credits,
              let crew = credits.crew,
              let director = crew.first(where: { $0.job == "Director" }) else {
            return String()
        }
        return director.name ?? String()
    }
}
