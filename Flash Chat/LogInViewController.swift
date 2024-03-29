//
//  LogInViewController.swift
//  Flash Chat
//
//  Created by Breno Rezende on 10/09/19.
//  Copyright © 2019 brezende. All rights reserved.

//  This is the view controller where users login



import UIKit
import Firebase
import SVProgressHUD

class LogInViewController: UIViewController, UITextFieldDelegate {

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

   
    fileprivate func logIn() {
        if let email = emailTextfield.text, let password = passwordTextfield.text, email.count > 0, password.count > 0 {
            let firebaseAuth = Auth.auth()
            
            SVProgressHUD.show()
            
            firebaseAuth.signIn(withEmail: email, password: password) {
                (user, error) in
                
                SVProgressHUD.dismiss()
                
                if let er = error {
                    SVProgressHUD.showError(withStatus: er.localizedDescription)
                } else {
                    print("User logged in")
                    self.performSegue(withIdentifier: "goToChat", sender: self)
                }
            }
        } else {
            SVProgressHUD.showError(withStatus: "Please enter a correct email and password")
        }
    }
    
    @IBAction func logInPressed(_ sender: AnyObject) {
        logIn()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailTextfield {
            passwordTextfield.becomeFirstResponder()
        } else {
            passwordTextfield.resignFirstResponder()
            logIn()
        }
        
        return true
    }
}  
