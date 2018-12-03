//
//  IntroViewController.swift
//  Tutor
//
//  Created by Eli Zhang on 12/1/18.
//  Copyright © 2018 Cornell AppDev. All rights reserved.
//

import UIKit
import SnapKit
import Hero

class IntroViewController: UIViewController {
    
    var boldPromptLabel: UILabel!
    var promptLabel: UILabel!
    var tapButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.hero.id = "white"
        
        boldPromptLabel = UILabel()
        boldPromptLabel.numberOfLines = 0
        boldPromptLabel.text = "Welcome to Tutor."
        boldPromptLabel.textAlignment = .center
        boldPromptLabel.font = UIFont.systemFont(ofSize: 55, weight: .bold)
        view.addSubview(boldPromptLabel)
        
        promptLabel = UILabel()
        promptLabel.numberOfLines = 0
        promptLabel.text = "Tap the screen to set up your profile and begin finding tutors/tutees!"
        promptLabel.textAlignment = .center
        promptLabel.font = UIFont.systemFont(ofSize: 40, weight: .light)
        view.addSubview(promptLabel)
        
        tapButton = UIButton()
        tapButton.backgroundColor = .clear
        tapButton.addTarget(self, action: #selector(nextScreen), for: .touchUpInside)
        view.addSubview(tapButton)
        
        setUpConstraints()
    }
    
    func setUpConstraints() {
        boldPromptLabel.snp.makeConstraints{ (make) -> Void in
            make.centerY.equalTo(view).offset(-80)
            make.leading.equalTo(view).offset(30)
            make.trailing.equalTo(view).offset(-30)
        }
        promptLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(boldPromptLabel.snp.bottom).offset(30)
            make.leading.equalTo(view).offset(30)
            make.trailing.equalTo(view).offset(-30)
        }
        tapButton.snp.makeConstraints{ (make) -> Void in
            make.edges.equalTo(view)
        }
    }
    
    @objc func nextScreen() {
        let colorSelectView = ColorSelectViewController()
        colorSelectView.hero.isEnabled = true
        present(colorSelectView, animated: true, completion: nil)
    }
}
