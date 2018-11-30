//
//  Username.swift
//  Tutor
//
//  Created by Eli Zhang on 11/21/18.
//  Copyright © 2018 Cornell AppDev. All rights reserved.
//

struct UserData: Codable {
    let success: Bool
    let data: User
}

struct User: Codable {
    let net_id: String
    let name: String
    let year: String
    let major: String
    let bio: String
    let url: String
}

struct UserArray: Codable {
    let success: Bool
    let data: [String]
}

struct UserMatchData: Codable {
    let success: Bool
    let data: UserMatch
}

struct UserMatch: Codable {
    let tutor_net_id: String
    let tutee_net_id: String
    let course_subject: String
    let course_num: Int
}
