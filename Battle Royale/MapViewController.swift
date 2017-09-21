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
    var seconds = 1200
    var timer = Timer()
    var locationUpdateTimer = Timer()
    var isTimerRunning = false
    var currentLocation: CLLocation? {
        didSet {
            setCurrentLocation()
            //            DANGER! update location 500 times/ sec
            //            locationManager.stopUpdatingLocation()
            //            locationManager.requestLocation()
            //            locationManager.startUpdatingLocation()
            
        }
    }
    
    var mapView: MGLMapView!
    var zoomLevel: Float = 18.0
    var circ = GMSCircle()
    var nextCircleCorordinate: CLLocationCoordinate2D?
    var ref: DatabaseReference!
    var allUid = [String]()
    var OtherPlayerCoords = [CLLocationCoordinate2D]()
    var allScoreCoords = [CLLocationCoordinate2D]()
    var score = 0
    var start = false
    var number = 0
    var mainShape: [MGLPolygon] = []
    var scoreShapes: [MGLPolygon] = []
    var otherPlayerShapes: [MGLPolygon] = []
    
    
    var otherPlayers: [PlayerCircle] = []
    var mainPlayerRadius: Int?
    
    var mainLayer: MGLFillStyleLayer?
    var scoreLayer: MGLFillStyleLayer?
    var otherPlayersLayer: MGLFillStyleLayer?
    var mainSource: MGLShapeSource?
    var scoreSource: MGLShapeSource?
    var otherPlayersSource: MGLShapeSource?
    
    
    
    let button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("▶︎", for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1).withAlphaComponent(0.8)
        button.layer.cornerRadius = 25
        button.layer.shadowRadius = 3
        button.layer.shadowColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        button.layer.shadowOpacity = 0.6
        
        
        button.addTarget(self, action: #selector(startGame), for: .touchUpInside)
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
        
        label.text = "20:00"
        label.font = label.font.withSize(30)
        label.backgroundColor = #colorLiteral(red: 0.8530249, green: 0.847953856, blue: 0.8569234014, alpha: 1).withAlphaComponent(0.9)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 15
        
        
        return label
    }()
    
    let moveToCurrentLoactionButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont(name: "system", size: 70)
        button.setTitle("◉", for: .normal)
        
        
        
        button.addTarget(self, action: #selector(moveCameraToPlayer), for: .touchUpInside)
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
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // update location every 5 sec
        runLocationUpdateTimer(with: 2)
        
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
        fetchOtherPlayersCoords(completion: { (otherPlayers) in
            
            self.otherPlayers = otherPlayers
            
            self.otherPlayerShapes = self.updateOtherPlayerShapes(otherPlayers)
            // mapbox update layer
            if let style = self.mapView.style {
                self.addLayer(to: style, with: "otherPlayer", #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1).withAlphaComponent(0.5), shapes: self.otherPlayerShapes, source: &self.otherPlayersSource, layer: &self.otherPlayersLayer)
            }
        })
        
        // firebase score coordinate update then:
        fetchAllScoreCoordinates(completion: { (allScoreCoords) in
            
            self.allScoreCoords = allScoreCoords
            self.scoreShapes = self.updateShapes(coords:allScoreCoords, radiusMeter: 50)
            
            // mapbox update layer
            if let style = self.mapView.style {
                self.addLayer(to: style, with: "scorePoints", #colorLiteral(red: 0.9272366166, green: 0.2351297438, blue: 0.103588976, alpha: 1).withAlphaComponent(0.5), shapes: self.scoreShapes, source: &self.scoreSource, layer: &self.scoreLayer)
            }
        })
        
        fetchMainPlayersCoords { (mainPlayerRadius) in
            self.mainPlayerRadius = mainPlayerRadius
            self.mainShape = self.updateShapes(coords: [(self.currentLocation?.coordinate)!], radiusMeter: Double(self.mainPlayerRadius!))
            if let style = self.mapView.style {
                self.addLayer(to: style, with: "mainPlayer", #colorLiteral(red: 0.02766608819, green: 0.4977955222, blue: 1, alpha: 1), shapes: self.mainShape, source: &self.mainSource, layer: &self.mainLayer)
                
            }
            
        }
    }
    
    @objc func startGame() {
        
        if start == false {
            startCount()
        }
        else {
            endCount()
        }
    }
    
    @objc func moveCameraToPlayer() {
        if let coord = currentLocation?.coordinate {
            let camera = MGLMapCamera(lookingAtCenter: coord, fromDistance: 200, pitch: 30, heading: 0)
            
            // Animate the camera movement over 1 seconds.
            mapView.setCamera(camera, withDuration: 1, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
        }
    }
    
    func startCount() {
        start = true
        button.setTitle("◼︎", for: .normal)
        runTimer()
        button.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1).withAlphaComponent(0.8)
        button.layer.shadowColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
    }
    
    func endCount() {
        start = false
        timer.invalidate()
        button.setTitle("▶︎", for: .normal)
        score = 0
        scoreLabel.text = "\(score)  ⦿"
        seconds = 1200
        timerLabel.text = timeString(time: TimeInterval(seconds))
        button.backgroundColor = #colorLiteral(red: 0.9272366166, green: 0.2351297438, blue: 0.103588976, alpha: 1).withAlphaComponent(0.8)
        button.layer.shadowColor = #colorLiteral(red: 0.9272366166, green: 0.2351297438, blue: 0.103588976, alpha: 1)
        popAlert()
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
    func fetchMainPlayersCoords(completion: @escaping (_ mainPlayerRadius: Int) -> ()) {
        ref = Database.database().reference()
        let userUid = Auth.auth().currentUser?.uid
        ref.child("coordinates").child("players").child(userUid!).observe(.value) { (snapshot) in
            var newMainPlayerRadius: Int
            if let playerValue = snapshot.value as? [Double] {
                if playerValue.count == 2 {
                    newMainPlayerRadius = 10
                } else {
                    newMainPlayerRadius = Int(playerValue[2])
                }
                completion(newMainPlayerRadius)
            }
        }
    }
    
    
    func fetchOtherPlayersCoords(completion: @escaping (_ OtherPlayerCoords: [PlayerCircle]) -> ()) {
        ref = Database.database().reference()
        let userUid = Auth.auth().currentUser?.uid
        ref.child("coordinates").child("players").observe(.value) { (snapshot) in
            var newOtherPlayers = [PlayerCircle]()
            let players = snapshot.children
            for player in players {
                if let player = player as? DataSnapshot {
                    if player.key != userUid {
                        
                        let otherPlayer = PlayerCircle(snapshot: player)
                        newOtherPlayers.append(otherPlayer)
                        completion(newOtherPlayers)
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


