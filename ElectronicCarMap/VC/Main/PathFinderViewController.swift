//
//  PathFinderViewController.swift
//  ElectronicCarMap
//
//  Created by Jkookoo on 2020/10/30.
//  Copyright © 2020 Jkookoo. All rights reserved.
//

import UIKit
import NMapsMap

class PathFinderViewController: UIViewController, chargerStationDelegate {
    // MARK: - ProPerties
    var clickedButton: UIButton?
    var startInfo: [String:String]?
    var destinationInfo: [String:String]?
    
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
        
        //좌표
        let marker = NMFMarker()
//        if let lat = charger?.lat, let lng = charger?.lng {
//            if let doubleLat = Double(lat), let doubleLng = Double(lng) {
//                let coord = NMGLatLng(lat: doubleLat, lng: doubleLng)
//                mapView.latitude = doubleLat
//                mapView.longitude = doubleLng
//                marker.position = coord
//            }
//        }
        
        mapView.positionMode = .direction
//        marker.mapView = mapView
//        infoWindow.open(with: marker)
        
        //auto layout
//        let hiddenViewLayout = self.naverMapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
//        self.hiddenViewLayouts.append(hiddenViewLayout)
        
//        let shownViewLayout = self.naverMapView.bottomAnchor.constraint(equalTo: self.chargerInfoView.topAnchor, constant: 40)
//        self.shownViewLayouts.append(shownViewLayout)
        
//        self.hideChargerInfoView();
    }
    
    func setLocationOverlay(lat: Double, lng: Double) {
        let mapView = self.naverMapView.mapView
        let marker = NMFMarker()
        //마커의 위치
        marker.position = NMGLatLng(lat: lat, lng: lng)
        marker.mapView = mapView
        
        mapView.latitude = lat
        mapView.longitude = lng
    }
    
    func onClickedAddress(spotInfo:[String:String]) {
        if self.clickedButton == self.startButton {
            self.startInfo = spotInfo
        } else {
            self.destinationInfo = spotInfo
        }
        
        self.clickedButton?.setTitle("  " + spotInfo["name"]!, for: .normal)
        self.setLocationOverlay(lat: Double(spotInfo["lat"]!)!, lng: Double(spotInfo["lng"]!)!)
    }
    
    func presentAddressSearchView() {
        let addressVC = self.storyboard?.instantiateViewController(identifier: "addressSearchViewController") as! AddressSearchViewController
        addressVC.modalPresentationStyle = .fullScreen
        addressVC.chargerDelegate = self
        
        present(addressVC, animated: false, completion: nil)
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var naverMapView: NMFNaverMapView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var destinationButton: UIButton!
    
    // MARK: - IBActions
    @IBAction func touchUpFindButton(_ sender: UIButton) {
        self.clickedButton = sender
        self.presentAddressSearchView()
    }
    
    @IBAction func touchUpCloseButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Delegates And DataSource
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeMap()
        
        if let startInfo = self.startInfo {
            self.startButton.setTitle("  " + startInfo["name"]!, for: .normal)
            self.setLocationOverlay(lat: Double(startInfo["lat"]!)!, lng: Double(startInfo["lng"]!)!)
        } else if let destinationInfo = self.destinationInfo {
            self.destinationButton.setTitle("  " + destinationInfo["name"]!, for: .normal)
            self.setLocationOverlay(lat: Double(destinationInfo["lat"]!)!, lng: Double(destinationInfo["lng"]!)!)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
}
