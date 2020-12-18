//
//  bookMarkChargerViewController.swift
//  ElectronicCarMap
//
//  Created by Jkookoo on 2020/10/27.
//  Copyright © 2020 Jkookoo. All rights reserved.
//

import UIKit
import Firebase

class BookMarkChargersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - ProPerties
    var chargerDelegate: chargerStationDelegate?
    let cellIdentifier = "bookMarkCell"
    var bookMarkChargerStationsId: [String] = []
    var bookMarkChargerStationsName: [String] = []
    let databaseRef = Database.database().reference()
    let myUid = Auth.auth().currentUser?.uid
    var editMode = false
    
    // MARK: - Methods
    func getBookMarkList() {
        self.databaseRef.child("users").child(self.myUid!).child("bookMark").observe(.value) { (dataSnapShot) in
            self.bookMarkChargerStationsId.removeAll()
            self.bookMarkChargerStationsName.removeAll()
            for item in dataSnapShot.children.allObjects as! [DataSnapshot] {
                let statId = item.key
                self.bookMarkChargerStationsId.append(statId)
                if let statName = item.value as? String {
                    self.bookMarkChargerStationsName.append(statName)
                }
            }
            
            DispatchQueue.main.async {
                if self.bookMarkChargerStationsId.count > 0 {
                    self.noListView.isHidden = true
                } else {
                    self.noListView.isHidden = false
                }
                
                self.bookMarkTableView.reloadData()
            }
        }
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var bookMarkTableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noListView: UIView!
    
    // MARK: - IBActions
    @IBAction func touchUpEditButton(_ sender: UIButton) {
        self.tableView.isEditing = !self.tableView.isEditing
        
        if self.tableView.isEditing {
            self.editButton.setTitle("Done", for: .normal)
        } else {
            self.editButton.setTitle("Edit", for: .normal)
        }
    }
    
    // MARK: - Delegates And DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.bookMarkChargerStationsId.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.bookMarkTableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as? BookMarkTableViewCell else {
            return UITableViewCell()
        }
        
        let bookMarkChargerStationName = self.bookMarkChargerStationsName[indexPath.row]
        let statName = bookMarkChargerStationName
        
        cell.chargerStationNameLabel.text = statName
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let chargerStationDic: [String:String] = ["chargerStationId":self.bookMarkChargerStationsId[indexPath.row]]
        NotificationCenter.default.post(name: Notification.Name(bookMarkNotificationName), object: chargerStationDic)
        
        self.tabBarController?.selectedIndex = 0
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.self.databaseRef.child("users").child(self.myUid!).child("bookMark").child(self.bookMarkChargerStationsId[indexPath.row]).removeValue()
            self.bookMarkChargerStationsId.remove(at: indexPath.row)
            self.bookMarkChargerStationsName.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if self.tableView.isEditing {
            return .delete
        }
        
        return .none
    }
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.layer.cornerRadius = 6
        self.getBookMarkList()
    }
}
