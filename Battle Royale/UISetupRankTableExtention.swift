//
//  UISetupRankTableExtention.swift
//  城市碰碰球-CityPonPon
//
//  Created by Vince Lee on 2017/10/7.
//  Copyright © 2017年 吳得人. All rights reserved.
//

import Foundation
import UIKit

extension RankTableViewController {
    
    func addGradiantLayer(sender: UITableViewController, colors: [CGColor]) {
        // Create Gradient Layer
        
        let gradientLayer = CAGradientLayer()
        // Set Layer Size
        gradientLayer.frame = sender.tableView.bounds
        // Provide an Array of CGColors
        gradientLayer.colors = colors 
        // Guesstimate a Match to 47° in Coordinates
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.95)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.05)
        
        // Add Gradient Layer to Test View
        let backgroundView = UIView(frame: sender.tableView.bounds)
        backgroundView.layer.insertSublayer(gradientLayer, at: 0)
         sender.tableView.backgroundView = backgroundView
        
    }
    
}
