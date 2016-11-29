//
//  DrawingView.swift
//  KidsApp
//
//  Created by Sam on 11/22/16.
//  Copyright © 2016 Sam. All rights reserved.
//

import UIKit
let BRUSH_WIDTH:CGFloat = 20

class DrawingView: UIView {
    
    var originalPath:UIBezierPath!
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
        drawingPath.lineWidth = BRUSH_WIDTH
        drawingPath.lineCapStyle =  .round
        drawingPath.lineJoinStyle = .round
        self.isMultipleTouchEnabled = false
        
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        draw(name: textToDraw!)
        UIColor.red.setStroke()
        drawingPath.stroke()
        
        let drawingPathBox = UIBezierPath(rect: drawingPath.bounds)
        drawingPathBox.stroke()
        
        
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
        timer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(self.generateResult), userInfo: nil, repeats: false)
    }
    
    func reset(){
        drawingPath.removeAllPoints()
        setNeedsDisplay()
    }
    
    func getBiggerFrame(fromPath path: CGPath) -> CGRect {
        let tmpFrame = path.boundingBox
        let biggerFrame = CGRect(x: CGFloat(tmpFrame.origin.x - 10 / 2), y: CGFloat(tmpFrame.origin.y - 10 / 2), width: CGFloat(tmpFrame.size.width + 10), height: CGFloat(tmpFrame.size.height + 10))
        return biggerFrame
    }
    
    func refreshDisplay(withPath path: CGPath) {
        self.setNeedsDisplay(self.getBiggerFrame(fromPath: path))
    }
    
    
    func draw(name:String){
        
        let font = UIFont(name: "Arial", size: BRUSH_WIDTH*15)!
        UIColor.white.setStroke()
        
        var lastCharWidth:CGFloat = 0
        
        for char in name.characters{
            
            var unichars = [UniChar]("\(char)".utf16)
            var glyphs = [CGGlyph](repeating: 0, count: unichars.count)
            let gotGlyphs = CTFontGetGlyphsForCharacters(font, &unichars, &glyphs, unichars.count)
            if gotGlyphs {
                
                let cgpath = CTFontCreatePathForGlyph(font, glyphs[0], nil)!
                let path = UIBezierPath(cgPath: cgpath)
                
                let dashes: [CGFloat] = [path.lineWidth*0, path.lineWidth*8]
                path.setLineDash(dashes, count: dashes.count, phase: 0)
                path.lineCapStyle = CGLineCap.round
                path.lineWidth = 4
                
                let transform = CGAffineTransform(scaleX: 1.0, y: -1.0)
                let translate = CGAffineTransform(translationX: lastCharWidth, y: -self.frame.width/2)
                path.apply(translate)
                path.apply(transform)
                
                path.stroke()
                
                lastCharWidth += path.bounds.width
                originalPath = path
                
                
                let anotherPath = UIBezierPath(rect: (originalPath?.bounds)!)
                anotherPath.stroke()
                
            }
        }
    }
    
    
    func generateResult(){
        
        // Started Checking result so terminate timer
        timer?.invalidate()
        
        // Bounding Box Check
        let originalBoundingBox = originalPath.bounds
        let drawingBoundingBox = drawingPath.bounds
        
        let widthCorrectness = (drawingBoundingBox.width + BRUSH_WIDTH)/originalBoundingBox.width
        let heightCorrectness = (drawingBoundingBox.height + BRUSH_WIDTH)/originalBoundingBox.height
        
        // Perimeter Check
        let noOFEdges:CGFloat = CGFloat(2)
        let drawingPerimeter = 2*drawingPath.length+noOFEdges*BRUSH_WIDTH
        let orginalPerimeter = originalPath.length
        let perimeterCorrectness = drawingPerimeter/orginalPerimeter
        
        // Area Check
        let drawingArea = drawingPath.length*BRUSH_WIDTH
        let originalArea = originalPath.area
        
        let areaCorrectness = drawingArea/originalArea
        
        // Points Check        
        var correct:CGFloat = 0
        
        for point in drawingPoints{
            if (originalPath?.contains(point))!{
                correct += 1
            }
        }
        
        let containsPointCorrectness = correct/CGFloat(drawingPoints.count)
        
        
        // Overall Result Calculation
        
        print("Width Correctness = 0.%2f %.",widthCorrectness*100)
        print("Height Correctness = 0.%2f %.",heightCorrectness*100)
        print("Perimeter Correctness = 0.%2f %.",perimeterCorrectness*100)
        print("Area Correctness = 0.%2f %.",areaCorrectness*100)
        print("Contains Point Correctness = 0.%2f %.",containsPointCorrectness*100)
        
    }
}
