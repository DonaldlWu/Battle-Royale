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
import FacebookLogin



class LoginViewController: UIViewController, GIDSignInUIDelegate {
    
    var handle: AuthStateDidChangeListenerHandle?
    var ref: DatabaseReference!
    var displayName: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
         GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        facebookLoginButton.delegate = self
        // TODO(developer) Configure the sign-in button look/feel
        // ...
        setupView()
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
    
    let welcomeImage: UIImageView = {
        let image = UIImageView()
        image.image = #imageLiteral(resourceName: "WelcomePage")
        
        return image
    }()
    
    
    
    let googleButton = GIDSignInButton()
    
    let accountTextfield: UITextField = {
        let textfield = UITextField()
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.placeholder = "帳號"
        textfield.borderStyle = .roundedRect
        textfield.autocorrectionType = .no
        return textfield
     }()
    let passwordsTextfield: UITextField = {
        let textfield = UITextField()
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.placeholder = "密碼"
        textfield.borderStyle = .roundedRect
        textfield.autocorrectionType = .no
        return textfield
    }()
    
    let passwordsLoginButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Login/Register", for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.9272366166, green: 0.2351297438, blue: 0.103588976, alpha: 1).withAlphaComponent(0.8)
        button.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        return button
    }()
    
    let facebookLoginButton = LoginButton(readPermissions: [ .publicProfile, .email])
    
    
    let activityView: UIActivityIndicatorView = {
        let activityView = UIActivityIndicatorView()
        activityView.activityIndicatorViewStyle = .gray
        activityView.hidesWhenStopped = true
        return activityView
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
