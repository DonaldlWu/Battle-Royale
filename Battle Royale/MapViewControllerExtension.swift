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
        ref = Database.database().reference()
        let coord = currentLocation?.coordinate
        if let lat = coord?.latitude, let lon = coord?.longitude, let userUid = Auth.auth().currentUser?.uid {
            ref.child("coordinates").child("players").updateChildValues([(userUid): [lat, lon]])
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
                if distance < 50 {
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
}

