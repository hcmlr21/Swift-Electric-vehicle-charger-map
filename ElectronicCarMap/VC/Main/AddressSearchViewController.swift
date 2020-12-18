//
//  AddressSearchViewController.swift
//  ElectronicCarMap
//
//  Created by Jkookoo on 2020/10/30.
//  Copyright © 2020 Jkookoo. All rights reserved.
//

import UIKit
import Alamofire

class AddressSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    // MARK: - ProPerties
    var searched: Bool = false
    var chargerDelegate: chargerStationDelegate?
    let roadAddrKey = "devU01TX0FVVEgyMDIwMTEwNDIxMjkyNzExMDM3MTQ="
    let naverGeocodingKeyId = "iaf1r9n5ki"
    let naverGeocodingKeyPass = "Sef6plir6Dz1baxmF2lbyTqtsorc2gQpup9FT3kc"
    let cellIdentifier = "addressCell"
    var searchedAddrs: [String:[Juso]] = ["buildingAddrs":[], "roadAddrs":[]]
    var spotInfo: [String:String] = [:]
    let addressSearchCilentId = "gUJ5HvMoYGrUx1pznTyd"
    let addressSearchClientSecret = "O7fz4Y_E8p"
    let baseUrl = "https://openapi.naver.com/v1/search/local.json"
    
    // MARK: - Methods
    func setSearchedAddresses(JSONObj: Any) {
        do {
            guard let jsonFormatedResponse = JSONObj as? NSDictionary, let results = jsonFormatedResponse["results"] as? NSDictionary, let addrs = results["juso"] else {
                return }
            let dataJSON = try JSONSerialization.data(withJSONObject: addrs, options: .prettyPrinted)
            let addrsResult = try JSONDecoder().decode([Juso].self, from: dataJSON)
            
            self.searchedAddrs["buildingAddrs"]!.removeAll()
            self.searchedAddrs["roadAddrs"]!.removeAll()
            for addr in addrsResult {
                if addr.bdNm != "" {
                    self.searchedAddrs["buildingAddrs"]?.append(addr)
                } else {
                    self.searchedAddrs["roadAddrs"]?.append(addr)
                }
                    
            }
            
            self.addressTableView.reloadData()
        } catch(let e) {
            print(e.localizedDescription)
        }
    }
    
    func requestAddress(addrKeyword: String) {
        if (addrKeyword.count < 2) {
            self.searchedAddrs["buildingAddrs"]!.removeAll()
            self.searchedAddrs["roadAddrs"]!.removeAll()
            self.addressTableView.reloadData()
        } else {
            let baseUrl = "http://www.juso.go.kr/addrlink/addrLinkApi.do"
            let param: [String : Any] = [
                "confmKey": self.roadAddrKey,
                "currentPage": "1",
                "countPerPage": "10",
                "keyword": addrKeyword,
                "resultType": "json"
            ]
            
            AF.request(baseUrl, method: .get, parameters: param).responseJSON { (response) in
                switch response.result {
                case .success(let JSONObj):
                    self.setSearchedAddresses(JSONObj: JSONObj)
                case .failure(let e):
                    print("AF", e.localizedDescription)
                }
            }
        }
    }
    
    func requestOverlay(addr: String) {
        let url = "https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode"
        let header:HTTPHeaders = [
            "X-NCP-APIGW-API-KEY-ID":self.naverGeocodingKeyId,
            "X-NCP-APIGW-API-KEY":self.naverGeocodingKeyPass
        ]
        let pram = ["query": addr]
        
        AF.request(url, method: .get, parameters: pram, headers: header).responseJSON { (response) in
            switch response.result {
            case .success(let JSONobj):
                do {
                    let JSONData = try JSONSerialization.data(withJSONObject: JSONobj, options: .prettyPrinted)
                    let CoordResponseResult = try JSONDecoder().decode(CoordResponse.self, from: JSONData)
                    let lat = CoordResponseResult.addresses[0].y!
                    let lng = CoordResponseResult.addresses[0].x!
                    self.spotInfo["lat"] = lat
                    self.spotInfo["lng"] = lng
                    self.chargerDelegate?.onClickedAddress(spotInfo: self.spotInfo)
                    
                    self.dismiss(animated: false, completion: nil)
                } catch(let e) {
                    print(e.localizedDescription)
                }
            case .failure(let e):
                print(e.localizedDescription)
            }
        }
    }
    
    func showChargerStationInfoDetail() {
        self.addressTableView.rowHeight = 70
        self.addressTableView.reloadData()
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var addressTableView: UITableView!
    @IBOutlet weak var addressSearchBar: UISearchBar!
    
    // MARK: - IBActions
    @IBAction func touchUpBackButton(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    // MARK: - Delegates And DataSource
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            if self.searchedAddrs["buildingAddrs"]!.count > 0 {
//                return "빌딩"
            }
        } else if section == 1 {
            if self.searchedAddrs["roadAddrs"]!.count > 0 {
                return "  "
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.searchedAddrs["buildingAddrs"]!.count
        } else  if section == 1 {
            return self.searchedAddrs["roadAddrs"]!.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.addressTableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)
        if indexPath.section == 0 {
            let address = self.searchedAddrs["buildingAddrs"]![indexPath.row]
            cell.textLabel?.text = address.bdNm
            if !self.searched {
                cell.detailTextLabel?.text = ""
            } else {
                cell.detailTextLabel?.text = address.roadAddrPart1
            }
        } else if indexPath.section == 1 {
            let address = self.searchedAddrs["roadAddrs"]![indexPath.row]
            cell.textLabel?.text = address.roadAddrPart1
            cell.detailTextLabel?.text = ""
        }
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.addressTableView.rowHeight = 45
        self.addressSearchBar.becomeFirstResponder()
        
        self.searched = false
        
        self.addressTableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(!searchText.trimmingCharacters(in: .whitespaces).isEmpty || searchText == "") {
            self.requestAddress(addrKeyword: searchText)
        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.searched = true
        
        self.showChargerStationInfoDetail()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            let addr = self.searchedAddrs["buildingAddrs"]![indexPath.row]
            self.spotInfo["name"] = addr.bdNm
            self.requestOverlay(addr: addr.roadAddrPart1!)
        } else if indexPath.section == 1 {
            let addr = self.searchedAddrs["roadAddrs"]![indexPath.row]
            self.spotInfo["name"] = addr.roadAddrPart1
            self.requestOverlay(addr: addr.roadAddrPart1!)
        }
    }
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addressSearchBar.delegate = self
        self.addressTableView.rowHeight = 45
        self.addressSearchBar.becomeFirstResponder()
    }
}
