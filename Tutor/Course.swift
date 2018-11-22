//
//  Class.swift
//  Tutor
//
//  Created by Eli Zhang on 11/21/18.
//  Copyright © 2018 Cornell AppDev. All rights reserved.
//

struct CourseData: Codable {
//    let success: Bool
    let data: [Course]
}

struct Course: Codable {
//    let course_name: String
//    let course_num: Int
    let number: Int
    let subject: String
}
