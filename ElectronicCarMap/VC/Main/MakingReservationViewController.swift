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

class MakingReservationViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, chargerStationDelegate {
    // MARK: - ProPerties
    var chargerDelegate: chargerStationDelegate?
    var chargerStation: ChargerStationModel!
    var chargers: [ChargerModel] = []
    var selectedChager: ChargerModel?
    let baseUrl = "http://34.123.73.237:10010/charger/"
    let myUid = Auth.auth().currentUser?.uid
    let databaseRef = Database.database().reference()
    let cellIdentifier = "chargerCell"
    var selectedCellIndex: Int?
    
    // MARK: - Methods
//    func setChargerInfo(selecteCharger: ChargerModel?) {
//        self.chargerIdButton.setTitle(selecteCharger.chargerId!, for: .normal)
//        self.chargerStatusLabel.text = self.setChargerStatus(chargerStatus: selecteCharger.status!)
//        self.chargerTypeLabel.text =  self.setchargerType(chargerType: selecteCharger.chargerType!)
//    }
    
    func setReservationResultToUserInfo(completion: @escaping () -> Void) {
        let value = [
            "reserved" : "true",
            "chargerStationName": self.chargerStation.statName,
            "chargerId": self.selectedChager!.chargerId!,
            "lat": String(self.chargerStation.lat),
            "lng": String(self.chargerStation.lng),
            "addr": self.chargerStation.address
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
    
    func checkChargerStationStatus(charger: ChargerModel?) {
        if let selectedCharger = charger, let chargerStatus = selectedCharger.status, chargerStatus == "2" {
            self.reservationButton.isEnabled = true
        } else {
            self.reservationButton.isEnabled = false
        }
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var chargerStationNameLabel: UILabel!
    @IBOutlet weak var chargerIdButton: UIButton!
    @IBOutlet weak var chargerTypeLabel: UILabel!
    @IBOutlet weak var chargerStatusLabel: UILabel!
    @IBOutlet weak var reservationButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
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
        
        let alert = UIAlertController(title: "예약", message: "예약을 진행하시겠습니까?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { (action) in
            self.dismiss(animated: false, completion: nil)
            self.changeChargerStatus {
                self.chargerDelegate?.onClickedReservationButton()
            }
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Delegates And DataSource
//    func pickChargerId(charger: ChargerModel) {
//        self.selectedChager = charger
//        self.setChargerInfo(selecteCharger: charger)
//        self.checkChargerStationStatus(charger: charger)
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let charger = chargers[indexPath.row]
        if let selectedIndex = self.selectedCellIndex, indexPath.row == selectedIndex {
            self.selectedCellIndex = nil
            self.selectedChager = nil
        } else {
            if charger.status == "2" {
                self.selectedChager = charger
                self.selectedCellIndex = indexPath.row
            }
        }
        
        
        
//        if let selectedIndex = self.selectedCellIndex, indexPath.row == selectedIndex {
//            self.selectedCellIndex = nil
//            self.selectedChager = nil
//        } else {
//            let charger = chargers[indexPath.row]
//
//            if charger.status == "2" {
//                self.selectedChager = charger
//                self.selectedCellIndex = indexPath.row
//            } else {
//                self.selectedCellIndex = nil
//                self.selectedChager = nil
//            }
//
//        }
        
        self.checkChargerStationStatus(charger: selectedChager)
        
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chargers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier) as? MakingReservationTableViewCell else {
            return UITableViewCell()
        }
        
        
        
        if let selectedindex = self.selectedCellIndex, indexPath.row == selectedindex {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        let charger = self.chargers[indexPath.row]
        if charger.status == "2" {
            cell.chargerIdLabel.textColor = .black
            cell.chargerTypeLabel.textColor = .black
            cell.chargerStatusLabel.textColor = .black
        } else {
            cell.chargerIdLabel.textColor = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)
            cell.chargerTypeLabel.textColor = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)
            cell.chargerStatusLabel.textColor = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)
        }
        cell.chargerIdLabel.text = charger.chargerId
        cell.chargerTypeLabel.text = self.setchargerType(chargerType: charger.chargerType!)
        cell.chargerStatusLabel.text = self.setChargerStatus(chargerStatus: charger.status!)
        
        
        return cell
    }
    
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.layer.cornerRadius = 6
        self.getChargers()
        self.chargerStationNameLabel.text = self.chargerStation.statName
    }
}

