//
//  favoriteChargerViewController.swift
//  ElectronicCarMap
//
//  Created by Jkookoo on 2020/10/27.
//  Copyright © 2020 Jkookoo. All rights reserved.
//

import UIKit

class favoriteChargersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - ProPerties
    let cellIdentifier = "favoriteCell"
    var favoriteChargers: [String] = ["zz"]
    
    // MARK: - Methods
    
    // MARK: - IBOutlets
    @IBOutlet weak var favoriteTableView: UITableView!
    
    // MARK: - IBActions
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - Delegates And DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.favoriteChargers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.favoriteTableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)
        cell.textLabel?.text = "zzz"
        cell.imageView?.image = UIImage(named: "star")
        
        return cell
    }
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.layer.cornerRadius = 6
        
    }
}
