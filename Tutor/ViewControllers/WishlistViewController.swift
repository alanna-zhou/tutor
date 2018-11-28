//
//  WishlistViewController.swift
//  Tutor
//
//  Created by Eli Zhang on 11/24/18.
//  Copyright © 2018 Cornell AppDev. All rights reserved.
//

import UIKit
import Alamofire
import ViewAnimator

class WishlistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView: UITableView!
    
    var courses: [Course] = []
    var courseNames: [String] = []
    var filteredCourses: [Course] = []
    var filteredCourseNames: [String] = []
    var searchController: UISearchController!
    let courseWishlistReuseIdentifier = "courseWishlistReuseIdentifier"
    
    let cellHeight: CGFloat = 60
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        NetworkManager.getAllCourses(completion: { courses in
                                    for course in self.courses {
                                        self.courseNames.append("\(course.course_subject) \(course.course_num): \(course.course_name)")
                                    }
                                    DispatchQueue.main.async {self.tableView.reloadData()}},
                                     failure: { () in self.courses = []})
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Find a class"
        navigationItem.hidesSearchBarWhenScrolling = true
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        tableView = UITableView()
        tableView.register(CourseWishlistTableViewCell.self, forCellReuseIdentifier: courseWishlistReuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        let rightFade = AnimationType.from(direction: .right, offset: 60.0)
        tableView.animate(animations: [rightFade], duration: 0.5)
        view.addSubview(tableView)
        
        setUpConstraints()
    }
    
    func setUpConstraints() {
        tableView.snp.makeConstraints{ (make) -> Void in
            make.top.bottom.leading.trailing.equalTo(view)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredCourses.count
        }
        return courseNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: courseWishlistReuseIdentifier, for: indexPath) as! CourseWishlistTableViewCell
        let course: String
        if isFiltering() {
            course = filteredCourseNames[indexPath.row]
        } else {
            course = courseNames[indexPath.row]
        }
        cell.addInfo(course: course)
        cell.setNeedsUpdateConstraints()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var courseAtIndex: Course
        if isFiltering() {
            courseAtIndex = filteredCourses[indexPath.row]
        } else {
            courseAtIndex = courses[indexPath.row]
        }
        let tutorTuteeCatalogViewController = TutorTuteeCatalogViewController(course: courseAtIndex)
        navigationController?.pushViewController(tutorTuteeCatalogViewController, animated: true)
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredCourseNames = courseNames.filter({( courseName: String) -> Bool in
            return courseName.lowercased().contains(searchText.lowercased())
        })
        filteredCourses = courses.filter({( course: Course ) -> Bool in
            return "\(course.course_subject) \(course.course_num): \(course.course_name)".lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
}

extension WishlistViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
