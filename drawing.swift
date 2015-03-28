//
//  drawing.swift
//  ImageAnnotation
//
//  Created by Sagar on 25/03/15.
//  Copyright (c) 2015 Sagar. All rights reserved.
//

import UIKit

class drawing: UIView {

    var lines: [Line ] = []
    //var linesOpacity: [Line ] = []
    var strokes: Array<Array<Line>> = []
    var strokesOpacity: Array<Array<Line>> = []
    var arrayIndex: Int = 0
    var arrayIndex1: Int = 0
    var cnt: Int = 0
    //var cnt1: Int = 0
    var lastpoint: CGPoint!
    var newPoint: CGPoint!
    var drawColor = UIColor.blackColor()
    var l_w: CGFloat! = 1
    
    @IBOutlet weak var undo: UIButton!
    
    @IBOutlet weak var redo: UIButton!
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        if MyVariables.flag == "drawline" {
            cnt=0
            lastpoint = touches.anyObject()?.locationInView(self) //it assigh the last point that touch
            
        } else if MyVariables.flag == "drawopacityline" {
            cnt=0
            lastpoint = touches.anyObject()?.locationInView(self) //it assigh the last point that touch
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        
        if MyVariables.flag == "drawline" {
            newPoint = touches.anyObject()?.locationInView(self) //it assigh the moves point
            cnt++
            lines.append(Line(start: lastpoint, end: newPoint, color: drawColor, l_width: l_w, cnt: cnt))
            lastpoint = newPoint
            self.setNeedsDisplay()
            
        } else if MyVariables.flag == "drawopacityline" {
            newPoint = touches.anyObject()?.locationInView(self) //it assigh the moves point
            cnt++
            lines.append(Line(start: lastpoint, end: newPoint, color: drawColor, l_width: l_w, cnt: cnt))
            lastpoint = newPoint
            self.setNeedsDisplay()
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
        if MyVariables.flag == "drawline" {
            strokes.insert(lines, atIndex: arrayIndex++)
            newPoint = lastpoint
            lines = []
            self.setNeedsDisplay()
            
        } else if MyVariables.flag == "drawopacityline" {
            strokesOpacity.insert(lines, atIndex: arrayIndex1++)
            newPoint = lastpoint
            lines = []
            self.setNeedsDisplay()
        }
    }
    
    override func drawRect(rect: CGRect) {
        
        var cxt = UIGraphicsGetCurrentContext()
        CGContextSetLineCap(cxt, kCGLineCapRound)
        UIGraphicsBeginImageContext(self.frame.size)
        
        for stroke in strokes {
            if stroke.count > 0 {
                CGContextBeginPath(cxt)
                CGContextSetLineWidth(cxt, stroke.first!.l_width)
                CGContextMoveToPoint(cxt, stroke.first!.start.x, stroke.first!.start.y)
            }
            
            for line in stroke {
                CGContextSetStrokeColorWithColor(cxt, line.color.CGColor)
                CGContextAddLineToPoint(cxt, line.end.x, line.end.y)
            }
            CGContextStrokePath(cxt)
        }
        
        for stroke in strokesOpacity {
            if stroke.count > 0 {
                CGContextBeginPath(cxt)
                CGContextSetAlpha(cxt, 0.4)
                CGContextSetLineWidth(cxt, 10)
                CGContextMoveToPoint(cxt, stroke.first!.start.x, stroke.first!.start.y)
            }
            
            for line in stroke {
                CGContextSetStrokeColorWithColor(cxt, line.color.CGColor)
                CGContextAddLineToPoint(cxt, line.end.x, line.end.y)
            }
            CGContextStrokePath(cxt)
        }

        
        if MyVariables.flag == "drawline" {
            undo.hidden = false
            redo.hidden = false
            
            if lines.count > 0 {
                CGContextBeginPath(cxt)
                CGContextSetLineWidth(cxt, lines.first!.l_width)
                CGContextMoveToPoint(cxt, lines.first!.start.x, lines.first!.start.y)
            }
            
            for line in lines {
                CGContextSetStrokeColorWithColor(cxt, line.color.CGColor)
                CGContextAddLineToPoint(cxt, line.end.x, line.end.y)
            }
            
            CGContextStrokePath(cxt)
            
            UIGraphicsEndImageContext()
            
        }
        else if MyVariables.flag == "drawopacityline" {
            undo.hidden = false
            redo.hidden = false
            
            if lines.count > 0 {
                CGContextBeginPath(cxt)
                CGContextSetAlpha(cxt, 0.4)
                CGContextSetLineWidth(cxt, 10)
                CGContextMoveToPoint(cxt, lines.first!.start.x, lines.first!.start.y)
            }
            
            for line in lines {
                CGContextSetStrokeColorWithColor(cxt, line.color.CGColor)
                CGContextAddLineToPoint(cxt, line.end.x, line.end.y)
            }
            
            CGContextStrokePath(cxt)
            
            UIGraphicsEndImageContext()
        }
    }
    
    func removeLastLine() {
        
        if strokes.count > 0 {
            for strock in strokes {
           //     strock.removeLast()
                self.setNeedsDisplay()
            }
        }
    }

}
