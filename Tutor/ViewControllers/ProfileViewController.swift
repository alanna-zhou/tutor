//
//  ProfileViewController.swift
//  Tutor
//
//  Created by Eli Zhang on 11/27/18.
//  Copyright © 2018 Cornell AppDev. All rights reserved.
//

import UIKit
import SnapKit
import GoogleSignIn
import Alamofire
import NotificationBannerSwift

class ProfileViewController: UIViewController {
    
    weak var delegate: ViewController!
    
    var nameTextField: UITextField!
    var netIDLabel: UILabel!
    var imageView: UIImageView!
    var yearTextField: UITextField!
    var majorTextField: UITextField!
    var bio: UITextView!
    var signOutButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        view.backgroundColor = .white
        
        nameTextField = UITextField()
        nameTextField.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        view.addSubview(nameTextField)
        
        netIDLabel = UILabel()
        netIDLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        view.addSubview(netIDLabel)
        
        yearTextField = UITextField()
        yearTextField.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        yearTextField.isUserInteractionEnabled = false
        view.addSubview(yearTextField)
        
        majorTextField = UITextField()
        majorTextField.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        majorTextField.isUserInteractionEnabled = false
        view.addSubview(majorTextField)
        
        bio = UITextView()
        bio.font = UIFont.systemFont(ofSize: 18, weight: .light)
        bio.isEditable = false
        view.addSubview(bio)
        
        signOutButton = UIButton()
        signOutButton.setTitle("Sign out", for: .normal)
        signOutButton.setTitleColor(.black, for: .normal)
        signOutButton.titleLabel?.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        signOutButton.addTarget(self, action: #selector(signOut), for: .touchUpInside)
        view.addSubview(signOutButton)
        
        let netID = UserDefaults.standard.string(forKey: "netID")!      // Net ID should always exist because user is logged in
        let checkUserURL = "http://localhost:5000/api/user/\(netID)/"
        Alamofire.request(checkUserURL, method: .get).validate().responseData { response in
            switch response.result {
            case let .success(data):
                let decoder = JSONDecoder()
                if let userdata = try? decoder.decode(UserData.self, from: data) {
                    if userdata.success {
                        self.nameTextField.text = userdata.data.name
                        self.netIDLabel.text = userdata.data.net_id
                        self.yearTextField.text = userdata.data.year
                        self.majorTextField.text = userdata.data.major
                        self.bio.text = userdata.data.bio
                    }
                }
            case let .failure(error):
                print("Couldn't connect to server!")
                print(error.localizedDescription)
            }
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(enableEditing))

        setUpConstraints()
    }
    
    func setUpConstraints() {
        nameTextField.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.equalTo(view).offset(20)
        }
        netIDLabel.snp.makeConstraints{ (make) -> Void in
            make.centerY.equalTo(nameTextField)
            make.leading.equalTo(nameTextField.snp.trailing).offset(20)
        }
        yearTextField.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(nameTextField.snp.bottom).offset(20)
            make.leading.equalTo(view).offset(20)
        }
        majorTextField.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(yearTextField)
            make.leading.equalTo(yearTextField.snp.trailing).offset(10)
        }
        bio.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(majorTextField.snp.bottom).offset(20)
            make.leading.equalTo(view).offset(20)
            make.trailing.equalTo(view).offset(-20)
        }
        signOutButton.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(bio.snp.bottom).offset(40)
            make.leading.equalTo(view).offset(20)
        }
    }
    

    @objc func enableEditing() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        nameTextField.isUserInteractionEnabled = true
        netIDLabel.isUserInteractionEnabled = true
        yearTextField.isUserInteractionEnabled = true
        majorTextField.isUserInteractionEnabled = true
        bio.isEditable = true
    }
    
    @objc func save() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(enableEditing))
        nameTextField.isUserInteractionEnabled = false
        netIDLabel.isUserInteractionEnabled = false
        yearTextField.isUserInteractionEnabled = false
        majorTextField.isUserInteractionEnabled = false
        bio.isEditable = false
        
        // Updates user information
        let netID = UserDefaults.standard.string(forKey: "netID")!      // Net ID should always exist because user is logged in
        let modifyUserURL = "http://localhost:5000/api/user/\(netID)/"
        guard let name = nameTextField.text else {
            return
        }
        guard let year = yearTextField.text else {
            return
        }
        guard let major = majorTextField.text else {
            return
        }
        guard let bio = bio.text else {
            return
        }
        let parameters: Parameters = ["name": name,
                                      "year": year,
                                      "major": major,
                                      "bio": bio]
        Alamofire.request(modifyUserURL, method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseData { response in
            switch response.result {
            case let .success(data):
                let decoder = JSONDecoder()
                print("Successful response")
                if let user = try? decoder.decode(UserData.self, from: data) {
                    if user.success {
                        let banner = NotificationBanner(title: "Successfully logged in!", style: .success)
                        banner.show()
                        self.dismiss(animated: true, completion: nil)
                        return
                    }
                }
            case let .failure(error):
                print("Connection to server failed!")
                print(error.localizedDescription)
            }
        }
    }
    
    @objc func signOut() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
        GIDSignIn.sharedInstance().signOut()
        navigationController?.popToRootViewController(animated: true)
        let banner = NotificationBanner(title: "Signed out successfully!", style: .success)
        banner.show()
        delegate?.checkUsername()
    }
}
