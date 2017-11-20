//
//  ViewController.swift
//  Paper Analyzer
//
//  Created by Huy Vu on 11/18/17.
//  Copyright © 2017 Zelda Stockhack. All rights reserved.
//

import UIKit
import Alamofire
import ALCameraViewController
import TesseractOCR

var googleURL = "https://translation.googleapis.com/language/translate/v2"
var googleAPIKey = "AIzaSyAm9QRWeYFSLq1RXF4uSEd0IwfLYoO0QzM"
var languageDict = [String : String]()

class ViewController: UIViewController, G8TesseractDelegate, UITextViewDelegate {
    var image : UIImage?
    var croppingParameters: CroppingParameters {
        return CroppingParameters(isEnabled: true, allowResizing: true, allowMoving: true, minimumSize: CGSize(width: 50, height: 50))
    }
    
    @IBOutlet weak var textView: UITextView!
    @IBAction func btn_scanCamera(_ sender: Any) {
        let cameraViewController = CameraViewController(croppingParameters: croppingParameters, allowsLibraryAccess: true) { [weak self] image, asset in
            self?.image = image
            self?.dismiss(animated: true, completion: {self?.convertToText()})
        }
        
        present(cameraViewController, animated: true, completion: nil)
    }
    
    @IBAction func btn_scanLibrary(_ sender: Any) {
        let libraryViewController = CameraViewController.imagePickerViewController(croppingParameters: croppingParameters) { [weak self] image, asset in
            self?.image = image
            self?.dismiss(animated: true, completion: {self?.convertToText()})
        }
        
        present(libraryViewController, animated: true, completion: nil)
    }
    
    @IBAction func btn_analyze(_ sender: Any) {
    }
    
    
    @IBOutlet weak var ol_camera: UIButton!
    @IBOutlet weak var ol_library: UIButton!
    @IBOutlet weak var ol_analyze: UIButton!
    @IBOutlet weak var ol_translate: UIButton!
    @IBOutlet weak var ol_setting: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        UIButton.addShadow(button: ol_camera)
        UIButton.addShadow(button: ol_library)
        UIButton.addShadow(button: ol_analyze)
        UIButton.addShadow(button: ol_translate)
        UIButton.addShadow(button: ol_setting)

        UITextView.addShadow(textView: textView)
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        self.textView.clipsToBounds = true
        UIView.addShadow(view: translateToView)
        UIView.addShadow(view: popUpScanFromLanguageView)

        //pop up view effect
        effect = visualEffectView.effect
        visualEffectView.effect = nil
        self.visualEffectView.isUserInteractionEnabled = false
        

        //Delegate
        textView.delegate = self

        self.updateSupportedLanguage()
        self.setUpLanguageDictionary()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination.restorationIdentifier == "analyze" {
            let nextScene = segue.destination as! AnalyzeViewController
            nextScene.requestText = self.textView.text
        }
    }
    func convertToText(){
        // Do any additional setup after loading the view, typically from a nib.
        if let tesseract = G8Tesseract(language: scannedFromLanguage){
            tesseract.delegate = self
            tesseract.image = self.image?.g8_blackAndWhite()
            self.textView.text = tesseract.recognizedText
            self.removeDoubleLine()
        }
    }

    @IBAction func btn_translateTo(_ sender: Any) {
        animateIn(popupView: translateToView)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func removeDoubleLine(){
        let newString = self.textView.text.replacingOccurrences(of: "\n\n", with: "\n", options: .literal, range: nil)
        self.textView.text = newString
    }
    
    //Effect
    var effect:UIVisualEffect!
    @IBOutlet var translateToView: UIView!
    
    @IBAction func btn_submitTranslation(_ sender: Any) {
        animateOut(popupView: translateToView)
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "translate") as! TranslationViewController
        
        newViewController.sourceText = self.textView.text
        let translationView = self.translateToView as! PopUpTranslationView
        newViewController.target = translationView.pickedLanguage
        
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    
    @IBAction func btn_cancelTranslation(_ sender: Any) {
        animateOut(popupView: translateToView)
    }
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    func animateIn(popupView : UIView) {
        self.view.addSubview(popupView)
        popupView.center = self.view.center
        popupView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        popupView.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.visualEffectView.effect = self.effect
            self.visualEffectView.isUserInteractionEnabled = true
            popupView.alpha = 1
            popupView.transform = CGAffineTransform.identity
        }
    }
    
    
    func animateOut (popupView : UIView) {
        UIView.animate(withDuration: 0.3, animations: {
            popupView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            popupView.alpha = 0
            self.visualEffectView.effect = nil
            self.visualEffectView.isUserInteractionEnabled = false
        }) { (success:Bool) in
            popupView.removeFromSuperview()
        }
    }
    
    func updateSupportedLanguage(){
        let serverURL = NSURL(string: googleURL)!
        let param = ["key": googleAPIKey]
        let URL = serverURL.appendingPathComponent("/languages")
        
        Alamofire.request(URL!, method: .post, parameters: param).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                var languageJSONArray = json["data"]["languages"].array
                if languageJSONArray != nil {
                    var languageArray = [String](repeatElement("", count: (languageJSONArray?.count)!))
                    for i in 0...languageArray.count - 1{
                        languageArray[i] = languageJSONArray![i]["language"].string!
                    }
                    let translationView = self.translateToView as! PopUpTranslationView
                    translationView.languageArray = languageArray
                    print(translationView.languageArray.count)
                }
                
            case .failure:
                print (request)
                print (response)
            }
        }
    }
    
    var scannedFromLanguage = "eng"
    @IBOutlet var popUpScanFromLanguageView: PopUpScanFromSourceView!
    @IBAction func btn_changeScanningLanguage(_ sender: Any) {
        animateIn(popupView: popUpScanFromLanguageView)
    }
    
    @IBAction func btn_submitChangeLanguage(_ sender: Any) {
        animateOut(popupView: popUpScanFromLanguageView)
        scannedFromLanguage = self.popUpScanFromLanguageView.pickedLanguage
    }
    @IBAction func btn_cancelChooseScanningLanguage(_ sender: Any) {
        animateOut(popupView: popUpScanFromLanguageView)
    }
    
    func setUpLanguageDictionary(){
        languageDict["af"] = "Afrikaans"
        languageDict["am"] = "Amharic"
        languageDict["ar"] = "Arabic"
        languageDict["az"] = "Azerbaijani"
        languageDict["be"] = "Belarusian "
        languageDict["bg"] = "Bulgarian"
        languageDict["bn"] = "Bengali"
        languageDict["bs"] = "Bosnian"
        languageDict["ca"] = "Catalan; Valencian"
        languageDict["ceb"] = "Cebuano"
        languageDict["co"] = "Corsican "
        languageDict["cs"] = "Czech"
        languageDict["cy"] = "Welsh"
        languageDict["da"] = "Danish"
        languageDict["de"] = "German "
        languageDict["el"] = "Greek, Modern"
        languageDict["en"] = "English"
        languageDict["eo"] = "Esperanto"
        languageDict["es"] = "Español"
        languageDict["et"] = "Estonian "
        languageDict["eu"] = "Basque"
        languageDict["fa"] = "Farsi"
        languageDict["fi"] = "Finnish"
        languageDict["fr"] = "French"
        languageDict["fy"] = "Western Frisian"
        languageDict["ga"] = "Irish"
        languageDict["gd"] = "Gaelic (Scottish)"
        languageDict["gl"] = "Galician"
        languageDict["gu"] = "Gujarati"
        languageDict["ha"] = "Hausa"
        languageDict["haw"] = "Hausa"
        languageDict["hi"] = "Hindi"
        languageDict["hmn"] = "Hmong"
        languageDict["hr"] = " Croatian"
        languageDict["ht"] = "Haitian Creole"
        languageDict["hu"] = "Hungarian"
        languageDict["hy"] = "Armenian"
        languageDict["id"] =  "Indonesian"
        languageDict["ig"] = "Igbo"
        languageDict["is"] = "Icelandic"
        languageDict["it"] = "Italian"
        languageDict["iw"] = "Hebrew"
        languageDict["ja"] = "Japanese"
        languageDict["jw"] = "Javanese"
        languageDict["ka"] = "Georgian"
        languageDict["kk"] = "Kazakh"
        languageDict["km"] = "Cambodian"
        languageDict["kn"] = " Kannada "
        languageDict["ko"] = "Korean"
        languageDict["ku"] = "Kurdish"
        languageDict["ky"] = "Kirghiz"
        languageDict["la"] = "Latin"
        languageDict["lb"] = "Luxembourgish"
        languageDict["lo"] = "Laotian"
        languageDict["lt "] = "Lithuanian"
        languageDict["lv"] = "Latvian (Lettish)"
        languageDict["mg"] = "Malagasy"
        languageDict["mi"] = "Maori"
        languageDict["mk"] = "Macedonian"
        languageDict["ml"] = "Malayalam"
        languageDict["mn"] = "Mongolian"
        languageDict["mr "] = "Marathi"
        languageDict["ms"] = "Malay"
        languageDict["mt"] = "Maltese"
        languageDict["my"] = "Burmese"
        languageDict["ne"] = "Nepali"
        languageDict["nl"] = "Dutch"
        languageDict["no "] = "Norwegian"
        languageDict["ny"] = "Chichewa, Chewa, Nyanja"
        languageDict["pa"] = "Punjabi (eastern)"
        languageDict["pl"] = "Polish"
        languageDict["ps"] = "Pashto, Pushto"
        languageDict["pt"] = "Portuguese"
        languageDict["ro"] = "Romanian"
        languageDict["ru"] = "Russian"
        languageDict["sd"] = "Sindhi"
        languageDict["si"] = "Sinhalese"
        languageDict["sk"] = "Slovak"
        languageDict["sl "] = "Slovenian"
        languageDict["sm"] = "Samoan"
        languageDict["sn"] = "Shona"
        languageDict["so"] = "Somali"
        languageDict["sq"] = "Albanian"
        languageDict["sr"] = "Serbian"
        languageDict["st"] = "Sesotho"
        languageDict["su"] = "Sundanese"
        languageDict["sv"] = "Swedish"
        languageDict["sw"] = "Swahili (Kiswahili)"
        languageDict["ta"] = "Tamil"
        languageDict["te"] = "Telugu "
        languageDict["tg"] = "Tajik"
        languageDict["th"] = "Thai"
        languageDict["tl"] = "Tagalog"
        languageDict["tr "] = "Turkish"
        languageDict["uk"] = "Ukranian"
        languageDict["ur"] = "Urdu"
        languageDict["uz"] = "Uzbek"
        languageDict["vi"] = "Vietnamese"
        languageDict["xh"] = "Xhosa"
        languageDict["yi"] = "Yiddish"
        languageDict["yo"] = "Yoruba"
        languageDict["zh"] = "Chinese"
        languageDict["zh-TW"] = "Chinese (T)"
        languageDict["zu"] = "Zulu"
    }
}

