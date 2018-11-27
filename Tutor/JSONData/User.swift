//
//  Username.swift
//  Tutor
//
//  Created by Eli Zhang on 11/21/18.
//  Copyright © 2018 Cornell AppDev. All rights reserved.
//

struct User: Codable {
    let net_id: String
    let name: String
    let year: String
    let major: String
    let bio: String
}

struct UserData: Codable {
    let success: Bool
    let data: User
}

struct UserArray: Codable {
    let success: Bool
    let data: [User]
}
