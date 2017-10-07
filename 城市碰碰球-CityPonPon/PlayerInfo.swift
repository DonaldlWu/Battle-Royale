//
//  PlayerInfo.swift
//  Battle Royale
//
//  Created by Vince Lee on 2017/9/11.
//  Copyright © 2017年 吳得人. All rights reserved.
//

import Foundation
import Firebase

class Player {
    var username: String?
    var score: Int?
    var imageURL: URL?
    
    
    init(snapshot: DataSnapshot) {
        
        if let snapshotValue = snapshot.value as? [String: Any] {
            username = ((snapshotValue["username"])! as! String)
            score = snapshotValue["score"] as? Int ?? 0
            imageURL = URL(string: (snapshotValue["image"] as? String ?? ""))
            
            
                
            
        } else {
            print("Player init snapshot failed")
        }
    }
    
    
}

