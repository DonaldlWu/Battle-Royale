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
    var seconds = 300
    var timer = Timer()
    var isTimerRunning = false
    var currentLocation: CLLocation? {
        didSet {
            setCurrentLocation()
        }
    }
    
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 18.0
    var circ = GMSCircle()
    var nextCircleCorordinate: CLLocationCoordinate2D?
    var ref: DatabaseReference!
    var allUid = [String]()
    var allOtherPlayerCoordinates = [CLLocationCoordinate2D]()
    var allScoreCoordinates = [CLLocationCoordinate2D]()
    var score = 0
    
    let button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("START", for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        button.addTarget(self, action: #selector(setCircle), for: .touchUpInside)
        return button
    }()
    
    let scoreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1)
        label.text = "score = 0"
        label.textAlignment = .center
        label.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        label.layer.cornerRadius = 0.15
        label.layer.masksToBounds = true
        label.clipsToBounds = true
        return label
    }()
    
    let timerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .cyan
        label.text = "05:00"
        label.textAlignment = .center
        label.textColor = .red
        label.clipsToBounds = true
        return label
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
        let camera = GMSCameraPosition.camera(withLatitude: 25.057203,
                                              longitude: 121.552778,
                                              zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = true
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.isMyLocationEnabled = true
        setupView()
    }

    @objc func setCircle() {
        button.isEnabled = false
        runTimer()
        if let lat = currentLocation?.coordinate.latitude , let lon = currentLocation?.coordinate.longitude {
            
            ref = Database.database().reference()
            let user = Auth.auth().currentUser
            ref.child("coordinates").child("players").updateChildValues([(user?.uid)!: [lat, lon]])
            
            let nextCircleCorordinate = randomCoordinate(from: (currentLocation?.coordinate)!)
            
            
            fetchAllPlayersCoordinates(completion: { (allOtherPlayerCoordinates, allScoreCoordinates)  in
                
                self.mapView.clear()
                self.addCircle(with: nextCircleCorordinate, circleColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).withAlphaComponent(0.1), strokeColor: #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1))
                self.addOtherPlayersCirclesAfterCompletion(with: allOtherPlayerCoordinates)
                self.addScoreCirclesAfterCompletion(with:allScoreCoordinates)
                
            })
        }
    }
    
    func randomCoordinate(from coordinate: CLLocationCoordinate2D) -> (CLLocationCoordinate2D) {
        
        let angleRandom = GKRandomDistribution(lowestValue: 0, highestValue: 360)
        let newaAngleRandom = angleRandom.nextInt()
        let nextLat = Double(coordinate.latitude) + sin(Double(newaAngleRandom) / 180 * Double.pi) * 0.0011
        let nextLon = Double(coordinate.longitude) + cos(Double(newaAngleRandom) / 180 * Double.pi) * 0.0011
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
    
    func fetchAllPlayersCoordinates(completion: @escaping (_ allOtherPlayerCoordinates: [CLLocationCoordinate2D], _ scoreCoordinates:  [CLLocationCoordinate2D]) -> ()) {
        
        ref = Database.database().reference()
        let userUid = Auth.auth().currentUser?.uid
        ref.child("coordinates").observe(.value) { (snapshot) in
            var allOtherPlayerCoordinates = [CLLocationCoordinate2D]()
            let playersSnapshot = snapshot.childSnapshot(forPath: "players")
            let playersCoordinates = playersSnapshot.children
            for player in playersCoordinates {
                if let player = player as? DataSnapshot {
                    if player.key != userUid {
                        if let playerCoordinate = player.value as? [Double] {
                            allOtherPlayerCoordinates.append(CLLocationCoordinate2D(latitude: playerCoordinate[0], longitude: playerCoordinate[1]))
                        }
                    }
                }
            }
            var newScoreCoordinates = [CLLocationCoordinate2D]()
            let scoreCoordinatesSnapshot = snapshot.childSnapshot(forPath: "scoreCoordinates")
            let scoreCoordinates = scoreCoordinatesSnapshot.children
            for coordinate in scoreCoordinates {
                
                if let coordinate = coordinate as? DataSnapshot {
                    
                    if let coordinate = coordinate.value as? [Double] {
                        newScoreCoordinates.append(CLLocationCoordinate2D(latitude: coordinate[0], longitude: coordinate[1]))
                        completion(allOtherPlayerCoordinates, newScoreCoordinates)
                    }
                }
            }
        }
    }
    
    func fetchAllScorePoints(completion: @escaping ([CLLocationCoordinate2D]) -> ()) {
        var allNewCoordinates = [CLLocationCoordinate2D]()
        ref = Database.database().reference()
        let userUid = Auth.auth().currentUser?.uid
        ref.child("scoreCoordinates").observe(.value) { (snapshot) in
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
    func addOtherPlayersCirclesAfterCompletion(with allOtherPlayerCoordinates: [CLLocationCoordinate2D]) {
        self.allOtherPlayerCoordinates = allOtherPlayerCoordinates
        for otherPlayerCoordinate in self.allOtherPlayerCoordinates {
            self.addCircle(with: otherPlayerCoordinate, circleColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).withAlphaComponent(0.1), strokeColor: #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1))
        }
    }
    func addScoreCirclesAfterCompletion(with allScoreCoordinates: [CLLocationCoordinate2D]) {
        self.allScoreCoordinates = allScoreCoordinates
        for scoreCoordinate in self.allScoreCoordinates {
            self.addCircle(with: scoreCoordinate, circleColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).withAlphaComponent(0.1), strokeColor: #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1))
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

