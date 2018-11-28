//
//  NetworkManager.swift
//  Tutor
//
//  Created by Eli Zhang on 11/27/18.
//  Copyright © 2018 Cornell AppDev. All rights reserved.
//

import Alamofire

class NetworkManager {
//    static func get(netID: String, @completion: ){
//        let checkUserURL = "http://35.190.144.148/api/user/\(netID)/"
//        Alamofire.request(checkUserURL, method: .get).validate().responseData { response in
//            switch response.result {
//            case let .success(data):
//                let decoder = JSONDecoder()
//                if let userdata = try? decoder.decode(UserData.self, from: data) {
//                    if userdata.success {
//                        print("User exists in database.")
//                        UserDefaults.standard.set(netID, forKey: "netID")
//                    }
//                }
//            case let .failure(error):
//                print("Couldn't connect to server!")
//                self.presentUserSetupView()
//                print(error.localizedDescription)
//            }
//        }
//    }
}
