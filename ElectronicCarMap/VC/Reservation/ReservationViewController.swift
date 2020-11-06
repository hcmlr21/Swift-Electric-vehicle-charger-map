//
//  reservationViewController.swift
//  ElectronicCarMap
//
//  Created by Jkookoo on 2020/10/27.
//  Copyright © 2020 Jkookoo. All rights reserved.
//

import UIKit
import NMapsMap


class ReservationViewController: UIViewController {
    // MARK: - ProPerties
    var charger: ChargerStationModel?
    
    // MARK: - Methods
    func makeMap() {
        let naverMapView = self.naverMapView!
        
        naverMapView.showCompass = true
        naverMapView.showLocationButton = false
        naverMapView.showZoomControls = true
        
        let mapView = naverMapView.mapView
        
        //좌표
        let marker = NMFMarker()
        if let lat = charger?.lat, let lng = charger?.lng {
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
    
    // MARK: - IBActions
    @IBAction func touch(_ sender: UIButton) {
        let reservationCompleteVC = self.storyboard?.instantiateViewController(identifier: "reservationCompleteViewController") as! ReservationCompleteViewController
        reservationCompleteVC.modalPresentationStyle = .fullScreen
        
        present(reservationCompleteVC, animated: true, completion: nil)
    }
    
    // MARK: - Delegates And DataSource
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLabel.layer.cornerRadius = 6
        self.startGuideButton.layer.cornerRadius = 10
        self.cancelReservationButton.layer.cornerRadius = 10
        
        self.makeMap()
    }
}
