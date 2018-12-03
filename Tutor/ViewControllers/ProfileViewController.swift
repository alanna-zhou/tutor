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
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: view.frame.height / 3, width: view.frame.width, height: view.frame.height * 2 / 3), cornerRadius: 0).cgPath
        layer.fillColor = UIColor.white.cgColor
        view.layer.addSublayer(layer)
        
        imageView = UIImageView()
        view.addSubview(imageView)
        
        nameTextField = UITextField()
        nameTextField.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        nameTextField.isUserInteractionEnabled = false
        nameTextField.placeholder = "Name"
        nameTextField.textAlignment = .center
        view.addSubview(nameTextField)
        
        netIDLabel = UILabel()
        netIDLabel.font = UIFont.systemFont(ofSize: 25, weight: .semibold)
        netIDLabel.textAlignment = .center
        view.addSubview(netIDLabel)
        
        yearTextField = UITextField()
        yearTextField.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        yearTextField.isUserInteractionEnabled = false
        yearTextField.placeholder = "Year"
        yearTextField.textAlignment = .center
        view.addSubview(yearTextField)
        
        majorTextField = UITextField()
        majorTextField.font = UIFont.systemFont(ofSize: 18	, weight: .regular)
        majorTextField.isUserInteractionEnabled = false
        majorTextField.placeholder = "Major"
        majorTextField.textAlignment = .center
        view.addSubview(majorTextField)
        
        bio = UITextView()
        bio.font = UIFont.systemFont(ofSize: 18, weight: .light)
        bio.textColor = .black
        view.addSubview(bio)
        
        signOutButton = UIButton()
        signOutButton.setTitle("Sign out", for: .normal)
        signOutButton.setTitleColor(.black, for: .normal)
        signOutButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .light)
        signOutButton.addTarget(self, action: #selector(signOut), for: .touchUpInside)
        view.addSubview(signOutButton)
        
        let netID = UserDefaults.standard.string(forKey: "netID")!      // Net ID should always exist because user is logged in
        NetworkManager.getUserInfo(netID: netID,
                                   completion: { user in
                                    self.nameTextField.text = user.name
                                    self.netIDLabel.text = user.net_id
                                    self.yearTextField.text = user.year
                                    self.majorTextField.text = user.major
                                    self.bio.text = user.bio
                                    self.bio.isEditable = false
                                    self.imageView.image = UIImage(named: user.pic_name)
                                    self.view.backgroundColor = ColorConverter.hexStringToUIColor(hex: user.warm_color)
                                    print(user.cool_color)
        },
                                   failure: {})
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(enableEditing))

        setUpConstraints()
    }
    
    func setUpConstraints() {
        imageView.snp.makeConstraints{ (make) -> Void in
            make.centerY.equalTo(view).offset(-1 * view.frame.height / 6)
            make.centerX.equalTo(view)
            make.height.width.equalTo(100)
        }
        nameTextField.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(imageView.snp.bottom).offset(10)
            make.centerX.equalTo(view)
        }
        netIDLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(nameTextField.snp.bottom).offset(10)
            make.centerX.equalTo(view)
        }
        yearTextField.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(netIDLabel.snp.bottom).offset(10)
            make.centerX.equalTo(view)
        }
        majorTextField.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(yearTextField.snp.bottom).offset(10)
            make.centerX.equalTo(view)
        }
        bio.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(majorTextField.snp.bottom).offset(20)
            make.leading.equalTo(view).offset(20)
            make.trailing.equalTo(view).offset(-20)
            make.height.equalTo(70)
        }
        signOutButton.snp.makeConstraints{ (make) -> Void in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
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
        // Updates user information
        let netID = UserDefaults.standard.string(forKey: "netID")!      // Net ID should always exist because user is logged in
        guard let name = nameTextField.text, name != "" else {
            let banner = NotificationBanner(title: "No name entered.", style: .danger)
            banner.show()
            return
        }
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
        NetworkManager.modifyUser(netID: netID, name: name, year: year, major: major, bio: bio, completion: {() in
            let banner = NotificationBanner(title: "Saved updated info!", style: .success)
            banner.show()
            self.dismiss(animated: true, completion: nil)
        })
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(enableEditing))
        nameTextField.isUserInteractionEnabled = false
        netIDLabel.isUserInteractionEnabled = false
        yearTextField.isUserInteractionEnabled = false
        majorTextField.isUserInteractionEnabled = false
        self.bio.isEditable = false
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
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
}
