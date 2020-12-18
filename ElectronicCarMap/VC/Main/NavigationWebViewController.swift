//
//  NavigationWebViewController.swift
//  ElectronicCarMap
//
//  Created by Jkookoo on 2020/11/21.
//  Copyright © 2020 Jkookoo. All rights reserved.
//

import UIKit
import WebKit
import KakaoSDKNavi

class NavigationWebViewController: UIViewController {
    // MARK: - ProPerties
    
    // MARK: - Methods
    func showNavi() {
        let destination = NaviLocation(name: "카카오판교오피스", x: "321286", y: "533707")
        let viaList = [NaviLocation(name: "판교역 1번출구", x: "321525", y: "532951")]
//        let safariViewController = SFSafariViewController(url: NaviApi.shared.webNavigateUrl(destination: destination, viaList:viaList)!)
//        safariViewController.modalTransitionStyle = .crossDissolve
//        safariViewController.modalPresentationStyle = .overCurrentContext
//        self.present(safariViewController, animated: true) {
//            print("웹안내 present success")
//        }
        self.naviWebView.load(URLRequest(url: NaviApi.shared.webNavigateUrl(destination: destination, viaList:viaList)!))
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var naviWebView: WKWebView!
    
    // MARK: - IBActions
    
    // MARK: - Delegates And DataSource
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.showNavi()
    }

}
