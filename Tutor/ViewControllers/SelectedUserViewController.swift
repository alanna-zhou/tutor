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
    var fullNameLabel: UILabel!
    var netIDLabel: UILabel!
    var majorTitleLabel: UILabel!
    var gradYearTitleLabel: UILabel!
    var bioTitleLabel: UILabel!
    var addButton: UIButton!
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
        
        fullNameLabel = UILabel()
        fullNameLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        
        netIDLabel = UILabel()
        netIDLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        
        majorTitleLabel = UILabel()
        
        gradYearTitleLabel = UILabel()
        
        bioTitleLabel = UILabel()
        
        addButton = UIButton()
        addButton.setTitle("Add", for: .normal)
        addButton.setTitleColor(.black, for: .normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        addButton.addTarget(self, action: #selector(addUser), for: .touchUpInside)

//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTutor))
        
        view.addSubview(fullNameLabel)
        view.addSubview(netIDLabel)
        view.addSubview(majorTitleLabel)
        view.addSubview(gradYearTitleLabel)
        view.addSubview(bioTitleLabel)
        view.addSubview(addButton)
        
        NetworkManager.getUserInfo(netID: netID,
                                   completion: { user in
                                    self.fullNameLabel.text = user.name
                                    self.netIDLabel.text = user.net_id
                                    self.gradYearTitleLabel.text = user.year
                                    self.majorTitleLabel.text = user.major
                                    self.bioTitleLabel.text = user.bio},
                                   failure: {})
        
        setUpConstraints()
        
    }
    func setUpConstraints(){
        fullNameLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.equalTo(view).offset(20)
        }
        netIDLabel.snp.makeConstraints{ (make) -> Void in
            make.centerY.equalTo(fullNameLabel)
            make.leading.equalTo(fullNameLabel.snp.trailing).offset(20)
        }
        gradYearTitleLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(fullNameLabel.snp.bottom).offset(20)
            make.leading.equalTo(view).offset(20)
        }
        majorTitleLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(gradYearTitleLabel)
            make.leading.equalTo(gradYearTitleLabel.snp.trailing).offset(10)
        }
        bioTitleLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(majorTitleLabel.snp.bottom).offset(20)
            make.leading.equalTo(view).offset(20)
            make.trailing.equalTo(view).offset(-20)
        }
        if (course != nil) {
            addButton.snp.makeConstraints{ (make) -> Void in
                make.top.equalTo(bioTitleLabel.snp.bottom).offset(40)
                make.leading.equalTo(view).offset(20)
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
        NetworkManager.addCourseToUser(netID: userNetID, isTutor: !isTutor, subject: course.course_subject, number: course.course_num, completion: {
            NetworkManager.matchUsers(tutorID: tutorID, tuteeID: tuteeID, course: self.course,
                                      completion: {() in
                                        let banner = NotificationBanner(title: "User added!", style: .success)
                                        banner.show()},
                                      failure: { error in
                                        let banner = NotificationBanner(title: error, style: .danger)
                                        banner.show()})
        }, failure: { error in
            let banner = NotificationBanner(title: error, style: .danger)
            banner.show()
        })
        (self.navigationController?.viewControllers.first as! ViewController).tableView.reloadData()
    }
}



        

