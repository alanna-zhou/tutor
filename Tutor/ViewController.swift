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
    var tutorTuteeSegment: UISegmentedControl!
    var selectedTutorCourses: [String] = []
    var selectedTuteeCourses: [String] = []
    var netID: String!
    var name: String!
    var bulletinManager: BLTNItemManager!
    
    var coursesLabel: UILabel!
    var tableView: UITableView!
    
    let courseReuseIdentifier = "courseReuseIdentifier"
    let cellHeight: CGFloat = 60
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        checkUsername()
        
        coursesLabel = UILabel()
        coursesLabel.text = "Your Courses"
        coursesLabel.textColor = .black
        coursesLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        coursesLabel.textAlignment = .center
        view.addSubview(coursesLabel)
        
        tutorTuteeSegment = UISegmentedControl()
        tutorTuteeSegment.translatesAutoresizingMaskIntoConstraints = false
        tutorTuteeSegment.insertSegment(withTitle: "Tutor", at: 0, animated: true)
        tutorTuteeSegment.insertSegment(withTitle: "Tutee", at: 1, animated: true)
        tutorTuteeSegment.selectedSegmentIndex = 0
        tutorTuteeSegment.addTarget(self, action: #selector(swapRole), for: .valueChanged)
        
        selectedTutorCourses = ["Aliens", "Ratatouille"]
        selectedTuteeCourses = ["Zoomba", "Roomba", "Tuba"]
        
        self.navigationItem.titleView = tutorTuteeSegment
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(pushWishlistView))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(signOut))
        
        tableView = UITableView()
        tableView.register(CourseTableViewCell.self, forCellReuseIdentifier: courseReuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        
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
            make.leading.trailing.equalTo(view)
            make.bottom.equalTo(view)
        }
    }
    
    @objc func swapRole() {
        tableView.reloadData()
    }
    
//    @objc func presentUserSetupView() {
//        let modalView = LoginViewController()
//        push(modalView, animated: true, completion: nil)
//    }
    
    @objc func pushWishlistView() {
        let navigationView = WishlistViewController()
        navigationController?.pushViewController(navigationView, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tutorTuteeSegment.selectedSegmentIndex == 0 {
            return selectedTutorCourses.count
        }
        return selectedTuteeCourses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: courseReuseIdentifier, for: indexPath) as! CourseTableViewCell
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
    
    func checkUsername() {
        let userID = UserDefaults.standard.string(forKey: "userID")
        if userID != nil {
            bulletinManager?.dismissBulletin(animated: true)
            let banner = NotificationBanner(title: "Logged in!", style: .success)
            banner.show()
            AudioServicesPlaySystemSound(1519)      // Vibrates
            
            login()
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
    
    @objc func signOut() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
        GIDSignIn.sharedInstance().signOut()
        print("Signed out.")
        checkUsername()
    }
    
    func login() {
        
    }
}
