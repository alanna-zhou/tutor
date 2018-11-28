//
//  TutorTuteeCatalogViewController.swift
//  Tutor
//
//  Created by Eli Zhang on 11/24/18.
//  Copyright © 2018 Cornell AppDev. All rights reserved.
//

import UIKit
import Alamofire
import SnapKit
import ViewAnimator

class TutorTuteeCatalogViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var course: Course!
    var tutors: [String] = []
    var tutees: [String] = []
    var tableView: UITableView!
    var tutorTuteeSegment: UISegmentedControl!
    
    var courseTutorsURL: String!
    var courseTuteesURL: String!
    
    let tutorTuteeReuseIdentifier = "tutorTuteeReuseIdentifier"
    let cellHeight: CGFloat = 90
    let cellSpacingHeight: CGFloat = 20

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let course_subject = course.course_subject
        let course_num = course.course_num
        courseTutorsURL = "http://35.190.144.148/api/course/\(course_subject)/\(course_num)/tutors/"
        courseTuteesURL = "http://35.190.144.148/api/course/\(course_subject)/\(course_num)/tutees/"
        getCourseInfo()
        
        tutorTuteeSegment = UISegmentedControl()
        tutorTuteeSegment.translatesAutoresizingMaskIntoConstraints = false
        tutorTuteeSegment.insertSegment(withTitle: "Tutor", at: 0, animated: true)
        tutorTuteeSegment.insertSegment(withTitle: "Tutee", at: 1, animated: true)
        tutorTuteeSegment.selectedSegmentIndex = 0
        tutorTuteeSegment.addTarget(self, action: #selector(swapRole), for: .valueChanged)
        
        self.navigationItem.titleView = tutorTuteeSegment
        
        tableView = UITableView()
        tableView.register(TutorTuteeTableViewCell.self, forCellReuseIdentifier: tutorTuteeReuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        let rightFade = AnimationType.from(direction: .right, offset: 60.0)
        tableView.animate(animations: [rightFade], duration: 0.5)
        view.addSubview(tableView)
        
        setUpConstraints()
    }
    
    func setUpConstraints() {
        tableView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalTo(view).offset(20)
            make.trailing.equalTo(view).offset(-20)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    init(course: Course) {
        super.init(nibName: nil, bundle: nil)
        self.course = course
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getCourseInfo() {
        Alamofire.request(courseTutorsURL, method: .get).validate().responseData { response in
            switch response.result {
            case let .success(data):
                let decoder = JSONDecoder()
                print("Successful response")
                if let userdata = try? decoder.decode(UserArray.self, from: data) {
                    if userdata.success {
                        self.tutors = userdata.data
                        self.tableView?.reloadData()
                    }
                }
            case let .failure(error):
                print("Connection to server failed!")
                print(error.localizedDescription)
                self.tutors = []
            }
        }
        
        Alamofire.request(courseTuteesURL, method: .get).validate().responseData { response in
            switch response.result {
            case let .success(data):
                let decoder = JSONDecoder()
                print("Successful response")
                if let userdata = try? decoder.decode(UserArray.self, from: data) {
                    if userdata.success {
                        self.tutees = userdata.data
                        self.tableView?.reloadData()
                    }
                }
            case let .failure(error):
                print("Connection to server failed!")
                print(error.localizedDescription)
                self.tutees = []
            }
        }
    }
    
    @objc func swapRole() {
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tutorTuteeSegment.selectedSegmentIndex == 0 {
            return tutors.count
        }
        return tutees.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tutorTuteeReuseIdentifier, for: indexPath) as! TutorTuteeTableViewCell
        var user: String
        if tutorTuteeSegment.selectedSegmentIndex == 0 {
            user = tutors[indexPath.row]
        }
        else {
            user = tutees[indexPath.row]
        }
        let checkUserURL = "http://35.190.144.148/api/user/\(user)/"
        Alamofire.request(checkUserURL, method: .get).validate().responseData { response in
            switch response.result {
            case let .success(data):
                let decoder = JSONDecoder()
                if let userdata = try? decoder.decode(UserData.self, from: data) {
                    if userdata.success {
                        print("User exists in database.")
                        cell.addInfo(user: userdata.data)
                        cell.setColor(tutor: self.tutorTuteeSegment.selectedSegmentIndex == 0)
                    }
                }
            case let .failure(error):
                print("Couldn't connect to server!")
                print(error.localizedDescription)
            }
        }
        cell.setNeedsUpdateConstraints()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var userAtIndex: String
        if tutorTuteeSegment.selectedSegmentIndex == 0 {
            userAtIndex = tutors[indexPath.row]
        } else {
            userAtIndex = tutees[indexPath.row]
        }
        let userProfileViewController = SelectedUserViewController(netID: userAtIndex, tutor: tutorTuteeSegment.selectedSegmentIndex == 0, course: self.course)
        navigationController?.pushViewController(userProfileViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
}
