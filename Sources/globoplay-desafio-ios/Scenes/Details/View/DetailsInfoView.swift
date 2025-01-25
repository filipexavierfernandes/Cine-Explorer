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
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally
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
    
    private func setupView(){
        addSubview(titleHeader)
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleHeader.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            titleHeader.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            titleHeader.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: 16),
            
            stackView.topAnchor.constraint(equalTo: titleHeader.bottomAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 16)
        ])
    }
    
    func configure(with film: Film) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        addLabel(withTitle: "Título Original", value: film.originalTitle)
        addLabel(withTitle: "Episódios", value: film.numberOfEpisodes != nil ? String(film.numberOfEpisodes!) : nil)
        addLabel(withTitle: "Ano de Produção", value: film.releaseDate?.prefix(4).description)
        addLabel(withTitle: "País", value: film.productionCountries?.map { $0.name }.joined(separator: ", "))
        addLabel(withTitle: "Direção", value: film.director)
        addLabel(withTitle: "Elenco", value: film.cast?.map { $0.name }.joined(separator: ", "))
    }

    private func addLabel(withTitle title: String, value: String?) {
        guard let value = value else { return }

        let titleLabel = UILabel()
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.textColor = UIColor(hex: "#D3D3D3")
        titleLabel.text = "\(title):"

        let valueLabel = UILabel()
        valueLabel.font = .systemFont(ofSize: 16)
        valueLabel.textColor = UIColor(hex: "#D3D3D3")
        valueLabel.text = value
        valueLabel.numberOfLines = 0

        let horizontalStackView = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        horizontalStackView.axis = .horizontal
        horizontalStackView.spacing = 4
        horizontalStackView.alignment = .top
        horizontalStackView.distribution = .fillProportionally

        stackView.addArrangedSubview(horizontalStackView)
    }
}
