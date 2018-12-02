//
//  ViewController.swift
//  Tutor
//
//  Created by Eli Zhang on 11/20/18.
//  Copyright © 2018 Cornell AppDev. All rights reserved.
//
import UIKit
import SnapKit
import Alamofire
import ViewAnimator
import BLTNBoard
import NotificationBannerSwift
import GoogleSignIn
import AudioToolbox

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var refreshControl: UIRefreshControl!
    var tutorTuteeSegment: UISegmentedControl!
    var selectedTutorCourses: [Course] = []
    var selectedTuteeCourses: [Course] = []
    var allCourses: [Course] = []
    var tutors: [String] = []
    var tutees: [String] = []
    var bulletinManager: BLTNItemManager!
    
    var coursesLabel: UILabel!
    var tableView: UITableView!
    
    let courseReuseIdentifier = "courseReuseIdentifier"
    let tutorTuteeReuseIdentifier = "tutorTuteeReuseIdentifier"
    let courseCellHeight: CGFloat = 60
    let tutorTuteeCellHeight: CGFloat = 90
    let cellSpacingHeight: CGFloat = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        checkUsername()
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pulledToRefresh), for: .valueChanged)
        
        coursesLabel = UILabel()
        coursesLabel.text = "Your Courses"
        coursesLabel.textColor = .black
        coursesLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        coursesLabel.textAlignment = .center
        view.addSubview(coursesLabel)
        
        tutorTuteeSegment = UISegmentedControl()
        tutorTuteeSegment.translatesAutoresizingMaskIntoConstraints = false
        tutorTuteeSegment.insertSegment(withTitle: "All", at: 0, animated: true)
        tutorTuteeSegment.insertSegment(withTitle: "Tutors", at: 1, animated: true)
        tutorTuteeSegment.insertSegment(withTitle: "Tutees", at: 2, animated: true)
        tutorTuteeSegment.selectedSegmentIndex = 0
        tutorTuteeSegment.addTarget(self, action: #selector(swapRole), for: .valueChanged)

        self.navigationItem.titleView = tutorTuteeSegment
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(pushWishlistView))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Gear"), style: .plain, target: self, action: #selector(pushProfileView))
        
        tableView = UITableView()
        tableView.register(CourseTableViewCell.self, forCellReuseIdentifier: courseReuseIdentifier)
        tableView.register(TutorTuteeTableViewCell.self, forCellReuseIdentifier: tutorTuteeReuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = refreshControl
        
        let rightFade = AnimationType.from(direction: .right, offset: 60.0)
        tableView.animate(animations: [rightFade], duration: 0.5)
        view.addSubview(tableView)
        
        setUpConstraints()
    }
    
    func setUpConstraints() {
        coursesLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalTo(view)
        }
        
        tableView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(coursesLabel.snp.bottom).offset(20)
            make.leading.equalTo(view).offset(20)
            make.trailing.equalTo(view).offset(-20)
            make.bottom.equalTo(view)
        }
    }
    
    @objc func swapRole() {
        tableView.reloadData()
        if tutorTuteeSegment.selectedSegmentIndex == 0 {
            self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
            coursesLabel.text = "Your Courses"
        }
        else if tutorTuteeSegment.selectedSegmentIndex == 1 {
            self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
            coursesLabel.text = "Your Tutors"
        }
        else {
            self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
            coursesLabel.text = "Your Tutees"
        }
    }
    
    // Presenting views
    @objc func pushProfileView() {
        let navigationView = ProfileViewController()
        navigationView.delegate = self
        navigationController?.pushViewController(navigationView, animated: true)
    }
    
    @objc func pushWishlistView() {
        let navigationView = WishlistViewController()
        navigationController?.pushViewController(navigationView, animated: true)
    }
    
    @objc func presentIntroViewController() {
        let modalView = IntroViewController()
        present(modalView, animated: true, completion: nil)
    }
    
    @objc func pulledToRefresh() {
        getCoursesAndUsers()
        refreshControl.endRefreshing()
    }
    
    func checkUsername() {
        let userID = UserDefaults.standard.string(forKey: "userID")
        if userID != nil {
            login()
            let banner = NotificationBanner(title: "Logged in!", style: .success)
            banner.show()
            AudioServicesPlaySystemSound(1519)      // Vibrates
            return
        }
        // Allow users to login
        let page = LoginBulletinPage(mainView: self, title: "User Login")
        page.delegate = self
        page.descriptionText = "Log into Google to start finding tutors/tutees!"
        page.isDismissable = false
        page.appearance.actionButtonColor = UIColor(red: 0.294, green: 0.85, blue: 0.392, alpha: 1) // Green
        page.alternativeButtonTitle = nil
        bulletinManager = {
            let rootItem: BLTNItem = page
            return BLTNItemManager(rootItem: rootItem)
        }()
        bulletinManager.backgroundViewStyle = .blurredDark
        bulletinManager.showBulletin(above: self)
    }
    
    // TODO: Multiple views presented at the same time
    func login() {
        guard let email = UserDefaults.standard.string(forKey: "email") else {
            return
        }
        guard let index = email.range(of: "@")?.lowerBound else {
            return
        }
        let netID = email[email.startIndex..<index]
        UserDefaults.standard.set(netID, forKey: "netID")
        
        NetworkManager.getUserInfo(netID: String(netID),
            completion: { user in
                self.bulletinManager?.dismissBulletin(animated: true)
        },  failure: { () in
            self.bulletinManager?.dismissBulletin(animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.presentIntroViewController()}     // Failure
            })
        
        getCoursesAndUsers()
    }
    
    @objc func getCoursesAndUsers() {
        if let netID = UserDefaults.standard.string(forKey: "netID") {
            self.allCourses = []
            NetworkManager.getTutorCourses(netID: String(netID),
                                           completion: { courses in
                                            self.selectedTutorCourses = courses
                                            self.allCourses.append(contentsOf: courses)
                                            DispatchQueue.main.async {self.tableView.reloadData()}})
            NetworkManager.getTuteeCourses(netID: String(netID),
                                           completion: { courses in
                                            self.selectedTuteeCourses = courses
                                            self.allCourses.append(contentsOf: courses)
                                            DispatchQueue.main.async {self.tableView.reloadData()}})
            NetworkManager.getTutorsForUser(netID: String(netID),
                                            completion: { tutors in
                                                self.tutors = tutors
                                                DispatchQueue.main.async {self.tableView.reloadData()}})
            NetworkManager.getTuteesForUser(netID: String(netID),
                                            completion: { tutees in
                                                self.tutees = tutees
                                                DispatchQueue.main.async {self.tableView.reloadData()}})
        }
    }
}

extension ViewController {
    // Tableview configuration
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tutorTuteeSegment.selectedSegmentIndex == 0 {
            return allCourses.count
        }
        else {
            return 1
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tutorTuteeSegment.selectedSegmentIndex == 0 {
            return 1
        }
        if tutorTuteeSegment.selectedSegmentIndex == 1 {
            return self.tutors.count
        }
        else {
            return self.tutees.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tutorTuteeSegment.selectedSegmentIndex == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: courseReuseIdentifier, for: indexPath) as! CourseTableViewCell
            var course: Course
            course = allCourses[indexPath.row]
            cell.addInfo(course: course)
            cell.setNeedsUpdateConstraints()
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: tutorTuteeReuseIdentifier, for: indexPath) as! TutorTuteeTableViewCell
            var user: String
            if tutorTuteeSegment.selectedSegmentIndex == 1 {
                user = tutors[indexPath.section]
            }
            else {
                user = tutees[indexPath.section]
            }
            NetworkManager.getUserInfo(netID: user,
                                       completion: {user in
                                        print("User exists in database.")
                                        cell.addInfo(user: user, isTutor: self.tutorTuteeSegment.selectedSegmentIndex == 0)},
                                       failure: {})
            cell.setNeedsUpdateConstraints()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tutorTuteeSegment.selectedSegmentIndex == 0 {
            return courseCellHeight
        }
        return tutorTuteeCellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        getCoursesAndUsers()
        if tutorTuteeSegment.selectedSegmentIndex == 0 {
            let tutorTuteeViewController = TutorTuteeCatalogViewController(course: allCourses[indexPath.row])
            navigationController?.pushViewController(tutorTuteeViewController, animated: true)
        }
        if tutorTuteeSegment.selectedSegmentIndex == 1 {
            let userAtIndex = tutors[indexPath.section]
            let userProfileViewController = SelectedUserViewController(netID: userAtIndex, isTutor: tutorTuteeSegment.selectedSegmentIndex == 1)
            navigationController?.pushViewController(userProfileViewController, animated: true)
        } else if tutorTuteeSegment.selectedSegmentIndex == 2 {
            let userAtIndex = tutees[indexPath.section]
            let userProfileViewController = SelectedUserViewController(netID: userAtIndex, isTutor: tutorTuteeSegment.selectedSegmentIndex == 1)
            navigationController?.pushViewController(userProfileViewController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tutorTuteeSegment.selectedSegmentIndex == 0 {
            return 0
        }
        return cellSpacingHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            var selectedCourse: Course
            let netID = UserDefaults.standard.string(forKey: "netID")!
            if tutorTuteeSegment.selectedSegmentIndex == 0 {
                selectedCourse = allCourses[indexPath.row]
                NetworkManager.deleteUserFromCourse(netID: netID, subject: selectedCourse.course_subject, number: selectedCourse.course_num, completion: {})
                allCourses.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
}
