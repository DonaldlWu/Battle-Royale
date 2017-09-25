//
//  MapBoxDelegate.swift
//  Battle Royale
//
//  Created by Vince Lee on 2017/9/14.
//  Copyright © 2017年 吳得人. All rights reserved.
//

import Foundation
import Mapbox
import GoogleMaps

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
            
            if circlesCoords.count != 0 {
                let shape = MGLPolygon(coordinates: circlesCoords, count: UInt(circlesCoords.count))
                
                newScoreShapes.append(shape)
            }
        }
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

    
     func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
          var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: "anno")
        
        if annotationImage == nil {
            // Leaning Tower of Pisa by Stefan Spieler from the Noun Project.
            var image = UIImage(named: "pisavector")!
            
            // The anchor point of an annotation is currently always the center. To
            // shift the anchor point to the bottom of the annotation, the image
            // asset includes transparent bottom padding equal to the original image
            // height.
            //
            // To make this padding non-interactive, we create another image object
            // with a custom alignment rect that excludes the padding.
            image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))
            
            // Initialize the ‘pisa’ annotation image with the UIImage we just loaded.
            annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "pisa")
        }
        
        return annotationImage
    }
    
    func addLayer(to style: MGLStyle,with identifier: String, _ color: UIColor, shapes: [MGLPolygon], source: inout MGLShapeSource?, layer:inout MGLFillStyleLayer?) {
        
        if let source = source, let layer = layer {
            style.removeLayer(layer)
            style.removeSource(source)
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
    
    func filterCoords(_ coords: [CLLocationCoordinate2D]) -> [CLLocationCoordinate2D]{
        var newCoords: [CLLocationCoordinate2D] = []
        for coord in coords {
            
            if let currentCoord = currentLocation?.coordinate, let radius = mainPlayerRadius {
                let path = GMSMutablePath()
                path.add(coord)
                path.add(currentCoord)
                let polyline = GMSPolyline(path: path)
                let distance =  polyline.path?.length(of: .geodesic) ?? 0
                if distance < Double(radius * 80) {
                    newCoords.append(coord)
                }
                
            }
        }
        return newCoords
    }
    
}
