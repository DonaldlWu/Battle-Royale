//
//  PasswordsLoginExtension.swift
//  Battle Royale
//
//  Created by Vince Lee on 2017/9/13.
//  Copyright © 2017年 吳得人. All rights reserved.
//

import Foundation
import Firebase

extension LoginViewController {
    
    @objc func handleRegister() {
        activityView.startAnimating()
        guard let email = accountTextfield.text, let password = passwordsTextfield.text else {
                print("RegisterError")
            activityView.stopAnimating()
                return
        }
        Auth.auth().createUser(withEmail: email, password: password, completion:
            { (user, error) in
                
                if error != nil {
                    if error!.localizedDescription == "The email address is already in use by another account." {
                    print(error!.localizedDescription)
                        self.handleLogin()
                        return
                    } else {
                        print(error!.localizedDescription)
                        self.failToLoginRegister()
                    }
                 self.failToLoginRegister()
                } else {
                    print("Passwords login success")
                    self.activityView.stopAnimating()
                    self.performSegue(withIdentifier: PropertKeys.loginToTutorialSegue, sender: self)
                }
        })
    }
    
    func handleLogin() {
        
        guard let email = accountTextfield.text, let password = passwordsTextfield.text else {
            print("EmailLoginError")
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print(error!)
                self.failToLoginRegister()
                return
            } else {
                self.activityView.stopAnimating()
                self.performSegue(withIdentifier: PropertKeys.loginToTutorialSegue, sender: self)
            }
            
            print("welcome \(String(describing: user?.email).description) login success")
        }
    }
    func failToLoginRegister() {
        let cancelAction = UIAlertAction(title: "Retry", style: .cancel, handler: nil)
        let alertController = UIAlertController(title: "Error", message: "Wrong login information. Passwords must be above 6 characters or email has been registered", preferredStyle: .alert)
        
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: self.activityView.stopAnimating)
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}




