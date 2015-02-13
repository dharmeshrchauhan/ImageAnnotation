//
//  ViewController.swift
//  ImageAnnotation
//
//  Created by Sagar on 13/02/15.
//  Copyright (c) 2015 Sagar. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UIPickerViewDelegate {

    var target : UIImageView?
    
    var textField : UITextField?
    
    var imageViewRect: UIImageView?
    
    var imageViewCircle: UIImageView?
    
    @IBOutlet weak var drawView: drawing!
    
    //@IBOutlet weak var arrowImageView: UIImageView!
    
    //@IBOutlet weak var textField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func saveImage(sender: AnyObject) {
        var image = takeScreenshot(view)
        UIImageWriteToSavedPhotosAlbum(image, self, Selector("image:didFinishSavingWithError:contextInfo:"), nil)
    }
    
    func takeScreenshot(theView: UIView) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(drawView.frame.size, true, 0.0)
        theView.drawViewHierarchyInRect(theView.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo: UnsafePointer<()>) {
        
        if(error != nil) {
            UIAlertView(title: "Error", message: "Image could not be saved.Please try again", delegate: nil, cancelButtonTitle: "Close").show()
        } else{
            UIAlertView(title: "Success", message: "Image was successfully saved in photoalbum", delegate: nil, cancelButtonTitle: "Close").show()
        }
    }
    
    // Add arrow image into UIImageView at runtime
    @IBAction func addArrow(sender: AnyObject) {
        target = UIImageView(image: UIImage(named: "arrow.png"))
        let size = self.view.bounds.size
        target?.center = CGPoint(x: size.width * 0.5, y: (size.height - 60) * 0.5)
        drawView.addSubview(target!)
        
        target!.multipleTouchEnabled = true
        target!.userInteractionEnabled = true
        
        // Add runtime PanGestureRecognizer into UIImageView
        target?.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "onPan:"))
        
        // Add runtime PinchGestureRecognizer into UIImageView
        target?.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: "onPinch:"))
        
        // Add runtime RotationGestureRecognizer into UIImageView
        target?.addGestureRecognizer(UIRotationGestureRecognizer(target: self, action: "onRotation:"))
    }
    
    // Add UITextView at runtime
    @IBAction func takeTextField(sender: AnyObject) {
        textField = UITextField(frame: CGRect(x: 180, y: 190, width: 100, height: 35))
        textField?.textColor = UIColor.blueColor()
        textField?.text = "TextField"
        drawView.addSubview(textField!)
        
        textField!.multipleTouchEnabled = true
        textField!.userInteractionEnabled = true
        
        // Add runtime PanGestureRecognizer into UITextField
        textField?.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "onPan:"))
    }
    
    @IBAction func addRectangle(sender: AnyObject) {
        /*imageViewRect = UIImageView(image: UIImage(named: "rectangle.png"))
        let size = self.view.bounds.size
        imageViewRect?.center = CGPoint(x: size.width * 0.5, y: (size.height - 60) * 0.5)
        drawView.addSubview(imageViewRect!)
        
        imageViewRect!.multipleTouchEnabled = true
        imageViewRect!.userInteractionEnabled = true
        
        // Add runtime PanGestureRecognizer into UIImageView
        imageViewRect?.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "opPan:"))*/
    }
    
    @IBAction func addCircle(sender: AnyObject) {
        
        var touch: UITouch!
    
        var circleCenter = touch.locationInView(view)
               
        var circleWidth = CGFloat(25 + (arc4random() % 50))
                
        var circleHeight = circleWidth
                
        var circleView = CircleView(frame: CGRectMake(circleCenter.x, circleCenter.y, circleWidth, circleHeight))
                
        drawView.addSubview(circleView)
           
        
        /*imageViewCircle = UIImageView(image: UIImage(named: "circle.png"))
        let size = self.view.bounds.size
        imageViewCircle?.center = CGPoint(x: size.width * 0.5, y: (size.height - 60) * 0.5)
        drawView.addSubview(imageViewCircle!)
        
        imageViewCircle!.multipleTouchEnabled = true
        imageViewCircle!.userInteractionEnabled = true
        
        // Add runtime PanGestureRecognizer into UIImageView
        imageViewCircle?.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "opPan:"))*/
    }
    
    func onPan(recognizer : UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(drawView)
        recognizer.view!.center = CGPoint(x:recognizer.view!.center.x + translation.x, y:recognizer.view!.center.y + translation.y)
        recognizer.setTranslation(CGPointZero, inView: drawView)
    }
    
    func onPinch(recognizer : UIPinchGestureRecognizer) {
        recognizer.view!.transform = CGAffineTransformScale(recognizer.view!.transform,recognizer.scale, recognizer.scale)
        recognizer.scale = 1
    }
    
    func onRotate(recognizer : UIRotationGestureRecognizer) {
        recognizer.view!.transform = CGAffineTransformRotate(recognizer.view!.transform, recognizer.rotation)
        recognizer.rotation = 0
    }
    
    // Select a color for draw line
    @IBAction func colorTapped(button: UIButton!) {
        var color : UIColor!
        
        if(button.titleLabel?.text == "Black") {
            color = UIColor.blackColor()
        } else if(button.titleLabel?.text == "Blue") {
            color = UIColor.blueColor()
        } else if(button.titleLabel?.text == "Red") {
            color = UIColor.redColor()
        } else if(button.titleLabel?.text == "Yellow") {
            color = UIColor.yellowColor()
        } else if(button.titleLabel?.text == "Green") {
            color = UIColor.greenColor()
        }
        drawView.drawColor = color
    }
    
    // Select a line width for draw a line
    @IBAction func lineWidthTapped(button: UIButton!) {
        var line_width : CGFloat!
        
        if(button.titleLabel?.text == "1") {
            line_width = 1
        } else if(button.titleLabel?.text == "2") {
            line_width = 2
        } else if(button.titleLabel?.text == "3") {
            line_width = 3
        } else if(button.titleLabel?.text == "4") {
            line_width = 4
        }
        drawView.l_w = line_width
    }
}

