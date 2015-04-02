//
//  drawing.swift
//  ImageAnnotation
//
//  Created by Sagar on 25/03/15.
//  Copyright (c) 2015 Sagar. All rights reserved.
//

import UIKit

class drawing: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    var lines: Array<Line> = []
    var strokes: Array<Array<Line>> = []
    var strokesOpacity: Array<Array<Line>> = []
    var arrayIndex: Int = 0
    var arrayIndex1: Int = 0
    var lastLineIndex: Int = 0
    var lastLineDraw: Array<String> = []
    var cnt: CGFloat = 0
    var lastpoint: CGPoint!
    var newPoint: CGPoint!
    var drawColor = UIColor.blackColor()
    var l_w: CGFloat! = 1
    var textField: UITextField?
    var circleWidth: CGFloat?
    var circleHeight: CGFloat?
    
    @IBOutlet weak var undo: UIButton!
    
    @IBOutlet weak var redo: UIButton!
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        if MyVariables.flag == "drawline" {
            lastpoint = touches.anyObject()?.locationInView(self) //it assigh the last point that touch
            
        } else if MyVariables.flag == "drawopacityline" {
            lastpoint = touches.anyObject()?.locationInView(self) //it assigh the last point that touch
            
        } else if MyVariables.flag == "addTextView" {
            lastpoint = touches.anyObject()?.locationInView(self)
            lastLineDraw.insert("addTextView", atIndex: lastLineIndex++)
            
        } else if MyVariables.flag == "drawCircle" {
            lastLineDraw.insert("drawCircle", atIndex: lastLineIndex++)
            
            // Set the Center of the Circle
            // 1
            lastpoint = touches.anyObject()?.locationInView(self)
                
            // Set a random Circle Radius
            // 2
            circleWidth = cnt
            circleHeight = circleWidth
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        
        if MyVariables.flag == "drawline" {
            newPoint = touches.anyObject()?.locationInView(self) //it assigh the moves point
            lines.append(Line(start: lastpoint, end: newPoint, color: drawColor, l_width: l_w))
            self.setNeedsDisplay()
            
        } else if MyVariables.flag == "drawopacityline" {
            newPoint = touches.anyObject()?.locationInView(self) //it assigh the moves point
            lines.append(Line(start: lastpoint, end: newPoint, color: drawColor, l_width: l_w))
            self.setNeedsDisplay()
            
        } else if MyVariables.flag == "drawCircle" {
            circleWidth = cnt++
            circleHeight = circleWidth
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
            
        } else if MyVariables.flag == "drawCircle" {
            //Create a new Cirecle
            var circleView = drawing(frame: CGRectMake(lastpoint!.x, lastpoint!.y, circleWidth!, circleHeight!))
            self.addSubview(circleView)
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
            
        } else if MyVariables.flag == "drawopacityline" {
            
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
            
        } else if MyVariables.flag == "drawCircle" {
            // Set the circle outerline-width
            CGContextSetLineWidth(cxt, 5.0)
            
            // Set the circle outerline-colour
            UIColor.redColor().set()
            
            // Create Circle
            CGContextAddArc(cxt, (frame.size.width)/2, frame.size.height/2, (frame.size.width - 10)/2, 0.0, CGFloat(M_PI * 2.0), 1)
            
            // Draw
            CGContextStrokePath(cxt)
        }
    }
    
    func onPan(recognizer : UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(self)
        recognizer.view!.center = CGPoint(x:recognizer.view!.center.x + translation.x, y:recognizer.view!.center.y + translation.y)
        recognizer.setTranslation(CGPointZero, inView: self)
    }
}
