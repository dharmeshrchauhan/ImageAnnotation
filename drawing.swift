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
    var cnt: Int = 0
    
    var lastpoint: CGPoint!
    var newPoint: CGPoint!
    
    var drawColor = UIColor.blackColor()
    
    var l_w: CGFloat! = 1
    var l_opacity: CGFloat! = 1
        
    @IBOutlet weak var undo: UIButton!
    
    @IBOutlet weak var redo: UIButton!
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        undo.hidden = false
        redo.hidden = false
        cnt=0
        lastpoint = touches.anyObject()?.locationInView(self) //it assigh the last point that touch
        
        self.superview!.bringSubviewToFront(self)
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        newPoint = touches.anyObject()?.locationInView(self) //it assigh the moves point
        cnt++
        //add both line
        lines.append(Line(start: lastpoint, end: newPoint!, color: drawColor, l_width: l_w, opacity: l_opacity,cnt: cnt))
        
        //now assign newPoint to lastpoint
        lastpoint = newPoint
       
        self.setNeedsDisplay()
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        newPoint = lastpoint
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

    func removeLastLine() {
        if lines.count > 0 {
            lines.removeLast()
            self.setNeedsDisplay()
        }
    }
}
