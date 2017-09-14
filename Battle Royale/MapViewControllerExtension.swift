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
        let userUid = Auth.auth().currentUser?.uid
        let coord = currentLocation?.coordinate
        if let lat = coord?.latitude, let lon = coord?.longitude {
            ref.child("coordinates").child("players").updateChildValues([(userUid)!: [lat, lon]])
        }
        
        if start == true {
            var allScoreCoordinatesIndex = -1
            for scoreCoordinate in allScoreCoords {
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
                    allScoreCoords.remove(at: allScoreCoordinatesIndex)
                    allScoreCoords.insert(self.randomCoordinate(from: (currentLocation?.coordinate)!), at: allScoreCoordinatesIndex)
                    ref = Database.database().reference()
                    let allScoreCoordinatesDoubleType = allScoreCoords.map{ [$0.latitude, $0.longitude]}
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
    
    
    
}

