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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
        
        
        // TODO(developer) Configure the sign-in button look/feel
        // ...
        view.addSubview(googleButton)
        view.addSubview(mapViewButton)
        
        googleButton.translatesAutoresizingMaskIntoConstraints = false
        googleButton.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        googleButton.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        googleButton.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        googleButton.heightAnchor.constraint(equalToConstant: 64).isActive = true
        
        
        
        mapViewButton.translatesAutoresizingMaskIntoConstraints = false
        mapViewButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -64).isActive = true
        mapViewButton.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        mapViewButton.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        googleButton.heightAnchor.constraint(equalToConstant: 64).isActive = true
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    
    let googleButton = GIDSignInButton()
    
    let mapViewButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("START", for: .normal)
        button.backgroundColor = .cyan
        button.addTarget(self, action: #selector(presentMapView), for: .touchUpInside)
        return button
    }()
    
    @objc func presentMapView() {
        let controller = storyboard?.instantiateViewController(withIdentifier: PropertKeys.tabBarController)
       
        if let user = Auth.auth().currentUser {
           
            ref = Database.database().reference()
        ref.child("users").child(user.uid).updateChildValues(["username": user.displayName!])
            
            
        
        present(controller!, animated: true, completion: nil)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
