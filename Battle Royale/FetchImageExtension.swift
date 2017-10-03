//
//  FetchImageExtension.swift
//  Battle Royale
//
//  Created by Vince Lee on 2017/9/24.
//  Copyright © 2017年 吳得人. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage

extension TutorialTableViewController {
    
    func fetchUserImage(completion: @escaping (UIImage?) -> ()) {
        if let photoURL = Auth.auth().currentUser?.photoURL {
        let task = URLSession.shared.dataTask(with: photoURL) { (data, response , error) in
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            }
            else {
                completion(nil)
            }
        }
        task.resume()
        }
    }
    
    func uploadImage() {
        let storageRef = storage.reference()
        let uid = Auth.auth().currentUser?.uid
        let userProfilePic = storageRef.child("images/\(uid!).jpg")
        if let image = playerImage {
        if let data = UIImageJPEGRepresentation(image, 1) {
            
            let uploadTask = userProfilePic.putData(data, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    return
                }
                // Metadata contains file metadata such as size, content-type, and download URL.
                let downloadURL = metadata.downloadURL
            }
        }
        }
    }
    
}

