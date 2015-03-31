//
//  drawing.swift
//  ImageAnnotation
//
//  Created by Sagar on 25/03/15.
//  Copyright (c) 2015 Sagar. All rights reserved.
//

import UIKit

class drawing: UIView {

    var lines: Array<Line> = []
//    var totalLine: Array<Array<Line>> = []
    var strokes: Array<Array<Line>> = []
    var strokesOpacity: Array<Array<Line>> = []
    var removeLine: Array<Array<Line>> = []
    var arrayIndex: Int = 0
    var arrayIndex1: Int = 0
    var lastLineIndex: Int = 0
//    var totalLineIndex: Int = 0
    var lastLineDraw: Array<String> = []
    var cnt: Int = 0
    var lastpoint: CGPoint!
    var newPoint: CGPoint!
    var drawColor = UIColor.blackColor()
    var l_w: CGFloat! = 1
    var textField: UITextField?
    
    @IBOutlet weak var undo: UIButton!
    
    @IBOutlet weak var redo: UIButton!
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        if MyVariables.flag == "drawline" {
            cnt=0
            lastpoint = touches.anyObject()?.locationInView(self) //it assigh the last point that touch
            
        } else if MyVariables.flag == "drawopacityline" {
            cnt=0
            lastpoint = touches.anyObject()?.locationInView(self) //it assigh the last point that touch
        } else if MyVariables.flag == "addTextView" {
            lastpoint = touches.anyObject()?.locationInView(self)
            lastLineDraw.insert("addTextView", atIndex: lastLineIndex++)
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        
        if MyVariables.flag == "drawline" {
            newPoint = touches.anyObject()?.locationInView(self) //it assigh the moves point
            cnt++
            lines.append(Line(start: lastpoint, end: newPoint, color: drawColor, l_width: l_w, cnt: cnt))
            self.setNeedsDisplay()
            
        } else if MyVariables.flag == "drawopacityline" {
            newPoint = touches.anyObject()?.locationInView(self) //it assigh the moves point
            cnt++
            lines.append(Line(start: lastpoint, end: newPoint, color: drawColor, l_width: l_w, cnt: cnt))
            self.setNeedsDisplay()
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
        if MyVariables.flag == "drawline" {
            lastLineDraw.insert("drawline", atIndex: lastLineIndex++)
            strokes.insert(lines, atIndex: arrayIndex++)
            newPoint = lastpoint
            lines = []
            NSLog("LastLineIndex: %i", lastLineIndex)
            self.setNeedsDisplay()
            
        } else if MyVariables.flag == "drawopacityline" {
            lastLineDraw.insert("drawopacityline", atIndex: lastLineIndex++)
            strokesOpacity.insert(lines, atIndex: arrayIndex1++)
            newPoint = lastpoint
            lines = []
            NSLog("LastLineIndex: %i", lastLineIndex)
            self.setNeedsDisplay()
        }
    }
    
    override func drawRect(rect: CGRect) {
        
        if strokes.count > 0 || strokesOpacity.count > 0 {
            undo.hidden = false
        }
        
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
            
        } else if MyVariables.flag == "addTextView" {
            
            textField = UITextField(frame: CGRect(x: lastpoint.x, y: lastpoint.y, width: 100, height: 35))
            textField?.textColor = lines.first?.color
            textField?.text = "."
            self.addSubview(textField!)
            textField!.multipleTouchEnabled = true
            textField!.userInteractionEnabled = true
            
            // Add runtime PanGestureRecognizer into UITextField
            textField?.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "onPan:"))
        }
    }
    
    func onPan(recognizer : UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(self)
        recognizer.view!.center = CGPoint(x:recognizer.view!.center.x + translation.x, y:recognizer.view!.center.y + translation.y)
        recognizer.setTranslation(CGPointZero, inView: self)
    }
}
