//
//  favoriteChargerViewController.swift
//  ElectronicCarMap
//
//  Created by Jkookoo on 2020/10/27.
//  Copyright © 2020 Jkookoo. All rights reserved.
//

import UIKit
import Firebase

class favoriteChargersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - ProPerties
    let cellIdentifier = "favoriteCell"
    var favoriteChargerStationsId: [String] = []
    var favoriteChargerStationsName: [String] = []
    let databaseRef = Database.database().reference()
    let myUid = Auth.auth().currentUser?.uid
    
    // MARK: - Methods
    func getFavoriteList() {
        self.databaseRef.child("users").child(self.myUid!).child("favorite").observe(.value) { (dataSnapShot) in
            self.favoriteChargerStationsId.removeAll()
            self.favoriteChargerStationsName.removeAll()
            for item in dataSnapShot.children.allObjects as! [DataSnapshot] {
                let statId = item.key
                self.favoriteChargerStationsId.append(statId)
                if let statName = item.value as? String {
                    self.favoriteChargerStationsName.append(statName)
                }
            }
            DispatchQueue.main.async {
                self.favoriteTableView.reloadData()
            }
        }
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var favoriteTableView: UITableView!
    
    // MARK: - IBActions
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - Delegates And DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.favoriteChargerStationsId.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.favoriteTableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)
        let favoriteChargerStationName = self.favoriteChargerStationsName[indexPath.row]
        let statName = favoriteChargerStationName
        
        cell.textLabel?.text = statName
        cell.imageView?.image = UIImage(named: "star")
        
        return cell
    }
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.layer.cornerRadius = 6
        self.getFavoriteList()
    }
}
