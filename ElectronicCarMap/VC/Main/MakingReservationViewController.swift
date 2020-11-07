//
//  MakingReservationViewController.swift
//  ElectronicCarMap
//
//  Created by Jkookoo on 2020/10/30.
//  Copyright © 2020 Jkookoo. All rights reserved.
//


import UIKit
import Alamofire
import Firebase

class MakingReservationViewController: UIViewController, UITextFieldDelegate, chargerStationDelegate {
    // MARK: - ProPerties
    var chargerDelegate: chargerStationDelegate?
    var chargerStation: ChargerStationModel!
    var chargers: [ChargerModel] = []
    var selectedChager: ChargerModel?
    let baseUrl = "http://34.123.73.237:10010/charger/"
    let myUid = Auth.auth().currentUser?.uid
    let databaseRef = Database.database().reference()
    
    // MARK: - Methods
    func setChargerInfo(selecteCharger: ChargerModel) {
        self.chargerIdButton.setTitle(selecteCharger.chargerId!, for: .normal)
        self.chargerStatusLabel.text = self.setChargerStatus(chargerStatus: selecteCharger.status!)
        self.chargerTypeLabel.text =  self.setchargerType(chargerType: selecteCharger.chargerType!)
    }
    
    func setReservationResultToUserInfo(completion: @escaping () -> Void) {
        let value = [
            "reserved" : "true",
            "chargerStationName": self.chargerStation.statName,
            "chargerId": self.selectedChager!.chargerId!,
            "lat": self.chargerStation.lat!,
            "lng": self.chargerStation.lng!
        ]
        
        self.databaseRef.child("users").child(self.myUid!).child("reservation").updateChildValues(value) { (error, databaseReference) in
            if error == nil {
                //성공
                completion()
            }
        }
    }
    
    func changeChargerStatus(completion: @escaping () -> Void) {
        let chargerId = self.selectedChager!.chargerId!
        let url = self.baseUrl + chargerId
        let header: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        let param = [
            "newStatus": "3"
        ]
        
        AF.request(url, method: .patch, parameters: param, encoding: JSONEncoding.default, headers: header).responseJSON { (response) in
            switch response.result {
            case .success:
                self.setReservationResultToUserInfo {
                    completion()
                }
            case .failure(let e):
                print("예약실패", e.localizedDescription)
            }
        }
    }
    
    func setChargerStatus(chargerStatus: String) -> String {
        switch chargerStatus {
        case "0":
            return "예약중"
        case "1":
            return "통신이상"
        case "2":
            return "충전가능"
        case "3":
            return "충전중"
        case "4":
            return "운영중지"
        case "5":
            return "점검중"
        case "9":
            return "통신이상"
        default:
            return ""
        }
    }
    
    func setchargerType(chargerType: String) -> String {
        switch chargerType  {
        case "01":
            return "DC차데모"
        case "02":
            return "AC완속"
        case "03":
            return "DC차데모+AC3상"
        case "04":
            return "DC콤보"
        case "05":
            return "DC차데모+DC콤보"
        case "06":
            return "DC차데모+AC3상+DC콤보"
        case "07":
            return "AC3상"
        default:
            return ""
        }
    }
    
    func getChargers() {
        if let chargers = self.chargerStation.chargers {
            self.chargers = chargers
        }
    }
    
    func checkChargerStationStatus(charger: ChargerModel) {
        if let chargerStatus = charger.status {
            if chargerStatus == "2" {
                self.reservationButton.isEnabled = true
            } else {
                self.reservationButton.isEnabled = false
            }
        }
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var chargerStationNameLabel: UILabel!
    @IBOutlet weak var chargerIdButton: UIButton!
    @IBOutlet weak var chargerTypeLabel: UILabel!
    @IBOutlet weak var chargerStatusLabel: UILabel!
    @IBOutlet weak var reservationButton: UIButton!
    
    // MARK: - IBActions
    @IBAction func touchUpCancelButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func touchUpChargerIdButton(_ sender: UIButton) {
        let chargerIdPickerVC = self.storyboard?.instantiateViewController(identifier: "chargerIdPickerViewController") as! ChargerIdPickerViewController
        chargerIdPickerVC.modalPresentationStyle = .overCurrentContext
        chargerIdPickerVC.modalTransitionStyle = .crossDissolve
        chargerIdPickerVC.chargerDelegate = self
        
        chargerIdPickerVC.chargers = self.chargers
        present(chargerIdPickerVC, animated: true, completion: nil)
    }
    
    @IBAction func touchUpReservationButton(_ sender: UIButton) {
        self.changeChargerStatus {
            self.dismiss(animated: false, completion: nil)
            self.chargerDelegate?.onClickedReservationButton()
        }
    }
    
    // MARK: - Delegates And DataSource
    func pickChargerId(charger: ChargerModel) {
        self.selectedChager = charger
        self.setChargerInfo(selecteCharger: charger)
        self.checkChargerStationStatus(charger: charger)
    }
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.layer.cornerRadius = 6
        self.getChargers()
        self.chargerStationNameLabel.text = self.chargerStation.statName
    }
}

