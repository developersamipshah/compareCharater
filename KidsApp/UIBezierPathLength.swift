//  The MIT License (MIT)
//
//  Copyright (c) 2016 Jansel Valentin
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.


import UIKit

extension CGPath{
    
    func getPathElementsPoints() -> [CGPoint] {
        var arrayPoints : [CGPoint]! = [CGPoint]()
        self.forEach { element in
            switch (element.type) {
            case CGPathElementType.moveToPoint:
                arrayPoints.append(element.points[0])
            case .addLineToPoint:
                arrayPoints.append(element.points[0])
            case .addQuadCurveToPoint:
                arrayPoints.append(element.points[0])
                arrayPoints.append(element.points[1])
            case .addCurveToPoint:
                arrayPoints.append(element.points[0])
                arrayPoints.append(element.points[1])
                arrayPoints.append(element.points[2])
            default: break
            }
        }
        return arrayPoints
    }
    
    func getPathElementsPointsAndTypes() -> ([CGPoint],[CGPathElementType]) {
        var arrayPoints : [CGPoint]! = [CGPoint]()
        var arrayTypes : [CGPathElementType]! = [CGPathElementType]()
        self.forEach { element in
            switch (element.type) {
            case CGPathElementType.moveToPoint:
                arrayPoints.append(element.points[0])
                arrayTypes.append(element.type)
            case .addLineToPoint:
                arrayPoints.append(element.points[0])
                arrayTypes.append(element.type)
            case .addQuadCurveToPoint:
                arrayPoints.append(element.points[0])
                arrayPoints.append(element.points[1])
                arrayTypes.append(element.type)
                arrayTypes.append(element.type)
            case .addCurveToPoint:
                arrayPoints.append(element.points[0])
                arrayPoints.append(element.points[1])
                arrayPoints.append(element.points[2])
                arrayTypes.append(element.type)
                arrayTypes.append(element.type)
                arrayTypes.append(element.type)
            default: break
            }
        }
        return (arrayPoints,arrayTypes)
    }
    
    func forEach( body: @convention(block) (CGPathElement) -> Void) {
        typealias Body = @convention(block) (CGPathElement) -> Void
        let callback: @convention(c) (UnsafeMutableRawPointer, UnsafePointer<CGPathElement>) -> Void = { (info, element) in
            let body = unsafeBitCast(info, to: Body.self)
            body(element.pointee)
        }
        print(MemoryLayout.size(ofValue: body))
        
        let unsafeBody = unsafeBitCast(body, to: UnsafeMutableRawPointer.self)
        self.apply(info: unsafeBody, function: unsafeBitCast(callback, to: CGPathApplierFunction.self))
    }
}


extension UIBezierPath {
    

    var points: [CGPoint] {
        let maxX = Int(self.cgPath.boundingBox.maxX)
        let maxY = Int(self.cgPath.boundingBox.maxY)
        
        let minX = Int(self.cgPath.boundingBox.minX)
        let minY = Int(self.cgPath.boundingBox.minY)
        
        var characterPixels = [CGPoint]()
        
        for x in minX...maxX {
            for y in minY...maxY {
                let point:CGPoint = CGPoint(x: x, y: y)
                if self.contains(point) {
                    characterPixels.append(point)
                }
            }
        }
        
        return characterPixels
    }
    
    var height:CGFloat {
        return self.cgPath.boundingBox.height
    }
    
    var width:CGFloat {
        return self.cgPath.boundingBox.width
    }
    
    /*
     get area of uibeizer path in pixels square with precision
     */
    var area: CGFloat {
        return CGFloat(self.points.count)
    }
    
    
    
    
    var length: CGFloat {
        var pathLength:CGFloat = 0.0
        var current = CGPoint.zero
        var first   = CGPoint.zero
        
        self.cgPath.forEach{ element in
            pathLength += element.distance(to: current, startPoint: first)
            
            if element.type == .moveToPoint{
                first = element.point
            }
            if element.type != .closeSubpath{
                current = element.point
            }
        }
        return pathLength
    }
}


extension CGPathElement{
    
    var point: CGPoint{
        switch type {
        case .moveToPoint, .addLineToPoint:
            return self.points[0]
        case .addQuadCurveToPoint:
            return self.points[1]
        case .addCurveToPoint:
            return self.points[2]
        case .closeSubpath:
            return CGRect.null.origin
        }
    }
    
    func distance(to point: CGPoint, startPoint: CGPoint ) -> CGFloat{
        switch type {
        case .moveToPoint:
            return 0.0
        case .closeSubpath:
            return point.distance(to:startPoint)
        case .addLineToPoint:
            return point.distance(to:self.points[0])
        case .addCurveToPoint:
            return BezierCurveLength(p0: point, c1: self.points[0], c2: self.points[1], p1: self.points[2])
        case .addQuadCurveToPoint:
            return BezierCurveLength(p0: point, c1: self.points[0], p1: self.points[1])
        }
    }
}

extension CGPoint{
    func distance(to:CGPoint) -> CGFloat{
        let dx = pow(to.x - self.x,2)
        let dy = pow(to.y - self.y,2)
        return sqrt(dx+dy)
    }
}



// Helper Functions

func CubicBezierCurveFactors(t:CGFloat) -> (CGFloat,CGFloat,CGFloat,CGFloat){
    let t1 = pow(1.0-t, 3.0)
    let t2 = 3.0*pow(1.0-t,2.0)*t
    let t3 = 3.0*(1.0-t)*pow(t,2.0)
    let t4 = pow(t, 3.0)
    
    return  (t1,t2,t3,t4)
}


func QuadBezierCurveFactors(t:CGFloat) -> (CGFloat,CGFloat,CGFloat){
    let t1 = pow(1.0-t,2.0)
    let t2 = 2.0*(1-t)*t
    let t3 = pow(t, 2.0)
    
    return (t1,t2,t3)
}

// Quadratic Bezier Curve
func BezierCurve(t:CGFloat,p0:CGFloat,c1:CGFloat,p1:CGFloat) -> CGFloat{
    let factors = QuadBezierCurveFactors(t: t)
    return (factors.0*p0) + (factors.1*c1) + (factors.2*p1)
}


// Quadratic Bezier Curve
func BezierCurve(t:CGFloat,p0:CGPoint,c1:CGPoint,p1:CGPoint) -> CGPoint{
    let x = BezierCurve(t: t, p0: p0.x, c1: c1.x, p1: p1.x)
    let y = BezierCurve(t: t, p0: p0.y, c1: c1.y, p1: p1.y)
    return CGPoint(x: x, y: y)
}



// Cubic Bezier Curve
func BezierCurve(t:CGFloat,p0:CGFloat, c1:CGFloat, c2:CGFloat, p1:CGFloat) -> CGFloat{
    let factors = CubicBezierCurveFactors(t: t)
    return (factors.0*p0) + (factors.1*c1) + (factors.2*c2) + (factors.3*p1)
}


// Cubic Bezier Curve
func BezierCurve(t: CGFloat, p0:CGPoint, c1:CGPoint, c2: CGPoint, p1: CGPoint) -> CGPoint{
    let x = BezierCurve(t: t, p0: p0.x, c1: c1.x, c2: c2.x, p1: p1.x)
    let y = BezierCurve(t: t, p0: p0.y, c1: c1.y, c2: c2.y, p1: p1.y)
    return CGPoint(x: x, y: y)
}


// Cubic Bezier Curve Length
func BezierCurveLength(p0:CGPoint,c1:CGPoint, c2:CGPoint, p1:CGPoint) -> CGFloat{
    let steps = 12 // on greater samples, more presicion
    
    var current  = p0
    var previous = p0
    var length:CGFloat = 0.0
    
    for i in 1...steps{
        let t = CGFloat(i) / CGFloat(steps)
        current = BezierCurve(t: t, p0: p0, c1: c1, c2: c2, p1: p1)
        length += previous.distance(to: current)
        previous = current
    }
    
    return length
}


// Quadratic Bezier Curve Length
func BezierCurveLength(p0:CGPoint,c1:CGPoint, p1:CGPoint) -> CGFloat{
    let steps = 12 // on greater samples, more presicion
    
    var current  = p0
    var previous = p0
    var length:CGFloat = 0.0
    
    for i in 1...steps{
        let t = CGFloat(i) / CGFloat(steps)
        current = BezierCurve(t: t, p0: p0, c1: c1, p1: p1)
        length += previous.distance(to: current)
        previous = current
    }
    return length
}
