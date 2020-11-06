//
//  ChargerDelegate.swift
//  ElectronicCarMap
//
//  Created by Jkookoo on 2020/10/28.
//  Copyright © 2020 Jkookoo. All rights reserved.
//

import UIKit

protocol chargerStationDelegate {
    func onClickedChargerStation(chargerStationId: String)
    func onClickedAddress(spotInfo:[String:String])
    func pickChargerId(charger: ChargerModel)
    func onClickedReservationButton()
}

extension chargerStationDelegate {
    //optional
    func onClickedChargerStation(chargerStationId: String) {
        
    }
    
    func onClickedAddress(spotInfo: [String:String]) {
        
    }
    
    func pickChargerId(charger: ChargerModel) {
        
    }
    
    func onClickedReservationButton() {
        
    }
}
