//
//  FBLoginDelegate.swift
//  Battle Royale
//
//  Created by Vince Lee on 2017/9/13.
//  Copyright © 2017年 吳得人. All rights reserved.
//

import Foundation
import Firebase
import FBSDKLoginKit
import FacebookLogin
import FacebookCore

extension LoginViewController: LoginButtonDelegate {
    
  
    //facebook logout
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Facebook logout")
    }
    
    
    /** @var handle
     @brief The handler for the auth state listener, to allow cancelling later.
     */
    
    
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        self.activityView.startAnimating()
        if let currentFbsdkAccessToken = FBSDKAccessToken.current() {
            let credential = FacebookAuthProvider.credential(withAccessToken: currentFbsdkAccessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { (user, error) in
                if let error = error {
                    print(error)
                    return
                }
                self.activityView.stopAnimating()
                self.performSegue(withIdentifier: PropertKeys.loginToTutorialSegue, sender: self)
                print("Successfully logged in with facebook...")
            }
        } else {
            self.activityView.stopAnimating()
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        print("Facebook logout")
    }
}
