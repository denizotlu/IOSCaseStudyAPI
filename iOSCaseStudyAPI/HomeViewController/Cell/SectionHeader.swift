//
//  ResultListViewCellModel.swift
//  iOSCaseStudyAPI
//
//  Created by Deniz Otlu on 11.10.2024.
//

import Foundation
import UIKit


class CollectionReusableView: UICollectionReusableView {
    
    static let identifier = "SectionHeader"
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
        
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupViews() {
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
           titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
           titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)

        ])
    }
}

