//
//  WishlistViewController.swift
//  Tutor
//
//  Created by Eli Zhang on 11/24/18.
//  Copyright © 2018 Cornell AppDev. All rights reserved.
//

import UIKit
import Alamofire

class WishlistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView: UITableView!
    
    var courses: [Course] = []
    var courseNames: [String] = []
    let courseWishlistReuseIdentifier = "courseWishlistReuseIdentifier"
    let getCoursesURL = "http://localhost:5000/api/courses/"
    
    let cellHeight: CGFloat = 60
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // Getting courses from server
        Alamofire.request(getCoursesURL, method: .get).validate().responseData { response in
            switch response.result {
            case let .success(data):
                let decoder = JSONDecoder()
                print("Successful response")
                if let coursedata = try? decoder.decode(CourseData.self, from: data) {
                    if coursedata.success {
                        self.courses = coursedata.data
                        for course in self.courses {
                            self.courseNames.append("\(course.course_name) \(course.course_num)")
                            self.tableView.reloadData()
                        }
                    }
                }
                else {
                    print("Couldn't decode tho rip")
                }
            case let .failure(error):
                print("Connection to server failed!")
                print(error.localizedDescription)
                self.courses = []
            }
        }
        
        tableView = UITableView()
        tableView.register(CourseWishlistTableViewCell.self, forCellReuseIdentifier: courseWishlistReuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        
        setUpConstraints()
    }
    
    func setUpConstraints() {
        tableView.snp.makeConstraints{ (make) -> Void in
            make.top.bottom.leading.trailing.equalTo(view)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courseNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: courseWishlistReuseIdentifier, for: indexPath) as! CourseWishlistTableViewCell
        let course = courseNames[indexPath.row]
        cell.addInfo(course: course)
        cell.setNeedsUpdateConstraints()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
}
