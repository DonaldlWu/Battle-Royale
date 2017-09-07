//
//  NextCircleViewController.swift
//  Battle Royale
//
//  Created by Vince Lee on 2017/9/7.
//  Copyright © 2017年 吳得人. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class NextCircleViewController: MapViewController {

   
    var coordinator = CLLocationCoordinate2D()
    
    let checkButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Check", for: .normal)
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(checkDist), for: .touchUpInside)
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
        
        
        view.addSubview(checkButton)
        checkButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -64).isActive = true
        checkButton.leftAnchor.constraint(equalTo: mapView.leftAnchor).isActive = true
        checkButton.rightAnchor.constraint(equalTo: mapView.rightAnchor).isActive = true
        checkButton.heightAnchor.constraint(equalToConstant: 64).isActive = true
        
    }
    
    @objc func checkDist() {
        let path = GMSMutablePath()
        path.add(CLLocationCoordinate2D(latitude: (currentLocation?.coordinate.latitude)!, longitude: (currentLocation?.coordinate.longitude)!))
        path.add(coordinator)
        let polyline = GMSPolyline(path: path)
        polyline.map = mapView
        let distance =  polyline.path?.length(of: .geodesic) ?? 0
        print(distance)
        if distance <= 200 {
            showAlertController(title: "SUCCESS")
        } else {
            showAlertController(title: "FAILD")
        }
    }
    
    @objc override func setCircle() {
        circ = GMSCircle(position: coordinator, radius: 50)
        circ.fillColor = UIColor(red:0.35, green:0, blue:0, alpha:0.05)
        circ.strokeColor = .red
        circ.strokeWidth = 5
        circ.map = mapView
    }
    
    func showAlertController(title: String) {
        if title == "SUCCESS" {
            let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
            let top = UIAlertAction(title: "OK", style: .destructive, handler: {
                alert -> Void in
                let mapViewController = self.navigationController?.viewControllers[0] as! MapViewController
                mapViewController.setCircle()
                self.navigationController?.popViewController(animated: true)
            })
            
            alertController.addAction(top)
            self.present(alertController, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
            let top = UIAlertAction(title: "OK", style: .destructive, handler: {
                alert -> Void in
                self.navigationController?.popViewController(animated: true)
            })
            
            alertController.addAction(top)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


