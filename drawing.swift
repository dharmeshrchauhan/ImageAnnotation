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
    
    var isDrawingCircle: Bool = false;
    var isDrawingRectangle: Bool = false;
    
    var lines: Array<Line> = []
    var circle_obj: Array<Circle> = []
    var rectangle_obj: Array<Rectangle> = []
    
    var strokes: Array<Array<Line>> = []
    var strokesOpacity: Array<Array<Line>> = []
    var lastLineDraw: Array<String> = []
    var redoshapetypes: Array<String> = []
    var circles: Array<CGRect> = []
    var rectangles: Array<CGRect> = []
    var redoArray: Array<Any> = []
    
    var arrayIndex: Int = 0
    var arrayIndex1: Int = 0
    var lastLineIndex: Int = 0
    
    var cnt: CGFloat = 0
    var lastpoint: CGPoint!
    var newPoint: CGPoint!
    var drawColor = UIColor.blackColor()
    var l_w: CGFloat! = 1
    
    var textField: UITextField?
    
    var circleWidth: CGFloat?
    var circleHeight: CGFloat?
    var rectWidth: CGFloat?
    var rectHeight: CGFloat?

    @IBOutlet weak var undo: UIButton!
    
    @IBOutlet weak var redo: UIButton!
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        if MyVariables.flag == "drawLine" {
            lastpoint = touches.anyObject()?.locationInView(self) //it assigh the last point that touch
            
        } else if MyVariables.flag == "drawOpacityLine" {
            lastpoint = touches.anyObject()?.locationInView(self) //it assigh the last point that touch
            
        } else if MyVariables.flag == "addTextView" {
            lastpoint = touches.anyObject()?.locationInView(self)
            lastLineDraw.insert("addTextView", atIndex: lastLineIndex++)
            self.setNeedsDisplay()
            
        } else if MyVariables.flag == "drawCircle" {
            isDrawingCircle = true;
            circle_obj.append(Circle(color: drawColor, l_width: l_w))
            lastLineDraw.insert("drawCircle", atIndex: lastLineIndex++)
            
            // Set the Center of the Circle
            // 1
            lastpoint = touches.anyObject()?.locationInView(self)
                
            // Set a random Circle Radius
            // 2
            circleWidth = cnt
            circleHeight = circleWidth
            
        } else if MyVariables.flag == "drawRectangle" {
            isDrawingRectangle = true;
            rectangle_obj.append(Rectangle(color: drawColor, l_width: l_w))
            lastLineDraw.insert("drawRectangle", atIndex: lastLineIndex++)
            
            // Set the Center of the Circle
            // 1
            lastpoint = touches.anyObject()?.locationInView(self)
            
            // Set a random Circle Radius
            // 2
            rectWidth = cnt
            rectHeight = rectWidth
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        
        if MyVariables.flag == "drawLine" {
            newPoint = touches.anyObject()?.locationInView(self) //it assigh the moves point
            lines.append(Line(start: lastpoint, end: newPoint, color: drawColor, l_width: l_w))
            self.setNeedsDisplay()
            
        } else if MyVariables.flag == "drawOpacityLine" {
            newPoint = touches.anyObject()?.locationInView(self) //it assigh the moves point
            lines.append(Line(start: lastpoint, end: newPoint, color: drawColor, l_width: l_w))
            self.setNeedsDisplay()
            
        } else if MyVariables.flag == "drawCircle" {
            circleWidth = cnt++
            circleHeight = circleWidth
            newPoint = touches.anyObject()?.locationInView(self) //it assigh the moves point
            self.setNeedsDisplay()
            
        } else if MyVariables.flag == "drawRectangle" {
            rectWidth = cnt++
            rectHeight = rectWidth
            newPoint = touches.anyObject()?.locationInView(self) //it assigh the moves point
            self.setNeedsDisplay()
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
        if MyVariables.flag == "drawLine" {
            lastLineDraw.insert("drawLine", atIndex: lastLineIndex++)
            strokes.insert(lines, atIndex: arrayIndex++)
            newPoint = lastpoint
            lines = []
            NSLog("LastLineIndex: %i", lastLineIndex)
            self.setNeedsDisplay()
            
        } else if MyVariables.flag == "drawOpacityLine" {
            lastLineDraw.insert("drawOpacityLine", atIndex: lastLineIndex++)
            strokesOpacity.insert(lines, atIndex: arrayIndex1++)
            newPoint = lastpoint
            lines = []
            NSLog("LastLineIndex: %i", lastLineIndex)
            self.setNeedsDisplay()
            
        } else if MyVariables.flag == "drawCircle" {
            isDrawingCircle = false
            circles.append(CGRectMake(lastpoint.x, lastpoint.y, (newPoint.x - lastpoint.x), (newPoint.y - lastpoint.y)))
            cnt = 0
            self.setNeedsDisplay()
        } else if MyVariables.flag == "drawRectangle" {
            isDrawingRectangle = false
            rectangles.append(CGRectMake(lastpoint.x, lastpoint.y, (newPoint.x - lastpoint.x) / 2, (newPoint.y - lastpoint.y) / 2))
            cnt = 0
            self.setNeedsDisplay()
        }
    }
    
    override func drawRect(rect: CGRect) {
        
        if strokes.count > 0 || strokesOpacity.count > 0 || circles.count > 0 || rectangles.count > 0 {
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
        
        //Draw Circle
        //if circle is being drawin
        if (isDrawingCircle)
        {
            // Set the circle outerline-width
            CGContextSetLineWidth(cxt, circle_obj.first!.l_width)
            // Set the circle outerline-colour
            CGContextSetStrokeColorWithColor(cxt,circle_obj.first?.color.CGColor)
            // Set circle opacity
            CGContextSetAlpha(cxt, 1.0)
            // Create circle
            CGContextAddEllipseInRect(cxt, CGRectMake(lastpoint.x, lastpoint.y, (newPoint.x - lastpoint.x), (newPoint.y - lastpoint.y)))
            // Draw
            CGContextStrokePath(cxt)
        }
        
        for circle in circles {
            CGContextSetLineWidth(cxt, circle_obj.first!.l_width)
            // Set the circle outerline-colour
            CGContextSetStrokeColorWithColor(cxt,circle_obj.first?.color.CGColor)
            // Create circle
            CGContextAddEllipseInRect(cxt, circle);
            // Draw
            CGContextStrokePath(cxt)
        }
        
        //Draw Rectangel
        //if rectangel is being drawin
        if (isDrawingRectangle)
        {
            // Set the rectangel outerline-width
            CGContextSetLineWidth(cxt, rectangle_obj.first!.l_width)
            // Set the rectangel outerline-colour
            CGContextSetStrokeColorWithColor(cxt,rectangle_obj.first?.color.CGColor)
            // Set rectangel opacity
            CGContextSetAlpha(cxt, 1.0)
            // Create rectangel
            CGContextAddRect(cxt, CGRectMake(lastpoint.x, lastpoint.y, (newPoint.x - lastpoint.x) / 2 , (newPoint.y - lastpoint.y) / 2))
            // Draw
            CGContextStrokePath(cxt)
        }
        
        for rectangle in rectangles {
            rectangle_obj.append(Rectangle(color: drawColor, l_width: l_w))
            CGContextSetLineWidth(cxt, rectangle_obj.first!.l_width)
            // Set the rectangel outerline-colour
            CGContextSetStrokeColorWithColor(cxt,rectangle_obj.first?.color.CGColor)
            // Create rectangel
            CGContextAddRect(cxt, rectangle);
            // Draw
            CGContextStrokePath(cxt)
        }

        //
        if MyVariables.flag == "drawLine" {
            
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
            
        } else if MyVariables.flag == "drawOpacityLine" {
            
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
            textField?.text = "Hello"
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
