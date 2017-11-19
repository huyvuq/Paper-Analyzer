//
//  Extensions.swift
//  Civics Test Trainer
//
//  Created by Huy Vu on 4/18/17.
//  Copyright © 2017 Pixel Guyz Studio. All rights reserved.
//

import Foundation
import UIKit

extension UIButton{
    static func addShadow( button : UIButton){
        button.layer.shadowOpacity = 0.7
        button.layer.shadowOffset = CGSize(width: 3.0, height: 2.0)
        button.layer.shadowRadius = 5.0
    }
    
//    static func sizeFit(button : UIButton){
//        let newHeight = button.frame.height + (button.titleLabel?.font.lineHeight)!*(CGFloat)((button.titleLabel?.numberOfLines)!-1)
//        print(button.titleLabel?.numberOfLines)
//        button.frame = CGRect(x: 0, y: 0, width: button.frame.width, height: 140)
//    }
}

class ResizableButton: UIButton {
   
}
extension UITextView{
    static func addShadow( textView : UITextView){
        textView.clipsToBounds = false;
        textView.layer.shadowOpacity = 0.7
        textView.layer.shadowOffset = CGSize(width: 3.0, height: 2.0)
        textView.layer.shadowRadius = 5.0
    }
}

extension UIView{
    static func addShadow( view : UIView){
        view.clipsToBounds = false;
        view.layer.shadowOpacity = 0.7
        view.layer.shadowOffset = CGSize(width: 3.0, height: 2.0)
        view.layer.shadowRadius = 5.0
    }
}

extension UITextView {
    
    func underlined(){
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.lightGray.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}

extension String {
    
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: r.lowerBound)
        let end = index(startIndex, offsetBy: r.upperBound)
        return self[Range(start ..< end)]
    }
}

extension String {
    
    func slice(from: String, to: String) -> String? {
        
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                substring(with: substringFrom..<substringTo)
            }
        }
    }
}
