//
//  Shapes.swift
//  Battle Royale
//
//  Created by Vince Lee on 2017/9/14.
//  Copyright © 2017年 吳得人. All rights reserved.
//

import Foundation
import Mapbox
import Firebase

struct PlayerCircle {
    
    var radius: Int?
    var coord: CLLocationCoordinate2D?
    var uid: String?
    
    init(snapshot: DataSnapshot) {
        if let snapshotValue = snapshot.value as? [Double] {
            if snapshotValue.count == 2 {
                coord = CLLocationCoordinate2D(latitude: snapshotValue[0], longitude: snapshotValue[1])
                uid = snapshot.key
                radius = 10
            } else {
                coord = CLLocationCoordinate2D(latitude: snapshotValue[0], longitude: snapshotValue[1])
                uid = snapshot.key
                radius = Int(snapshotValue[2])
            }
        }
    }
    
}

struct ScoreCircle {
    var coord: CLLocationCoordinate2D!
    var index: Int!
    init(snapshot: DataSnapshot) {
        if let snapshotValue = snapshot.value as? [String: Any] {
            let lat = ((snapshotValue["lat"])! as! Double)
            let lon = ((snapshotValue["lon"])! as! Double)
            index = Int(snapshot.key)
            coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
    }
    init(coord: CLLocationCoordinate2D!, index: Int!) {
        self.coord = coord
        self.index = index
    }
}

class ScoreCircles {
    var coords = [CLLocationCoordinate2D]()
    
    init(coords: [ScoreCircle]) {
        var scoreCoords: [CLLocationCoordinate2D] {
            var newCoords = [CLLocationCoordinate2D]()
            for coord in coords {
                newCoords.append(coord.coord)
            }
            return newCoords
        }
        self.coords = scoreCoords
    }
}
