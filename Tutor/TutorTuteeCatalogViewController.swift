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

class TutorTuteeCatalogViewController: UIViewController {

    var course: Course!
    var tutors: [String]!
    var tutees: [String]!
    var tableView: UITableView!
    
    var courseTutorsURL: String!
    var courseTuteesURL: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let course_subject = course.course_subject
        let course_num = course.course_num
        courseTutorsURL = "http://localhost:5000/api/course/\(course_subject)/\(course_num)/tutors/"
        courseTuteesURL = "http://localhost:5000/api/course/\(course_subject)/\(course_num)/tutees/"
        
        getCourseInfo()
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
                if let coursedata = try? decoder.decode(UserData.self, from: data) {
                    if coursedata.success {
                        self.tutors = coursedata.data
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
                if let coursedata = try? decoder.decode(UserData.self, from: data) {
                    if coursedata.success {
                        self.tutees = coursedata.data
                    }
                }
            case let .failure(error):
                print("Connection to server failed!")
                print(error.localizedDescription)
                self.tutees = []
            }
        }
    }
}
