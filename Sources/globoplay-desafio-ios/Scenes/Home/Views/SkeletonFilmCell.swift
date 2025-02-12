//
//  SkeletonFilmCell.swift
//  globoplay-desafio-ios
//
//  Created by Filipe Xavier Fernandes on 23/01/25.
//

import Foundation
import UIKit

class SkeletonFilmCell: UICollectionViewCell {
    static let reuseIdentifier = "SkeletonFilmCell"

    private let skeletonView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray.withAlphaComponent(0.5)
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(skeletonView)
        NSLayoutConstraint.activate([
            skeletonView.topAnchor.constraint(equalTo: contentView.topAnchor),
            skeletonView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            skeletonView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            skeletonView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
