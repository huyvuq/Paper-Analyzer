//
//  PopUpScanFromSourceView.swift
//  Paper Analyzer
//
//  Created by Huy Vu on 11/19/17.
//  Copyright © 2017 Zelda Stockhack. All rights reserved.
//

import UIKit

class PopUpScanFromSourceView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    //data picker
    var languageArray : [String?] = ["eng","fra"]
    var pickedLanguage = "eng"
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languageArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return languageArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickedLanguage = languageArray[row]!;
    }

}
