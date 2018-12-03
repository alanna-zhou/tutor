//
//  CourseWishlistTableViewCell.swift
//  Tutor
//
//  Created by Eli Zhang on 11/24/18.
//  Copyright © 2018 Cornell AppDev. All rights reserved.
//

import UIKit
import SnapKit

class CourseWishlistTableViewCell: UITableViewCell {
    
    var courseLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.layer.cornerRadius = 10
        
        courseLabel = UILabel()
        courseLabel.font = UIFont.systemFont(ofSize: 25, weight: .semibold)
        courseLabel.textColor = .white
        contentView.addSubview(courseLabel)
    }
    
    override func updateConstraints() {
        courseLabel.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(contentView.snp.centerY)
            make.leading.equalTo(contentView).offset(20)
            make.trailing.equalTo(contentView).offset(-20)
        }
        super.updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func addInfo(course: String) {
        courseLabel.text = course
        contentView.backgroundColor = getCorrespondingColor(hashedInt: course.hashValue % 16)
    }
    
    func getCorrespondingColor(hashedInt: Int) -> UIColor {
        var color: UIColor
        let number = abs(hashedInt % 8)
        switch(number) {
        case 0: color = UIColor(red: 0.933, green: 0.427, blue: 0.663, alpha: 1) // #ee6da9
        case 1: color = UIColor(red: 0.627, green: 0.522, blue: 0.741, alpha: 1) // #a085bd
        case 2: color = UIColor(red: 0.333, green: 0.451, blue: 0.722, alpha: 1) // #5573b8
        case 3: color = UIColor(red: 0.176, green: 0.192, blue: 0.569, alpha: 1) // #2d3191
        case 4: color = UIColor(red: 0.059, green: 0.063, blue: 0.294, alpha: 1) // #0f104b
        case 5: color = UIColor(red: 0.286, green: 0.663, blue: 0.616, alpha: 1) // #49a99d
        case 6: color = UIColor(red: 0.635, green: 0.824, blue: 0.608, alpha: 1) // #a2d29b
        case 7: color = UIColor(red: 0.424, green: 0.808, blue: 0.961, alpha: 1) // #6ccef5
        default: return .black
        }
        return color
    }
}
