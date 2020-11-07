//
//  ReservationCompleteViewController.swift
//  ElectronicCarMap
//
//  Created by Jkookoo on 2020/11/06.
//  Copyright © 2020 Jkookoo. All rights reserved.
//

import UIKit

class ReservationCompleteViewController: UIViewController {
    // MARK: - ProPerties
    
    // MARK: - Methods
    
    // MARK: - IBOutlets
    @IBAction func touchUpOkButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: NSNotification.Name(reservationCompleteNotificationName), object: nil)
    }
    
    // MARK: - IBActions
    
    // MARK: - Delegates And DataSource
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}
