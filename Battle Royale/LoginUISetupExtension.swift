//
//  PasswordLoginExtension.swift
//  Battle Royale
//
//  Created by Vince Lee on 2017/9/13.
//  Copyright © 2017年 吳得人. All rights reserved.
//

import Foundation
import UIKit


extension LoginViewController {
    
    func setupView() {
        
        view.addSubview(googleButton)
        view.addSubview(mapViewButton)
        view.addSubview(accountTextfield)
        view.addSubview(passwordsTextfield)
        view.addSubview(passwordsLoginButton)
        view.addSubview(facebookLoginButton)
        
        mapViewButton.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mapViewButton.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        mapViewButton.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        // google button
        googleButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: googleButton, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 0.9, constant: 0).isActive = true
        NSLayoutConstraint(item: googleButton, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 0.2, constant: 0).isActive = true
        NSLayoutConstraint(item: googleButton, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 0.8, constant: 0).isActive = true
        
        
        // accountTextfield
        NSLayoutConstraint(item: accountTextfield, attribute: .bottom, relatedBy: .equal, toItem: passwordsTextfield, attribute: .top, multiplier: 1, constant: -30).isActive = true
        NSLayoutConstraint(item: accountTextfield, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 0.2, constant: 0).isActive = true
        NSLayoutConstraint(item: accountTextfield, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 0.8, constant: 0).isActive = true
        
        
        
        // passwordsTextfield
        NSLayoutConstraint(item: passwordsTextfield, attribute: .bottom, relatedBy: .equal, toItem: passwordsLoginButton, attribute: .top, multiplier: 1, constant: -30).isActive = true
        NSLayoutConstraint(item: passwordsTextfield, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 0.2, constant: 0).isActive = true
        NSLayoutConstraint(item: passwordsTextfield, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 0.8, constant: 0).isActive = true
        
        // passwordsLoginButton
        passwordsLoginButton.layer.cornerRadius = 3

        NSLayoutConstraint(item: passwordsLoginButton, attribute: .bottom, relatedBy: .equal, toItem: facebookLoginButton, attribute: .top, multiplier: 1, constant: -30).isActive = true
        NSLayoutConstraint(item: passwordsLoginButton, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 0.2, constant: 0).isActive = true
        NSLayoutConstraint(item: passwordsLoginButton, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 0.8, constant: 0).isActive = true
        
        //  fb button
        facebookLoginButton.translatesAutoresizingMaskIntoConstraints = false
        facebookLoginButton.layer.cornerRadius = 10
        NSLayoutConstraint(item: facebookLoginButton, attribute: .bottom, relatedBy: .equal, toItem: googleButton, attribute: .top, multiplier: 1, constant: -30).isActive = true
        NSLayoutConstraint(item: facebookLoginButton, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 0.2, constant: 0).isActive = true
        NSLayoutConstraint(item: facebookLoginButton, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 0.8, constant: 0).isActive = true
        // height
        NSLayoutConstraint(item: facebookLoginButton, attribute: .height, relatedBy: .equal, toItem: passwordsLoginButton, attribute: .height, multiplier: 1, constant: 0).isActive = true
    
    }
}
