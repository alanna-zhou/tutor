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
import GoogleSignIn

class LoginViewController: UIViewController, UITextFieldDelegate, GIDSignInUIDelegate {

    var signInButton: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        signInButton = GIDSignInButton()
        view.addSubview(signInButton)
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signInSilently()
        
        setUpConstraints()
    }
    
    func setUpConstraints() {
        signInButton.snp.makeConstraints{ (make) -> Void in
            make.edges.equalTo(view)
        }
    }
    
    @objc func validateUsername() {
//        UserDefaults.standard.set(username, forKey: "netID")
//        UserDefaults.standard.set(name, forKey: "name")
//        nextStep(username: username, name: name)
    }
    
    func nextStep(username: String, name: String) {
//        let navigationView = ProfileViewController(username: username, name: name)
//        navigationController?.pushViewController(navigationView, animated: true)
    }
}
