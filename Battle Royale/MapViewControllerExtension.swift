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
    
    func updateMainPlayerCircle() {
        ref = Database.database().reference()
        if let coord = currentLocation?.coordinate, let radius = mainPlayerRadius, let style = mapView.style, let userUid = Auth.auth().currentUser?.uid  {
            let mainShape = updateShapes(coords: [coord], radiusMeter: Double(radius))
            self.addLayer(to: style, with: "mainPlayer", MapViewController.mainPlayerColor, shapes: mainShape)
         
                let lat = coord.latitude
                let lon = coord.longitude
                ref.child("coordinates").child("players").updateChildValues([(userUid): [lat, lon, mainPlayerRadius]])
        }
    }
    
    func setCurrentLocation() {
        ref = Database.database().reference()
        if let coord = self.currentLocation?.coordinate, let radius = self.mainPlayerRadius {
            
            // update socre coords in X distance
            let allScoreCoordsFiltered = filterCoords(scoreCoords)
            let scoreShapes = self.updateShapes(coords:allScoreCoordsFiltered , radiusMeter: 50)
            let mainShape = self.updateShapes(coords: [coord], radiusMeter: Double(radius))
            // mapbox update layer
            if let style = self.mapView.style {
               self.addLayer(to: style, with: "scorePoints", #colorLiteral(red: 0.9272366166, green: 0.2351297438, blue: 0.103588976, alpha: 1).withAlphaComponent(0.5), shapes: scoreShapes)
                self.addLayer(to: style, with: "mainPlayer", MapViewController.mainPlayerColor, shapes: mainShape)
            }
            // game start then compute player  and score/other players distance
            if start == true {
                var scoreCoords: [CLLocationCoordinate2D] {
                    var coords = [CLLocationCoordinate2D]()
                    for coord in self.scoreCoords {
                        coords.append(coord.coord)
                    }
                    return coords
                }
                scoreDistance(distanceLimit: Double(50 + mainPlayerRadius!), coords: scoreCoords)
                otherPlayerDistance(coords: otherPlayers)
            }
            if let userUid = Auth.auth().currentUser?.uid {
                let lat = coord.latitude
                let lon = coord.longitude
                ref.child("coordinates").child("players").updateChildValues([(userUid): [lat, lon, mainPlayerRadius]])
            }
        }
    }
    func scoreDistance(distanceLimit: Double, coords: [CLLocationCoordinate2D]) {
        let currentCoord = currentLocation?.coordinate
        var scoreCoordIndex = -1
        for coord in coords {
            scoreCoordIndex += 1
            let path = GMSMutablePath()
            path.add(coord)
            path.add(currentCoord!)
            let polyline = GMSPolyline(path: path)
            let distance =  polyline.path?.length(of: .geodesic) ?? 0
            if distance < distanceLimit {
                // iphone vibrate
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                // update score
                score += 5
                mainPlayerRadius! += 5

                scoreLabel.text = "\(score)  ⦿"
                // delete score coordinate and add a random one
                scoreCoords.remove(at: scoreCoordIndex)
                let newRandomCoord = ScoreCircle(coord: self.randomCoordinate(radius: 300, from: currentCoord!), index: scoreCoordIndex)
                scoreCoords.insert(newRandomCoord, at: scoreCoordIndex)
                ref = Database.database().reference()
              
                ref.child("coordinates").child("scoreCoordinates").child("\(scoreCoordIndex)").updateChildValues(["lat" : Double(newRandomCoord.coord.latitude), "lon": Double(newRandomCoord.coord.longitude)])
            }
        }
    }
    
    func otherPlayerDistance(coords: [PlayerCircle]) {
        let currentCoord = currentLocation?.coordinate
        var allScoreCoordinatesIndex = -1
        for coord in coords {
            
            allScoreCoordinatesIndex += 1
            let path = GMSMutablePath()
            if let coord = coord.coord {
                path.add(coord)
            }
            path.add(currentCoord!)
            let polyline = GMSPolyline(path: path)
            let distance =  polyline.path?.length(of: .geodesic) ?? 0
            if let mainPlayerRadius = mainPlayerRadius, let coordRadius = coord.radius, distance < Double(mainPlayerRadius + coordRadius) {
                // iphone vibrate
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                // update score
                if mainPlayerRadius > coordRadius {
                    score += Int(coordRadius)
                    self.mainPlayerRadius = self.mainPlayerRadius! + coordRadius
                    scoreLabel.text = "\(score)  ⦿"
                    if let uid = coord.uid {
                        ref.child("coordinates").child("players").child(uid).removeValue()
                    }
                } else if mainPlayerRadius < coordRadius{
                    
                    self.mainPlayerRadius = 10
                    endCount()
                    locationManager.stopUpdatingLocation()
                }
                
            }
        }
    }
    
    
    
}

