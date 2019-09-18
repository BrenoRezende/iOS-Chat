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

class RegisterViewController: UIViewController {

    //Pre-linked IBOutlets

    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
  
    @IBAction func registerPressed(_ sender: AnyObject) {
        
        if let email = emailTextfield.text, let password = passwordTextfield.text {
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
        }
    }
    
    fileprivate func goToChatScreen() {
        self.performSegue(withIdentifier: "goToChat", sender: self)
    }
    
}
