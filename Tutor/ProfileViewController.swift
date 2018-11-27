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
    
    var nameLabel: UILabel!
    var netIDLabel: UILabel!
    var imageView: UIImageView!
    var yearLabel: UITextField!
    var majorLabel: UITextField!
    var bio: UITextView!
    var signOutButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        view.backgroundColor = .white
        
        nameLabel = UILabel()
        nameLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        view.addSubview(nameLabel)
        
        netIDLabel = UILabel()
        netIDLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        view.addSubview(netIDLabel)
        
        yearLabel = UITextField()
        yearLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        yearLabel.isUserInteractionEnabled = false
        view.addSubview(yearLabel)
        
        majorLabel = UITextField()
        majorLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        majorLabel.isUserInteractionEnabled = false
        view.addSubview(majorLabel)
        
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
                        self.nameLabel.text = userdata.data.name
                        self.netIDLabel.text = userdata.data.net_id
                        self.yearLabel.text = userdata.data.year
                        self.majorLabel.text = userdata.data.major
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
        nameLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.equalTo(view).offset(20)
        }
        netIDLabel.snp.makeConstraints{ (make) -> Void in
            make.centerY.equalTo(nameLabel)
            make.leading.equalTo(nameLabel.snp.trailing).offset(20)
        }
        yearLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(nameLabel.snp.bottom).offset(20)
            make.leading.equalTo(view).offset(20)
        }
        majorLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(yearLabel)
            make.leading.equalTo(yearLabel.snp.trailing).offset(10)
        }
        bio.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(majorLabel.snp.bottom).offset(20)
            make.leading.equalTo(view).offset(20)
            make.trailing.equalTo(view).offset(-20)
        }
        signOutButton.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(bio.snp.bottom).offset(40)
            make.leading.equalTo(view).offset(20)
        }
    }
    

    @objc func enableEditing() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(disableEditing))
        yearLabel.isUserInteractionEnabled = true
        majorLabel.isUserInteractionEnabled = true
        bio.isEditable = true
    }
    
    @objc func disableEditing() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(enableEditing))
        yearLabel.isUserInteractionEnabled = false
        majorLabel.isUserInteractionEnabled = false
        bio.isEditable = false
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
