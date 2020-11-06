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
    var addrdButton: UIButton?
    var chargerStationButton: UIButton?
    var startInfo: [String:String]?
    var destinationInfo: [String:String]?
    var startMarker = NMFMarker()
    var destinationMarker = NMFMarker()
    var hiddenViewLayouts: [NSLayoutConstraint] = []
    var shownViewLayouts: [NSLayoutConstraint] = []
    
    // MARK: - Methods
    func makeMap() {
        self.naverMapView.showCompass = true
        self.naverMapView.showLocationButton = true
        self.naverMapView.showZoomControls = true
        self.naverMapView.showScaleBar = true
        
        let mapView = self.naverMapView.mapView
        mapView.positionMode = .direction
        
        let hiddenViewLayout = self.naverMapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        self.hiddenViewLayouts.append(hiddenViewLayout)
        
        let shownViewLayout = self.naverMapView.bottomAnchor.constraint(equalTo: self.guideStartButton.topAnchor)
        self.shownViewLayouts.append(shownViewLayout)
        
        self.hideGuideStartButton()
    }
    
    func setLocationOverlay(marker: NMFMarker, lat: Double, lng: Double) {
        let mapView = self.naverMapView.mapView
        //마커의 위치
        marker.position = NMGLatLng(lat: lat, lng: lng)
        marker.mapView = mapView
        
        mapView.latitude = lat
        mapView.longitude = lng
    }
    
    func removeLocationOverLay(marker: NMFMarker) {
        marker.mapView = nil
    }
    
    func presentAddressSearchView() {
        let addressVC = self.storyboard?.instantiateViewController(identifier: "addressSearchViewController") as! AddressSearchViewController
        addressVC.modalPresentationStyle = .fullScreen
        addressVC.chargerDelegate = self
        
        present(addressVC, animated: false, completion: nil)
    }
    
    func setDirection() {
        if let startInfo = self.startInfo, let destinationInfo = self.destinationInfo {
            self.startButton.setTitleColor(.black, for: .normal)
            self.destinationButton.setTitleColor(.black, for: .normal
            )
            self.startButton.setTitle("  " + startInfo["name"]!, for: .normal)
            self.destinationButton.setTitle("  " + destinationInfo["name"]!, for: .normal)
         
            let startLat = Double(startInfo["lat"]!)!
            let startLng = Double(startInfo["lng"]!)!
            self.setLocationOverlay(marker: self.startMarker, lat: startLat, lng: startLng)
            
            let destinationLat = Double(destinationInfo["lat"]!)!
            let destinationLng = Double(destinationInfo["lng"]!)!
            self.setLocationOverlay(marker: self.destinationMarker, lat: destinationLat, lng: destinationLng)
            
            self.showGuideStartButton()
            let smallLat = min(startLat, destinationLat)
            let bigLat = max(startLat, destinationLat)
            let smallLng = min(startLng, destinationLng)
            let bigLng = max(startLng, destinationLng)
            let cameraUpdate = NMFCameraUpdate(fit: NMGLatLngBounds(southWest: NMGLatLng(lat: smallLat, lng: bigLng), northEast: NMGLatLng(lat: bigLat, lng: smallLng)), padding: 100)
            cameraUpdate.animation = .easeIn
            cameraUpdate.animationDuration = 0.8
            self.naverMapView.mapView.moveCamera(cameraUpdate)
            
            //경로 추가
        } else {
            self.hideGuideStartButton()
            if let startInfo = self.startInfo {
                self.startButton.setTitleColor(.black, for: .normal)
                self.startButton.setTitle("  " + startInfo["name"]!, for: .normal)
                self.destinationButton.setTitleColor(#colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1), for: .normal)
                self.destinationButton.setTitle("  도착지 입력", for: .normal)
                
                self.setLocationOverlay(marker: self.startMarker, lat: Double(startInfo["lat"]!)!, lng: Double(startInfo["lng"]!)!)
                self.removeLocationOverLay(marker: self.destinationMarker)
            }
            
            if let destinationInfo = self.destinationInfo {
                self.destinationButton.setTitleColor(.black, for: .normal)
                self.destinationButton.setTitle("  " + destinationInfo["name"]!, for: .normal)
                self.startButton.setTitleColor(#colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1), for: .normal)
                self.startButton.setTitle("  출발지 입력", for: .normal)
                
                self.setLocationOverlay(marker: self.destinationMarker, lat: Double(destinationInfo["lat"]!)!, lng: Double(destinationInfo["lng"]!)!)
                self.removeLocationOverLay(marker: self.startMarker)
            }
        }
        
        self.chargerStationButton?.isEnabled = false
        self.addrdButton?.isEnabled = true
    }
    
    func setMarkerImage(charegrMarker: NMFMarker, chargerInfo: [String:String]?, addrMarker: NMFMarker, addrInfo: [String:String]?) {
        charegrMarker.iconImage = NMFOverlayImage(name: "electronicMarker")
        charegrMarker.width = NMF_MARKER_IMAGE_GRAY.imageWidth + 13
        charegrMarker.height = NMF_MARKER_IMAGE_GRAY.imageHeight + 5
        if let chargerInfo = chargerInfo {
            charegrMarker.captionText = chargerInfo["name"]!
        }
        
        
        addrMarker.iconImage = NMF_MARKER_IMAGE_RED
        addrMarker.width = NMF_MARKER_IMAGE_RED.imageWidth
        addrMarker.height = NMF_MARKER_IMAGE_RED.imageHeight
        if let addrInfo = addrInfo {
            charegrMarker.captionText = addrInfo["name"]!
        }
    }
    
    func setChargerStationInfo() {
        if self.startInfo != nil {
            self.chargerStationButton = self.startButton
            self.addrdButton = self.destinationButton
            self.setMarkerImage(charegrMarker: self.startMarker, chargerInfo: self.startInfo, addrMarker: self.destinationMarker, addrInfo: self.destinationInfo)
        } else {
            self.chargerStationButton = self.destinationButton
            self.addrdButton = self.startButton
            self.setMarkerImage(charegrMarker: self.destinationMarker, chargerInfo: self.startInfo, addrMarker: self.startMarker , addrInfo: self.destinationInfo)
        }
    }
    
    func showGuideStartButton() {
        self.guideStartButton.isHidden = false
        NSLayoutConstraint.deactivate(self.hiddenViewLayouts)
        NSLayoutConstraint.activate(self.shownViewLayouts)
    }

    func hideGuideStartButton() {
        self.guideStartButton.isHidden = true
        NSLayoutConstraint.deactivate(self.shownViewLayouts)
        NSLayoutConstraint.activate(self.hiddenViewLayouts)
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var naverMapView: NMFNaverMapView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var destinationButton: UIButton!
    @IBOutlet weak var guideStartButton: UIButton!
    
    // MARK: - IBActions
    @IBAction func touchUpFindButton(_ sender: UIButton) {
        self.presentAddressSearchView()
    }
    
    @IBAction func touchUpSwitchDirectionButton(_ sender: UIButton) {
        swap(&self.addrdButton, &self.chargerStationButton)
        swap(&self.startInfo, &self.destinationInfo)
        swap(&self.startMarker, &destinationMarker)
        self.setDirection()
    }
    
    @IBAction func touchUpCloseButton(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    // MARK: - Delegates And DataSource
    func onClickedAddress(spotInfo:[String:String]) {
        if self.addrdButton == self.startButton {
            self.startInfo = spotInfo
        } else {
            self.destinationInfo = spotInfo
        }
        
        self.setDirection()
    }
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeMap()
        
        self.setChargerStationInfo()
        
        self.setDirection()
    }
}
