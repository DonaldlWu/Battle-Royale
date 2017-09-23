//
//  TapHideButtonExtension.swift
//  Battle Royale
//
//  Created by Vince Lee on 2017/9/23.
//  Copyright © 2017年 吳得人. All rights reserved.
//

import Foundation
import UIKit

extension MapViewController: UIGestureRecognizerDelegate {
    
   @objc func handleSingleTap(tap: UITapGestureRecognizer) {
        print("單指時觸發")
    
        if hideButton {
            hideButton = false
            
            button.isHidden = false
            moveToCurrentLoactionButton.isHidden = false
            scoreLabel.isHidden = false
            timerLabel.isHidden = false
            
            
        } else {
            hideButton = true
            
            button.isHidden = true
            moveToCurrentLoactionButton.isHidden = true
            scoreLabel.isHidden = true
            timerLabel.isHidden = true
        }
        
        
    }

    
}
