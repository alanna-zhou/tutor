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
    var profilePhoto: UIImageView!
    
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
        
        profilePhoto = UIImageView()
        contentView.addSubview(profilePhoto)
        
        self.selectedBackgroundView = {
            let view = UIView()
            view.layer.cornerRadius = 20
            view.backgroundColor = UIColor.lightGray
            return view
        }()
    }
    
    override func updateConstraints() {
        profilePhoto.snp.makeConstraints { (make) -> Void in
            make.trailing.equalTo(contentView).offset(-20)
            make.height.width.equalTo(50)
            make.centerY.equalTo(contentView)
        }
        nameLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(contentView.snp.top).offset(20)
            make.leading.equalTo(contentView).offset(20)
            make.trailing.equalTo(profilePhoto).offset(-20)
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
        profilePhoto.image = UIImage(named: user.pic_name)
        if (isTutor) {
            contentView.backgroundColor = ColorConverter.hexStringToUIColor(hex: user.warm_color)
        }
        else {
            contentView.backgroundColor = ColorConverter.hexStringToUIColor(hex: user.cool_color)
        }
    }
}
