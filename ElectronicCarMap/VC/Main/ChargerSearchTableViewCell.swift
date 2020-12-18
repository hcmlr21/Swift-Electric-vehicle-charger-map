//
//  ChargerSearchTableViewCell.swift
//  ElectronicCarMap
//
//  Created by Jkookoo on 2020/11/22.
//  Copyright © 2020 Jkookoo. All rights reserved.
//

import UIKit

class ChargerSearchTableViewCell: UITableViewCell {
    // MARK: - ProPerties
    
    // MARK: - Methods
    
    // MARK: - IBOutlets
    @IBOutlet weak var chargerStationNameLabel: UILabel!
    @IBOutlet weak var chargerAddressLabel: UILabel!
    @IBOutlet weak var chargerAvailableImageView: UIImageView!
    @IBOutlet weak var chargerAvailableLabel: UILabel!
    
    // MARK: - IBActions
    
    // MARK: - Delegates And DataSource
    
    // MARK: - Life Cycles
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
