//
//  ChargerIdPickerViewController.swift
//  ElectronicCarMap
//
//  Created by Jkookoo on 2020/11/03.
//  Copyright © 2020 Jkookoo. All rights reserved.
//

import UIKit

class ChargerIdPickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    // MARK: - ProPerties
    var chargers: [ChargerModel] = []
    var chargerDelegate: chargerStationDelegate?
    
    // MARK: - Methods
    
    // MARK: - IBOutlets
    @IBOutlet weak var chargerIdPicker: UIPickerView!
    
    // MARK: - IBActions
    @objc func tapView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return chargers.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.chargers[row].chargerId!
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.chargerDelegate?.pickChargerId(charger: self.chargers[row])
    }
    
    @IBAction func touchUpDoneButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Delegates And DataSource
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapView = UITapGestureRecognizer(target: self, action: #selector(self.tapView))
        self.view.addGestureRecognizer(tapView)
        self.chargerIdPicker.delegate = self
        self.chargerIdPicker.dataSource = self
        //auto select first element
        pickerView(self.chargerIdPicker, didSelectRow: 0, inComponent: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
}
