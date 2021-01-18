//
//  RoundButton.swift
//  BTG
//
//  Created by Guilherme Kauffmann on 16/01/21.
//

import UIKit
import AudioToolbox.AudioServices

@IBDesignable
class StyleButton: UIButton {
    @IBInspectable var roundButton: Bool = false {
        didSet {
            if roundButton {
                layer.cornerRadius = frame.height / 2
            }
        }
    }
    
    @IBInspectable var shadowOffset: CGSize = CGSize(width: 0.0, height: 0.0) { didSet { updateShadow() }}
    @IBInspectable var shadowRadius: CGFloat = 0 { didSet { updateShadow() }}
    @IBInspectable var borderWidth: CGFloat = 0 { didSet { updateBorder() }}
    @IBInspectable var borderColor: UIColor = .black { didSet { updateBorder() }}
    @IBInspectable var cornerRadius: CGFloat = 0 { didSet { updateBorder() }}
        
    override func prepareForInterfaceBuilder() {
        if roundButton {
            layer.cornerRadius = frame.height / 2
        }
    }
    
    func updateShadow() {
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = 0.25
        layer.shadowColor = UIColor.black.cgColor
    }
    
    func updateBorder() {
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        layer.cornerRadius = cornerRadius
    }
    
    class func vibrar() {
        let pop = SystemSoundID(1520)
        AudioServicesPlaySystemSoundWithCompletion(pop, {
        })
    }
    
}
