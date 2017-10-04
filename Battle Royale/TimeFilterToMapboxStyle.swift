//
//  TimeFilterToMapboxStyle.swift
//  Battle Royale
//
//  Created by Vince Lee on 2017/10/4.
//  Copyright © 2017年 吳得人. All rights reserved.
//

import Foundation
import Mapbox
import UIKit

extension MapViewController {
    func timeFilterMapboxStyleImport() -> MGLMapView {
        let UTCDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        
        let dayMap = URL(string: "mapbox://styles/vince9458/cj7j8jyhv6afo2rnitqd3xnmq")
        let nightMap = URL(string:
             "mapbox://styles/vince9458/cj8d67t5x0xub2sn9bnnt8po1")
        let hour24TimeStr = formatter.string(from: UTCDate)
        if let time = Int(hour24TimeStr), time > 6 && time < 18 {
            return MGLMapView(frame: view.bounds, styleURL: dayMap)
        } else {
            
            
            return MGLMapView(frame: view.bounds, styleURL: nightMap)
           
        }
    }

    func dayNightUIFilter() {
        let UTCDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        let hour24TimeStr = formatter.string(from: UTCDate)
         if let time = Int(hour24TimeStr), time > 6 && time < 18 {
            UIApplication.shared.statusBarStyle = .default
         } else {
            // status bar
            UIApplication.shared.statusBarStyle = .lightContent
    }
    
}
}
