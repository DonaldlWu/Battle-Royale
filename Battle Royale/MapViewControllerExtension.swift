//
//  MapViewControllerExtension.swift
//  Battle Royale
//
//  Created by 吳得人 on 2017/9/6.
//  Copyright © 2017年 吳得人. All rights reserved.
//

import UIKit
import GoogleMaps

import Firebase
import AudioToolbox

extension MapViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
//        print("Location: \(location)")
//        print("-----------------------------")
//        print(location.coordinate)
//        print("-----------------------------")
        
        if mapView.isHidden {
            mapView.isHidden = false
            
        } else {
            
        }
        currentLocation = location
        
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
    
    func setCurrentLocation() {
        print(currentLocation!)
        
        ref = Database.database().reference()
        let user = Auth.auth().currentUser
        
        if let lat = currentLocation?.coordinate.latitude, let lon = currentLocation?.coordinate.longitude {
            ref.child("coordinates").child("players").updateChildValues([(user?.uid)!: [lat, lon]])
        }
        
        if start == true {
            var allScoreCoordinatesIndex = -1
            for scoreCoordinate in allScoreCoordinates {
                allScoreCoordinatesIndex += 1
                let path = GMSMutablePath()
                path.add((currentLocation?.coordinate)!)
                path.add(scoreCoordinate)
                let polyline = GMSPolyline(path: path)
                
                let distance =  polyline.path?.length(of: .geodesic) ?? 0
                if distance < 55 {
                    // iphone vibrate
               AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                    // update score
                    score += 1
                    scoreLabel.text = "\(score)  ⦿"
                    // delete score coordinate and add a random one
                    allScoreCoordinates.remove(at: allScoreCoordinatesIndex)
                    allScoreCoordinates.insert(self.randomCoordinate(from: (currentLocation?.coordinate)!), at: allScoreCoordinatesIndex)
                    ref = Database.database().reference()
                    let allScoreCoordinatesDoubleType = allScoreCoordinates.map{ [$0.latitude, $0.longitude]}
                    ref.child("coordinates").child("scoreCoordinates").setValue(allScoreCoordinatesDoubleType)
                    
                }
            }
        }
    }
    
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
    }
    
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
            seconds = 300
            timerLabel.text = timeString(time: TimeInterval(seconds))
            button.backgroundColor = #colorLiteral(red: 0.9272366166, green: 0.2351297438, blue: 0.103588976, alpha: 1)
            button.layer.shadowColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
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
    
}

