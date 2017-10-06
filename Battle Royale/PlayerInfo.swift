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
    var image: UIImage?
    
    init(snapshot: DataSnapshot) {
        
        if let snapshotValue = snapshot.value as? [String: Any] {
            username = ((snapshotValue["username"])! as! String)
            score = snapshotValue["score"] as? Int ?? 0
            imageURL = URL(string: (snapshotValue["image"] as? String ?? ""))
            
            if let imageURL = imageURL {
                fetchUserImage(imageURL: imageURL, completion: { (image) in
                    DispatchQueue.main.async {
                        self.image = image
                    }
                })
            } else {
                self.image = #imageLiteral(resourceName: "Unknown")
                
            }
        } else {
            print("Player init snapshot failed")
        }
    }
    func fetchUserImage(imageURL: URL, completion: @escaping (UIImage?) -> ()) {
        
        let task = URLSession.shared.dataTask(with: imageURL) { (data, response , error) in
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            }
            
        }
        task.resume()
    }
    
}

