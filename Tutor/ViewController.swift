//
//  ViewController.swift
//  Tutor
//
//  Created by Eli Zhang on 11/20/18.
//  Copyright © 2018 Cornell AppDev. All rights reserved.
//

import UIKit
import SnapKit
import DropDown
import Alamofire

class ViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    var tutoring: Bool = true
    var tutorTuteeSegment: UISegmentedControl!
    var searchBar: UISearchBar!
    var courses: [Course] = []
    var courseNames: [String] = []
    var matchingCourses: [String] = []
    var selectedTutorCourses: [String] = []
    var selectedTuteeCourses: [String] = []
    var dropDown: DropDown!

    var coursesLabel: UILabel!
    var tableView: UITableView!
    
    let getCoursesURL = "http://localhost:5000/api/courses/"
    let courseWishlistReuseIdentifier = "courseWishlistReuseIdentifier"
    let cellHeight: CGFloat = 60
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        if (!checkUsername()) {
            presentUserSetupView()
        }
        
//        // Getting courses from server
//        Alamofire.request(getCoursesURL, method: .get).validate().responseData { response in
//            switch response.result {
//            case let .success(data):
//                let decoder = JSONDecoder()
//                print("Successful response")
//                if let coursedata = try? decoder.decode(CourseData.self, from: data) {
//                    if coursedata.success {
//                        self.courses = coursedata.data
//                    }
//                }
//                else {
//                    print("Couldn't decode tho rip")
//                }
//            case let .failure(error):
//                print("Connection to server failed!")
//                print(error.localizedDescription)
//                self.courses = []
//            }
//        }
        
        // Prints JSON
//        Alamofire.request(getCoursesURL, method: .get).validate().responseJSON { response in
//            switch response.result {
//            case let .success(data):
//                print(data)
//                print("Successful response")
//            case let .failure(error):
//                print("Connection to server failed!")
//                print(error.localizedDescription)
//                self.courses = []
//            }
//        }
        
        for course in courses {
            courseNames.append("\(course.subject): \(course.number)")
        }
        
        // Making search bar and dropdown menu
        searchBar = UISearchBar()
        view.addSubview(searchBar)
        
//        dropDown = DropDown()
//        dropDown.anchorView = searchBar
//        dropDown.backgroundColor = .white
//        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
//            print("Selected item: \(item) at index: \(index)")
//        }
//        dropDown.direction = .bottom
        
        tutorTuteeSegment = UISegmentedControl()
        tutorTuteeSegment.translatesAutoresizingMaskIntoConstraints = false
        tutorTuteeSegment.insertSegment(withTitle: "Tutor", at: 0, animated: true)
        tutorTuteeSegment.insertSegment(withTitle: "Tutee", at: 1, animated: true)
        tutorTuteeSegment.selectedSegmentIndex = 0
        tutorTuteeSegment.addTarget(self, action: #selector(swapRole), for: .valueChanged)
        
        selectedTutorCourses = ["Filial Piety", "Smiley Face", "The Amazing Race", "Aliens", "Ratatouille"]
        selectedTuteeCourses = ["Zoomba", "Roomba", "Tuba"]
        
        self.navigationItem.titleView = tutorTuteeSegment
        tableView = UITableView()
        tableView.register(CourseWishlistTableViewCell.self, forCellReuseIdentifier: courseWishlistReuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        
        setUpConstraints()
    }
    
    func setUpConstraints() {
        searchBar.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalTo(view)
        }
        
        tableView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(searchBar.snp.bottom)
            make.leading.trailing.equalTo(view)
            make.bottom.equalTo(view)
        }
    }
    
    @objc func swapRole() {
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        matchingCourses = searchText.isEmpty ? courseNames : courseNames.filter({ (option) -> Bool in
            option.range(of: searchText, options: .caseInsensitive) != nil
        })
        
        dropDown.dataSource = matchingCourses
        dropDown.show()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        for ob: UIView in ((searchBar.subviews[0] )).subviews {
            if let z = ob as? UIButton {
                let btn: UIButton = z
                btn.setTitleColor(UIColor.white, for: .normal)
            }
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        matchingCourses = courseNames
        dropDown.hide()
    }
    
    @objc func presentUserSetupView() {
        let modalView = LoginViewController()
        let navigationViewController = UINavigationController(rootViewController: modalView)
        present(navigationViewController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tutorTuteeSegment.selectedSegmentIndex == 0 {
            return selectedTutorCourses.count
        }
        return selectedTuteeCourses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: courseWishlistReuseIdentifier, for: indexPath) as! CourseWishlistTableViewCell
        var course: String
        if tutorTuteeSegment.selectedSegmentIndex == 0 {
            course = selectedTutorCourses[indexPath.row]
        }
        else {
            course = selectedTuteeCourses[indexPath.row]
        }
        cell.addInfo(course: course)
        cell.setNeedsUpdateConstraints()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func checkUsername() -> Bool {
        return true
    }
}

