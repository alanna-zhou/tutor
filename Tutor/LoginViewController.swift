//
//  LoginViewController.swift
//  Tutor
//
//  Created by Eli Zhang on 11/20/18.
//  Copyright © 2018 Cornell AppDev. All rights reserved.
//

import UIKit
import SnapKit
import NotificationBannerSwift

class LoginViewController: UIViewController, UITextFieldDelegate {

    var titleLabel: UILabel!
    var netIDLabel: UILabel!
    var netIDTextField: UITextField!
    var nameLabel: UILabel!
    var nameTextField: UITextField!
    var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        titleLabel = UILabel()
        titleLabel.text = "User Login"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        view.addSubview(titleLabel)

        netIDLabel = UILabel()
        netIDLabel.text = "Net ID:"
        netIDLabel.textAlignment = .left
        netIDLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        view.addSubview(netIDLabel)
        
        netIDTextField = UITextField()
        netIDTextField.textAlignment = .left
        netIDTextField.placeholder = "Enter your Net ID here."
        netIDTextField.delegate = self
        netIDTextField.tag = 0
        view.addSubview(netIDTextField)
        
        nameLabel = UILabel()
        nameLabel.text = "Name:"
        nameLabel.textAlignment = .left
        nameLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        view.addSubview(nameLabel)
        
        nameTextField = UITextField()
        nameTextField.textAlignment = .left
        nameTextField.placeholder = "Enter your name here."
        nameTextField.delegate = self
        nameTextField.tag = 1
        view.addSubview(nameTextField)
        
        loginButton = UIButton()
        loginButton.setTitle("Login", for: .normal)
        loginButton.setTitleColor(.black, for: .normal)
        loginButton.titleLabel?.textAlignment = .center
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        loginButton.addTarget(self, action: #selector(validateUsername), for: .touchUpInside)
        view.addSubview(loginButton)
        
        setUpConstraints()
    }
    
    func setUpConstraints() {
        titleLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(30)
            make.centerX.equalTo(view)
        }
        
        netIDLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(titleLabel.snp.bottom).offset(40)
            make.leading.equalTo(view).offset(40)
        }
        
        netIDTextField.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(netIDLabel.snp.bottom).offset(15)
            make.leading.equalTo(view).offset(40)
        }
        
        nameLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(netIDTextField.snp.bottom).offset(30)
            make.leading.equalTo(view).offset(40)
        }
        
        nameTextField.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(nameLabel.snp.bottom).offset(15)
            make.leading.equalTo(view).offset(40)
        }
        
        loginButton.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(nameTextField.snp.bottom).offset(40)
            make.centerX.equalTo(view)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = self.view.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
    
    @objc func validateUsername() {
        guard let username = netIDTextField.text, username != "" else {
            let banner = NotificationBanner(title: "NetID field is blank.", style: .danger)
            banner.show()
            return
        }
        guard let name = nameTextField.text, name != "" else {
            let banner = NotificationBanner(title: "No name entered.", style: .danger)
            banner.show()
            return
        }
        let defaults = UserDefaults.standard
        defaults.set(username, forKey: "netID")
        defaults.set(name, forKey: "name")
        nextStep(username: username, name: name)
    }
    
    func nextStep(username: String, name: String) {
        let navigationView = ProfileViewController()
        navigationView.username = username
        navigationView.name = name
        navigationController?.pushViewController(navigationView, animated: true)
    }
}
