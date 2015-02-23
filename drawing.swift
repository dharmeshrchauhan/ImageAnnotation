//
//  drawing.swift
//  ImageAnnotation
//
//  Created by Sagar on 16/02/15.
//  Copyright (c) 2015 Sagar. All rights reserved.
//

import UIKit

class drawing: UIView {
    
    var lines: [Line ] = []
    var lastpoint: CGPoint!
    var drawColor = UIColor.blackColor()
    var l_w: CGFloat! = 1
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        lastpoint = touches.anyObject()?.locationInView(self) //it assigh the last point that touch
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        var newPoint = touches.anyObject()?.locationInView(self) //it assigh the moves point
        
        //add both line
        lines.append(Line(start: lastpoint, end: newPoint!, color: drawColor, l_width: l_w))
        
        //now assign newPoint to lastpoint
        lastpoint = newPoint
        
        self.setNeedsDisplay()
    }
    
    // It draw a line into a view
    override func drawRect(rect: CGRect) {
        var cxt = UIGraphicsGetCurrentContext()
        CGContextSetLineCap(cxt, kCGLineCapRound)
        
        for line in lines {
            CGContextBeginPath(cxt)
            CGContextSetLineWidth(cxt, line.l_width)
            CGContextMoveToPoint(cxt, line.start.x, line.start.y)
            CGContextAddLineToPoint(cxt, line.end.x, line.end.y)
            CGContextSetStrokeColorWithColor(cxt, line.color.CGColor)
            CGContextStrokePath(cxt)
        }
    }
    
    // It handel runtime handelPinch method
    @IBAction func handlePinch(recognizer : UIPinchGestureRecognizer) {
        recognizer.view!.transform = CGAffineTransformScale(recognizer.view!.transform,recognizer.scale, recognizer.scale)
        recognizer.scale = 1
    }


}
