//
//  signUpViewController.swift
//  Users
//
//  Created by Kaden Oldham on 12/4/17.
//  Copyright © 2017 Kaden Oldham. All rights reserved.
//

import UIKit

class signUpViewController: UIViewController {
    
    //MARK: - outlets
    @IBOutlet weak var explanationLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!

    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserController.shared.fetchCurrentUser()
        NotificationCenter.default.addObserver(self, selector: #selector(segueToTableView), name: UserController.shared.currentUserWasSetNotification, object: nil)
    }
    
    //MARK: - segue
    @objc func segueToTableView() {
        DispatchQueue.main.async {
            self.userNameLabel.isHidden = true
            self.usernameTextField.isHidden = true
            self.explanationLabel.text = ""
            self.loginButton.isHidden = true
            self.performSegue(withIdentifier: "toCollectionTV", sender: self)
        }
    }
    
    //MARK: - action
    @IBAction func logInButtonTapped(_ sender: Any) {
        guard let username = usernameTextField.text else { return }
        if UserController.shared.currentUser == nil {
            UserController.shared.createUserWith(username: username, email: "", completion: { (success) in
                if !success {
                    print("Error creating user")
                } else {
                    print("successful creating \(username)")
                }
            })
        } else {
            UserController.shared.updateCurrentUser(username: username, email: "", completion: { (success) in
                if !success {
                    print("Error updating user")
                } else {
                    print("successful updating \(username)")
                }
            })
        }
    }
    
    //MARK: - alert
    func presentSimpleAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dissmissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        alert.addAction(dissmissAction)
        self.present(alert, animated: true, completion: nil)
    }
}
