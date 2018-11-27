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
    var netIDLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        nameLabel = UILabel()
        nameLabel.font = UIFont.systemFont(ofSize: 25, weight: .semibold)
        contentView.addSubview(nameLabel)
        
        netIDLabel = UILabel()
        netIDLabel.font = UIFont.systemFont(ofSize: 25, weight: .semibold)
        contentView.addSubview(netIDLabel)
    }
    
    override func updateConstraints() {
        nameLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(contentView.snp.top).offset(20)
            make.leading.equalTo(contentView).offset(20)
            make.trailing.equalTo(contentView).offset(-20)
        }
        netIDLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(contentView.snp.bottom).offset(30)
            make.leading.trailing.equalTo(nameLabel)
        }
        super.updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func addInfo(user: User) {
        nameLabel.text = user.name
        netIDLabel.text = user.net_id
    }
}
