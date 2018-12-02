//
//  ColorCollectionViewCell.swift
//  Tutor
//
//  Created by Eli Zhang on 12/1/18.
//  Copyright © 2018 Cornell AppDev. All rights reserved.
//

import UIKit

class ColorCollectionViewCell: UICollectionViewCell {
    var color: UIColor!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 40
    }
    
    func configure(color: UIColor) {
        self.color = color
        contentView.backgroundColor = color
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
