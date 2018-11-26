//
//  LoginBulletinPage.swift
//  Tutor
//
//  Created by Eli Zhang on 11/26/18.
//  Copyright © 2018 Cornell AppDev. All rights reserved.
//

import UIKit
import BLTNBoard
import GoogleSignIn
import SnapKit

class LoginBulletinPage: BLTNPageItem, GIDSignInUIDelegate {
    
    var signInButton: GIDSignInButton!
    var viewController: UIViewController!
    
    init(mainView: UIViewController, title: String) {
        super.init(title: title)
        self.viewController = mainView
    }
    
    override func makeViewsUnderDescription(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
        signInButton = GIDSignInButton()
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signInSilently()
        return [signInButton]
    }
    
    // Present a view that prompts the user to sign in with Google
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!) {
        viewController.present(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    func sign(_ signIn: GIDSignIn!,
              dismiss viewController: UIViewController!) {
        viewController.dismiss(animated: true, completion: nil)
    }
}
