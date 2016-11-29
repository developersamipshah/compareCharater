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

    }
    
    

}

