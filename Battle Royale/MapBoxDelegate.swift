//
//  MapBoxDelegate.swift
//  Battle Royale
//
//  Created by Vince Lee on 2017/9/14.
//  Copyright © 2017年 吳得人. All rights reserved.
//

import Foundation
import  Mapbox

extension MapViewController: MGLMapViewDelegate {
    
    func addOtherPlayersCirclesAfterCompletion(with allOtherPlayerCoordinates: [CLLocationCoordinate2D]) {
        self.allOtherPlayerCoordinates = allOtherPlayerCoordinates
            self.addPolygonCircle(coords: allOtherPlayerCoordinates, radiusMeter: 50)
        
    }
    func addScoreCirclesAfterCompletion(with allScoreCoordinates: [CLLocationCoordinate2D]) {
        self.allScoreCoordinates = allScoreCoordinates
        
            self.addPolygonCircle(coords: allScoreCoordinates, radiusMeter: 50)
        
    }
    func addPolygonCircle(coords: [CLLocationCoordinate2D], radiusMeter: Double) {
        let circleNumbers = 64
        
        for center in coords {
            var circlesCoords: [CLLocationCoordinate2D] = []
            for i in 1...circleNumbers {
                
                let lat = Double(center.latitude) + sin(Double(i) / Double(circleNumbers) * 2 * Double.pi) * 0.000008983417785 * radiusMeter * cos(center.latitude / 180 * Double.pi)
                let lon = Double(center.longitude) + cos(Double(i) / Double(circleNumbers) * 2 * Double.pi) * 0.000009014705689 * radiusMeter
                let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                
                circlesCoords.append(coord)
            }
            let shape = MGLPolygon(coordinates: circlesCoords, count: UInt(circlesCoords.count))
            
            mapView.addAnnotation(shape)
        }
        
    }
    
    
    func mapView(_ mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
        return 0.2
    }
    func mapView(_ mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        return #colorLiteral(red: 0.9272366166, green: 0.2351297438, blue: 0.103588976, alpha: 1)
    }
    
    func mapView(_ mapView: MGLMapView, fillColorForPolygonAnnotation annotation: MGLPolygon) -> UIColor {
        return #colorLiteral(red: 0.9272366166, green: 0.2351297438, blue: 0.103588976, alpha: 1)
        
        
    }
}
