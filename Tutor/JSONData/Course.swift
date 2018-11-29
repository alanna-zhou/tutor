//
//  Class.swift
//  Tutor
//
//  Created by Eli Zhang on 11/21/18.
//  Copyright © 2018 Cornell AppDev. All rights reserved.
//

struct CourseData: Codable {
    let success: Bool
    let data: [Course]
}

struct Course: Codable {
    let course_name: String
    let course_num: Int
    let course_subject: String
}

struct AddCourse: Codable {
    let net_id: String
    let is_tutor: Bool // true if tutor, false if tutee
    let course_subject: String
    let course_num: Int
    let course_number: String
}

struct AddCourseData: Codable {
    let success: Bool
    let data: AddCourse
}
