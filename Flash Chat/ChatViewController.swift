//
//  ViewController.swift
//  Flash Chat
//
//  Created by Breno Rezende on 10/09/19.
//  Copyright © 2019 brezende. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    let messageCellIdentifier = "customMessageCell"
    let messageCellNibName = "MessageCell"
    
    var messages = [Message]()
    let messagesDB = Database.database().reference().child("Messages")
    
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    var heightConstraintDefaultValue = CGFloat()
    let keyboardHeight: CGFloat = 308
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        heightConstraintDefaultValue = heightConstraint.constant
                
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        messageTextfield.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)

        messageTableView.register(UINib(nibName: messageCellNibName, bundle: nil), forCellReuseIdentifier: messageCellIdentifier)
    
        self.configureTableView()
        self.retrieveMessages()
    }

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: messageCellIdentifier, for: indexPath) as! CustomMessageCell
        
        cell.senderUsername.text = messages[indexPath.row].sender
        cell.messageBody.text = messages[indexPath.row].body
        cell.avatarImageView.image = #imageLiteral(resourceName: "egg")
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    @objc func tableViewTapped() {
        messageTextfield.endEditing(true)
    }
    
    func configureTableView() {
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 100
    }
    
    
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
            self.heightConstraint.constant = self.keyboardHeight
            self.view.layoutIfNeeded()
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
            self.heightConstraint.constant = self.heightConstraintDefaultValue
            self.view.layoutIfNeeded()
        }
    }
    
    ///////////////////////////////////////////
    
        
    //MARK: - Send & Receive from Firebase
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        messageTextfield.endEditing(true)
        
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
                
        let newMessage = ["Sender" : Auth.auth().currentUser?.email, "MessageBody" : messageTextfield.text]
            
        self.messagesDB.childByAutoId().setValue(newMessage) {
            (error, reference) in
            
            if error != nil {
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
            } else {
                self.messageTextfield.text = ""
            }
            
            self.messageTextfield.isEnabled = true
            self.sendButton.isEnabled = true
        }
        
    }
    
    func retrieveMessages() {
        
        self.messagesDB.observe(.childAdded) {
            (snapshot) in
            
            let snapshotValue = snapshot.value as? Dictionary<String, String>
            
            guard let value = snapshotValue else { return }
            guard let sender = value["Sender"] else { return }
            guard let messageBody = value["MessageBody"] else { return }
            
            let message = Message(sender: sender, body: messageBody)
            
            self.messages.append(message)
            self.messageTableView.reloadData()
        }
    }
    

    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        do {
            try Auth.auth().signOut()
            
            self.navigationController?.popToRootViewController(animated: true)
        } catch {
            print("Error trying to sign out: \(Error.self)")
        }
        
    }
    


}
