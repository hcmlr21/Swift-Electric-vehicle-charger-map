//
//  MainMapViewController.swift
//  ElectronicCarMap
//
//  Created by Jkookoo on 2020/10/25.
//  Copyright © 2020 Jkookoo. All rights reserved.
//

import UIKit
import Alamofire
import NMapsMap
import Firebase

class MainMapViewController: UIViewController, CLLocationManagerDelegate, searchPlaceDelegate {
    // MARK: - ProPerties
    var chargerStation: ChargerStationModel?
    var marker: NMFMarker = NMFMarker()
    let keyId = "iaf1r9n5ki"
    let keyPass = "Sef6plir6Dz1baxmF2lbyTqtsorc2gQpup9FT3kc"
    let locationManager = CLLocationManager()
    var hiddenViewLayouts: [NSLayoutConstraint] = []
    var shownViewLayouts: [NSLayoutConstraint] = []
    var baseUrl = "http://34.123.73.237:10010/chargerStation"
    let databaseRef = Database.database().reference()
    let myUid = Auth.auth().currentUser?.uid
    
    // MARK: - Methods
    func makeMap() {
//        let infoWindow = NMFInfoWindow()
//        let dataSource = NMFInfoWindowDefaultTextSource.data()
//        dataSource.title = "정보 창 내용"
//        infoWindow.dataSource = dataSource
        
        let naverMapView = self.naverMapView!
        
        naverMapView.showCompass = true
        naverMapView.showLocationButton = true
        naverMapView.showZoomControls = true
        
        let mapView = naverMapView.mapView
//        let currentLocation = mapView.locationOverlay.location
        
        //지도의 위치 -> 현재위치로 바꿔주기
        let dLat = Double(37.565199)
        let dLng = Double(126.983339)
        mapView.latitude = dLat
        mapView.longitude = dLng
        
        mapView.positionMode = .direction
        
        //auto layout
        let hiddenViewLayout = self.naverMapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        self.hiddenViewLayouts.append(hiddenViewLayout)
        
        let shownViewLayout = self.naverMapView.bottomAnchor.constraint(equalTo: self.chargerInfoView.topAnchor, constant: 30)
        self.shownViewLayouts.append(shownViewLayout)
        
        self.hideChargerInfoView()
    }
    
    func setLocationOverlay() {
        let mapView = self.naverMapView.mapView
        let lat = Double((self.chargerStation?.lat)!)!
        let lng = Double((self.chargerStation?.lng)!)!
        //마커의 위치 설정
        self.marker.position = NMGLatLng(lat: lat, lng: lng)
        self.marker.mapView = mapView
        //맵의 위치 설정
        mapView.latitude = lat
        mapView.longitude = lng
        self.marker.touchHandler = { (overlay) -> Bool in
            if(self.chargerInfoView.isHidden) {
                self.showChargerInfoView()
            } else {
                self.hideChargerInfoView()
            }
            
            return true
        }
    }
    
    @objc func tapView() {
        self.view.endEditing(true)
    }
    
    func requestUserLocationAllow() {
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.delegate = self
    }
    
    func hideChargerInfoView() {
        self.chargerInfoView.isHidden = true
        NSLayoutConstraint.deactivate(self.shownViewLayouts)
        NSLayoutConstraint.activate(self.hiddenViewLayouts)
    }
    
    func setChargerInfoView() {
//        @IBOutlet weak var statNameLabel: UILabel!
//        @IBOutlet weak var statAddressLabel: UILabel!
//        @IBOutlet weak var statStatusLabel: UILabel!
//        @IBOutlet weak var statUseTimeLabel: UILabel!
//        @IBOutlet weak var reservationButton: UIButton!
//        @IBOutlet weak var statButton: UIButton!
//        @IBOutlet weak var destinationButton: UIButton!
//        @IBOutlet weak var infoCloseButton: UIButton!
        
        
        self.databaseRef.child("users").child(self.myUid!).child("favorite").observe(.value) { (dataSnapShot) in
            var check = false
            for item in dataSnapShot.children.allObjects as! [DataSnapshot] {
                let statId = item.key
                if statId == self.chargerStation?.statId {
                    check = true
                    break
                }
            }
            
            if check {
                self.statFavoriteButton.imageView?.image = UIImage(named: "star")
            } else {
                self.statFavoriteButton.imageView?.image = UIImage(named: "emptyStar")
            }
        }
        
        self.statNameLabel.text = self.chargerStation?.statName
        self.statAddressLabel.text = self.chargerStation?.address
//        self.statStatusLabel.text = self.chargerStation.
//        self.statUseTimeLabel
    }
    
    func showChargerInfoView() {
        self.setChargerInfoView()
        self.chargerInfoView.isHidden = false
        NSLayoutConstraint.deactivate(self.hiddenViewLayouts)
        NSLayoutConstraint.activate(self.shownViewLayouts)
    }
    
    func setChargerStation(JSONObj: Any) {
        do{
            guard let jsonFormatedResponse = JSONObj as? NSDictionary, let chargerstation = jsonFormatedResponse["chargerStation"] else  { return }
            //JSONObject를 JSONData로 바꿔주는 작업
            let dataJSON = try JSONSerialization.data(withJSONObject: chargerstation, options: .prettyPrinted)
            let chargerStation = try JSONDecoder().decode(ChargerStationModel.self, from: dataJSON)
            self.chargerStation = chargerStation
            self.showChargerInfoView()
            self.setLocationOverlay()
        } catch{
            print(error.localizedDescription)
        }
    }
    
    func requestChargerStaionDetail(chargerStation: ChargerStationModel) {
        let url = self.baseUrl + "/" + chargerStation.statId
        AF.request(url, method: .get).responseJSON { (response) in
            switch response.result {
            case .success(let obj):
                self.setChargerStation(JSONObj: obj)
            case .failure(let e):
                print(e)
            }
        }
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var searchBarButton: UIButton!
    @IBOutlet weak var naverMapView: NMFNaverMapView!
    @IBOutlet weak var chargerInfoView: UIView!
    //infoView
    @IBOutlet weak var statNameLabel: UILabel!
    @IBOutlet weak var statAddressLabel: UILabel!
    @IBOutlet weak var statStatusLabel: UILabel!
    @IBOutlet weak var statUseTimeLabel: UILabel!
    @IBOutlet weak var reservationButton: UIButton!
    @IBOutlet weak var statButton: UIButton!
    @IBOutlet weak var destinationButton: UIButton!
    @IBOutlet weak var infoCloseButton: UIButton!
    @IBOutlet weak var statFavoriteButton: UIButton!
    
    // MARK: - IBActions
    @IBAction func touchUpSearchBarButton(_ sender: UIButton) {
        let chargerSearchVC = self.storyboard?.instantiateViewController(identifier: "chargerSearchViewController") as! ChargerSearchViewController
        
        chargerSearchVC.modalPresentationStyle = .fullScreen
        chargerSearchVC.chargerDelegate = self
        
        present(chargerSearchVC, animated: false, completion: nil)
    }
    
    @IBAction func touchUpCloseInfoView(_ sender: UIButton) {
        self.hideChargerInfoView()
    }
    
    @IBAction func touchUpReservationButton(_ sender: UIButton) {
        let makingRservationVC = self.storyboard?.instantiateViewController(identifier: "makingReservationViewController") as! MakingReservationViewController
        
        makingRservationVC.modalPresentationStyle = .fullScreen
        if let chargerStation = self.chargerStation {
            makingRservationVC.chargerStation = chargerStation
            present(makingRservationVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func touchUpFavoriteButton(_ sender: UIButton) {
        self.databaseRef.child("users").child(self.myUid!).child("favorite").observeSingleEvent(of: .value, with: { (dataSnapShot) in
            var check: Bool = false
            for item in dataSnapShot.children.allObjects as! [DataSnapshot] {
                let statId = item.key
                if statId == self.chargerStation?.statId {
                    check = true
                    break
                }
            }
            
            if check {
                self.databaseRef.child("users").child(self.myUid!).child("favorite").child(self.chargerStation!.statId).removeValue()
                self.statFavoriteButton.imageView?.image = UIImage(named: "emptyStar")
            } else {
                let value = [self.chargerStation?.statId:self.chargerStation?.statName]
                self.databaseRef.child("users").child(self.myUid!).child("favorite").updateChildValues(value)
                self.statFavoriteButton.imageView?.image = UIImage(named: "star")
            }
        })
    }
    
    
    
    // MARK: - Delegates And DataSource
    func onClikedChargerStation(chargerStation: ChargerStationModel) {
        self.requestChargerStaionDetail(chargerStation: chargerStation)
//        self.setLocationOverlay(lat: Double(chargerStation.lat)!, lng: Double(chargerStation.lng)!)
        
//        self.setLocationOverlay(lat: 35.512571, lng: 129.422104)
        
    }

    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.chargerInfoView.isHidden = true
//        self.naverMapView.translatesAutoresizingMaskIntoConstraints = false
        
        self.databaseRef.child("users").child(self.myUid!).child("favorite").observe(.value) { (dataSnapShot) in
            for item in dataSnapShot.children.allObjects as! [DataSnapshot] {
                let statId = item.key
                if statId == self.chargerStation?.statId {
                    self.statFavoriteButton.imageView?.image = UIImage(named: "star")
                    break
                }
            }
        }
        
        self.requestUserLocationAllow()
        
        self.searchBarButton.layer.cornerRadius = self.searchBarButton.frame.height / 4
        
        let tapView = UITapGestureRecognizer(target: self, action: #selector(self.tapView))
        self.view.addGestureRecognizer(tapView)
        
        self.makeMap()
    }
}
