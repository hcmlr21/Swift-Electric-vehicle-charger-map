//
//  MyInfoViewController.swift
//  ElectronicCarMap
//
//  Created by Jkookoo on 2020/10/25.
//  Copyright © 2020 Jkookoo. All rights reserved.
//

import UIKit

class MyInfoViewController: UIViewController {
    // MARK: - ProPerties
    
    // MARK: - Methods
    @objc func tapView() {
        self.view.endEditing(true)
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - IBActions
    @IBAction func touchUpLogoutButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Delegates And DataSource
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLabel.layer.cornerRadius = 6
        
        let tapView = UITapGestureRecognizer(target: self, action: #selector(self.tapView))
        self.view.addGestureRecognizer(tapView)

    }
}
