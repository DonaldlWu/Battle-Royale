//
//  DLImageExtension.swift
//  Battle Royale
//
//  Created by Vince Lee on 2017/9/25.
//  Copyright © 2017年 吳得人. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage
import Mapbox

extension MapViewController {
    
    
    
    func downdloadImage() {
        var nearbyPlayerUid: [String] = []
        var nearbyPlayerImage: [UIImage] = []
        var pointAnnotations = [CustomPointAnnotation]()
        for player in otherPlayers {
            let pathReference = storage.reference(withPath: "images/\(player.uid!).jpg")
            pathReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    // Uh-oh, an error occurred!
                } else {
                    // Data for "images/island.jpg" is returned
                    if let image = UIImage(data: data!) {
                        let anno = MGLPointAnnotation()
                        anno.coordinate = player.coord!
                        self.mapView.addAnnotation(anno)
                        print("anno")
                        nearbyPlayerImage.append(image)
                        
                        
                        
                    }
                }
                
            }
            let count = pointAnnotations.count + 1
            let point = CustomPointAnnotation(coordinate: player.coord!, title: "\(player.uid!)", subtitle: nil)
            
                // Set the custom `image` and `reuseIdentifier` properties, later used in the `mapView:imageForAnnotation:` delegate method.
                // Create a unique reuse identifier for each new annotation image.
                point.reuseIdentifier = "customAnnotation\(count)"
                // This dot image grows in size as more annotations are added to the array.
                point.image = nearbyPlayerImage[count]
                
                // Append each annotation to the array, which will be added to the map all at once.
                pointAnnotations.append(point)
            }
            
            // Add the point annotations to the map. This time the method name is plural.
            // If you have multiple annotations to add, batching their addition to the map is more efficient.
            mapView.addAnnotations(pointAnnotations)
            
        }
        
        
        
    }

