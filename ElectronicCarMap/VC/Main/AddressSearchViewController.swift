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
    var chargerDelegate: chargerStationDelegate?
    let roadAddrKey = "devU01TX0FVVEgyMDIwMTEwNDIxMjkyNzExMDM3MTQ="
    let keyId = "iaf1r9n5ki"
    let keyPass = "Sef6plir6Dz1baxmF2lbyTqtsorc2gQpup9FT3kc"
    let cellIdentifier = "addressCell"
    let addressSearchCilentId = "gUJ5HvMoYGrUx1pznTyd"
    let addressSearchClientSecret = "O7fz4Y_E8p"
    let baseUrl = "https://openapi.naver.com/v1/search/local.json"
    var searchedAddrs: [Juso] = []
    var coord: [String: String]?
    var spotInfo: [String:String] = [:]
    
    // MARK: - Methods
    func setSearchedAddresses(JSONObj: Any) {
        do {
            guard let jsonFormatedResponse = JSONObj as? NSDictionary, let results = jsonFormatedResponse["results"] as? NSDictionary, let addrs = results["juso"] else {
                return }
            let dataJSON = try JSONSerialization.data(withJSONObject: addrs, options: .prettyPrinted)
            let addrsResult = try JSONDecoder().decode([Juso].self, from: dataJSON)
            self.searchedAddrs = addrsResult
            
            self.addressTableView.reloadData()
        } catch(let e) {
            print(e.localizedDescription)
        }
    }
    
    func requestAddress(addrKeyword: String) {
        if addrKeyword.count < 2 {
            self.searchedAddrs = []
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
            "X-NCP-APIGW-API-KEY-ID":self.keyId,
            "X-NCP-APIGW-API-KEY":self.keyPass
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
    
    // MARK: - IBOutlets
    @IBOutlet weak var addressTableView: UITableView!
    @IBOutlet weak var addressSearchBar: UISearchBar!
    
    // MARK: - IBActions
    
    // MARK: - Delegates And DataSource
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchedAddrs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.addressTableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)
        let address = self.searchedAddrs[indexPath.row]
        cell.textLabel?.text = address.bdNm
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.requestAddress(addrKeyword: searchText)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let addr = self.searchedAddrs[indexPath.row]
        self.spotInfo["name"] = addr.bdNm
        self.requestOverlay(addr: self.searchedAddrs[indexPath.row].roadAddrPart1!)
    }
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addressSearchBar.delegate = self
        self.addressSearchBar.becomeFirstResponder()
    }
}
