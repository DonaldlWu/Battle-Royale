//
//  MapUISetupExtension.swift
//  Battle Royale
//
//  Created by Vince Lee on 2017/9/15.
//  Copyright © 2017年 吳得人. All rights reserved.
//

import Foundation
import UIKit

extension MapViewController {
    func setupView() {
        
        view.addSubview(mapView)
        mapView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
        mapView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        mapView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor).isActive = true
        mapView.isHidden = true
        
        mapView.addSubview(button)
        NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .equal, toItem: mapView, attribute: .bottom, multiplier: 0.95, constant: 0).isActive = true
        NSLayoutConstraint(item: button, attribute: .leading, relatedBy: .equal, toItem: mapView, attribute: .trailing, multiplier: 0.3, constant: 0).isActive = true
        NSLayoutConstraint(item: button, attribute: .trailing, relatedBy: .equal, toItem: mapView, attribute: .trailing, multiplier: 0.7, constant: 0).isActive = true
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        
        view.addSubview(scoreLabel)
        NSLayoutConstraint(item: scoreLabel, attribute: .top, relatedBy: .equal, toItem: mapView, attribute: .bottom, multiplier: 0.12, constant: 0).isActive = true
        NSLayoutConstraint(item: scoreLabel, attribute: .leading, relatedBy: .equal, toItem: mapView, attribute: .trailing, multiplier: 0.1, constant: 0).isActive = true
        NSLayoutConstraint(item: scoreLabel, attribute: .trailing, relatedBy: .equal, toItem: mapView, attribute: .trailing, multiplier: 0.45, constant: 0).isActive = true
        scoreLabel.heightAnchor.constraint(equalToConstant: 64).isActive = true
        
        view.addSubview(timerLabel)
        NSLayoutConstraint(item: timerLabel, attribute: .top, relatedBy: .equal, toItem: mapView, attribute: .bottom, multiplier: 0.12, constant: 0).isActive = true
        NSLayoutConstraint(item: timerLabel, attribute: .leading, relatedBy: .equal, toItem: mapView, attribute: .trailing, multiplier: 0.55, constant: 0).isActive = true
        NSLayoutConstraint(item: timerLabel, attribute: .trailing, relatedBy: .equal, toItem: mapView, attribute: .trailing, multiplier: 0.9, constant: 0).isActive = true
        timerLabel.heightAnchor.constraint(equalToConstant: 64).isActive = true
        
        view.addSubview(moveToCurrentLoactionButton)
        NSLayoutConstraint(item: moveToCurrentLoactionButton, attribute: .centerY, relatedBy: .equal, toItem: button, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
 
       NSLayoutConstraint(item: moveToCurrentLoactionButton, attribute: .height, relatedBy: .equal, toItem: button, attribute: .height, multiplier: 0.8, constant: 0).isActive = true
        
        NSLayoutConstraint(item: moveToCurrentLoactionButton, attribute: .centerX, relatedBy: .equal, toItem: mapView, attribute: .trailing, multiplier: 0.83, constant: 0).isActive = true
        
        NSLayoutConstraint(item: moveToCurrentLoactionButton, attribute: .width, relatedBy: .equal, toItem: moveToCurrentLoactionButton, attribute: .height, multiplier: 1, constant: 0).isActive = true
       
    }
    
    
    
    
}
