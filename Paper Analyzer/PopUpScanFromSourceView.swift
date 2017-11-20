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
    var languageArrayMap : [language] = [language.init(languageName: "English", languageSymbol: "eng"),
                                      language.init(languageName: "Chinese Simple", languageSymbol: "chi-sim"),
                                      language.init(languageName: "Chinese Traditional", languageSymbol: "chi-tra"),
                                      language.init(languageName: "Japanese", languageSymbol: "jpn"),
                                      language.init(languageName: "French", languageSymbol: "fra"),
                                      language.init(languageName: "Korean", languageSymbol: "kor"),
                                      language.init(languageName: "Lao", languageSymbol: "lao"),
                                      language.init(languageName: "Indian", languageSymbol: "ind"),
                                      language.init(languageName: "Spanish", languageSymbol: "spa"),
                                      language.init(languageName: "Vietnamese", languageSymbol: "vie")]
    
    var pickedLanguage = "eng"
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languageArrayMap.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return languageArrayMap[row].languageName
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickedLanguage = languageArrayMap[row].languageSymbol;
    }

}

struct language {
    var languageName = ""
    var languageSymbol = ""
}
