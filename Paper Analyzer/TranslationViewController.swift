//
//  TranslationViewController.swift
//  Paper Analyzer
//
//  Created by Huy Vu on 11/18/17.
//  Copyright © 2017 Zelda Stockhack. All rights reserved.
//

import UIKit
import Alamofire

class TranslationViewController: UIViewController {
    var sourceText = ""
    var target = "en"
    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        UITextView.addShadow(textView: self.textView)
        self.textView.clipsToBounds = true
        self.textView.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

        // Do any additional setup after loading the view.
        translate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func translate(){
        let serverURL = NSURL(string: googleURL)!
        let param = ["key": googleAPIKey, "q" : sourceText, "target": target]
        let URL = serverURL.appendingPathComponent("")
        
        Alamofire.request(URL!, method: .post, parameters: param).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print (json)
                var translationJSONArray = json["data"]["translations"].array
                if translationJSONArray != nil || (translationJSONArray?.count)! > 0 {
                    self.textView.text = translationJSONArray?[0]["translatedText"].string!
                }
            case .failure:
                print (request)
                print (response)
            }
        }

    }
}
