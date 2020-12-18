//
//  ChargerStationSearchFilteringViewController.swift
//  ElectronicCarMap
//
//  Created by Jkookoo on 2020/11/27.
//  Copyright © 2020 Jkookoo. All rights reserved.
//

import UIKit

class ChargerStationSearchFilteringViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - ProPerties
    let filterMenu: [String] = ["DC차데모", "AC완속", "DC차데모+AC3상", "DC콤보", "DC차데모+DC콤보", "DC차데모+AC3상+DC콤보", "AC3상", "충전가능"]
    let cellIdentifiter = "filterCell"
    var searchFilter: [Bool]?
    var chargerStationDelegate: chargerStationDelegate?
    
    // MARK: - Methods
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - IBActions
    @IBAction func touchUpDoneButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        
        if !self.searchFilter![7] {
            self.searchFilter = nil
        }
        self.chargerStationDelegate?.setChargerStationSearchFilter(filter: self.searchFilter)
    }
    
    // MARK: - Delegates And DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 7
        } else if section == 1 {
            return 1
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: self.cellIdentifiter, for: indexPath)
        
        if indexPath.section == 0 {
            cell.textLabel?.text = self.filterMenu[indexPath.row]
            
            if self.searchFilter![indexPath.row] {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        } else if indexPath.section == 1 {
            cell.textLabel?.text = self.filterMenu[indexPath.row + 7]
            
            if self.searchFilter![indexPath.row + 7] {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "충전 타입"
        } else  if section == 1 {
            return "사용 가능"
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            self.searchFilter![indexPath.row] = !self.searchFilter![indexPath.row]
        } else if indexPath.section == 1 {
            self.searchFilter![indexPath.row + 7] = !self.searchFilter![indexPath.row + 7]
        }
        
        self.tableView.reloadData()
    }
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.searchFilter == nil {
            self.searchFilter = [Bool](repeating: false, count: self.filterMenu.count)
        }
    }
}
