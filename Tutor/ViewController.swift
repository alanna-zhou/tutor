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

class ViewController: UIViewController, UISearchBarDelegate {
    var tutoring: Bool = true
    var tutorTuteeSegment: UISegmentedControl!
    var searchBar: UISearchBar!
    var courses: [Course] = []
    var courseNames: [String] = []
    var matchingCourses: [String] = []
    var dropDown: DropDown!

    var coursesLabel: UILabel!
    var coursesTable: UITableView!
    
    let getCoursesURL = "http://localhost:5000/api/courses/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        if (!checkUsername()) {
            presentUserSetupView()
        }
        
        // Getting courses from server
        Alamofire.request(getCoursesURL, method: .get).validate().responseData { response in
            switch response.result {
            case let .success(data):
                let decoder = JSONDecoder()
                print("Successful response")
                if let coursedata = try? decoder.decode(CourseData.self, from: data) {
//                    if coursedata.success {
                        self.courses = coursedata.data
//                    }
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
        
        // Prints JSON
        Alamofire.request(getCoursesURL, method: .get).validate().responseJSON { response in
            switch response.result {
            case let .success(data):
                print(data)
                print("Successful response")
            case let .failure(error):
                print("Connection to server failed!")
                print(error.localizedDescription)
                self.courses = []
            }
        }
        
        for course in courses {
            courseNames.append("\(course.subject): \(course.number)")
        }
        
        // Making search bar and dropdown menu
        searchBar = UISearchBar()
        view.addSubview(searchBar)
        
        dropDown = DropDown()
        dropDown.anchorView = searchBar
        dropDown.backgroundColor = .white
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
        }
        dropDown.direction = .bottom
        
        tutorTuteeSegment = UISegmentedControl()
        tutorTuteeSegment.translatesAutoresizingMaskIntoConstraints = false
        tutorTuteeSegment.insertSegment(withTitle: "Add", at: 0, animated: true)
        tutorTuteeSegment.insertSegment(withTitle: "Remove", at: 1, animated: true)
        tutorTuteeSegment.subviews[1].tintColor = UIColor(red: 0.18, green: 0.80, blue: 0.44, alpha: 1.0)
        tutorTuteeSegment.subviews[0].tintColor = .red
        tutorTuteeSegment.selectedSegmentIndex = 0
        tutorTuteeSegment.addTarget(self, action: #selector(swapRole), for: .valueChanged)
        
        self.navigationItem.titleView = tutorTuteeSegment
        coursesTable = UITableView()
        
        
        setUpConstraints()
    }
    
    func setUpConstraints() {
        searchBar.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalTo(view)
        }
    }
    
    @objc func swapRole() {
        tutoring = !tutoring
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
    
    func checkUsername() -> Bool {
        return true
    }
}

