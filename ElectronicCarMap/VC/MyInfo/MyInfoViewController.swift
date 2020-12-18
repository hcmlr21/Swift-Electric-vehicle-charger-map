//
//  MyInfoViewController.swift
//  ElectronicCarMap
//
//  Created by Jkookoo on 2020/10/25.
//  Copyright © 2020 Jkookoo. All rights reserved.
//

import UIKit
import Firebase

class MyInfoViewController: UIViewController {
    // MARK: - ProPerties
    let myUid = Auth.auth().currentUser?.uid
    let dataRef = Database.database().reference()
    
    // MARK: - Methods
    @objc func tapView() {
        self.view.endEditing(true)
    }
    
    func getMyInfo() {
        self.dataRef.child("users").child(self.myUid!).observeSingleEvent(of: .value) { (dataSnapShot) in
            let userModel = UserModel()
            for item in dataSnapShot.children.allObjects as! [DataSnapshot] {
                userModel.setValue(item.value, forKey: item.key)
            }
            
            DispatchQueue.main.async {
                self.nameLabel.text = userModel.userName
            }
        }
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    // MARK: - IBActions
    @IBAction func touchUpLogoutButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "로그아웃", message: "로그아웃 하시겠습니까?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { (action) in
            self.dismiss(animated: false, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Delegates And DataSource
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getMyInfo()
        self.titleLabel.layer.cornerRadius = 6
    }
}
