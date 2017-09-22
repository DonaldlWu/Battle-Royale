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

    
    init(snapshot: DataSnapshot) {
        if let snapshotValue = snapshot.value as? [Double] {
            if snapshotValue.count == 2 {
                coord = CLLocationCoordinate2D(latitude: snapshotValue[0], longitude: snapshotValue[1])
                radius = 10
            } else {
                coord = CLLocationCoordinate2D(latitude: snapshotValue[0], longitude: snapshotValue[1])
                self.radius = Int(snapshotValue[2])
            }
        }
    }
    
}
