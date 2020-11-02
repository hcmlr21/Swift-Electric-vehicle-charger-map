//
//  SignInViewController.swift
//  ElectronicCarMap
//
//  Created by Jkookoo on 2020/10/25.
//  Copyright © 2020 Jkookoo. All rights reserved.
//

import UIKit
import Firebase

class SignInViewController: UIViewController {
    // MARK: - ProPerties
    let databaseRef = Database.database().reference()
    // MARK: - Methods
    func alert(message: String) {
        let alertController = UIAlertController(title: "로그인 실패", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func signIn() {
        if let name = self.nameTextField.text, let email = self.emailTextField.text, let password = self.passwordTextField.text {
            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                if(error == nil) {
                    let myUid = user?.user.uid
                    let value = [
                        "userName": name,
                        "userEmail": email,
                        "uid": myUid!
                    ]

                    self.databaseRef.child("users").child(myUid!).setValue(value) { (error, ref) in
                        if(error == nil) {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                    
                } else {
                    self.alert(message: "회원가입 오류")
                }
            }
        }
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: - IBActions
    @IBAction func touchUpSignInButton(_ sender: UIButton) {
        self.signIn()
    }
    
    @IBAction func touchUpCancelButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func tapView() {
        self.view.endEditing(true)
    }
    
    // MARK: - Delegates And DataSource
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapView = UITapGestureRecognizer(target: self, action: #selector(self.tapView))
        self.view.addGestureRecognizer(tapView)
    }
}
