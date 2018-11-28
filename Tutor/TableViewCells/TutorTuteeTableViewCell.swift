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
        
        nameLabel = UILabel()
        nameLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        contentView.addSubview(nameLabel)
        
        userInfoLabel = UILabel()
        userInfoLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        contentView.addSubview(userInfoLabel)
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
    
    func addInfo(user: User) {
        nameLabel.text = user.name
        userInfoLabel.text = "\(user.net_id) • \(user.year) • \(user.major)"
    }
}
