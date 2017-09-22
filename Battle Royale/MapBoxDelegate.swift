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
    
    func updateShapes(coords: [CLLocationCoordinate2D], radiusMeter: Double) -> [MGLPolygon]{
        let circleNumbers = 64
        var newScoreShapes: [MGLPolygon] = []
        for center in coords {
            var circlesCoords: [CLLocationCoordinate2D] = []
            for i in 1...circleNumbers {
                let lat = Double(center.latitude) + sin(Double(i) / Double(circleNumbers) * 2 * Double.pi) * 0.000008983417785 * radiusMeter * cos(center.latitude / 180 * Double.pi)
                let lon = Double(center.longitude) + cos(Double(i) / Double(circleNumbers) * 2 * Double.pi) * 0.000009014705689 * radiusMeter
                let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                circlesCoords.append(coord)
            }
            let shape = MGLPolygon(coordinates: circlesCoords, count: UInt(circlesCoords.count))
            newScoreShapes.append(shape)
        }
        //                mapView.addAnnotations(newScoreShapes)
        
        return newScoreShapes
    }
    
    func updateOtherPlayerShapes(_ otherPlayers: [PlayerCircle]) -> [MGLPolygon]{
        let circleNumbers = 64
        var newScoreShapes: [MGLPolygon] = []
        for otherPlayer in otherPlayers {
            var circlesCoords: [CLLocationCoordinate2D] = []
            if let lat = otherPlayer.coord?.latitude, let lon = otherPlayer.coord?.longitude, let radius = otherPlayer.radius {
                for i in 1...circleNumbers {
                    let lat = Double(lat) + sin(Double(i) / Double(circleNumbers) * 2 * Double.pi) * 0.000008983417785 * Double(radius) * cos(lat / 180 * Double.pi)
                    let lon = Double(lon) + cos(Double(i) / Double(circleNumbers) * 2 * Double.pi) * 0.000009014705689 * Double(radius)
                    let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    circlesCoords.append(coord)
                }
            }
            let shape = MGLPolygon(coordinates: circlesCoords, count: UInt(circlesCoords.count))
            newScoreShapes.append(shape)
        }
        //                mapView.addAnnotations(newScoreShapes)
        
        return newScoreShapes
    }
    
    
    func mapView(_ mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
        return 1
    }
    func mapView(_ mapView: MGLMapView, strokeColorForShapeAnnotation annotations: MGLShape) -> UIColor {
        return #colorLiteral(red: 0.9272366166, green: 0.2351297438, blue: 0.103588976, alpha: 1)
    }
    
    func mapView(_ mapView: MGLMapView, fillColorForPolygonAnnotation annotation: MGLPolygon) -> UIColor {
        return #colorLiteral(red: 0.9272366166, green: 0.2351297438, blue: 0.103588976, alpha: 1)
    }
    
    
    func addLayer(to style: MGLStyle,with identifier: String, _ color: UIColor, shapes: [MGLPolygon], source: inout MGLShapeSource?, layer:inout MGLFillStyleLayer?) {
        
        if let source = source, let layer = layer {
            
//            style.removeSource(source)
            style.removeLayer(layer)
            number += 1
        }
        
        source = MGLShapeSource(identifier: "\(identifier)-\(number)", shapes: shapes, options: nil)
        layer = MGLFillStyleLayer(identifier: "\(identifier)-\(number)", source: source!)
        layer!.sourceLayerIdentifier = "\(identifier)-\(number)"
        layer!.fillColor = MGLStyleValue(rawValue: color)
        style.addSource(source!)
        if let building = style.layer(withIdentifier: "building") {
            // You can insert a layer below an existing style layer
            style.insertLayer(layer!, below: building)
        } else {
            // or you can simply add it above all layers
            style.addLayer(layer!)
        }
    }
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        
    }
    
}

