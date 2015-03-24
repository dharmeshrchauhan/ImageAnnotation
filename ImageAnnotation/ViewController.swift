//
//  ViewController.swift
//  ImageAnnotation
//
//  Created by Sagar on 13/02/15.
//  Copyright (c) 2015 Sagar. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UIAlertViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPopoverControllerDelegate {
    
    var lines: [Line ] = []
    
    var picker: UIImagePickerController? = UIImagePickerController()
    
    var popover: UIPopoverController? = nil
    
    @IBOutlet weak var btnClickMe: UIBarButtonItem!
   
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var drawView: drawing!
    
    @IBOutlet weak var colorView: UIView!
 
    @IBOutlet weak var lineWidthView: UIView!
    
    @IBOutlet weak var colorButton: UIButton!
    
    @IBOutlet weak var drawingWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var drawingHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var undo: UIButton!
    
    @IBOutlet weak var redo: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        colorView.hidden = true
//        lineWidthView.hidden = true
//        undo.hidden = true
//        redo.hidden = true
        picker?.delegate = self
    }

    @IBAction func selectColor(sender: AnyObject) {
        colorView.hidden = !colorView.hidden
        lineWidthView.hidden = !lineWidthView.hidden
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
    
    @IBAction func btnImagePickerClicked(sender: AnyObject) {
        
        var alert:UIAlertController = UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        var cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                self.openCamera()
        }
        
        var gallaryAction = UIAlertAction(title: "Gallary", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                self.openGallary()
        }
        
        var cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
                UIAlertAction in
        }
        
        // Add the actions
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        
        // Present the actionsheet
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone
        {
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else
        {
            popover=UIPopoverController(contentViewController: alert)
            //popover!.presentPopoverFromRect(btnClickMe.frame, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
        }
    }
    
    func openCamera()
    {
        if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
            picker?.allowsEditing = false
            picker?.sourceType = UIImagePickerControllerSourceType.Camera
            picker?.cameraCaptureMode = .Photo
            presentViewController(picker!, animated: true, completion: nil)
        } else {
            noCamera()
        }
    }
    
    func noCamera(){
        let alertVC = UIAlertController(title: "No Camera", message: "Sorry, this device has no camera", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style:.Default, handler: nil)
        alertVC.addAction(okAction)
        presentViewController(alertVC, animated: true, completion: nil)
    }
    
    func openGallary()
    {
        picker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone
        {
            self.presentViewController(picker!, animated: true, completion: nil)
        }
        else
        {
            popover=UIPopoverController(contentViewController: picker!)
            //popover?.presentPopoverFromRect(btnClickMe.frame, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]!)
    {
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        var tempImage: UIImage=(info[UIImagePickerControllerOriginalImage] as UIImage)
        
        //sets the selected image to image view
        imageView.image = tempImage
        
        //set the imageView size to drawView
        let scaleFactorX =  imageView.frame.size.width / imageView.image!.size.width
        let scaleFactorY =  imageView.frame.size.height / imageView.image!.size.height
        let scaleFactor = (scaleFactorX < scaleFactorY ? scaleFactorX : scaleFactorY)
        
        let displayWidth: CGFloat = imageView.image!.size.width * scaleFactor
        let displayHeight: CGFloat = imageView.image!.size.height * scaleFactor
        
        NSLog("ImageviewWidth: \(imageView.frame.size.width), ImageviewHeight: \(imageView.frame.size.height)")
        NSLog("DisplayWidth: \(displayWidth), DisplayHeight: \(displayHeight)")
  
        drawingWidthConstraint.constant = displayWidth
        drawingHeightConstraint.constant = displayHeight
        

//        var x: CGFloat
//        var y: CGFloat
//        x = imageView.frame.origin.x + (imageView.frame.size.width - displayWidth) / 2
//        y = imageView.frame.origin.y + (imageView.frame.size.height - displayHeight) / 2
        
//        drawView.frame = CGRect(x: x, y: y, width: displayWidth, height: displayHeight)
       // drawView.

//        NSLog("DisplayWidth: %d, DisplayHeight: %d", displayWidth, displayHeight)
        
        //drawView.frame = CGRect()
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func undoAction(sender: AnyObject) {
        var theDrawView = drawView as drawing
        
        for var i=drawView.cnt;i>=0;i-- {
            theDrawView.removeLastLine()
        }
    }
    
    @IBAction func redoAction(sender: AnyObject) {
        var theDrawView = drawView as drawing
        
    }
    
    /*   // Add arrow image into UIImageView at runtime
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
       
        /*imageViewCircle = UIImageView(image: UIImage(named: "circle.png"))
        let size = self.view.bounds.size
        imageViewCircle?.center = CGPoint(x: size.width * 0.5, y: (size.height - 60) * 0.5)
        drawView.addSubview(imageViewCircle!)
        
        imageViewCircle!.multipleTouchEnabled = true
        imageViewCircle!.userInteractionEnabled = true
        
        // Add runtime PanGestureRecognizer into UIImageView
        imageViewCircle?.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "opPan:"))*/
    } */
    
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
        colorButton.backgroundColor = color
        colorView.hidden = !colorView.hidden
        lineWidthView.hidden = !lineWidthView.hidden
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
        lineWidthView.hidden = !lineWidthView.hidden
        colorView.hidden = !colorView.hidden
    }
}

