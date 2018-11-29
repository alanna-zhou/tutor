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
import BLTNBoard
import NotificationBannerSwift

class TutorTuteeCatalogViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var course: Course!
    var tutors: [String] = []
    var tutees: [String] = []
    var tableView: UITableView!
    var tutorTuteeSegment: UISegmentedControl!
    var bulletinManager: BLTNItemManager!
    
    var courseTutorsURL: String!
    var courseTuteesURL: String!
    
    let tutorTuteeReuseIdentifier = "tutorTuteeReuseIdentifier"
    let cellHeight: CGFloat = 90
    let cellSpacingHeight: CGFloat = 20

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
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
        NetworkManager.getCourseTutors(subject: course.course_subject, number: course.course_num, completion: { users in
            self.tutors = users
            self.checkEmpty()
            DispatchQueue.main.async {self.tableView?.reloadData()}}, failure: { () in self.tutors = []})
        NetworkManager.getCourseTutees(subject: course.course_subject, number: course.course_num, completion: { users in
            self.tutees = users
            DispatchQueue.main.async {self.tableView?.reloadData()}}, failure: { () in self.tutees = []})
    }
    
    func checkEmpty() {
        let page = BLTNPageItem(title: "Add Class")
        page.actionButtonTitle = "Sure"
        page.alternativeButtonTitle = "Not now"
        page.isDismissable = true
        page.appearance.actionButtonColor = UIColor(red: 0.294, green: 0.85, blue: 0.392, alpha: 1) // Green
        page.requiresCloseButton = false
        if tutorTuteeSegment.selectedSegmentIndex == 0 && tutors.count == 0 {
            page.descriptionText = "This course has no tutors. Would you like to add yourself to the tutee list?"
            page.actionHandler = { (item: BLTNActionItem) in
                self.bulletinManager.dismissBulletin(animated: true)
                let netID = UserDefaults.standard.string(forKey: "netID")!
                NetworkManager.addCourseToUser(netID: netID, isTutor: false, subject: self.course.course_subject, number: self.course.course_num, completion: {})
                let banner = NotificationBanner(title: "Added to course as tutee!", style: .success)
                banner.show()
                (self.navigationController?.viewControllers.first as! ViewController).tableView.reloadData()
            }
            page.alternativeHandler = { (item: BLTNActionItem) in
                self.bulletinManager.dismissBulletin(animated: true)
            }
        }
        else if tutorTuteeSegment.selectedSegmentIndex == 1 && tutees.count == 0 {
            page.descriptionText = "This course has no tutees. Would you like to add yourself to the tutor list?"
            page.actionHandler = { (item: BLTNActionItem) in
                self.bulletinManager.dismissBulletin(animated: true)
                let netID = UserDefaults.standard.string(forKey: "netID")!
                NetworkManager.addCourseToUser(netID: netID, isTutor: true, subject: self.course.course_subject, number: self.course.course_num, completion: {})
                let banner = NotificationBanner(title: "Added to course as tutor!", style: .success)
                banner.show()
                (self.navigationController?.viewControllers.first as! ViewController).tableView.reloadData()
            }
            page.alternativeHandler = { (item: BLTNActionItem) in
                self.bulletinManager.dismissBulletin(animated: true)
            }
        }
        else {
            return
        }
        bulletinManager = {
            let rootItem: BLTNItem = page
            return BLTNItemManager(rootItem: rootItem)
        }()
        bulletinManager.backgroundViewStyle = .blurredDark
        bulletinManager.showBulletin(above: self)
    }
    
    @objc func swapRole() {
        tableView.reloadData()
        checkEmpty()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tutorTuteeSegment.selectedSegmentIndex == 0 {
            return self.tutors.count
        }
        return self.tutees.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tutorTuteeReuseIdentifier, for: indexPath) as! TutorTuteeTableViewCell
        var user: String
        if tutorTuteeSegment.selectedSegmentIndex == 0 {
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var userAtIndex: String
        if tutorTuteeSegment.selectedSegmentIndex == 0 {
            userAtIndex = tutors[indexPath.section]
        } else {
            userAtIndex = tutees[indexPath.section]
        }
        let userProfileViewController = SelectedUserViewController(netID: userAtIndex, isTutor: tutorTuteeSegment.selectedSegmentIndex == 0, course: self.course)
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
