//
//  ProfileCollectionViewCell.swift
//  Tutor
//
//  Created by Eli Zhang on 12/1/18.
//  Copyright © 2018 Cornell AppDev. All rights reserved.
//

import UIKit

class ProfileCollectionViewCell: UICollectionViewCell {
    var profilePic: UIImage!
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 40
        
        imageView = UIImageView()
    }
    
    func configure(picture: String) {
        profilePic = UIImage(named: picture)
        imageView = UIImageView(image: profilePic)
        imageView.contentMode = .scaleAspectFit
        contentView.addSubview(imageView)
    }
    
    override func updateConstraints() {
        imageView.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(contentView)
        }
        super.updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
