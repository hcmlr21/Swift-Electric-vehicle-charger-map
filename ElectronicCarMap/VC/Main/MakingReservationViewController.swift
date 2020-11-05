//
//  MakingReservationViewController.swift
//  ElectronicCarMap
//
//  Created by Jkookoo on 2020/10/30.
//  Copyright © 2020 Jkookoo. All rights reserved.
//

import UIKit

class MakingReservationViewController: UIViewController, UITextFieldDelegate, chargerStationDelegate {
    // MARK: - ProPerties
    var chargerStation: ChargerStationModel!
    var chargers: [ChargerModel] = []
    
    // MARK: - Methods
    func setChargerInfo(selecteCharger: ChargerModel) {
        self.chargerTypeLabel.text = selecteCharger.chargerType
        self.chargerStatusLabel.text = selecteCharger.status
    }
    
    func getChargers() {
        if let chargers = self.chargerStation.chargers {
            self.chargers = chargers
        }
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var chargerStationNameLabel: UILabel!
    @IBOutlet weak var chargerIdButton: UIButton!
    @IBOutlet weak var chargerTypeLabel: UILabel!
    @IBOutlet weak var chargerStatusLabel: UILabel!
    
    // MARK: - IBActions
    @IBAction func touchUpCancelButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func touchUpChargerIdButton(_ sender: UIButton) {
        let chargerIdPickerVC = self.storyboard?.instantiateViewController(identifier: "chargerIdPickerViewController") as! ChargerIdPickerViewController
        chargerIdPickerVC.modalPresentationStyle = .overCurrentContext
        chargerIdPickerVC.modalTransitionStyle = .crossDissolve
        chargerIdPickerVC.chargerDelegate = self
        var chargers: [ChargerModel] = []
        for charger in self.chargers {
            chargers.append(charger)
        }
        
        chargerIdPickerVC.chargers = chargers
        present(chargerIdPickerVC, animated: true, completion: nil)
    }
    
    // MARK: - Delegates And DataSource
    func pickChargerId(charger: ChargerModel) {
        self.chargerIdButton.setTitle(charger.chargerId!, for: .normal)
        setChargerInfo(selecteCharger: charger)
    }
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getChargers()
        self.chargerStationNameLabel.text = self.chargerStation.statName
    }
}
