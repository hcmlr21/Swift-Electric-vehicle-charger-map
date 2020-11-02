//
//  UserModel.swift
//  ElectronicCarMap
//
//  Created by Jkookoo on 2020/11/02.
//  Copyright © 2020 Jkookoo. All rights reserved.
//

import Foundation
//
//class UserModel: NSObject {
//    @objc var userEmail: String?
//    @objc var userName: String?
//    @objc var uid: String?
//    @objc var favorite: [String]?
//    var reservation: Bool?
////    @objc var pushToken: String?
//}

struct UserModel: Codable {
    var userEmail: String?
    var userName: String?
    var uid: String?
    var favorite: [String:String]?
    var reservation: Bool?
//    @objc var pushToken: String?
}
