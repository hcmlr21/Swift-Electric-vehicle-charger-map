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

//struct APIrespons : Codable{
//    var success : Bool
//    var chargerStations: [ChargerStation]
//}


class ChargerSearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    // MARK: - ProPerties
    var chargerDelegate: searchPlaceDelegate?
    let chargerKey = "?serviceKey=VSiTPgmdSow8suOp6MW6%2BIoHCZ9DU6kDloiZ3oDh6mCe%2Fr7FjD7A9Usupx6q0cOq1akSrizFlCkKhYchpNBm1w%3D%3D&" //전기차데이터 key
    let chargerBaseUrl2 = "http://open.ev.or.kr:8080/openapi/services/EvCharger/getChargerInfo"//전기차데이터1 url endpoint
    let chargerBaseUrl3 = "http://openapi.kepco.co.kr/service/EvInfoServiceV2/getEvSearchList"
    let chargerBalseUrl = "http://34.123.73.237:10010/chargerStation"
    var searchedChargerStations: [ChargerStationModel] = []
    let cellIdentifier = "chargerCell"
    
    // MARK: - Methods
    @objc func tapView() {
        self.view.endEditing(true)
    }
    
    func setChargerStations(JSONObj: Any) {
        do {
            guard let jsonFormatedResponse = JSONObj as? NSDictionary, let chargerstations = jsonFormatedResponse["chargerStations"] else  { return }
            
            let dataJSON = try JSONSerialization.data(withJSONObject: chargerstations, options: .prettyPrinted)
            let chargerStationsResult = try JSONDecoder().decode([ChargerStationModel].self, from: dataJSON)
            let chargerStionsCount = chargerStationsResult.count
            
            self.searchedChargerStations.removeAll()
            for i in 0..<chargerStionsCount {
                let chargerStation = chargerStationsResult[i]
                self.searchedChargerStations.append(chargerStation)
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
    
    func getCharger2(name: String, addr: String) {
        let url = self.chargerBalseUrl
        
        if (name == "") && (addr == "") {
            self.searchedChargerStations = []
            self.chargerTableView.reloadData()
        } else  {
            let param = ["name": name, "address" : addr]
            self.requestChargerStations(url: url, param: param)
        }
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var chargerSearchBar: UISearchBar!
    @IBOutlet weak var chargerTableView: UITableView!
    
    // MARK: - IBActions
    @IBAction func touchUpBackButton(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    // MARK: - Delegates And DataSource
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchedChargerStations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.chargerTableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)
        
        let charger = self.searchedChargerStations[indexPath.row]
        cell.textLabel?.text = charger.statName
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.getCharger2(name: searchText, addr: searchText)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.chargerDelegate?.onClikedChargerStation(chargerStation: self.searchedChargerStations[indexPath.row])
        self.dismiss(animated: false, completion: nil)
        
    }
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.chargerSearchBar.becomeFirstResponder()
        self.chargerSearchBar.delegate = self
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
