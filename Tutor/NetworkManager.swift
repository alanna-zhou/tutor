//
//  NetworkManager.swift
//  Tutor
//
//  Created by Eli Zhang on 11/27/18.
//  Copyright © 2018 Cornell AppDev. All rights reserved.
//

import Alamofire

class NetworkManager {
    static func getUserInfo(netID: String, completion: @escaping (User) -> Void, failure: @escaping () -> Void) {
        let checkUserURL = "http://35.190.144.148/api/user/\(netID)/"
        Alamofire.request(checkUserURL, method: .get).validate().responseData { response in
            switch response.result {
            case let .success(data):
                let decoder = JSONDecoder()
                if let userdata = try? decoder.decode(UserData.self, from: data) {
                    if userdata.success {
                        print("User exists in database.")
                        completion(userdata.data)
                    }
                }
            case let .failure(error):
                print("Couldn't connect to server!")
                print(error.localizedDescription)
                failure()
            }
        }
    }
    
    static func getAllCourses(completion: @escaping ([Course]) -> Void, failure: @escaping () -> Void) {
        let getCoursesURL = "http://35.190.144.148/api/courses/"
        Alamofire.request(getCoursesURL, method: .get).validate().responseData { response in
            switch response.result {
            case let .success(data):
                let decoder = JSONDecoder()
                print("Successful response")
                if let coursedata = try? decoder.decode(CourseData.self, from: data) {
                    if coursedata.success {
                        completion(coursedata.data)
                    }
                }
            case let .failure(error):
                print("Connection to server failed!")
                print(error.localizedDescription)
                failure()
            }
        }
    }
    
    static func getTutorCourses(netID: String, completion: @escaping ([Course]) -> Void) {
        let tutorCoursesURL = "http://35.190.144.148/api/tutor/\(netID)/courses/"

        Alamofire.request(tutorCoursesURL, method: .get).validate().responseData { response in
            switch response.result {
            case let .success(data):
                let decoder = JSONDecoder()
                if let coursedata = try? decoder.decode(CourseData.self, from: data) {
                    if coursedata.success {
                        completion(coursedata.data)
                    }
                }
            case let .failure(error):
                print("Couldn't connect to server!")
                print(error.localizedDescription)
            }
        }
    }
    
    static func getTuteeCourses(netID: String, completion: @escaping ([Course]) -> Void) {
        let tuteeCoursesURL = "http://35.190.144.148/api/tutee/\(netID)/courses/"
        Alamofire.request(tuteeCoursesURL, method: .get).validate().responseData { response in
            switch response.result {
            case let .success(data):
                let decoder = JSONDecoder()
                if let coursedata = try? decoder.decode(CourseData.self, from: data) {
                    if coursedata.success {
                        completion(coursedata.data)
                    }
                }
            case let .failure(error):
                print("Couldn't connect to server!")
                print(error.localizedDescription)
            }
        }
    }
    
    static func getCourseTutors(subject: String, number: Int, completion: @escaping ([String]) -> Void, failure: @escaping () -> Void) {
        let courseTutorsURL = "http://35.190.144.148/api/course/\(subject)/\(number)/tutors/"
        Alamofire.request(courseTutorsURL, method: .get).validate().responseData { response in
            switch response.result {
            case let .success(data):
                let decoder = JSONDecoder()
                print("Successful response")
                if let userdata = try? decoder.decode(UserArray.self, from: data) {
                    if userdata.success {
                        completion(userdata.data)
                    }
                }
            case let .failure(error):
                print("Connection to server failed!")
                print(error.localizedDescription)
                failure()
            }
        }
    }
    
    static func getCourseTutees(subject: String, number: Int, completion: @escaping ([String]) -> Void, failure: @escaping () -> Void) {
        let courseTuteesURL = "http://35.190.144.148/api/course/\(subject)/\(number)/tutees/"
        Alamofire.request(courseTuteesURL, method: .get).validate().responseData { response in
            switch response.result {
            case let .success(data):
                let decoder = JSONDecoder()
                print("Successful response")
                if let userdata = try? decoder.decode(UserArray.self, from: data) {
                    if userdata.success {
                        completion((userdata.data))
                    }
                }
            case let .failure(error):
                print("Connection to server failed!")
                print(error.localizedDescription)
                failure()
            }
        }
    }
    
    static func addUser(netID: String, name: String, year: String, major: String, bio: String, completion: @escaping () -> Void) {
        let addUserURL = "http://35.190.144.148/api/user/"
        let parameters: Parameters = ["net_id": netID,
                                      "name": name,
                                      "year": year,
                                      "major": major,
                                      "bio": bio]
        Alamofire.request(addUserURL, method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseData { response in
            switch response.result {
            case let .success(data):
                let decoder = JSONDecoder()
                if let user = try? decoder.decode(UserData.self, from: data) {
                    if user.success {
                        completion()
                    }
                }
            case let .failure(error):
                print("Couldn't connect to server!")
                print(error.localizedDescription)
            }
        }
    }
    
    static func modifyUser(netID: String, name: String, year: String, major: String, bio: String, completion: @escaping () -> Void) {
        let modifyUserURL = "http://35.190.144.148/api/user/\(netID)/"
        let parameters: Parameters = ["name": name,
                                      "year": year,
                                      "major": major,
                                      "bio": bio]
        Alamofire.request(modifyUserURL, method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseData { response in
            switch response.result {
            case let .success(data):
                let decoder = JSONDecoder()
                print("Successful response")
                if let user = try? decoder.decode(UserData.self, from: data) {
                    if user.success {
                        completion()
                    }
                }
            case let .failure(error):
                print("Connection to server failed!")
                print(error.localizedDescription)
            }
        }
    }
    
    static func matchUsers(tutorID: String, tuteeID: String, course: Course, completion: @escaping() -> Void) {
        let matchUsersURL = "http://35.190.144.148/api/match/"
        let parameters: Parameters = ["tutor_net_id": tutorID,
                                      "tutee_net_id": tuteeID,
                                      "course_subject": course.course_subject,
                                      "course_num": course.course_num]
        Alamofire.request(matchUsersURL, method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseData { response in
            switch response.result {
            case let .success(data):
                let decoder = JSONDecoder()
                print("Successful response")
                if let userMatch = try? decoder.decode(UserMatchData.self, from: data) {
                    if userMatch.success {
                        completion()
                    }
                }
            case let .failure(error):
                print("Connection to server failed!")
                print(error.localizedDescription)
            }
        }
    }
}
