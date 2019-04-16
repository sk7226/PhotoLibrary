//
//  PhotoCell.swift
//  Assignment
//
//  Created by admin on 14/04/19.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    //MARK: - Properties
    let photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.image = UIImage(named: "placeholder")

        return iv
    }()
    
    //MARK: - Lifecycle Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - View setup Methods
    fileprivate func setupView(){
        addSubview(photoImageView)
        NSLayoutConstraint.activate([
            photoImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            photoImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            photoImageView.topAnchor.constraint(equalTo: topAnchor),
            photoImageView.bottomAnchor.constraint(equalTo: bottomAnchor),

            ])
    }
}

