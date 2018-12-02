//
//  ProfileSetupViewController.swift
//  Tutor
//
//  Created by Eli Zhang on 11/20/18.
//  Copyright © 2018 Cornell AppDev. All rights reserved.
//

import UIKit
import SnapKit
import Alamofire
import NotificationBannerSwift
import Hero

class ProfileSetupViewController: UIViewController, UITextFieldDelegate {

    var yearLabel: UILabel!
    var yearTextField: UITextField!
    var majorLabel: UILabel!
    var majorTextField: UITextField!
    var bioLabel: UILabel!
    var bio: UITextView!
    var submitButton: UIButton!
    var role: Role!
    var color: UIColor!
    var id: String!
    
    init(color: UIColor!, role: Role, id: String) {
        super.init(nibName: nil, bundle: nil)
        self.color = color
        self.role = role
        self.id = id
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.color = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = color
        view.hero.id = id
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)

        yearLabel = UILabel()
        yearLabel.text = "Year:"
        yearLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        view.addSubview(yearLabel)
        
        yearTextField = UITextField()
        yearTextField.textAlignment = .left
        yearTextField.placeholder = "Graduation year"
        yearTextField.delegate = self
        yearTextField.tag = 0
        view.addSubview(yearTextField)
        
        majorLabel = UILabel()
        majorLabel.text = "Major:"
        majorLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        view.addSubview(majorLabel)
        
        majorTextField = UITextField()
        majorTextField.textAlignment = .left
        majorTextField.placeholder = "Enter your major"
        majorTextField.delegate = self
        majorTextField.tag = 1
        view.addSubview(majorTextField)
        
        bioLabel = UILabel()
        bioLabel.text = "Bio:"
        bioLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        view.addSubview(bioLabel)
        
        bio = UITextView()
        bio.backgroundColor = color
        bio.isEditable = true
        bio.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        view.addSubview(bio)
        
        submitButton = UIButton()
        submitButton.setTitle("Submit", for: .normal)
        submitButton.titleLabel?.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        submitButton.addTarget(self, action: #selector(validateProfile), for: .touchUpInside)
        view.addSubview(submitButton)
        
        switch(color) {
        case UIColor.white:
            yearLabel.textColor = .black
            yearTextField.textColor = .black
            majorLabel.textColor = .black
            majorTextField.textColor = .black
            bioLabel.textColor = .black
            bio.textColor = .black
            submitButton.setTitleColor(.black, for: .normal)
        default:
            yearLabel.textColor = .white
            yearTextField.textColor = .white
            yearTextField.attributedPlaceholder = NSAttributedString(string: "Graduation year",
                                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
            majorLabel.textColor = .white
            majorTextField.textColor = .white
            majorTextField.attributedPlaceholder = NSAttributedString(string: "Enter your major",
                                                                       attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
            bioLabel.textColor = .white
            bio.textColor = .white
            submitButton.setTitleColor(.white, for: .normal)
        }
        setUpConstraints()
    }
    
    func setUpConstraints() {
        yearLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.equalTo(view).offset(20)
            make.width.equalTo(80)
        }
        yearTextField.snp.makeConstraints{ (make) -> Void in
            make.centerY.equalTo(yearLabel)
            make.leading.equalTo(yearLabel.snp.trailing)
            make.trailing.equalTo(view).offset(-20)
        }
        majorLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(yearTextField.snp.bottom).offset(30)
            make.leading.equalTo(view).offset(20)
            make.width.equalTo(80)
        }
        majorTextField.snp.makeConstraints{ (make) -> Void in
            make.centerY.equalTo(majorLabel)
            make.leading.equalTo(majorLabel.snp.trailing)
            make.trailing.equalTo(view).offset(-20)
        }
        bioLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(majorTextField.snp.bottom).offset(20)
            make.leading.equalTo(view).offset(20)
        }
        bio.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(bioLabel.snp.bottom).offset(20)
            make.height.equalTo(100)
            make.leading.equalTo(view).offset(15)
            make.trailing.equalTo(view).offset(-20)
        }
        submitButton.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(bio.snp.bottom).offset(40)
            make.centerX.equalTo(view)
        }
        
    }
    
    @objc func validateProfile() {
        guard let year = yearTextField.text, year != "" else {
            let banner = NotificationBanner(title: "No year entered.", style: .danger)
            banner.show()
            return
        }
        guard let major = majorTextField.text, major != "" else {
            let banner = NotificationBanner(title: "No major entered.", style: .danger)
            banner.show()
            return
        }
        guard let bio = bio.text, bio != "" else {
            let banner = NotificationBanner(title: "No bio entered.", style: .danger)
            banner.show()
            return
        }
        guard let netID = UserDefaults.standard.string(forKey: "netID") else {
            return
        }
        guard let name = UserDefaults.standard.string(forKey: "fullName") else {
            return
        }
        
        NetworkManager.getUserInfo(netID: netID,
                                   completion: { user in        // If user exists and profile is being edited
                                    NetworkManager.modifyUser(netID: netID, name: name, year: year, major: major, bio: bio,
                                        completion: {() in
                                        let banner = NotificationBanner(title: "Profile updated!", style: .success)
                                        banner.show()
                                        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)})},
                                   failure: { () in             // If user doesn't exist and a new profile is being created
                                    NetworkManager.addUser(netID: netID, name: name, year: year, major: major, bio: bio,
                                        completion: { () in
                                        let banner = NotificationBanner(title: "Successfully logged in!", style: .success)
                                        banner.show()
                                        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
                                        })})
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = self.view.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        yearTextField.resignFirstResponder()
        majorTextField.resignFirstResponder()
        bio.resignFirstResponder()
    }
}
