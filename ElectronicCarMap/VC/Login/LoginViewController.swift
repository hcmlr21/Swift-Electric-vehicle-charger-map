//
//  LoginViewController.swift
//  ElectronicCarMap
//
//  Created by Jkookoo on 2020/10/25.
//  Copyright © 2020 Jkookoo. All rights reserved.
//

import UIKit
import SHSearchBar
import Firebase

class LoginViewController: UIViewController {
    // MARK: - ProPerties
    
    // MARK: - Methods
    func loginEvent() {
        if let email = self.emailTextField.text, let password = self.passwordTextField.text {
            Auth.auth().signIn(withEmail: email , password: password) { (user, error) in
                if(error != nil) {
                    self.alert(message: error.debugDescription)
                }
            }
        } else {
            self.alert(message: "회원정보 오류")
        }
    }
    
    func presentSignIn() {
        let signInVC = self.storyboard?.instantiateViewController(identifier: "signInViewController") as! SignInViewController
        signInVC.modalPresentationStyle = .fullScreen
        
        present(signInVC, animated: true, completion: nil)
    }
    
    func alert(message: String) {
        let alertController = UIAlertController(title: "로그인 실패", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func authSetting() {
        do {
            try Auth.auth().signOut()
        } catch(let e) {
            print(e.localizedDescription)
        }
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if(user != nil) {
                let mainVC = self.storyboard?.instantiateViewController(identifier: "mainViewTabBarController") as! UITabBarController
                mainVC.modalPresentationStyle = .fullScreen
                
                self.present(mainVC, animated: false, completion: nil)
            }
        }
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: - IBActions
    @IBAction func touchUpLoginButton(_ sender: UIButton) {
        self.loginEvent()
    }
    
    @IBAction func touchUpSignUpButton(_ sender: UIButton) {
        self.presentSignIn()
    }
    
    @objc func tapView() {
        self.view.endEditing(true)
    }
    
    // MARK: - Delegates And DataSource
    
    // MARK: - Life Cycles
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewDidLoad()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.authSetting()
        
        self.emailTextField.text = "jay@naver.com"
        self.passwordTextField.text = "123456"
        
        let tapView = UITapGestureRecognizer(target: self, action: #selector(self.tapView))
        self.view.addGestureRecognizer(tapView)
    }
}
