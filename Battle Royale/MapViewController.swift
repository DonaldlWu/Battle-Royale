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
import FirebaseStorage
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
           
            
        }
    }
    
    var savedCoords = [CLLocationCoordinate2D]()
    
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
    var hideButton = false
    var number = 0
    
    var otherPlayers: [PlayerCircle] = []
    var mainPlayerRadius: Int? {
        didSet {
            updateMainPlayerCircle()
        }
    }
    var mainPlayerColor = #colorLiteral(red: 0.02766584791, green: 0.4977956414, blue: 1, alpha: 1)
    
    var mainLayer: MGLFillStyleLayer?
    var scoreLayer: MGLFillStyleLayer?
    
    var otherPlayersLayer: MGLFillStyleLayer?
    var mainSource: MGLShapeSource?
    var scoreSource: MGLShapeSource?
    
    var otherPlayersSource: MGLShapeSource?
    
    let storage = Storage.storage()
    
    
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
        button.setImage(#imageLiteral(resourceName: "compass"), for: .normal)
        
        button.backgroundColor = #colorLiteral(red: 0.8694403768, green: 0.8642715216, blue: 0.8734138608, alpha: 1).withAlphaComponent(0.7)
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(moveCameraToPlayer), for: .touchUpInside)
        return button
        
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 2
        
        locationManager.delegate = self
        locationManager.pausesLocationUpdatesAutomatically = false
        
        mainPlayerRadius = 10
        
        locationManager.stopUpdatingLocation()
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
        
        
        
        // update location every 2 sec
        //        runLocationUpdateTimer(with: 2)
        
//         mapView setup
        
        self.mapView = timeFilterMapboxStyleImport()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        mapView.setCenter(CLLocationCoordinate2D(latitude: 25.021293, longitude: 121.538006), zoomLevel: 9, animated: false)
        
        mapView.userTrackingMode = .follow
        mapView.showsUserLocation = true
        mapView.attributionButton.isHidden = true
        mapView.logoView.isHidden = true
        
        mapView.delegate = self
        
        setupView()
        // double tap hide buttons and labels
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(tap:)))
        for recognizer in mapView.gestureRecognizers! where recognizer is UITapGestureRecognizer {
            doubleTap.require(toFail: recognizer)
        }
        
        mapView.addGestureRecognizer(doubleTap)
        
       
        
        
        
        // divide fetch from firebase to 2 completion
        // otherPlayers and scorePoints
        
        // firebase otherplayers coordinate update then:
        
        
        fetchOtherPlayersCoords(completion: { (otherPlayers) in
            
            self.otherPlayers = otherPlayers
            let otherPlayerShapes = self.updateOtherPlayerShapes(otherPlayers)
            
            
            // mapbox update layer
            if let style = self.mapView.style {
                self.addLayer(to: style, with: "otherPlayer", #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1).withAlphaComponent(0.5), shapes: otherPlayerShapes, source: &self.otherPlayersSource, layer: &self.otherPlayersLayer)
            }
        })
        
        // firebase score coordinate update then:
        fetchAllScoreCoordinates(completion: { (allScoreCoords) in
            self.allScoreCoords = allScoreCoords
            
            let allScoreCoordsFiltered = self.filterCoords(allScoreCoords)
            let scoreShapes = self.updateShapes(coords:allScoreCoordsFiltered , radiusMeter: 50)
            // mapbox update layer
            if let style = self.mapView.style {
                self.addLayer(to: style, with: "scorePoints", #colorLiteral(red: 0.9272366166, green: 0.2351297438, blue: 0.103588976, alpha: 1).withAlphaComponent(0.5), shapes: scoreShapes, source: &self.scoreSource, layer: &self.scoreLayer)
            }
        })
        

    }
    override func viewDidAppear(_ animated: Bool) {
        dayNightUIFilter()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .default
    }
    
    @objc func startGame() {
        
        if start == false {
            startCount()
            locationManager.startUpdatingLocation()
            if let coord = currentLocation?.coordinate,  savedCoords.count == 0 {
                savedCoords.append(coord)
                print(savedCoords)
            }
        }
        else {
            endCount()
        }
    }
    
    @objc func moveCameraToPlayer() {
        if let coord = currentLocation?.coordinate, let radius = mainPlayerRadius {
            let camera = MGLMapCamera(lookingAtCenter: coord, fromDistance: CLLocationDistance(radius * 30), pitch: 30, heading: 0)
            
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
        popAlert()
        button.setTitle("▶︎", for: .normal)
        seconds = 1200
        timerLabel.text = timeString(time: TimeInterval(seconds))
        button.backgroundColor = #colorLiteral(red: 0.9272366166, green: 0.2351297438, blue: 0.103588976, alpha: 1).withAlphaComponent(0.8)
        button.layer.shadowColor = #colorLiteral(red: 0.9272366166, green: 0.2351297438, blue: 0.103588976, alpha: 1)
        
    }
    
    func randomCoordinate(radius: Int, from coordinate: CLLocationCoordinate2D) -> (CLLocationCoordinate2D) {
        
        let angleRandom = GKRandomDistribution(lowestValue: 0, highestValue: 360)
        let newaAngleRandom = angleRandom.nextInt()
        let nextLat = Double(coordinate.latitude) + sin(Double(newaAngleRandom) / 180 * Double.pi) * 0.000008983417785 * Double(radius) * cos(coordinate.latitude / 180 * Double.pi)
        let nextLon = Double(coordinate.longitude) + cos(Double(newaAngleRandom) / 180 * Double.pi) * 0.000009014705689 * Double(radius)
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
        ref.child("coordinates").child("players").child(userUid!).observeSingleEvent(of: .value, with: { (snapshot) in
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
            
        )}
    
    
    
    
    func fetchOtherPlayersCoords(completion: @escaping (_ OtherPlayerCoords: [PlayerCircle]) -> ()) {
        ref = Database.database().reference()
        let userUid = Auth.auth().currentUser?.uid
        ref.child("coordinates").child("players").observe(.childRemoved) { (snapshot) in
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


