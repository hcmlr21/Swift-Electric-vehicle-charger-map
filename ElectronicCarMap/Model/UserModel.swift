//
//  UserModel.swift
//  ElectronicCarMap
//
//  Created by Jkookoo on 2020/11/02.
//  Copyright © 2020 Jkookoo. All rights reserved.
//

import Foundation

class UserModel: NSObject {
    @objc var userEmail: String?
    @objc var userName: String?
    @objc var uid: String?
    @objc var favorite: [String]?
    @objc var bookMark: [String:String]?
    @objc var reservation: [String:String]?
}
