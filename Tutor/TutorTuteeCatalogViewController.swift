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
    var tutors: [User] = []
    var tutees: [User] = []
    var tableView: UITableView!
    var tutorTuteeSegment: UISegmentedControl!
    
    var courseTutorsURL: String!
    var courseTuteesURL: String!
    
    let tutorTuteeReuseIdentifier = "tutorTuteeReuseIdentifier"
    let cellHeight: CGFloat = 70

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let course_subject = course.course_subject
        let course_num = course.course_num
        courseTutorsURL = "http://localhost:5000/api/course/\(course_subject)/\(course_num)/tutors/"
        courseTuteesURL = "http://localhost:5000/api/course/\(course_subject)/\(course_num)/tutees/"
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
        
        let rightFade = AnimationType.from(direction: .right, offset: 60.0)
        tableView.animate(animations: [rightFade], duration: 0.5)
        view.addSubview(tableView)
        
        setUpConstraints()
    }
    
    func setUpConstraints() {
        tableView.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(view)
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
        var user: User
        if tutorTuteeSegment.selectedSegmentIndex == 0 {
            user = tutors[indexPath.row]
        }
        else {
            user = tutees[indexPath.row]
        }
        cell.addInfo(user: user)
        cell.setNeedsUpdateConstraints()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
}
