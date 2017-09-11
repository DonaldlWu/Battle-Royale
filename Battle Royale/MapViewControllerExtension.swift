//
//  MapViewControllerExtension.swift
//  Battle Royale
//
//  Created by 吳得人 on 2017/9/6.
//  Copyright © 2017年 吳得人. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Firebase

extension MapViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        print("-----------------------------")
        print(location.coordinate)
        print("-----------------------------")
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        if mapView.isHidden {
            mapView.isHidden = false
            
        } else {
            mapView.animate(to: camera)
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
        var allScoreCoordinatesIndex = -1
        
        for scoreCoordinate in allScoreCoordinates {
            allScoreCoordinatesIndex += 1
            let path = GMSMutablePath()
            path.add((currentLocation?.coordinate)!)
            path.add(scoreCoordinate)
            let polyline = GMSPolyline(path: path)
            polyline.map = mapView
            let distance =  polyline.path?.length(of: .geodesic) ?? 0
            if distance < 50 {
                score += 1
                scoreLabel.text = "score = \(score)"
                allScoreCoordinates.remove(at: allScoreCoordinatesIndex)
                allScoreCoordinates.insert(self.randomCoordinate(from: (currentLocation?.coordinate)!), at: allScoreCoordinatesIndex)
                ref = Database.database().reference()
                let allScoreCoordinatesDoubleType = allScoreCoordinates.map{ [$0.latitude, $0.longitude]}
                ref.child("coordinates").child("scoreCoordinates").setValue(allScoreCoordinatesDoubleType)
                
            }
        }
    }
    
    func setupView() {
        view.addSubview(mapView)
        mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: 64).isActive = true
        mapView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        mapView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -128).isActive = true
        mapView.isHidden = true
        
        view.addSubview(button)
        button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60).isActive = true
        button.leftAnchor.constraint(equalTo: mapView.leftAnchor).isActive = true
        button.rightAnchor.constraint(equalTo: mapView.rightAnchor)
            .isActive = true
        button.heightAnchor.constraint(equalToConstant: 64).isActive = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logout))
        
        view.addSubview(scoreLabel)
        scoreLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 64).isActive = true
        scoreLabel.leftAnchor.constraint(equalTo: mapView.leftAnchor).isActive = true
        scoreLabel.rightAnchor.constraint(equalTo: mapView.centerXAnchor).isActive = true
        scoreLabel.heightAnchor.constraint(equalToConstant: 64).isActive = true
        
        view.addSubview(timerLabel)
        timerLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 64).isActive = true
        timerLabel.leftAnchor.constraint(equalTo: mapView.centerXAnchor).isActive = true
        timerLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -50).isActive = true
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
            button.isEnabled = true
            seconds = 300
            timerLabel.text = timeString(time: TimeInterval(seconds))
        }
    }
    
    func popAlert() {
        let alertController = UIAlertController(title: "你的成績", message: "\(scoreLabel.text!)分", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "UPDATE", style: .default, handler: {
            alert -> Void in
            //            update to firebase
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
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

