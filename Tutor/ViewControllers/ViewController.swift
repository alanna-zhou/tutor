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
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Gear"), style: .plain, target: self, action: #selector(pushProfileView))
        
        tableView = UITableView()
        tableView.register(CourseTableViewCell.self, forCellReuseIdentifier: courseReuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        
//        let rightFade = AnimationType.from(direction: .right, offset: 60.0)
//        tableView.animate(animations: [rightFade], duration: 0.5)
        let fromAnimation = AnimationType.from(direction: .right, offset: 30.0)
        let zoomAnimation = AnimationType.zoom(scale: 0.2)
        UIView.animate(views: tableView.visibleCells,
                       animations: [fromAnimation, zoomAnimation], delay: 0.5)
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
    
    @objc func presentUserSetupView() {
        let modalView = ProfileSetupViewController()
        present(modalView, animated: true, completion: nil)
    }
    
    @objc func pushProfileView() {
        let navigationView = ProfileViewController()
        navigationView.delegate = self
        navigationController?.pushViewController(navigationView, animated: true)
    }
    
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
    
    func login() {
        guard let email = UserDefaults.standard.string(forKey: "email") else {
            return
        }
        guard let index = email.range(of: "@")?.lowerBound else {
            return
        }
        let netID = email[email.startIndex..<index]
        UserDefaults.standard.set(netID, forKey: "netID")
        let checkUserURL = "http://localhost:5000/api/user/\(netID)/"
        Alamofire.request(checkUserURL, method: .get).validate().responseData { response in
            switch response.result {
            case let .success(data):
                let decoder = JSONDecoder()
                if let userdata = try? decoder.decode(UserData.self, from: data) {
                    if userdata.success {
                        print("User exists in database.")
                        UserDefaults.standard.set(netID, forKey: "netID")
                    }
                }
            case let .failure(error):
                print("Couldn't connect to server!")
                self.presentUserSetupView()
                print(error.localizedDescription)
            }
        }
    }
}
