//
//  TutorTuteeTableViewCell.swift
//  Tutor
//
//  Created by Eli Zhang on 11/25/18.
//  Copyright © 2018 Cornell AppDev. All rights reserved.
//

import UIKit
import SnapKit

class TutorTuteeTableViewCell: UITableViewCell {

    var nameLabel: UILabel!
    var userInfoLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.layer.cornerRadius = 20
        
        nameLabel = UILabel()
        nameLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        nameLabel.textColor = .white
        contentView.addSubview(nameLabel)
        
        userInfoLabel = UILabel()
        userInfoLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        userInfoLabel.textColor = .white
        contentView.addSubview(userInfoLabel)
        
        self.selectedBackgroundView = {
            let view = UIView()
            view.layer.cornerRadius = 20
            view.backgroundColor = UIColor.lightGray
            return view
        }()
    }
    
    override func updateConstraints() {
        nameLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(contentView.snp.top).offset(20)
            make.leading.equalTo(contentView).offset(20)
            make.trailing.equalTo(contentView).offset(-20)
        }
        userInfoLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(nameLabel.snp.bottom).offset(10)
            make.leading.trailing.equalTo(nameLabel)
        }
        super.updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func addInfo(user: User, isTutor: Bool) {
        nameLabel.text = user.name
        userInfoLabel.text = "\(user.net_id) • \(user.year) • \(user.major)"
        contentView.backgroundColor = chooseColor(cool: isTutor)
    }
    
    func setColor(tutor: Bool) {
        contentView.backgroundColor = chooseColor(cool: tutor)
    }
    
    func chooseColor(cool: Bool) -> UIColor {
        var color: UIColor
        let number = Int.random(in: 1...8)
        if cool {
            // Cool Colors
            switch(number) {
            case 1: color = UIColor(red: 0.361, green: 0.831, blue: 0.784, alpha: 1) // #5cd4c8
            case 2: color = UIColor(red: 0.298, green: 0.737, blue: 0.871, alpha: 1) // #4cbcde
            case 3: color = UIColor(red: 0.243, green: 0.663, blue: 0.929, alpha: 1) // #3ea9ed
            case 4: color = UIColor(red: 0.278, green: 0.596, blue: 0.922, alpha: 1) // #4798eb
            case 5: color = UIColor(red: 0.443, green: 0.565, blue: 0.925, alpha: 1) // #7190ec
            case 6: color = UIColor(red: 0.624, green: 0.541, blue: 0.914, alpha: 1) // #9f8ae9
            case 7: color = UIColor(red: 0.757, green: 0.518, blue: 0.898, alpha: 1) // #c184e5
            case 8: color = UIColor(red: 0.784, green: 0.514, blue: 0.902, alpha: 1) // #c883e6
            default: return .black
            }
        }
        else {
            // Warm Colors
            switch(number) {
            case 1: color = UIColor(red: 0.929, green: 0.718, blue: 0.259, alpha: 1) // #edb742
            case 2: color = UIColor(red: 0.925, green: 0.651, blue: 0.247, alpha: 1) // #eca63f
            case 3: color = UIColor(red: 0.929, green: 0.584, blue: 0.298, alpha: 1) // #ed954c
            case 4: color = UIColor(red: 0.929, green: 0.498, blue: 0.373, alpha: 1) // #ed7f5f
            case 5: color = UIColor(red: 0.929, green: 0.424, blue: 0.482, alpha: 1) // #ed6c7b
            case 6: color = UIColor(red: 0.933, green: 0.431, blue: 0.588, alpha: 1) // #ee6e96
            case 7: color = UIColor(red: 0.937, green: 0.486, blue: 0.714, alpha: 1) // #ef7cb6
            case 8: color = UIColor(red: 0.937, green: 0.541, blue: 0.812, alpha: 1) // #ef8acf
            default: return .black
            }
        }
        return color
    }
}
