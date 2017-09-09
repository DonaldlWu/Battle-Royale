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
import GameKit
import Firebase
import GoogleSignIn

class MapViewController: UIViewController {
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 18.0
    var circ = GMSCircle()
    var nextCircleCorordinate: CLLocationCoordinate2D?
    var ref: DatabaseReference!
    var allUid = [String]()
    var allCoordinates = [CLLocationCoordinate2D]()
    
    
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
        mapView.settings.compassButton = true
        
        //mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.isMyLocationEnabled = true
        
        // Add the map to the view, hide it until we've got a location update.
        view.addSubview(mapView)
        
        mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: 64).isActive = true
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
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logout))
        
    }
    
    @objc func setCircle() {
        if let lat = currentLocation?.coordinate.latitude , let lon = currentLocation?.coordinate.longitude {
            
            ref = Database.database().reference()
            let user = Auth.auth().currentUser
            ref.child("coordinates").updateChildValues([(user?.uid)!: [lat, lon]])
            
            let nextCircleCorordinate = randomCoordinate(lat: lat, lon: lon)
            
            
            fetchAllPlayersCoordinates(completion: { (allNewCoordinates) in
                
                print(self.allCoordinates)
                self.mapView.clear()
                self.addCircle(with: nextCircleCorordinate, circleColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).withAlphaComponent(0.1), strokeColor: #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1))
                self.allCoordinates = allNewCoordinates
                for otherCoordinate in self.allCoordinates {
                    self.addCircle(with: otherCoordinate, circleColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).withAlphaComponent(0.1), strokeColor: #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1))
                    
                    
                }
            })
            
            
            
            
        }
    }
    
    
    @objc func nextCircle() {
        let nextController = NextCircleViewController()
        if let nextCircleCorordinate = self.nextCircleCorordinate {
            nextController.coordinator = nextCircleCorordinate
            show(nextController, sender: nil)
        }
    }
    
    func randomCoordinate(lat: CLLocationDegrees, lon: CLLocationDegrees ) -> (CLLocationCoordinate2D) {
        
        let angleRandom = GKRandomDistribution(lowestValue: 0, highestValue: 360)
        let newaAngleRandom = angleRandom.nextInt()
        let nextLat = Double(lat) + sin(Double(newaAngleRandom) / 180 * Double.pi) * 0.0005
        let nextLon = Double(lon) + cos(Double(newaAngleRandom) / 180 * Double.pi) * 0.0005
        nextCircleCorordinate = CLLocationCoordinate2D(latitude: nextLat, longitude: nextLon)
        return nextCircleCorordinate!
    }
    
    func addCircle(with circleCorordinate: CLLocationCoordinate2D, circleColor: UIColor, strokeColor: UIColor) {
        
        circ = GMSCircle(position: circleCorordinate, radius: 50)
        circ.fillColor = circleColor
        circ.strokeColor = strokeColor
        circ.strokeWidth = 5
        circ.map = mapView
        
    }
    
    func fetchAllPlayersUid(completion: @escaping ([String]) -> ()) {
        var newAllUid = [String]()
        ref = Database.database().reference()
        ref.child("users").observe(.value, with: { (snapshot) in
            newAllUid = []
            for uid in snapshot.children {
                if let uid = uid as? DataSnapshot {
                    DispatchQueue.main.async {
                        newAllUid.append(uid.key)
                        print(newAllUid)
                        completion(newAllUid)
                    }
                }
            }
        })
    }
    
    func fetchAllPlayersCoordinates(completion: @escaping ([CLLocationCoordinate2D]) -> ()) {
        var allNewCoordinates = [CLLocationCoordinate2D]()
        ref = Database.database().reference()
        let userUid = Auth.auth().currentUser?.uid
        ref.child("coordinates").observe(.value) { (snapshot) in
            let coordinates = snapshot.children
            for player in coordinates {
                if let player = player as? DataSnapshot {
                    if player.key != userUid {
                        if let playerCoordinate = player.value as? [Double] {
                            
                            allNewCoordinates.append(CLLocationCoordinate2D(latitude: playerCoordinate[0], longitude: playerCoordinate[1]))
                            completion(allNewCoordinates)
                        }
                    }
                }
            }
        }
        
        
        
        
        
    }
    
    @objc func logout() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        GIDSignIn.sharedInstance().signOut()
        dismiss(animated: true, completion: nil)
        
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

