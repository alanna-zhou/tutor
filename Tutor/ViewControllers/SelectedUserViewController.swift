//
//  SelectedTutorViewController.swift
//  Tutor
//
//  Created by Emily Wanderer on 11/27/18.
//  Copyright © 2018 Cornell AppDev. All rights reserved.
//

import UIKit
import SnapKit
import Alamofire
import NotificationBannerSwift

class SelectedUserViewController: UIViewController {
    var netID: String!
    var nameLabel: UILabel!
    var netIDLabel: UILabel!
    var yearAndMajorLabel: UILabel!
    var bio: UITextView!
    var addButton: UIButton!
    var imageView: UIImageView!
    var isTutor: Bool!
    var course: Course!
    
    init(netID: String, isTutor: Bool, course: Course) {
        super.init(nibName: nil, bundle: nil)
        self.netID = netID
        self.isTutor = isTutor
        self.course = course
    }
    
    init(netID: String, isTutor: Bool) {
        super.init(nibName: nil, bundle: nil)
        self.netID = netID
        self.isTutor = isTutor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = .white
        title = "Profile"
        
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: view.frame.height / 3, width: view.frame.width, height: view.frame.height * 2 / 3), cornerRadius: 0).cgPath
        layer.fillColor = UIColor.white.cgColor
        view.layer.addSublayer(layer)
        
        imageView = UIImageView()
        
        nameLabel = UILabel()
        nameLabel.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        nameLabel.textAlignment = .center
        
        netIDLabel = UILabel()
        netIDLabel.font = UIFont.systemFont(ofSize: 25, weight: .semibold)
        netIDLabel.textAlignment = .center
        
        yearAndMajorLabel = UILabel()
        yearAndMajorLabel.font = UIFont.systemFont(ofSize: 22, weight: .regular)
        yearAndMajorLabel.textAlignment = .center
        
        bio = UITextView()
        bio.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        
        addButton = UIButton()
        addButton.setTitle("Add User", for: .normal)
        addButton.setTitleColor(.black, for: .normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 30, weight: .semibold)
        addButton.addTarget(self, action: #selector(addUser), for: .touchUpInside)
        
        view.addSubview(nameLabel)
        view.addSubview(netIDLabel)
        view.addSubview(yearAndMajorLabel)
        view.addSubview(bio)
        view.addSubview(addButton)
        view.addSubview(imageView)
        
        NetworkManager.getUserInfo(netID: netID,
                                   completion: { user in
                                    self.nameLabel.text = user.name
                                    self.netIDLabel.text = user.net_id
                                    self.yearAndMajorLabel.text = "\(user.year) • \(user.major)"
                                    self.imageView.image = UIImage(named: user.pic_name)
                                    self.bio.text = user.bio
                                    self.bio.isEditable = false
                                    if self.isTutor {
                                        self.view.backgroundColor = ColorConverter.hexStringToUIColor(hex: user.warm_color)
                                    }
                                    else {
                                        self.view.backgroundColor = ColorConverter.hexStringToUIColor(hex: user.cool_color)
                                    }}, failure: {})
        
        setUpConstraints()
        
    }
    func setUpConstraints(){
        imageView.snp.makeConstraints{ (make) -> Void in
            make.centerY.equalTo(view).offset(-1 * view.frame.height / 6)
            make.centerX.equalTo(view)
            make.height.width.equalTo(100)
        }
        nameLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(imageView.snp.bottom).offset(10)
            make.centerX.equalTo(view)
        }
        netIDLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(nameLabel.snp.bottom).offset(10)
            make.centerX.equalTo(view)
        }
        yearAndMajorLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(netIDLabel.snp.bottom).offset(15)
            make.centerX.equalTo(view)
        }
        bio.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(yearAndMajorLabel.snp.bottom).offset(20)
            make.leading.equalTo(view).offset(20)
            make.trailing.equalTo(view).offset(-20)
            make.height.equalTo(70)
        }
        if (course != nil) {
            addButton.snp.makeConstraints{ (make) -> Void in
                make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
                make.centerX.equalTo(view)
            }
        }
    }
    
    
    @objc func addUser(sender: UIButton) {
        var tutorID: String
        var tuteeID: String
        guard let userNetID = UserDefaults.standard.string(forKey: "netID") else {
            return
        }
        if isTutor {
            tutorID = self.netID    // Added tutor
            tuteeID = userNetID     // User adding tutor
        }
        else {
            tutorID = userNetID     // User adding tutee
            tuteeID = self.netID    // Added tutee
        }
        NetworkManager.addCourseToUser(netID: userNetID, isTutor: !isTutor, subject: course.course_subject, number: course.course_num, completion: { () in
            NetworkManager.matchUsers(tutorID: tutorID, tuteeID: tuteeID, course: self.course,
                                      completion: {() in
                                        let banner = NotificationBanner(title: "User added!", style: .success)
                                        banner.show()
                                        (self.navigationController?.viewControllers.first as! ViewController).getCoursesAndUsers()
            },
                                      failure: { error in
                                        let banner = NotificationBanner(title: error, style: .danger)
                                        banner.show()})},
            failure: { error in
            let banner = NotificationBanner(title: error, style: .danger)
            banner.show()
        })
    }
}



        

