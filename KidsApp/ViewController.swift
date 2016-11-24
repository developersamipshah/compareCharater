//
//  ViewController.swift
//  KidsApp
//
//  Created by Sam on 11/22/16.
//  Copyright © 2016 Sam. All rights reserved.
//

import UIKit
import CoreText
import QuartzCore

class ViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var drawingView: DrawingView!
    @IBOutlet weak var exampleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let text = NSMutableAttributedString(string: "Thank you")
        text.addAttributes([NSUnderlineStyleAttributeName: NSUnderlineStyle.patternDot.rawValue], range: NSMakeRange(0, text.length))
    }
    
  
    
    @IBAction func drawButtonTouched(_ sender: AnyObject) {
        print(textField.text)
        drawingView.textToDraw = textField.text
        drawingView.reset()
//        setupDrawing()
    }
    
    func setupDrawing(){
        let font = UIFont(name: "Acme-Regular", size: 60)
        let fontPath = Bundle.main.path(forResource: "Acme-Regular", ofType: "ttf")
        
        do{
            let fontData:CFData = try NSData(contentsOfFile: fontPath!)
            print(fontData)
            let error :UnsafeMutablePointer<Unmanaged<CFError>?>? = nil
            let provider:CGDataProvider = CGDataProvider(data: fontData)!
            
            let customFont = CGFont.init(provider)
            
            let registered = CTFontManagerRegisterGraphicsFont(customFont, error)
            
            if !registered{
                print("Failed to load custom font")
            }
            
            let name = "Samip"
            let font  = CTFontCreateWithName("Acme-Regular" as CFString?, 60, nil)
            let count = name.characters.count
            
            var glyphs = Array<CGGlyph>(repeating: 0, count: count)
            var chars = [UniChar]()
        }catch {
            print("error")
            return
        }
        
        
    }
    
    

}

