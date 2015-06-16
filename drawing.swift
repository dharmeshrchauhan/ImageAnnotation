//
//  drawing.swift
//  ImageAnnotation
//
//  Created by Sagar on 25/03/15.
//  Copyright (c) 2015 Sagar. All rights reserved.
//

import UIKit

class drawing: UIView, UITextFieldDelegate {

    var view_controller: ViewController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        var center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    var isDrawingCircle: Bool = false
    var isDrawingRectangle: Bool = false
    var isDrawingStraightLine: Bool = false
    var keyboardStatus: Bool = false
    
    var objTextField: TextField?
    var circle_obj: Circle?
    var rectangle_obj: Rectangle?
    var straightline_obj: StraightLine?
    var textField: UITextField?

    var lines: Array<Line> = []
    var strokes: Array<Array<Line>> = []
    var strokesOpacity: Array<Array<Line>> = []
    var lastLineDraw: Array<String> = []
    var redoshapetypes: Array<String> = []
    var circles: Array<Circle> = []
    var rectangles: Array<Rectangle> = []
    var straightlines: Array<StraightLine> = []
    var textFields: Array<UITextField> = []
    var redoArray: Array<Any> = []
    
    var tmpcnt: Int = 0
    var cntTextField: Int = 1000
    var lastpoint: CGPoint!
    var newPoint: CGPoint!
    var drawColor = UIColor.whiteColor()
    var l_w: CGFloat! = 1
    var textFieldFontSize: CGFloat = 20
    var lineOpacity: CGFloat = 0.0
    
    @IBOutlet weak var undo: UIButton!
    @IBOutlet weak var redo: UIButton!
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        
        let array = Array(touches)
        let touch = array[0] as! UITouch
        
        if redoArray.count > 0 {
            redo.hidden = true
            redoArray = []
        }
        
        if MyVariables.flag == "drawLine" {
            view_controller!.isImageSaved = false
            lastpoint = touch.locationInView(self) //it assigh the last point that touch
            
        } else if MyVariables.flag == "drawOpacityLine" {
            lastpoint = touch.locationInView(self) //it assigh the last point that touch
            
        } else if MyVariables.flag == "addTextField" {
            
            if keyboardStatus == false {
                tmpcnt++
                var textFieldWidth: CGFloat = 30
                var textFieldHeight: CGFloat = 50
                
                lastpoint = touch.locationInView(self)
                objTextField = TextField(color: drawColor, start: lastpoint, fontSize: textFieldFontSize)
                
                lastLineDraw.append("addTextField")
                
                textField = UITextField(frame: CGRect(x: objTextField!.start.x, y: objTextField!.start.y, width: textFieldWidth, height: textFieldHeight))
                
                textField!.textColor = objTextField!.color
                
                textField?.font = UIFont.systemFontOfSize(objTextField!.fontSize)
                textField!.borderStyle = UITextBorderStyle.None
                textField!.layer.masksToBounds = true
                textField!.layer.borderColor = objTextField!.color.CGColor
                textField!.layer.borderWidth = 0.5
                textField?.tag = cntTextField++
                
                textFields.append(textField!)
                self.addSubview(textField!)
                textField!.becomeFirstResponder()
                
                textField!.delegate = self
                textField!.multipleTouchEnabled = true
                textField!.userInteractionEnabled = true
                
                // Add runtime PanGestureRecognizer into UITextField
                textField?.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "onPan:"))
                
                self.setNeedsDisplay()
            }
        } else if MyVariables.flag == "drawCircle" {
            isDrawingCircle = true
            lastpoint = touch.locationInView(self)
            circle_obj = Circle(color: drawColor, l_width: l_w, start: lastpoint, end: lastpoint)
            lastLineDraw.append("drawCircle")
            
        } else if MyVariables.flag == "drawRectangle" {
            isDrawingRectangle = true
            lastpoint = touch.locationInView(self)
            rectangle_obj = Rectangle(color: drawColor, l_width: l_w, start: lastpoint, end: lastpoint)
            lastLineDraw.append("drawRectangle")
            
        } else if MyVariables.flag == "drawStraightLine" {
            isDrawingStraightLine = true
            lastpoint = touch.locationInView(self)
            straightline_obj = StraightLine(start: lastpoint, end: lastpoint, color: drawColor, l_width: l_w)
            lastLineDraw.append("drawStraightLine")
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesMoved(touches, withEvent: event)
        
        let array = Array(touches)
        let touch = array[0] as! UITouch
        
        if MyVariables.flag == "drawLine" {
            newPoint = touch.locationInView(self) //it assigh the moves point
            lines.append(Line(start: lastpoint, end: newPoint, color: drawColor, l_width: l_w))
            self.setNeedsDisplay()
            
        } else if MyVariables.flag == "drawOpacityLine" {
            newPoint = touch.locationInView(self) //it assigh the moves point
            lines.append(Line(start: lastpoint, end: newPoint, color: drawColor, l_width: l_w))
            self.setNeedsDisplay()
            
        } else if MyVariables.flag == "drawCircle" {
            newPoint = touch.locationInView(self) //it assigh the moves point
            circle_obj!.end = newPoint
            self.setNeedsDisplay()
            
        } else if MyVariables.flag == "drawRectangle" {
            newPoint = touch.locationInView(self) //it assigh the moves point
            rectangle_obj!.end = newPoint
            self.setNeedsDisplay()
            
        } else if MyVariables.flag == "drawStraightLine" {
            newPoint = touch.locationInView(self) //it assigh the moves point
            straightline_obj!.end = newPoint
            self.setNeedsDisplay()
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        
        if MyVariables.flag == "drawLine" {
            lastLineDraw.append("drawLine")
            strokes.append(lines)
            newPoint = lastpoint
            lines = []
            self.setNeedsDisplay()
            tmpcnt++
            
        } else if MyVariables.flag == "drawOpacityLine" {
            lastLineDraw.append("drawOpacityLine")
            strokesOpacity.append(lines)
            newPoint = lastpoint
            lines = []
            self.setNeedsDisplay()
            tmpcnt++
            
        } else if MyVariables.flag == "drawCircle" {
            isDrawingCircle = false
            circles.append(circle_obj!)
            circle_obj = nil
            self.setNeedsDisplay()
            tmpcnt++
            
        } else if MyVariables.flag == "drawRectangle" {
            isDrawingRectangle = false
            rectangles.append(rectangle_obj!)
            rectangle_obj = nil
            self.setNeedsDisplay()
            tmpcnt++
            
        } else if MyVariables.flag == "drawStraightLine" {
            isDrawingStraightLine = false
            straightlines.append(straightline_obj!)
            straightline_obj = nil
            self.setNeedsDisplay()
            tmpcnt++
        }
    }
    
    override func drawRect(rect: CGRect) {
        
        if strokes.count > 0 || strokesOpacity.count > 0 || circles.count > 0 || rectangles.count > 0 || straightlines.count > 0 || textFields.count > 0 {
            undo.hidden = false
        }
        
        var cxt = UIGraphicsGetCurrentContext()
        CGContextSetLineCap(cxt, kCGLineCapRound)
        UIGraphicsBeginImageContext(self.frame.size)
        
        //for DrawLine
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
        
        //for DrawOpacityLine
        for stroke in strokesOpacity {
            lineOpacity = 0.4
            if stroke.count > 0 {
                CGContextBeginPath(cxt)
                CGContextSetAlpha(cxt, lineOpacity)
                CGContextSetLineWidth(cxt, 13)
                CGContextMoveToPoint(cxt, stroke.first!.start.x, stroke.first!.start.y)
            }
            
            for line in stroke {
                CGContextSetStrokeColorWithColor(cxt, line.color.CGColor)
                CGContextAddLineToPoint(cxt, line.end.x, line.end.y)
            }
            CGContextStrokePath(cxt)
        }
        
        //Draw StraightLine
        //if straightline is being drawin
        if (isDrawingStraightLine)
        {
            CGContextSetLineWidth(cxt, straightline_obj!.l_width)
            CGContextSetStrokeColorWithColor(cxt,straightline_obj?.color.CGColor)
            CGContextSetAlpha(cxt, 1.0)
            // Create straightline
            CGContextMoveToPoint(cxt, straightline_obj!.start.x, straightline_obj!.start.y)
            CGContextAddLineToPoint(cxt, straightline_obj!.end.x, straightline_obj!.end.y)
            // Draw
            CGContextStrokePath(cxt)
        }
        
        for straightline in straightlines {
            CGContextSetLineWidth(cxt, straightline.l_width)
            CGContextSetStrokeColorWithColor(cxt,straightline.color.CGColor)
            CGContextSetAlpha(cxt, 1.0)
            // Create straightline
            CGContextMoveToPoint(cxt, straightline.start.x, straightline.start.y)
            CGContextAddLineToPoint(cxt, straightline.end.x, straightline.end.y)
            // Draw
            CGContextStrokePath(cxt)
        }
        
        //Draw Circle
        //if circle is being drawin
        if (isDrawingCircle)
        {
            // Set the circle outerline-width
            CGContextSetLineWidth(cxt, circle_obj!.l_width)
            // Set the circle outerline-colour
            CGContextSetStrokeColorWithColor(cxt,circle_obj?.color.CGColor)
            // Set circle opacity
            CGContextSetAlpha(cxt, 1.0)
            // Create circle
            CGContextAddEllipseInRect(cxt, CGRectMake(circle_obj!.start.x, circle_obj!.start.y, (circle_obj!.end.x - circle_obj!.start.x), (circle_obj!.end.y - circle_obj!.start.y)))
            // Draw
            CGContextStrokePath(cxt)
        }
        
        for circle in circles {
            CGContextSetLineWidth(cxt, circle.l_width)
            // Set the circle outerline-colour
            CGContextSetStrokeColorWithColor(cxt,circle.color.CGColor)
            // Set circle opacity
            CGContextSetAlpha(cxt, 1.0)
            // Create circle
            CGContextAddEllipseInRect(cxt, CGRectMake(circle.start.x, circle.start.y, (circle.end.x - circle.start.x), (circle.end.y - circle.start.y)))
            // Draw
            CGContextStrokePath(cxt)
        }
        
        //Draw Rectangel
        //if rectangel is being drawin
        if (isDrawingRectangle)
        {
            // Set the rectangel outerline-width
            CGContextSetLineWidth(cxt, rectangle_obj!.l_width)
            // Set the rectangel outerline-colour
            CGContextSetStrokeColorWithColor(cxt,rectangle_obj?.color.CGColor)
            // Set rectangel opacity
            CGContextSetAlpha(cxt, 1.0)
            // Create rectangel
            CGContextAddRect(cxt, CGRectMake(rectangle_obj!.start.x, rectangle_obj!.start.y, (rectangle_obj!.end.x - rectangle_obj!.start.x) / 2 , (rectangle_obj!.end.y - rectangle_obj!.start.y) / 2))
            // Draw
            CGContextStrokePath(cxt)
        }
        
        for rectangle in rectangles {
            CGContextSetLineWidth(cxt, rectangle.l_width)
            // Set the rectangel outerline-colour
            CGContextSetStrokeColorWithColor(cxt,rectangle.color.CGColor)
            // Set rectangel opacity
            CGContextSetAlpha(cxt, 1.0)
            // Create rectangel
            CGContextAddRect(cxt, CGRectMake(rectangle.start.x, rectangle.start.y, (rectangle.end.x - rectangle.start.x) / 2 , (rectangle.end.y - rectangle.start.y) / 2));
            // Draw
            CGContextStrokePath(cxt)
        }

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
            lineOpacity = 0.4
            if lines.count > 0 {
                CGContextBeginPath(cxt)
                CGContextSetAlpha(cxt, lineOpacity)
                CGContextSetLineWidth(cxt, 10)
                CGContextMoveToPoint(cxt, lines.first!.start.x, lines.first!.start.y)
            }
            
            for line in lines {
                CGContextSetStrokeColorWithColor(cxt, line.color.CGColor)
                CGContextAddLineToPoint(cxt, line.end.x, line.end.y)
            }
            
            CGContextStrokePath(cxt)
            lineOpacity = 0.0
            UIGraphicsEndImageContext()
        }
    }

    func onPan(recognizer : UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(self)
        recognizer.view!.center = CGPoint(x:recognizer.view!.center.x + translation.x, y:recognizer.view!.center.y + translation.y)
        recognizer.setTranslation(CGPointZero, inView: self)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        var txtAfterUpdate:NSString = self.textField!.text as NSString
        println("\(self.textField?.frame.size.width)")
        if self.textField?.frame.size.width < 250 {
            txtAfterUpdate = txtAfterUpdate.stringByReplacingCharactersInRange(range, withString: string)
            
            var r: CGRect = txtAfterUpdate.boundingRectWithSize(CGSizeMake(260, 0), options: NSStringDrawingOptions.UsesLineFragmentOrigin , attributes: { [NSFontAttributeName: UIFont.systemFontOfSize(self.objTextField!.fontSize)] }(), context: nil)
            
            textField.frame.size.width = r.width + 10
            
            return true
        }
        else {
            return false
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        // it check textField is empty or not if empty then it does not add to subview as well as does not append to textFields array
        if count(textField.text) <= 0 {
            for view in self.subviews {
                if view.isKindOfClass(UITextField) {
                    if view.tag == cntTextField - 1 {
                        view.removeFromSuperview()
                        textFields.removeLast()
                        cntTextField--
                        undo.hidden = true
                        self.setNeedsDisplay()
                    }
                }
            }
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        keyboardStatus = true
        
        var info:NSDictionary = notification.userInfo!
        
        var keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        
        if view_controller?.screenTouchPoint?.y > keyboardSize.height + 25 {
            var keyboardHeight = keyboardSize.height + 200
            self.view_controller!.resultViewTopConstraint.constant = self.view_controller!.resultViewTopConstraint.constant - keyboardHeight
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        keyboardStatus = false
        
        var info:NSDictionary = notification.userInfo!
        
        var keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        
        if view_controller?.screenTouchPoint?.y > keyboardSize.height + 25 {
            var keyboardHeight = keyboardSize.height + 200
            self.view_controller!.resultViewTopConstraint.constant = self.view_controller!.resultViewTopConstraint.constant + keyboardHeight
        }
        
        textField!.userInteractionEnabled = false
        textField!.layer.borderWidth = 0.0
    }
}