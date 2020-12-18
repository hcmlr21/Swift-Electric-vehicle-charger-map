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

let bookMarkNotificationName = "bookMarkNotification"
let completeReservationAndGoReservationDetailNotificationName = "completeReservationAndGoReservationDetailNotification"
let completeReservationAndGoMainViewNotificationName = "completeReservationAndGoMainViewNotification"

class MainMapViewController: UIViewController, CLLocationManagerDelegate, chargerStationDelegate {
    // MARK: - ProPerties
    var currentAreaChargerStations: [ChargerStationModel] = []
    var currentAreaChargerStationsMarkers: [NMFMarker] = []
    var chargerStation: ChargerStationModel?
    var selectedChargerStation: ChargerStationModel?
    var searchedChargerStationMarker: NMFMarker = NMFMarker()
    let locationManager = CLLocationManager()
    var hiddenViewLayouts: [NSLayoutConstraint] = []
    var shownViewLayouts: [NSLayoutConstraint] = []
    var removeViewLayouts: [NSLayoutConstraint] = []
    var makeViewLayouts: [NSLayoutConstraint] = []
    let baseUrl = "http://34.123.73.237:10010/chargerStation"
    let databaseRef = Database.database().reference()
    let myUid = Auth.auth().currentUser?.uid
    
    // MARK: - Methods
    func setBookMarkNotiObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.onClickedBookMarkChargerStation), name: Notification.Name(bookMarkNotificationName), object: nil)
    }
    
    func setReservationCompleteNotiObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(onClickedCompleteReservationAndGoReservationDetailButton), name: NSNotification.Name(completeReservationAndGoReservationDetailNotificationName), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onClickedReservationCompleteButton), name: NSNotification.Name(completeReservationAndGoMainViewNotificationName), object: nil)
    }
    
    func resetMap() {
        self.searchedChargerStationMarker.captionText = ""
        self.searchedChargerStationMarker.mapView = nil
        for marker in self.currentAreaChargerStationsMarkers {
            marker.mapView = nil
        }
        self.removeChargerInfoView()
        self.setChargerStationName(name: "")
    }
    
    func setInfoViewLayout() {
        let removeViewLayout = self.naverMapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        self.removeViewLayouts.append(removeViewLayout)
        
        let hiddenViewLayout = self.naverMapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        let hiddenViewLayout2 = self.chargerStationInfoView.heightAnchor.constraint(equalToConstant: self.infoCloseButton.frame.height)
        
        self.hiddenViewLayouts.append(hiddenViewLayout)
        self.hiddenViewLayouts.append(hiddenViewLayout2)
        
        let makeViewLayout = self.naverMapView.bottomAnchor.constraint(equalTo: self.chargerStationInfoView.topAnchor, constant: 30)
        self.makeViewLayouts.append(makeViewLayout)
        
        let shownViewLayout = self.naverMapView.bottomAnchor.constraint(equalTo: self.chargerStationInfoView.topAnchor, constant: 30)
        let shownViewLayout2 = self.chargerStationInfoView.heightAnchor.constraint(equalToConstant: self.chargerStationInfoView.frame.height)
        self.shownViewLayouts.append(shownViewLayout)
        self.shownViewLayouts.append(shownViewLayout2)
    }

    func makeMap() {
        let naverMapView = self.naverMapView!
        
        naverMapView.showCompass = true
        naverMapView.showLocationButton = true
        naverMapView.showZoomControls = true
        naverMapView.showScaleBar = true
        
        let mapView = naverMapView.mapView
        
        let coord = locationManager.location?.coordinate
//        let dLat = Double(37.565199)
//        let dLng = Double(126.983339)

//        self.setLocation(lat: coord!.latitude, lng: coord!.longitude)
        
        mapView.positionMode = .direction
        
        self.setInfoViewLayout()
        
        self.removeChargerInfoView()
    }
    
    func setMarkerImage(charegrMarker: NMFMarker, imageName: String) {
        charegrMarker.iconImage = NMFOverlayImage(name: imageName)
        charegrMarker.width = NMF_MARKER_IMAGE_GRAY.imageWidth - 7
        charegrMarker.height = NMF_MARKER_IMAGE_GRAY.imageHeight - 8
    }
    
    func setLocationMarker(chargerStation: ChargerStationModel, marker: NMFMarker) {
        let mapView = self.naverMapView.mapView
        
        marker.captionText = chargerStation.statName
        if chargerStation.availableChargerCount > 0 {
            self.setMarkerImage(charegrMarker: marker, imageName: "electronicMarker")
        } else {
            self.setMarkerImage(charegrMarker: marker, imageName: "unableElectronicMarker")
        }
        
        //마커의 위치 설정
        marker.position = NMGLatLng(lat: chargerStation.lat, lng: chargerStation.lng)
        marker.mapView = mapView
        
        marker.touchHandler = { (overlay) -> Bool in
            if(self.chargerStationDetailView.isHidden || self.selectedChargerStation?.statId != chargerStation.statId) {
                self.selectedChargerStation = chargerStation
                
                self.requestChargerStaionDetail(chargerStationId: chargerStation.statId) {
                    self.setLocation(lat: (10001
                                            * self.selectedChargerStation!.lat) / 10000, lng: self.selectedChargerStation!.lng)
                    self.makeChargerInfoView(chargerStation: self.selectedChargerStation!)
                    self.showChargerInfoView()
                }
            } else {
                self.hideChargerInfoView()
            }
            
            return true
        }
    }
    
    func setLocation(lat: Double, lng: Double) {
        //맵의 위치 설정
        let mapView = self.naverMapView.mapView
        
        mapView.latitude = lat
        mapView.longitude = lng
    }
    
    
    @objc func tapView() {
        self.view.endEditing(true)
    }
    
    func requestUserLocationAllow() {
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
    }
    
    func setChargerInfoView(chargerStation: ChargerStationModel) {
        self.databaseRef.child("users").child(self.myUid!).child("bookMark").observe(.value) { (dataSnapShot) in
            var check = false
            for item in dataSnapShot.children.allObjects as! [DataSnapshot] {
                let statId = item.key
                if statId == chargerStation.statId {
                    check = true
                    break
                }
            }
            
            if check {
                self.statBookMarkButton.imageView?.image = UIImage(named: "star")
            } else {
                self.statBookMarkButton.imageView?.image = UIImage(named: "emptyStar")
            }
        }
        
        self.statNameLabel.text = chargerStation.statName
        self.statAddressLabel.text = chargerStation.address
        if chargerStation.useTime == "" {
            self.statUseTimeLabel.text = "제공되지 않음"
        } else {
            self.statUseTimeLabel.text = chargerStation.useTime
        }
        
        if chargerStation.availableChargerCount > 0 {
            self.statStatusLabel.text = "충전가능"
            self.chargerAvailableImageView.image = UIImage(named: "electronicMarker")
            self.reservationButton.isEnabled = true
        } else {
            self.statStatusLabel.text = "충전불가능"
            self.chargerAvailableImageView.image = UIImage(named: "unableElectronicMarker")
            self.reservationButton.isEnabled = false
        }
    }
    
    func makeChargerInfoView(chargerStation: ChargerStationModel) {
        self.setChargerInfoView(chargerStation: chargerStation)
        self.chargerStationInfoView.isHidden = false
        self.chargerStationDetailView.isHidden = false
        NSLayoutConstraint.deactivate(self.hiddenViewLayouts)
        NSLayoutConstraint.deactivate(self.removeViewLayouts)
        NSLayoutConstraint.deactivate(self.shownViewLayouts)
        NSLayoutConstraint.activate(self.makeViewLayouts)
    }
    
    func showChargerInfoView() {
        self.chargerStationDetailView.isHidden = false
        NSLayoutConstraint.deactivate(self.hiddenViewLayouts)
        NSLayoutConstraint.deactivate(self.removeViewLayouts)
        NSLayoutConstraint.activate(self.shownViewLayouts)
        NSLayoutConstraint.deactivate(self.makeViewLayouts)
    }

    func hideChargerInfoView() {
        self.chargerStationDetailView.isHidden = true
        NSLayoutConstraint.activate(self.hiddenViewLayouts)
        NSLayoutConstraint.deactivate(self.removeViewLayouts)
        NSLayoutConstraint.deactivate(self.shownViewLayouts)
        NSLayoutConstraint.deactivate(self.makeViewLayouts)
    }
    
    func removeChargerInfoView() {
        self.chargerStationInfoView.isHidden = true
        NSLayoutConstraint.deactivate(self.hiddenViewLayouts)
        NSLayoutConstraint.activate(self.removeViewLayouts)
        NSLayoutConstraint.deactivate(self.shownViewLayouts)
        NSLayoutConstraint.deactivate(self.makeViewLayouts)
    }
    
    func setChargerStationName(name: String) {
        if name == "" {
            self.searchBarButton.setTitleColor(#colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1), for: .normal)
            self.searchBarButton.setTitle("      충전소 검색", for: .normal)
        } else {
            self.searchBarButton.setTitleColor(.black, for: .normal)
            self.searchBarButton.setTitle("      " + name, for: .normal)
        }
    }
    
    func setChargerStation(JSONObj: Any, completeion: (() -> Void)?)  {
        do{
            guard let jsonFormatedResponse = JSONObj as? NSDictionary, let chargerStationObj = jsonFormatedResponse["chargerStation"] else  { return }
            //JSONObject를 JSONData로 바꿔주는 작업
            let dataJSON = try JSONSerialization.data(withJSONObject: chargerStationObj, options: .prettyPrinted)
            let chargerStation = try JSONDecoder().decode(ChargerStationModel.self, from: dataJSON)
            self.selectedChargerStation = chargerStation
            
            completeion?()
        } catch{
            print(error.localizedDescription)
        }
    }
    
    func requestChargerStaionDetail(chargerStationId: String, completion: (() -> Void)?) {
        let url = self.baseUrl + "/" + chargerStationId
        AF.request(url, method: .get).responseJSON { (response) in
            switch response.result {
            case .success(let obj):
                self.setChargerStation(JSONObj: obj) {
                    completion?()
                }
            case .failure(let e):
                print(e)
            }
        }
    }
    
    func getCurrentAreaChargerStations(minLat: Double, maxLat: Double, minLng: Double, maxLng: Double) {
        let url = self.baseUrl;
        let param = [
            "minLat": minLat,
            "maxLat": maxLat,
            "minLng": minLng,
            "maxLng": maxLng
        ]
    
        AF.request(url, parameters: param).responseJSON { (response) in
            switch response.result {
            case .success(let JSONObj):
                do {
                    guard let jsonFormatedResponse = JSONObj as? NSDictionary, let chargerstations = jsonFormatedResponse["chargerStations"] else  { return }
                    
                    let dataJSON = try JSONSerialization.data(withJSONObject: chargerstations, options: .prettyPrinted)
                    let chargerStationsResult = try JSONDecoder().decode([ChargerStationModel].self, from: dataJSON)
                    
                    self.currentAreaChargerStations = chargerStationsResult
                    self.setOverlays()
                } catch(let e) {
                    print(e.localizedDescription)
                }
                
            case .failure(let e):
                print(e.localizedDescription);
            }
        }
    }
    
    func setOverlays() {
        for chargerStation in self.currentAreaChargerStations {
            let marker = NMFMarker()
            self.currentAreaChargerStationsMarkers.append(marker)
            DispatchQueue.main.async {
                self.setLocationMarker(chargerStation: chargerStation, marker: marker)
            }
        }
    }
    
    func checkReservation(completion: @escaping () -> Void) {
        self.databaseRef.child("users").child(self.myUid!).child("reservation").observeSingleEvent(of: .value) { (dataSnapShot) in
            let reservationModel = ReservationModel()
            for item in dataSnapShot.children.allObjects as! [DataSnapshot] {
                reservationModel.setValue(item.value, forKey: item.key)
            }
            
            if reservationModel.reserved == "true" {
                let alert = UIAlertController(title: "", message: "예약내역이 존재합니다.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            } else {
                completion()
            }
        }
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var searchBarButton: UIButton!
    @IBOutlet weak var naverMapView: NMFNaverMapView!
    @IBOutlet weak var chargerStationInfoView: UIView!
    //infoView
    @IBOutlet weak var statNameLabel: UILabel!
    @IBOutlet weak var statBookMarkButton: UIButton!
    @IBOutlet weak var statAddressLabel: UILabel!
    @IBOutlet weak var statStatusLabel: UILabel!
    @IBOutlet weak var chargerAvailableImageView: UIImageView!
    @IBOutlet weak var statUseTimeLabel: UILabel!
    @IBOutlet weak var reservationButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var destinationButton: UIButton!
    @IBOutlet weak var infoCloseButton: UIButton!
    @IBOutlet weak var chargerStationDetailView: UIView!
    
    
    // MARK: - IBActions
    @IBAction func touchUpSearchBarButton(_ sender: UIButton) {
        let chargerSearchVC = self.storyboard?.instantiateViewController(identifier: "chargerSearchViewController") as! ChargerSearchViewController
        
        chargerSearchVC.modalPresentationStyle = .fullScreen
        chargerSearchVC.chargerDelegate = self
        
        present(chargerSearchVC, animated: false, completion: nil)
    }
    
    @IBAction func touchUpCloseInfoView(_ sender: UIButton) {
        if !self.chargerStationDetailView.isHidden {
            self.hideChargerInfoView()
        } else {
            self.showChargerInfoView()
        }
    }
    
    @IBAction func touchUpDirectionButton(_ sender: UIButton) {
        let pathFinderVC = self.storyboard?.instantiateViewController(identifier: "pathFinderViewController") as! PathFinderViewController
        pathFinderVC.modalPresentationStyle = .fullScreen
        
        let chargerStationInfo = [
            "name": self.selectedChargerStation!.statName,
            "lat": String(self.selectedChargerStation!.lat),
            "lng": String(self.selectedChargerStation!.lng)
        ]
        
        if sender == self.startButton {
            pathFinderVC.startInfo = chargerStationInfo
        } else {
            pathFinderVC.destinationInfo = chargerStationInfo
        }
        
        present(pathFinderVC, animated: false, completion: nil)
    }
    
    @IBAction func touchUpReservationButton(_ sender: UIButton) {
        self.checkReservation {
            let makingRservationVC = self.storyboard?.instantiateViewController(identifier: "makingReservationViewController") as! MakingReservationViewController
            
            makingRservationVC.modalPresentationStyle = .fullScreen
            makingRservationVC.chargerDelegate = self
            makingRservationVC.chargerStation = self.selectedChargerStation
            self.present(makingRservationVC, animated: false, completion: nil)
        }
    }
    
    @IBAction func touchUpBookMarkButton(_ sender: UIButton) {
        self.databaseRef.child("users").child(self.myUid!).child("bookMark").observeSingleEvent(of: .value, with: { (dataSnapShot) in
            var check: Bool = false
            let chargerStation = self.selectedChargerStation
            for item in dataSnapShot.children.allObjects as! [DataSnapshot] {
                let statId = item.key
                if statId == chargerStation?.statId {
                    check = true
                    break
                }
            }
            
            if check {
                self.databaseRef.child("users").child(self.myUid!).child("bookMark").child(chargerStation!.statId).removeValue()
                self.statBookMarkButton.imageView?.image = UIImage(named: "emptyStar")
            } else {
                let value = [chargerStation?.statId:chargerStation?.statName]
                self.databaseRef.child("users").child(self.myUid!).child("bookMark").updateChildValues(value)
                self.statBookMarkButton.imageView?.image = UIImage(named: "star")
            }
        })
    }
    
    @IBAction func touchUpSearchBarResetButton(_ sender: UIButton) {
        self.resetMap()
    }
    
    @objc func onClickedBookMarkChargerStation(notification: NSNotification) {
        if let chargerStationIdDic = notification.object as? NSDictionary {
            if let chargerStationId = chargerStationIdDic["chargerStationId"] as? String {
                self.onClickedChargerStation(chargerStationId: chargerStationId)
            }
        }
    }
    
    @objc func onClickedCompleteReservationAndGoReservationDetailButton(notification: NSNotification) {
        //화면초기화
        self.resetMap()
           
        self.tabBarController?.selectedIndex = 2
    }
    
    @objc func onClickedReservationCompleteButton(notification: NSNotification) {
        //화면초기화
        self.resetMap()
    }
    
    @IBAction func touchUpSearchCurrentBoundsButton(_ sender: UIButton) {
        //표시된 마커 모두 지우기
        self.searchedChargerStationMarker.mapView = nil
        for marker in self.currentAreaChargerStationsMarkers {
            marker.mapView = nil
        }
        self.currentAreaChargerStationsMarkers.removeAll()
        
        let center = self.naverMapView.mapView.coveringBounds.center
        
        let sw = self.naverMapView.mapView.contentBounds.boundsLatLngs[0]
        let ne = self.naverMapView.mapView.contentBounds.boundsLatLngs[1]
        
        var minLat = 0.0
        var maxLat = 0.0
        var minLng = 0.0
        var maxLng = 0.0
        
        if ne.lat - sw.lat < 0.07 {
            let latPortion = (center.lat - sw.lat) / 2.5
            let lngPortion = (center.lng - sw.lng) / 3
            
            minLat = sw.lat + latPortion
            maxLat = ne.lat - latPortion
            
            minLng = sw.lng + lngPortion
            maxLng = ne.lng - lngPortion
        } else {
            minLat = center.lat - 0.025
            maxLat = center.lat + 0.025
            
            minLng = center.lng - 0.015
            maxLng = center.lng + 0.015
        }
        
        self.getCurrentAreaChargerStations(minLat: minLat, maxLat: maxLat, minLng: minLng, maxLng: maxLng)
        
        if let searchedChargerStation = self.chargerStation {
            self.setLocationMarker(chargerStation: searchedChargerStation, marker: self.searchedChargerStationMarker)
        }
    }
    
    // MARK: - Delegates And DataSource
    func onClickedChargerStation(chargerStationId: String) {
        self.requestChargerStaionDetail(chargerStationId: chargerStationId) {
            self.chargerStation = self.selectedChargerStation
            self.setChargerStationName(name: self.chargerStation!.statName)
            self.setLocationMarker(chargerStation: self.chargerStation!, marker: self.searchedChargerStationMarker)
            self.setLocation(lat: self.chargerStation!.lat, lng: self.chargerStation!.lng)
            self.makeChargerInfoView(chargerStation: self.chargerStation!)
        }
    }
    
    func onClickedReservationButton() {
        let reservationCompleteVC = self.storyboard?.instantiateViewController(identifier: "reservationCompleteViewController") as! ReservationCompleteViewController
        reservationCompleteVC.modalPresentationStyle = .fullScreen
        
        self.present(reservationCompleteVC, animated: false, completion: nil)
    }
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.databaseRef.child("users").child(self.myUid!).child("bookMark").observe(.value) { (dataSnapShot) in
            for item in dataSnapShot.children.allObjects as! [DataSnapshot] {
                let statId = item.key
                if statId == self.chargerStation?.statId {
                    self.statBookMarkButton.imageView?.image = UIImage(named: "star")
                    break
                }
            }
        }
        
        self.requestUserLocationAllow()
        
        self.searchBarButton.layer.cornerRadius = self.searchBarButton.frame.height / 4
        
        let tapView = UITapGestureRecognizer(target: self, action: #selector(self.tapView))
        self.view.addGestureRecognizer(tapView)
        
        self.makeMap()
        self.setBookMarkNotiObserver()
        self.setReservationCompleteNotiObserver()
    }
}
