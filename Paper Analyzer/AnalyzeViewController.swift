//
//  AnalyzeViewController.swift
//  Paper Analyzer
//
//  Created by Huy Vu on 11/18/17.
//  Copyright © 2017 Zelda Stockhack. All rights reserved.
//

import UIKit
import Alamofire

let networkAppDirectory = "grammarchecker/"
//let networkURL = "http://localhost/~apple/" + networkAppDirectory
let networkURL = "http://34.204.53.195/" + networkAppDirectory

class AnalyzeViewController: UIViewController {
    var requestText: String?
    
    @IBOutlet weak var sourceTextView: UITextView!
    @IBOutlet weak var mistakeTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UITextView.addShadow(textView: sourceTextView)
        sourceTextView.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        sourceTextView.clipsToBounds = true

        UITextView.addShadow(textView: mistakeTextView)
        mistakeTextView.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        mistakeTextView.clipsToBounds = true

        self.requestAnalyze()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func requestAnalyze(){
        sourceTextView.text = requestText
        let serverURL = NSURL(string: networkURL)!
        let param = ["text":requestText!]
        let URL = serverURL.appendingPathComponent("index.php")

        Alamofire.request(URL!, method: .post, parameters: param).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                self.prepareAnalyzedText(json: json)
            case .failure:
                print (request)
                print (response)
            }
        }
    }
    
    func prepareAnalyzedText(json: JSON){
        self.mistakeTextView.text = "No mistakes found"

        let matches = json["matches"]
        if matches != JSON.null {
            let sentences = requestText?.components(separatedBy: ".")
            
            if matches.count > 0{
                
                let errorArray = matches.array!
                print (matches)
                var resultStr = ""
                
                var i = 0;
                var sentenceOffset = -1;
                var line = 0;
                for s in sentences!{
                    if s == " " || s == "" || s.isEmpty || s=="\n"{
                        continue;
                    }
                    var str = s
                    //if use this in the future, add code in extensions file
                    if (s[0] == " "){
                        str = String(s.characters.dropFirst())
                    }
                    line += 1
                    resultStr += "\(line). " + str + ": "

                    sentenceOffset = sentenceOffset + (s.characters.count) + 1
                    while (i < errorArray.count){
                        if (errorArray[i]["offset"].int! < sentenceOffset){
                            let sliceFrom = requestText?.index((requestText?.startIndex)!, offsetBy: errorArray[i]["offset"].int!)
                            let sliceTo = requestText?.index((requestText?.startIndex)!, offsetBy: errorArray[i]["offset"].int! + errorArray[i]["length"].int! - 1)
                            
                            resultStr += "\n" + (requestText?[sliceFrom!...sliceTo!])!
                            
                            resultStr += ": " + errorArray[i]["message"].string!
                            
                            //now suggest replacement
                            let replacements = errorArray[i]["replacements"]
                            if replacements != JSON.null {
                                resultStr += ". Replacements: "
                                var replacementArray = replacements.array
                                if ((replacementArray?.count)! > 0){
                                    for i in 0...(replacementArray?.count)! - 1 {
                                        resultStr += (replacementArray?[i]["value"].string)!
                                        if i != replacements.count-1 {
                                            resultStr += ", "
                                        }
                                    }
                                }
                            }
                            i += 1
                        } else {
                            break
                        }
                    }
                    resultStr += "\n\n"
                }
                self.mistakeTextView.text = resultStr;
            }
        }
    }
    
}
