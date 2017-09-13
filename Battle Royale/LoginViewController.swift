//
//  LoginViewController.swift
//  Battle Royale
//
//  Created by Vince Lee on 2017/9/8.
//  Copyright © 2017年 吳得人. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import GoogleSignIn




class LoginViewController: UIViewController, GIDSignInUIDelegate {
    
    var handle: AuthStateDidChangeListenerHandle?
    var ref: DatabaseReference!
    var displayName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
         GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        // TODO(developer) Configure the sign-in button look/feel
        // ...
        view.addSubview(googleButton)
        view.addSubview(mapViewButton)
        
        googleButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: googleButton, attribute: .top, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 0.7, constant: 0).isActive = true
         NSLayoutConstraint(item: googleButton, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 0.2, constant: 0).isActive = true
        NSLayoutConstraint(item: googleButton, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 0.8, constant: 0).isActive = true
        
        mapViewButton.translatesAutoresizingMaskIntoConstraints = false
        mapViewButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -64).isActive = true
        mapViewButton.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        mapViewButton.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
        }
        if Auth.auth().currentUser != nil {
            presentTutorial()
        } else {
            // No user is signed in.
            // ...
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    @IBAction func unwindToLogin(segue: UIStoryboardSegue) {
        
    }
    
    let googleButton = GIDSignInButton()
    
    let mapViewButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("START", for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.9272366166, green: 0.2351297438, blue: 0.103588976, alpha: 1).withAlphaComponent(0.8)
        button.addTarget(self, action: #selector(presentTutorial), for: .touchUpInside)
        return button
    }()
    
    @objc func presentTutorial() {
        if Auth.auth().currentUser != nil {
        performSegue(withIdentifier: PropertKeys.loginToTutorialSegue, sender: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
