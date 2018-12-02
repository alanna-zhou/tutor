//
//  PromptViewController.swift
//  Tutor
//
//  Created by Eli Zhang on 11/29/18.
//  Copyright © 2018 Cornell AppDev. All rights reserved.
//

import UIKit
import SnapKit
import Hero

class PromptViewController: UIViewController {

    var promptLabel: UILabel!
    var tapButton: UIButton!
    var warm: String!
    var cool: String!
    var imageURL: String!
    
    weak var delegate: ProfilePictureViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.hero.id = "white"

        promptLabel = UILabel()
        promptLabel.numberOfLines = 0
        promptLabel.text = "I want to be a:"
        promptLabel.textAlignment = .center
        promptLabel.font = UIFont.systemFont(ofSize: 70, weight: .light)
        view.addSubview(promptLabel)
        
        tapButton = UIButton()
        tapButton.backgroundColor = .clear
        tapButton.addTarget(self, action: #selector(nextScreen), for: .touchUpInside)
        view.addSubview(tapButton)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.nextScreen()
        }
        
        setUpConstraints()
    }
    
    func setUpConstraints() {
        promptLabel.snp.makeConstraints{ (make) -> Void in
            make.center.equalTo(view)
            make.leading.trailing.equalTo(view)
        }
        tapButton.snp.makeConstraints{ (make) -> Void in
            make.edges.equalTo(view)
        }
    }
    
    func addInfo(warm: String, cool: String, imageURL: String) {
        self.warm = warm
        self.cool = cool
        self.imageURL = imageURL
    }
    
    @objc func nextScreen() {
        let roleSelectView = RoleSelectionViewController()
        roleSelectView.delegate = self
        roleSelectView.hero.isEnabled = true
        roleSelectView.addInfo(warm: warm, cool: cool, imageURL: imageURL)
        present(roleSelectView, animated: true, completion: nil)
    }
}
