//
//  RegisterViewController.swift
//  Flash Chat
//
//  Created by Breno Rezende on 10/09/19.
//  Copyright © 2019 brezende. All rights reserved.

//  This is the View Controller which registers new users with Firebase
//

import UIKit
import Firebase
import SVProgressHUD

class RegisterViewController: UIViewController, UITextFieldDelegate {

    //Pre-linked IBOutlets

    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextfield.delegate = self
        passwordTextfield.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
  
    fileprivate func register() {
        if let email = emailTextfield.text, let password = passwordTextfield.text, email.count > 0, password.count > 0 {
            let firebaseAuth = Auth.auth()
            
            SVProgressHUD.show()
            
            firebaseAuth.createUser(withEmail: email, password: password) { (user, error) in
                
                SVProgressHUD.dismiss()
                
                if let er = error {
                    SVProgressHUD.showError(withStatus: er.localizedDescription)
                } else if let user = user {
                    print("User created! \(user.user)")
                    self.goToChatScreen()
                } else {
                    print("User created but not returned")
                    self.goToChatScreen()
                }
                
            }
        } else {
            SVProgressHUD.showError(withStatus: "Please enter a correct email and password")
        }
    }
    
    @IBAction func registerPressed(_ sender: AnyObject) {
        register()
    }
    
    fileprivate func goToChatScreen() {
        self.performSegue(withIdentifier: "goToChat", sender: self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextfield {
            passwordTextfield.becomeFirstResponder()
        } else {
            passwordTextfield.resignFirstResponder()
            register()
        }
        
        return true
    }
    
}
