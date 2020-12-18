//
//  SearchViewController.swift
//  ElectronicCarMap
//
//  Created by Jkookoo on 2020/10/26.
//  Copyright © 2020 Jkookoo. All rights reserved.
//

import UIKit
import Alamofire
import SWXMLHash

class ChargerSearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, chargerStationDelegate {
    // MARK: - ProPerties
    var searchFilter: [Bool]?
    var searched: Bool = false
    var chargerDelegate: chargerStationDelegate?
    let chargerStationBaseUrl = "http://34.123.73.237:10010/chargerStation"
    var searchedChargerStations: [ChargerStationModel] = []
    let cellIdentifier = "chargerCell"
    
    // MARK: - Methods
    @objc func tapView() {
        self.view.endEditing(true)
    }
    
    func setChargerStations(JSONObj: Any) {
        do {
            guard let jsonFormatedResponse = JSONObj as? NSDictionary, let chargerStations = jsonFormatedResponse["chargerStations"] else  { return }
            
            let dataJSON = try JSONSerialization.data(withJSONObject: chargerStations, options: .prettyPrinted)
            let chargerStationsResult = try JSONDecoder().decode([ChargerStationModel].self, from: dataJSON)
            
            var filteredChargerStation: [ChargerStationModel] = []
            if let _ = self.searchFilter {
                for chargerStation in chargerStationsResult {
                    if(chargerStation.availableChargerCount > 0) {
                        filteredChargerStation.append(chargerStation)
                    }
                }
                
                self.searchedChargerStations = filteredChargerStation
            } else {
                self.searchedChargerStations = chargerStationsResult
            }
            
            self.chargerTableView.reloadData()
        } catch{
            print(error.localizedDescription)
        }
    }
    
    func requestChargerStations(url: String, param: [String:String]) {
        AF.request(url, method: .get, parameters: param).responseJSON { (response) in
            switch response.result {
            case .success(let obj):
                self.setChargerStations(JSONObj: obj)
            case .failure(let e):
                print(e)
            }
        }
    }
    
    func getCharger(name: String, addr: String) {
        let url = self.chargerStationBaseUrl
        
        if (name == "") && (addr == "") {
            self.searchedChargerStations = []
            self.chargerTableView.reloadData()
        } else  {
            let param = ["name": name, "address" : addr]
            self.requestChargerStations(url: url, param: param)
        }
    }
    
    func showChargerStationInfoDetail() {
        self.chargerTableView.rowHeight = 70
        self.chargerTableView.reloadData()
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var chargerSearchBar: UISearchBar!
    @IBOutlet weak var chargerTableView: UITableView!
    
    // MARK: - IBActions
    @IBAction func touchUpBackButton(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func touchUpFilteringButton(_ sender: UIButton) {
        let filterVC = self.storyboard?.instantiateViewController(identifier: "chargerStationSearchFilteringViewController") as! ChargerStationSearchFilteringViewController
        filterVC.modalPresentationStyle = .fullScreen
        
        filterVC.chargerStationDelegate = self
        filterVC.searchFilter = self.searchFilter
        
        present(filterVC, animated: true, completion: nil)
    }
    
    // MARK: - Delegates And DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchedChargerStations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.chargerTableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as? ChargerSearchTableViewCell else {
            return UITableViewCell()
        }
        
        let chargerStation = self.searchedChargerStations[indexPath.row]
        
        cell.chargerStationNameLabel.text = chargerStation.statName
        
        if !self.searched {
            cell.chargerAddressLabel.isHidden = true
            cell.chargerAddressLabel.text = ""
        } else {
            cell.chargerAddressLabel.isHidden = false
            cell.chargerAddressLabel.text = chargerStation.address
        }
        
        if chargerStation.availableChargerCount > 0 {
            cell.chargerAvailableImageView.image = UIImage(named: "electronicMarker")
            cell.chargerAvailableLabel.font = cell.chargerAvailableLabel.font.withSize(12)
            cell.chargerAvailableLabel.text = "충전가능"
        } else {
            cell.chargerAvailableImageView.image = UIImage(named: "unableElectronicMarker")
            cell.chargerAvailableLabel.font = cell.chargerAvailableLabel.font.withSize(10)
            cell.chargerAvailableLabel.text = "충전불가능"
        }
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.chargerTableView.rowHeight = 45
        self.chargerSearchBar.becomeFirstResponder()
        
        self.searched = false
        
        self.chargerTableView.reloadData()
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.getCharger(name: searchText, addr: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.searched = true
        
        self.showChargerStationInfoDetail()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.chargerDelegate?.onClickedChargerStation(chargerStationId: self.searchedChargerStations[indexPath.row].statId)
        self.dismiss(animated: false, completion: nil)
    }
    
    func setChargerStationSearchFilter(filter: [Bool]?) {
        self.searchFilter = filter
        self.chargerSearchBar.text = ""
        self.getCharger(name: "", addr: "")
    }
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.chargerSearchBar.delegate = self
        self.chargerTableView.rowHeight = 45
        self.chargerSearchBar.becomeFirstResponder()
    }
}

@IBDesignable extension UIButton {
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
    
}
