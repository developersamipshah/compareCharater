//
//  DrawingView.swift
//  KidsApp
//
//  Created by Sam on 11/22/16.
//  Copyright © 2016 Sam. All rights reserved.
//

import UIKit

class DrawingView: UIView {
    
    
    var originalPath:UIBezierPath?
    var drawingPath:UIBezierPath!
    var drawingPoints:[CGPoint] = [CGPoint]()
    var timer:Timer?
    
    var textToDraw:String? = "A"{
        didSet{
            setNeedsDisplay()
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetup()
    }
    
    
    func initialSetup(){
        self.backgroundColor = UIColor.lightGray
        
        drawingPath = UIBezierPath()
        drawingPath.lineWidth = 8
        drawingPath.lineCapStyle = .round
        drawingPath.lineJoinStyle = .bevel
        self.isMultipleTouchEnabled = false
        
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        draw(name: textToDraw!)
        UIColor.red.setStroke()
        drawingPath.stroke()
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let location = touch?.location(in: self)
        drawingPoints.append(location!)
        drawingPath.move(to: location!)
        timer?.invalidate()
        setNeedsDisplay()
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let location = touch?.location(in: self)
        drawingPoints.append(location!)
        drawingPath.addLine(to: location!)
        timer?.invalidate()
        setNeedsDisplay()
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        setNeedsDisplay()
        timer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(self.compareDrawing), userInfo: nil, repeats: false)
    }
    
    func reset(){
        drawingPath.removeAllPoints()
        setNeedsDisplay()
    }
    
    
    func draw(name:String){
        
        let font = UIFont(name: "Acme-Regular", size: 70)!
        UIColor.white.setStroke()
        var lastCharWidth:CGFloat = 0
        
        for char in name.characters{
            
            var unichars = [UniChar]("\(char)".utf16)
            var glyphs = [CGGlyph](repeating: 0, count: unichars.count)
            let gotGlyphs = CTFontGetGlyphsForCharacters(font, &unichars, &glyphs, unichars.count)
            if gotGlyphs {
                
                let cgpath = CTFontCreatePathForGlyph(font, glyphs[0], nil)!
                
                let path = UIBezierPath(cgPath: cgpath)
                
                let area = path.bounds.width * path.bounds.height
                print(area)
                
                
                let dashes: [CGFloat] = [path.lineWidth*0, path.lineWidth*2]
                path.setLineDash(dashes, count: dashes.count, phase: 0)
                path.lineCapStyle = CGLineCap.round
                path.lineWidth = 2
                
                let transform = CGAffineTransform(scaleX: 1.0, y: -1.0)
                let translate = CGAffineTransform(translationX: lastCharWidth, y: -100)
                path.apply(translate)
                path.apply(transform)
                
                path.stroke()
                
                path.fill()
                
                
                lastCharWidth += path.bounds.width
                originalPath = path
                
            }
        }
    }
    
    func compareDrawing(){
        timer?.invalidate()
        var correct:CGFloat = 0
        var wrong:CGFloat = 0
        
//        originalPath?.fill()
        
        for point in drawingPoints{
            if  (originalPath?.contains(point))!{
                correct += 1
            }else{
                wrong += 1
            }
        }
        
        if correct > 0{
            print(correct/CGFloat(drawingPoints.count))
            let percentageCorrect:CGFloat = (correct / CGFloat(drawingPoints.count) ) * 100
            switch percentageCorrect {
            case 80...100:
                print("Excellent")
                
            case 60...79:
                print("Good")
                
            default:
                print("Do it again")
            }
        }else{
            print("Do it again")
        }
        
    }
}
