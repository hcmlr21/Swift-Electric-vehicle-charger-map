//
//  ChargerDelegate.swift
//  ElectronicCarMap
//
//  Created by Jkookoo on 2020/10/28.
//  Copyright © 2020 Jkookoo. All rights reserved.
//

import UIKit

protocol chargerStationDelegate {
    func onClikedChargerStation(chargerStationId: String)
    func pickChargerId(charger: ChargerModel)
}

extension chargerStationDelegate {
    //optional
    func onClikedChargerStation(chargerStationId: String) {
        
    }
    
    func pickChargerId(charger: ChargerModel) {
        
    }
}
