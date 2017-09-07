//
//  ViewController.swift
//  Battle Royale
//
//  Created by 吳得人 on 2017/9/6.
//  Copyright © 2017年 吳得人. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class MapViewController: UIViewController {
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 18.0
    var circ = GMSCircle()
    var nextCircleCorordinate: CLLocationCoordinate2D?
    
    
    let button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("START", for: .normal)
        button.backgroundColor = .cyan
        button.addTarget(self, action: #selector(setCircle), for: .touchUpInside)
        return button
    }()
    
    let nextButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Next", for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.9601936936, green: 0.4837267399, blue: 0.5332353115, alpha: 1)
        button.addTarget(self, action: #selector(nextCircle), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        placesClient = GMSPlacesClient.shared()
        let camera = GMSCameraPosition.camera(withLatitude: 25.039016,
                                              longitude: 121.376042,
                                              zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.settings.myLocationButton = true
        //mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.isMyLocationEnabled = true
        
        // Add the map to the view, hide it until we've got a location update.
        view.addSubview(mapView)
        
        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mapView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        mapView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -128).isActive = true
        
        mapView.isHidden = true
        view.addSubview(button)
        
        button.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        button.leftAnchor.constraint(equalTo: mapView.leftAnchor).isActive = true
        button.rightAnchor.constraint(equalTo: mapView.rightAnchor).isActive = true
        button.heightAnchor.constraint(equalToConstant: 64).isActive = true
        
        view.addSubview(nextButton)
        
        nextButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -64).isActive = true
        nextButton.leftAnchor.constraint(equalTo: mapView.leftAnchor).isActive = true
        nextButton.rightAnchor.constraint(equalTo: mapView.rightAnchor).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: 64).isActive = true
        
    }
    
    @objc func setCircle() {
        if let lat = currentLocation?.coordinate.latitude , let lon = currentLocation?.coordinate.longitude {
            //let circleCenter = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            let nextLat = Double(lat) + 0.0013
            nextCircleCorordinate = CLLocationCoordinate2D(latitude: nextLat, longitude: lon)
            mapView.clear()
            mapView.reloadInputViews()
            circ = GMSCircle(position: nextCircleCorordinate!, radius: 50)
            circ.fillColor = UIColor(red:0.35, green:0, blue:0, alpha:0.05)
            circ.strokeColor = .red
            circ.strokeWidth = 5
            circ.map = mapView
            
            
        }
    }
    
    
    @objc func nextCircle() {
        let nextController = NextCircleViewController()
        if let nextCircleCorordinate = self.nextCircleCorordinate {
            
            nextController.coordinator = nextCircleCorordinate
           
            
            show(nextController, sender: nil)
            
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextCircleController = segue.destination as? NextCircleViewController
        nextCircleController?.nextCircleCorordinate = self.nextCircleCorordinate!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

