//
//  ViewController.swift
//  Battle Royale
//
//  Created by 吳得人 on 2017/9/6.
//  Copyright © 2017年 吳得人. All rights reserved.
//

import UIKit
import GoogleMaps
import Mapbox
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
    
    var mapView: MGLMapView!
    
    var zoomLevel: Float = 18.0
    var circ = GMSCircle()
    var nextCircleCorordinate: CLLocationCoordinate2D?
    var ref: DatabaseReference!
    var allUid = [String]()
    var allOtherPlayerCoordinates = [CLLocationCoordinate2D]()
    var allScoreCoordinates = [CLLocationCoordinate2D]()
    var score = 0
    var start = false
    
    let button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("▶︎", for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1).withAlphaComponent(0.8)
        button.layer.cornerRadius = 25
        button.layer.shadowRadius = 3
        button.layer.shadowColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        button.layer.shadowOpacity = 0.6
        
        
        button.addTarget(self, action: #selector(setCircle), for: .touchUpInside)
        return button
    }()
    
    let scoreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.text = "0  ⦿"
        
        label.font = label.font.withSize(30)
        label.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1).withAlphaComponent(0.9)
        label.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 15
        
        
        return label
    }()
    
    let timerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.text = "05:00"
        label.font = label.font.withSize(30)
        label.backgroundColor = #colorLiteral(red: 0.8530249, green: 0.847953856, blue: 0.8569234014, alpha: 1).withAlphaComponent(0.9)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 15
        
        
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
        
        
        let camera = GMSCameraPosition.camera(withLatitude: 25.057203,
                                              longitude: 121.552778,
                                              zoom: zoomLevel)
        let url = URL(string: "mapbox://styles/vince9458/cj7j8jyhv6afo2rnitqd3xnmq")
        self.mapView = MGLMapView(frame: view.bounds, styleURL: url)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.setCenter(CLLocationCoordinate2D(latitude: 25.021293, longitude: 121.538006), zoomLevel: 9, animated: false)
        
        mapView.userTrackingMode = .follow
        mapView.showsUserLocation = true
        mapView.delegate = self
        setupView()
        
        
        // divide fetch from firebase to 2 completion
        // otherPlayers and scorePoints
        
        // firebase otherplayers coordinate update then:
        fetchAllOhterPlayersCoordinates(completion: { (allOtherPlayerCoordinates) in
            
            print(allOtherPlayerCoordinates)

            self.addOtherPlayersCirclesAfterCompletion(with: allOtherPlayerCoordinates)
            self.addScoreCirclesAfterCompletion(with: self.allScoreCoordinates)
        })
        // firebase score coordinate update then:
        fetchAllScoreCoordinates(completion: { (allScoreCoordinates) in
            
            self.addOtherPlayersCirclesAfterCompletion(with: self.allOtherPlayerCoordinates)
            self.addScoreCirclesAfterCompletion(with:allScoreCoordinates)
        })
    }
    
    @objc func setCircle() {
      
        if start == false {
            start = true
            button.setTitle("◼︎", for: .normal)
            runTimer()
            button.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
            button.layer.shadowColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        }
        else {
            start = false
            timer.invalidate()
            button.setTitle("▶︎", for: .normal)
            score = 0
            scoreLabel.text = "\(score)  ⦿"
            seconds = 300
            timerLabel.text = timeString(time: TimeInterval(seconds))
            button.backgroundColor = #colorLiteral(red: 0.9272366166, green: 0.2351297438, blue: 0.103588976, alpha: 1)
            button.layer.shadowColor = #colorLiteral(red: 0.9272366166, green: 0.2351297438, blue: 0.103588976, alpha: 1)
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
    
    
    func fetchAllPlayersUid(completion: @escaping ([String]) -> ()) {
        var newAllUid = [String]()
        ref = Database.database().reference()
        ref.child("users").observe(.value, with: { (snapshot) in
            newAllUid = []
            for uid in snapshot.children {
                if let uid = uid as? DataSnapshot {
                    DispatchQueue.main.async {
                        newAllUid.append(uid.key)
                        
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
    
    func fetchAllOhterPlayersCoordinates(completion: @escaping (_ allOtherPlayerCoordinates: [CLLocationCoordinate2D]) -> ()) {
        ref = Database.database().reference()
        let userUid = Auth.auth().currentUser?.uid
        ref.child("coordinates").child("players").observe(.value) { (snapshot) in
            var allOtherPlayerCoordinates = [CLLocationCoordinate2D]()
            let players = snapshot.children
            for player in players {
                if let player = player as? DataSnapshot {
                    if player.key != userUid {
                        if let playerValue = player.value as? [Double] {
                            allOtherPlayerCoordinates.append(CLLocationCoordinate2D(latitude: playerValue[0], longitude: playerValue[1]))
                            completion(allOtherPlayerCoordinates)
                        }
                    }
                }
            }
        }
    }
    
    func fetchAllScoreCoordinates(completion: @escaping ([CLLocationCoordinate2D]) -> ()) {
        ref = Database.database().reference()
        ref.child("coordinates").child("scoreCoordinates").observe(.value) { (snapshot) in
            var allNewCoordinates = [CLLocationCoordinate2D]()
            let coordinates = snapshot.children
            for coordinate in coordinates {
                if let coordinate = coordinate as? DataSnapshot {
                    
                    if let coordinateValue = coordinate.value as? [Double] {
                        allNewCoordinates.append(CLLocationCoordinate2D(latitude: coordinateValue[0], longitude: coordinateValue[1]))
                        completion(allNewCoordinates)
                    }
                    
                }
            }
        }
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


