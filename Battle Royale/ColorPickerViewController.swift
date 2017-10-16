//
//  ColorPickerView.swift
//  城市碰碰球-CityPonPon
//
//  Created by Vince Lee on 2017/10/14.
//  Copyright © 2017年 吳得人. All rights reserved.
//

import UIKit

extension EditProfileTableViewController: UIPickerViewDelegate, UIPickerViewDataSource  {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return colorsToChoose.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        
        pickerLabel.backgroundColor = colorsToChoose[row]
        
        return pickerLabel
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 45
    }
    
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
