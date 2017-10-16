//
//  ColorController.swift
//  城市碰碰球-CityPonPon
//
//  Created by Vince Lee on 2017/10/16.
//  Copyright © 2017年 吳得人. All rights reserved.
//

import Foundation
import Firebase

class ColorController {
    var colorDefault: UserDefaults!
    
    func save(colorIndex: Int) {
        if let uid = Auth.auth().currentUser?.uid {
        colorDefault.set(colorIndex, forKey: uid)
        }
    }
    func read() -> Int{
        if let uid = Auth.auth().currentUser?.uid {
            let colorIndex = colorDefault.integer(forKey: uid)
            return colorIndex
        } else {
         return 0
        }
    }
    init() {
        colorDefault = UserDefaults.standard
    }
}
