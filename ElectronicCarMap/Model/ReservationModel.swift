//
//  ReservationModel.swift
//  ElectronicCarMap
//
//  Created by Jkookoo on 2020/11/07.
//  Copyright © 2020 Jkookoo. All rights reserved.
//

import Foundation

class ReservationModel: NSObject {
    @objc var reserved: String?
    @objc var chargerStationName: String?
    @objc var chargerId: String?
    @objc var lat: String?
    @objc var lng: String?
    @objc var addr: String?
}
