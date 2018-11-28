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
    var tutor: Bool!
    var course: Course!
    
    init(netID: String, tutor: Bool, course: Course) {
        super.init(nibName: nil, bundle: nil)
        self.netID = netID
        self.tutor = tutor
        self.course = course
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
        
        let checkUserURL = "http://35.190.144.148/api/user/\(netID!)/"  // NetID should always be initialized in init
        Alamofire.request(checkUserURL, method: .get).validate().responseData { response in
            switch response.result {
            case let .success(data):
                let decoder = JSONDecoder()
                if let userdata = try? decoder.decode(UserData.self, from: data) {
                    if userdata.success {
                        self.fullNameLabel.text = userdata.data.name
                        self.netIDLabel.text = userdata.data.net_id
                        self.gradYearTitleLabel.text = userdata.data.year
                        self.majorTitleLabel.text = userdata.data.major
                        self.bioTitleLabel.text = userdata.data.bio
                    }
                }
            case let .failure(error):
                print("Couldn't connect to server!")
                print(error.localizedDescription)
            }
        }
        
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
        addButton.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(bioTitleLabel.snp.bottom).offset(40)
            make.leading.equalTo(view).offset(20)
        }
    }
    
    
    @objc func addUser(sender: UIButton) {
        let matchUsersURL = "http://35.190.144.148/api/match/"
        var tutorID: String
        var tuteeID: String
        guard let userNetID = UserDefaults.standard.string(forKey: "netID") else {
            return
        }
        if tutor {
            tutorID = self.netID
            tuteeID = userNetID
        }
        else {
            tutorID = userNetID
            tuteeID = self.netID
        }
        let parameters: Parameters = ["tutor_net_id": tutorID,
                                       "tutee_net_id": tuteeID,
                                       "course_subject": course.course_subject,
                                       "course_num": course.course_num]
        Alamofire.request(matchUsersURL, method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseData { response in
            switch response.result {
            case let .success(data):
                let decoder = JSONDecoder()
                print("Successful response")
                if let userMatch = try? decoder.decode(UserMatchData.self, from: data) {
                    if userMatch.success {
                        let banner = NotificationBanner(title: "User added!", style: .success)
                        banner.show()
                    }
                }
                else {
                    let banner = NotificationBanner(title: "FAIL!", style: .danger)
                    banner.show()
                }
            case let .failure(error):
                print("Connection to server failed!")
                print(error.localizedDescription)
            }
        }
        navigationController?.popViewController(animated: true)
    }
}



        

