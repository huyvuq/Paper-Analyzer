//
//  ViewController.swift
//  Paper Analyzer
//
//  Created by Huy Vu on 11/18/17.
//  Copyright © 2017 Zelda Stockhack. All rights reserved.
//

import UIKit
import ALCameraViewController
import TesseractOCR

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
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        UIButton.addShadow(button: ol_camera)
        UIButton.addShadow(button: ol_library)
        UIButton.addShadow(button: ol_analyze)
        UITextView.addShadow(textView: textView)
        
        //Delegate
        textView.delegate = self

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
        if let tesseract = G8Tesseract(language: "eng"){
            tesseract.delegate = self
            tesseract.image = self.image?.g8_blackAndWhite()
            self.textView.text = tesseract.recognizedText
            self.removeDoubleLine()
        }
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
}

