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
import ChameleonFramework

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
    var keyboardHeight = CGFloat()
    var keyboardAnimationDuration: Double = 0.24
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        heightConstraintDefaultValue = heightConstraint.constant
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
                
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        messageTextfield.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)

        messageTableView.register(UINib(nibName: messageCellNibName, bundle: nil), forCellReuseIdentifier: messageCellIdentifier)
    
        self.configureTableView()
        self.retrieveMessages()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.messageTextfield.becomeFirstResponder()
        self.messageTextfield.resignFirstResponder()
    }
    
    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: messageCellIdentifier, for: indexPath) as! CustomMessageCell
        
        cell.senderUsername.text = messages[indexPath.row].sender
        cell.messageBody.text = messages[indexPath.row].body
        cell.avatarImageView.image = #imageLiteral(resourceName: "egg")
        
        if cell.senderUsername.text == Auth.auth().currentUser?.email {
            cell.messageBackground.backgroundColor = UIColor.flatNavyBlue()
            cell.avatarImageView.backgroundColor = UIColor.flatSand()
        }
        
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
        UIView.animate(withDuration: self.keyboardAnimationDuration) {
            self.heightConstraint.constant = self.keyboardHeight + self.heightConstraintDefaultValue
            self.view.layoutIfNeeded()
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: self.keyboardAnimationDuration) {
            self.heightConstraint.constant = self.heightConstraintDefaultValue
            self.view.layoutIfNeeded()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == messageTextfield {
            self.sendMessage()
        }
        
        return true
    }
    
    ///////////////////////////////////////////
    
        
    //MARK: - Send & Receive from Firebase
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        self.sendMessage()
    }
    
    func sendMessage() {
        
        if let message = messageTextfield.text, !message.isEmpty {
            
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
    }
    
    func retrieveMessages() {
        
        SVProgressHUD.show()
        
        self.messagesDB.observe(.childAdded) {
            (snapshot) in
            
            SVProgressHUD.dismiss()
            
            let snapshotValue = snapshot.value as? Dictionary<String, String>
            
            guard let value = snapshotValue else { return }
            guard let sender = value["Sender"] else { return }
            guard let messageBody = value["MessageBody"] else { return }
            
            let message = Message(sender: sender, body: messageBody)
            
            self.messages.append(message)
            self.messageTableView.reloadData()
        }
    }
    
    // MARK: - Logout from Firebase
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        do {
            try Auth.auth().signOut()
            
            self.navigationController?.popToRootViewController(animated: true)
        } catch {
            print("Error trying to sign out: \(Error.self)")
        }
        
    }
    
    // MARK: - System Methods
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        if let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.keyboardHeight = keyboardRect.height
        }
        
        if let duration = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue) as? Double {
            self.keyboardAnimationDuration = duration
        }
    }


}
