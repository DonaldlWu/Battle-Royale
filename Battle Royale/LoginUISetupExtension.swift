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
        view.addSubview(welcomeImage)
        view.addSubview(accountTextfield)
        view.addSubview(passwordsTextfield)
        view.addSubview(passwordsLoginButton)
        view.addSubview(facebookLoginButton)
        view.addSubview(activityView)
        
        
        
        
        // google button
        googleButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: googleButton, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 0.9, constant: 0).isActive = true
        NSLayoutConstraint(item: googleButton, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 0.2, constant: 0).isActive = true
        NSLayoutConstraint(item: googleButton, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 0.8, constant: 0).isActive = true
        
        
        
        // accountTextfield
        NSLayoutConstraint(item: accountTextfield, attribute: .bottom, relatedBy: .equal, toItem: passwordsTextfield, attribute: .top, multiplier: 1, constant: -15).isActive = true
        NSLayoutConstraint(item: accountTextfield, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 0.2, constant: 0).isActive = true
        NSLayoutConstraint(item: accountTextfield, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 0.8, constant: 0).isActive = true
        
        
        
        // passwordsTextfield
        NSLayoutConstraint(item: passwordsTextfield, attribute: .bottom, relatedBy: .equal, toItem: passwordsLoginButton, attribute: .top, multiplier: 1, constant: -15).isActive = true
        NSLayoutConstraint(item: passwordsTextfield, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 0.2, constant: 0).isActive = true
        NSLayoutConstraint(item: passwordsTextfield, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 0.8, constant: 0).isActive = true
        
        // passwordsLoginButton
        passwordsLoginButton.layer.cornerRadius = 3

        NSLayoutConstraint(item: passwordsLoginButton, attribute: .bottom, relatedBy: .equal, toItem: facebookLoginButton, attribute: .top, multiplier: 1, constant: -15).isActive = true
        NSLayoutConstraint(item: passwordsLoginButton, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 0.2, constant: 0).isActive = true
        NSLayoutConstraint(item: passwordsLoginButton, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 0.8, constant: 0).isActive = true
        
        //  fb button
        facebookLoginButton.translatesAutoresizingMaskIntoConstraints = false
        facebookLoginButton.layer.cornerRadius = 10
        NSLayoutConstraint(item: facebookLoginButton, attribute: .bottom, relatedBy: .equal, toItem: googleButton, attribute: .top, multiplier: 1, constant: -15).isActive = true
        NSLayoutConstraint(item: facebookLoginButton, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 0.2, constant: 0).isActive = true
        NSLayoutConstraint(item: facebookLoginButton, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 0.8, constant: 0).isActive = true
        // height
        NSLayoutConstraint(item: facebookLoginButton, attribute: .height, relatedBy: .equal, toItem: passwordsLoginButton, attribute: .height, multiplier: 1, constant: 0).isActive = true
        
        // welcome image
        welcomeImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: welcomeImage, attribute: .bottom, relatedBy: .equal, toItem: accountTextfield, attribute: .top, multiplier: 1, constant: -15).isActive = true
        NSLayoutConstraint(item: welcomeImage, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 40).isActive = true
        NSLayoutConstraint(item: welcomeImage, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 0.15, constant: 0).isActive = true
        NSLayoutConstraint(item: welcomeImage, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 0.85, constant: 0).isActive = true
        welcomeImage.contentMode = .scaleAspectFit
    
        
        activityView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: activityView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: activityView, attribute: .centerY, relatedBy: .equal, toItem: accountTextfield, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        
        
        
    }
}
