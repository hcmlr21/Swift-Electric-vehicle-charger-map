//
//  MakingReservationViewController.swift
//  ElectronicCarMap
//
//  Created by Jkookoo on 2020/10/30.
//  Copyright © 2020 Jkookoo. All rights reserved.
//

import UIKit

class MakingReservationViewController: UIViewController {
    // MARK: - ProPerties
    var chargerStation: ChargerStationModel!
    // MARK: - Methods
    func setChargerInfo() {
        self.chargerStationNameLabel.text = self.chargerStation.statName
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var chargerStationNameLabel: UILabel!
    
    // MARK: - IBActions
    @IBAction func touchUpCancelButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Delegates And DataSource
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setChargerInfo()
    }
}
