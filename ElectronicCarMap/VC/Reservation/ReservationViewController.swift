//
//  reservationViewController.swift
//  ElectronicCarMap
//
//  Created by Jkookoo on 2020/10/27.
//  Copyright © 2020 Jkookoo. All rights reserved.
//

import UIKit
import SafariServices
import NMapsMap
import Firebase
import Alamofire
import KakaoSDKNavi

class ReservationViewController: UIViewController {
    // MARK: - ProPerties
    var charger: ChargerStationModel?
    var reservationInfo: ReservationModel?
    let databaseRef = Database.database().reference()
    let myUid = Auth.auth().currentUser?.uid
    let baseUrl = "http://34.123.73.237:10010/charger/"
    let marker = NMFMarker()
    
    // MARK: - Methods
    func checkReservation() {
        self.databaseRef.child("users").child(self.myUid!).child("reservation").observe(.value) { (dataSnapShot) in
            let reservationModel = ReservationModel()
            for item in dataSnapShot.children.allObjects as! [DataSnapshot] {
                reservationModel.setValue(item.value, forKey: item.key)
            }
            self.reservationInfo = reservationModel
            
            if reservationModel.reserved == "true" {
                self.setReservationInfo()
            } else {
                self.noInfoView.isHidden = false
            }
        }
    }
    
    func sendCancelReservationResultToUserInfo() {
        let value = [
            "reserved" : "false",
            "chargerStationName": "",
            "chargerId": "",
            "lat":"",
            "lng":"",
            "addr":""
        ]
        
        self.databaseRef.child("users").child(self.myUid!).child("reservation").updateChildValues(value) { (error, databaseReference) in
            if error == nil {
                //성공
            }
        }
    }
    
    func setReservationInfo() {
        self.noInfoView.isHidden = true
        self.chargerStationNameLabel.text = self.reservationInfo?.chargerStationName
        self.chargerIdLabel.text = self.reservationInfo?.chargerId
        self.addressLabel.text = self.reservationInfo?.addr
        self.setLocationOverlay()
    }
    
    func changeReservationStatus(completion: @escaping () -> Void) {
        let chargerId = self.reservationInfo!.chargerId!
        let url = self.baseUrl + chargerId
        let header: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        let param = [
            "newStatus": "2"
        ]
        
        AF.request(url, method: .patch, parameters: param, encoding: JSONEncoding.default, headers: header).responseJSON { (response) in
            switch response.result {
            case .success:
                completion()
            case .failure(let e):
                print("예약취소실패", e.localizedDescription)
            }
        }
    }
    
    func makeMap() {
        let naverMapView = self.naverMapView!
        naverMapView.showCompass = true
        naverMapView.showLocationButton = false
        naverMapView.showZoomControls = false
        naverMapView.showScaleBar = true
    }
    
    func setLocationOverlay() {
        let mapView = naverMapView.mapView
        
        marker.mapView = nil
        if let lat = self.reservationInfo?.lat, let lng = self.reservationInfo?.lng {
            if let doubleLat = Double(lat), let doubleLng = Double(lng) {
                
                let coord = NMGLatLng(lat: doubleLat, lng: doubleLng)
                mapView.latitude = doubleLat
                mapView.longitude = doubleLng
                marker.position = coord
            }
        }
        
        marker.mapView = mapView
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var naverMapView: NMFNaverMapView!
    @IBOutlet weak var startGuideButton: UIButton!
    @IBOutlet weak var cancelReservationButton: UIButton!
    @IBOutlet weak var noInfoView: UIView!
    @IBOutlet weak var chargerStationNameLabel: UILabel!
    @IBOutlet weak var chargerIdLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    // MARK: - IBActions
    @IBAction func touchUpCancelReservation(_ sender: UIButton) {
        let alert = UIAlertController(title: "예약취소", message: "예약을 취소하시겠습니까?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { (action) in
            self.changeReservationStatus {
                self.sendCancelReservationResultToUserInfo()
            }
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }

    @IBAction func touchUpGuidePathButton(_ sender: UIButton) {
        let destinationName = self.reservationInfo!.chargerStationName!
        let destinationLng = self.reservationInfo!.lng!
        let destinationLat = self.reservationInfo!.lat!
        
        let options = NaviOption(coordType: .WGS84)
        let destination = NaviLocation(name: destinationName, x: destinationLng, y: destinationLat)
        let safariViewController = SFSafariViewController(url: NaviApi.shared.webNavigateUrl(destination: destination, option: options)!)
        safariViewController.modalPresentationStyle = .fullScreen
        self.present(safariViewController, animated: false, completion: nil)
    }
    
    
    // MARK: - Delegates And DataSource
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLabel.layer.cornerRadius = 6
        self.startGuideButton.layer.cornerRadius = 10
        self.cancelReservationButton.layer.cornerRadius = 10
        
        self.makeMap()
        self.checkReservation()
    }
}
