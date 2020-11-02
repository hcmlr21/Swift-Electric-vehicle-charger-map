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
    let cellIdentifier = "addressCell"
    let addresses: [String] = []
    let addressSearchCilentId = "gUJ5HvMoYGrUx1pznTyd"
    let addressSearchClientSecret = "O7fz4Y_E8p"
    let baseUrl = "https://openapi.naver.com/v1/search/local.json"
    
    // MARK: - Methods
    func naverSearchPlace(searchName: String) {
        let header: HTTPHeaders = ["X-Naver-Client-Id": self.addressSearchCilentId, "X-Naver-Client-Secret": self.addressSearchClientSecret]
        
        let coordinate: String = "35.512571" + "," + "129.422104" // 현재 지도 중심의 좌표 // 한글도 검색될 수 있도록 URL Encoding
        let encodedSearchName = searchName.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        AF.request("https://naveropenapi.apigw.ntruss.com/map-place/v1/search?query=" + encodedSearchName! + "&coordinate=" + coordinate, method: .get, encoding: URLEncoding.default, headers: header).validate(statusCode: 200..<300).responseJSON { (response) -> Void in
            
//            if response.result {
//                var swiftyJsonVar = JSON(response.result.value!)
//                print(swiftyJsonVar)
//                let searchResultCount = swiftyJsonVar["meta"]["count"].int! // 최대 5개까지 검색함.
//                let searchResult = swiftyJsonVar["places"]
//                for i in 0 ... searchResultCount-1 {
//                    self.searchedPlaces.append(searchResult[i]["name"].string!)
//                    self.searchedLatitude.append(Double(searchResult[i]["y"].string!)!)
//                    self.searchedLongitude.append(Double(searchResult[i]["x"].string!)!)
//                }
//
//            } else {
//
//            }
        }
    }
    
    
    
    func requestAddress() {
        let url = self.baseUrl
        let header: HTTPHeaders = ["X-Naver-Client-Id": self.addressSearchCilentId, "X-Naver-Client-Secret": self.addressSearchClientSecret]
        
        let pram = ["query": "구의"]
//        AF.request(<#T##convertible: URLConvertible##URLConvertible#>, method: <#T##HTTPMethod#>, parameters: <#T##Parameters?#>, encoding: <#T##ParameterEncoding#>, headers: <#T##HTTPHeaders?#>, interceptor: <#T##RequestInterceptor?#>, requestModifier: <#T##Session.RequestModifier?##Session.RequestModifier?##(inout URLRequest) throws -> Void#>)
        
        
        AF.request(url, method: .get, parameters: pram, headers: header).responseJSON { (response) in
            switch response.result {
            case .success(let JSONobj):
            debugPrint(response)
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
        return self.addresses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.addressTableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)
        let address = self.addresses[indexPath.row]
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addressSearchBar.delegate = self
        self.addressSearchBar.becomeFirstResponder()
        
        self.requestAddress()
    }
}
