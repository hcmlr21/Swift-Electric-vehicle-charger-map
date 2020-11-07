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
let reservationCompleteNotificationName = "reservationCompleteNotification"

class MainMapViewController: UIViewController, CLLocationManagerDelegate, chargerStationDelegate {
    // MARK: - ProPerties
    var chargerStation: ChargerStationModel?
    var marker: NMFMarker = NMFMarker()
    let keyId = "iaf1r9n5ki"
    let keyPass = "Sef6plir6Dz1baxmF2lbyTqtsorc2gQpup9FT3kc"
    let locationManager = CLLocationManager()
    var hiddenViewLayouts: [NSLayoutConstraint] = []
    var shownViewLayouts: [NSLayoutConstraint] = []
    let baseUrl = "http://34.123.73.237:10010/chargerStation"
    let databaseRef = Database.database().reference()
    let myUid = Auth.auth().currentUser?.uid
    
    // MARK: - Methods
    func setBookMarkNotiObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.onClickedBookMarkChargerStation), name: Notification.Name(bookMarkNotificationName), object: nil)
    }
    
    func setReservationCompleteNotiObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(onClickedReservationCompleteButton), name: NSNotification.Name(reservationCompleteNotificationName), object: nil)
    }
    
    func resetMap() {
        self.marker.captionText = ""
        self.marker.mapView = nil
        self.hideChargerInfoView()
        self.setChargerStationName(name: "")
    }

    func makeMap() {
        let naverMapView = self.naverMapView!
        
        naverMapView.showCompass = true
        naverMapView.showLocationButton = true
        naverMapView.showZoomControls = true
        naverMapView.showScaleBar = true
        
        self.setMarkerImage(charegrMarker: self.marker)
        
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
    
    func setMarkerImage(charegrMarker: NMFMarker) {
        charegrMarker.iconImage = NMFOverlayImage(name: "electronicMarker")
        charegrMarker.width = NMF_MARKER_IMAGE_GRAY.imageWidth + 13
        charegrMarker.height = NMF_MARKER_IMAGE_GRAY.imageHeight + 5
    }
    
    func setLocationOverlay() {
        let mapView = self.naverMapView.mapView
        let lat = Double((self.chargerStation?.lat)!)!
        let lng = Double((self.chargerStation?.lng)!)!
        
        self.marker.captionText = self.chargerStation!.statName
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
    
    func setChargerInfoView() {
//        @IBOutlet weak var reservationButton: UIButton!
//        @IBOutlet weak var statButton: UIButton!
//        @IBOutlet weak var destinationButton: UIButton!
//        @IBOutlet weak var infoCloseButton: UIButton!
        
        
        self.databaseRef.child("users").child(self.myUid!).child("bookMark").observe(.value) { (dataSnapShot) in
            var check = false
            for item in dataSnapShot.children.allObjects as! [DataSnapshot] {
                let statId = item.key
                if statId == self.chargerStation?.statId {
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
        
        self.statNameLabel.text = self.chargerStation?.statName
        self.statAddressLabel.text = self.chargerStation?.address
        self.statUseTimeLabel.text = self.chargerStation?.useTime
        if self.chargerStation!.availableChargerCount > 0 {
            self.statStatusLabel.text = "충전가능"
            self.chargerAvailableImageView.image = UIImage(named: "electronicMarker")
        } else {
            self.statStatusLabel.text = "충전불가능"
            self.chargerAvailableImageView.image = UIImage(named: "unableElectronicMarker")
        }
        
//        self.statUseTimeLabel
    }
    
    func showChargerInfoView() {
        self.setChargerInfoView()
        self.chargerInfoView.isHidden = false
        NSLayoutConstraint.deactivate(self.hiddenViewLayouts)
        NSLayoutConstraint.activate(self.shownViewLayouts)
    }

    func hideChargerInfoView() {
        self.chargerInfoView.isHidden = true
        NSLayoutConstraint.deactivate(self.shownViewLayouts)
        NSLayoutConstraint.activate(self.hiddenViewLayouts)
    }
    
    func setChargerStationName(name: String) {
        if name == "" {
            self.searchBarButton.setTitleColor(#colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1), for: .normal)
            self.searchBarButton.setTitle("  충전소 검색", for: .normal)
        } else {
            self.searchBarButton.setTitleColor(.black, for: .normal)
            self.searchBarButton.setTitle("  " + name, for: .normal)
        }
    }
    
    func setChargerStation(JSONObj: Any) {
        do{
            guard let jsonFormatedResponse = JSONObj as? NSDictionary, let chargerStationObj = jsonFormatedResponse["chargerStation"] else  { return }
            //JSONObject를 JSONData로 바꿔주는 작업
            let dataJSON = try JSONSerialization.data(withJSONObject: chargerStationObj, options: .prettyPrinted)
            let chargerStation = try JSONDecoder().decode(ChargerStationModel.self, from: dataJSON)
            self.chargerStation = chargerStation
            self.setChargerStationName(name: chargerStation.statName)
            self.showChargerInfoView()
            self.setLocationOverlay()
        } catch{
            print(error.localizedDescription)
        }
    }
    
    func requestChargerStaionDetail(chargerStationId: String) {
        let url = self.baseUrl + "/" + chargerStationId
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
    @IBOutlet weak var statBookMarkButton: UIButton!
    @IBOutlet weak var statAddressLabel: UILabel!
    @IBOutlet weak var statStatusLabel: UILabel!
    @IBOutlet weak var chargerAvailableImageView: UIImageView!
    @IBOutlet weak var statUseTimeLabel: UILabel!
    @IBOutlet weak var reservationButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var destinationButton: UIButton!
    @IBOutlet weak var infoCloseButton: UIButton!
    
    
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
    
    @IBAction func touchUpDirectionButton(_ sender: UIButton) {
        let pathFinderVC = self.storyboard?.instantiateViewController(identifier: "pathFinderViewController") as! PathFinderViewController
        pathFinderVC.modalPresentationStyle = .fullScreen
        
        let chargerStationInfo = [
            "name": self.chargerStation!.statName,
            "lat": self.chargerStation!.lat!,
            "lng": self.chargerStation!.lng!
        ]
        
        if sender == self.startButton {
            pathFinderVC.startInfo = chargerStationInfo
        } else {
            pathFinderVC.destinationInfo = chargerStationInfo
        }
        
        present(pathFinderVC, animated: false, completion: nil)
        
    }
    
    @IBAction func touchUpReservationButton(_ sender: UIButton) {
        let makingRservationVC = self.storyboard?.instantiateViewController(identifier: "makingReservationViewController") as! MakingReservationViewController
        
        makingRservationVC.modalPresentationStyle = .fullScreen
        makingRservationVC.chargerDelegate = self
        if let chargerStation = self.chargerStation {
            makingRservationVC.chargerStation = chargerStation
            present(makingRservationVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func touchUpBookMarkButton(_ sender: UIButton) {
        self.databaseRef.child("users").child(self.myUid!).child("bookMark").observeSingleEvent(of: .value, with: { (dataSnapShot) in
            var check: Bool = false
            for item in dataSnapShot.children.allObjects as! [DataSnapshot] {
                let statId = item.key
                if statId == self.chargerStation?.statId {
                    check = true
                    break
                }
            }
            
            if check {
                self.databaseRef.child("users").child(self.myUid!).child("bookMark").child(self.chargerStation!.statId).removeValue()
                self.statBookMarkButton.imageView?.image = UIImage(named: "emptyStar")
            } else {
                let value = [self.chargerStation?.statId:self.chargerStation?.statName]
                self.databaseRef.child("users").child(self.myUid!).child("bookMark").updateChildValues(value)
                self.statBookMarkButton.imageView?.image = UIImage(named: "star")
            }
        })
    }
    
    @objc func onClickedBookMarkChargerStation(notification: NSNotification) {
        if let chargerStationIdDic = notification.object as? NSDictionary {
            if let chargerStationId = chargerStationIdDic["chargerStationId"] as? String {
                self.onClickedChargerStation(chargerStationId: chargerStationId)
            }
        }
    }
    
    @objc func onClickedReservationCompleteButton(notification: NSNotification) {
        //화면초기화
        self.resetMap()
        
        
        self.tabBarController?.selectedIndex = 2
    }
    
    // MARK: - Delegates And DataSource
    func onClickedChargerStation(chargerStationId: String) {
        self.requestChargerStaionDetail(chargerStationId: chargerStationId)
//        self.setLocationOverlay(lat: Double(chargerStation.lat)!, lng: Double(chargerStation.lng)!)
        
//        self.setLocationOverlay(lat: 35.512571, lng: 129.422104)
    }
    
    func onClickedReservationButton() {
        let reservationCompleteVC = self.storyboard?.instantiateViewController(identifier: "reservationCompleteViewController") as! ReservationCompleteViewController
        reservationCompleteVC.modalPresentationStyle = .fullScreen
        
        self.present(reservationCompleteVC, animated: false, completion: nil)
    }
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.chargerInfoView.isHidden = true
//        self.naverMapView.translatesAutoresizingMaskIntoConstraints = false
        
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
