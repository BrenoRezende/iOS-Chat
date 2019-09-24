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

class LogInViewController: UIViewController {

    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

   
    @IBAction func logInPressed(_ sender: AnyObject) {

        if let email = emailTextfield.text, let password = passwordTextfield.text {
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
        }
        
    }
}  
