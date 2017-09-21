//
//  TimerExtension.swift
//  Battle Royale
//
//  Created by Vince Lee on 2017/9/14.
//  Copyright © 2017年 吳得人. All rights reserved.
//

import Foundation
import UIKit
import Firebase

extension MapViewController {
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(MapViewController.updateTimer)), userInfo: nil, repeats: true)
    }
    
    
    
    @objc func updateTimer() {
        seconds -= 1
        timerLabel.text = timeString(time: TimeInterval(seconds))
        if seconds == 0 {
            timer.invalidate()
            popAlert()
            start = false
            seconds = 1200
            timerLabel.text = timeString(time: TimeInterval(seconds))
            button.backgroundColor = #colorLiteral(red: 0.9272366166, green: 0.2351297438, blue: 0.103588976, alpha: 1).withAlphaComponent(0.8)
            button.layer.shadowColor = #colorLiteral(red: 0.9272366166, green: 0.2351297438, blue: 0.103588976, alpha: 1)
            button.setTitle("▶︎", for: .normal)
        }
    }
    
    func popAlert() {
        let alertController = UIAlertController(title: "你的成績", message: "\(score)分", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "UPDATE", style: .default, handler: {
            alert -> Void in
            //            update to firebase
            self.ref = Database.database().reference()
            let userUid = Auth.auth().currentUser?.uid
            self.ref.child("users").child(userUid!).updateChildValues(["score" : self.score])
            self.score = 0
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            self.score = 0
        })
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func timeString(time: TimeInterval) -> String {
        //        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i",  minutes, seconds)
        //        return String(format:"%02i:%02i:%02i",hours ,minutes, seconds)
    }
    
    func runLocationUpdateTimer(with sec: Double) {
        locationUpdateTimer = Timer.scheduledTimer(timeInterval: sec, target: self, selector: (#selector(MapViewController.updateLocation)), userInfo: nil, repeats: true)
    }
    
    @objc func updateLocation() {
        locationManager.stopUpdatingLocation()
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
    }
}
