//
//  ViewController.swift
//  Tutor
//
//  Created by Eli Zhang on 11/20/18.
//  Copyright © 2018 Cornell AppDev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        if checkUsername() {
            presentUserSetupView()
        }
    }
    
    @objc func presentUserSetupView() {
        let modalView = LoginViewController()
        let navigationViewController = UINavigationController(rootViewController: modalView)
        present(navigationViewController, animated: true, completion: nil)
    }
    
    func checkUsername() -> Bool {
        return true
    }
}

