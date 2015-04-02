//
//  ViewController.swift
//  ImageAnnotation
//
//  Created by Sagar on 13/02/15.
//  Copyright (c) 2015 Sagar. All rights reserved.
//

import UIKit

struct MyVariables {
    static var flag: String = ""
}

class ViewController: UIViewController,UIAlertViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPopoverControllerDelegate, UIActionSheetDelegate {
    
    var picker: UIImagePickerController? = UIImagePickerController()
    
    var popover: UIPopoverController? = nil
    
    var rotation: CGFloat = 0.0
    
    //var textField: UITextField?
    
    //@IBOutlet weak var btnClickMe: UIBarButtonItem!
   
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var drawView: drawing!
    
    @IBOutlet weak var colorView: UIView!
 
    @IBOutlet weak var lineWidthView: UIView!
    
    @IBOutlet weak var colorButton: UIButton!

    @IBOutlet weak var btnGallery: UIButton!
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var functionalityButton: UIButton!
    
    @IBOutlet weak var rotationView: UIView!
    
    @IBOutlet weak var selectFunctionalityView: UIView!
    
    @IBOutlet weak var cropView: UIView!
    
    @IBOutlet weak var btnDone: UIButton!
    
    @IBOutlet weak var drawingWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var drawingHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var undo: UIButton!
    
    @IBOutlet weak var redo: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        colorButton.hidden = true
        functionalityButton.hidden = true
        colorView.hidden = true
        lineWidthView.hidden = true
        undo.hidden = true
        redo.hidden = true
        rotationView.hidden = true
        selectFunctionalityView.hidden = true
        cropView.hidden = true
        btnDone.hidden = true
        picker?.delegate = self
    }
    
    @IBAction func selectPhotoAction(sender: AnyObject) {
        if (NSClassFromString("UIAlertController") != nil)
        {
            var alert:UIAlertController = UIAlertController(title: "Choose Image", message: "Please chooce image", preferredStyle: UIAlertControllerStyle.ActionSheet)
            
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
            }
        }
        else {
            var actionSheet: UIActionSheet = UIActionSheet()
            actionSheet.title = "Choose Image"
            actionSheet.addButtonWithTitle("Camera")
            actionSheet.addButtonWithTitle("Gallery")
            actionSheet.addButtonWithTitle("Cancel")
            actionSheet.cancelButtonIndex = 2
            actionSheet.delegate = self
            actionSheet.showInView(self.view)
        }
    }
    
    @IBAction func selectColor(sender: AnyObject) {
        if imageView.image != nil {
            colorView.hidden = !colorView.hidden
            lineWidthView.hidden = !lineWidthView.hidden
        }
    }
        
    @IBAction func selectFunctionality(sender: AnyObject) {
        if imageView.image != nil {
            selectFunctionalityView.hidden = !selectFunctionalityView.hidden
            rotationView.hidden = true
        }
    }
    
    @IBAction func cropImageAction(sender: AnyObject) {
        selectFunctionalityView.hidden = true
        cropView.hidden = false
        btnDone.hidden = false
        // Add runtime PanGestureRecognizer into UIView
        cropView?.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "onPan:"))
        
        // Add runtime PinchGestureRecognizer into UIView
        cropView?.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: "onPinch:"))
    }
    
    @IBAction func DoneAction(sender: AnyObject) {

        var scaleFactorX =  imageView.frame.size.width / imageView.image!.size.width
        var scaleFactorY =  imageView.frame.size.height / imageView.image!.size.height
        var scaleFactor = (scaleFactorX < scaleFactorY ? scaleFactorX : scaleFactorY)
        
        let x = (cropView.frame.origin.x - drawView.frame.origin.x) / scaleFactor
        let y = (cropView.frame.origin.y - drawView.frame.origin.y) / scaleFactor
        
        let width = cropView.frame.size.width / scaleFactor
        let height = cropView.frame.size.height / scaleFactor
        
        let customRect: CGRect = CGRectMake(x, y, width, height)
        
        var imageRef: CGImageRef = CGImageCreateWithImageInRect(imageView.image?.CGImage, customRect)
        
        var cropped: UIImage =  UIImage(CGImage: imageRef)!
        
        imageView.image = cropped
        
        
        scaleFactorX =  imageView.frame.size.width / imageView.image!.size.width
        scaleFactorY =  imageView.frame.size.height / imageView.image!.size.height
        scaleFactor = (scaleFactorX < scaleFactorY ? scaleFactorX : scaleFactorY)
        
        let displayWidth: CGFloat = imageView.image!.size.width * scaleFactor
        let displayHeight: CGFloat = imageView.image!.size.height * scaleFactor

        //NSLog("ImageviewWidth: \(imageView.frame.size.width), ImageviewHeight: \(imageView.frame.size.height)")
        //NSLog("DisplayWidth: \(displayWidth), DisplayHeight: \(displayHeight)")
        
        drawingWidthConstraint.constant = displayWidth
        drawingHeightConstraint.constant = displayHeight
        
        cropView.hidden = true
        btnDone.hidden = true
    }
    
    @IBAction func rotationAction(sender: AnyObject) {
        selectFunctionalityView.hidden = !selectFunctionalityView.hidden
        rotationView.hidden = !rotationView.hidden
    }
    
    @IBAction func sideRotationAction(button: UIButton) {
        if(button.titleLabel?.text == "R") {
                rotation += 90.0
                self.imageView.transform = CGAffineTransformMakeRotation(degreesToRadians(rotation))
        } else if(button.titleLabel?.text == "L") {
                rotation -= 90.0
                self.imageView.transform = CGAffineTransformMakeRotation(degreesToRadians(rotation))
        }
        
        let scaleFactorX =  imageView.frame.size.width / imageView.image!.size.width
        let scaleFactorY =  imageView.frame.size.height / imageView.image!.size.height
        let scaleFactor = (scaleFactorX < scaleFactorY ? scaleFactorX : scaleFactorY)
        
        let displayWidth: CGFloat = imageView.image!.size.width * scaleFactor
        let displayHeight: CGFloat = imageView.image!.size.height * scaleFactor
        
        //NSLog("ImageviewWidth: \(imageView.frame.size.width), ImageviewHeight: \(imageView.frame.size.height)")
        //NSLog("DisplayWidth: \(displayWidth), DisplayHeight: \(displayHeight)")
        
        drawingWidthConstraint.constant = displayWidth
        drawingHeightConstraint.constant = displayHeight
    }
    
    func degreesToRadians(x: CGFloat) -> CGFloat{
        return 3.14 * (x) / 180.0
    }
    
    @IBAction func addTextAction(sender: AnyObject) {
        selectFunctionalityView.hidden = true
        MyVariables.flag = "addTextView"
        
        /* textField = UITextField(frame: CGRect(x: 130, y: 150, width: 100, height: 35))
        textField?.textColor = UIColor.blueColor()
        textField?.text = "."
        drawView.addSubview(textField!)
        textField!.multipleTouchEnabled = true
        textField!.userInteractionEnabled = true
        
        // Add runtime PanGestureRecognizer into UITextField
        textField?.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "onPan:")) */
    }
    
    @IBAction func drawLineAction(sender: AnyObject) {
        selectFunctionalityView.hidden = true
        MyVariables.flag = "drawline"
    }
    
    @IBAction func drawOpacityLineAction(sender: AnyObject) {
        selectFunctionalityView.hidden = true
        MyVariables.flag = "drawopacityline"
    }
    
    @IBAction func saveImage(sender: AnyObject) {
        var image = takeScreenshot(imageView)
        UIImageWriteToSavedPhotosAlbum(image, self, Selector("image:didFinishSavingWithError:contextInfo:"), nil)
    }
    
    func takeScreenshot(theView: UIView) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(imageView.frame.size, true, 0.0)
        theView.drawViewHierarchyInRect(theView.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo: UnsafePointer<()>) {
        
        if(error != nil) {
            UIAlertView(title: "Error", message: "Image could not be saved.Please try again", delegate: nil, cancelButtonTitle: "Close").show()
        } else{
            UIAlertView(title: "Success", message: "Image successfully saved to Camera Roll", delegate: nil, cancelButtonTitle: "Close").show()
        }
    }
    
    @IBAction func btnImagePickerClicked(sender: AnyObject) {
        
        if (NSClassFromString("UIAlertController") != nil)
        {
            var alert:UIAlertController = UIAlertController(title: "Choose Image", message: "Please chooce image", preferredStyle: UIAlertControllerStyle.ActionSheet)
            
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
            }
        }
        else {
            var actionSheet: UIActionSheet = UIActionSheet()
            actionSheet.title = "Choose Image"
            actionSheet.addButtonWithTitle("Camera")
            actionSheet.addButtonWithTitle("Gallery")
            actionSheet.addButtonWithTitle("Cancel")
            actionSheet.cancelButtonIndex = 2
            actionSheet.delegate = self
            actionSheet.showInView(self.view)
        }
    }
    
    func actionSheet(actionSheet: UIActionSheet!, clickedButtonAtIndex buttonIndex: Int){
        
        var sourceType:UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.Camera
        
        if (buttonIndex == 0)
        {
            if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) //Camera not available
            {
//                let alert = UIAlertView(title: "No Camera", message: "Sorry, this device has no camera", delegate: self, cancelButtonTitle: "Cancel")
//                alert.show()
                sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            }
            self.displayImagepicker(sourceType)
        }
        else if (buttonIndex == 1)
        {
            sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.displayImagepicker(sourceType)
        }
    }
    
    func displayImagepicker(sourceType:UIImagePickerControllerSourceType)
    {
        var imagePicker:UIImagePickerController = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func openCamera()
    {
        if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
            picker?.allowsEditing = false
            picker?.sourceType = UIImagePickerControllerSourceType.Camera
            picker?.cameraCaptureMode = .Photo
            presentViewController(picker!, animated: true, completion: nil)
        } else {
            //no camera
            let alertVC = UIAlertController(title: "No Camera", message: "Sorry, this device has no camera", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style:.Default, handler: nil)
            alertVC.addAction(okAction)
            presentViewController(alertVC, animated: true, completion: nil)
        }
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
        
        drawView.strokes = []
        drawView.strokesOpacity = []
        drawView.lastLineDraw = []
        undo.hidden = true
        redo.hidden = true
        
        label.hidden = true
        btnGallery.hidden = true
        colorButton.hidden = false
        functionalityButton.hidden = false
        
        drawView.setNeedsDisplay()
        
        colorButton.backgroundColor = UIColor.blackColor()
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func undoAction(sender: AnyObject) {
       
        if drawView.lastLineIndex != 0 {
            if drawView.lastLineDraw[drawView.lastLineIndex - 1] == "drawline" {
                if drawView.strokes.count > 0 {
                    drawView.strokes.removeLast()
                    drawView.arrayIndex--
                    drawView.lastLineIndex--
                    if drawView.lastLineIndex == 0 {
                        undo.hidden = true }
                    if drawView.lastLineIndex > 1 {
                        redo.hidden = false }
                    drawView.setNeedsDisplay()
                }
            } else if drawView.lastLineDraw[drawView.lastLineIndex - 1] == "drawopacityline" {
                if drawView.strokesOpacity.count > 0 {
                    drawView.strokesOpacity.removeLast()
                    drawView.arrayIndex1--
                    drawView.lastLineIndex--
                    if drawView.lastLineIndex == 0 {
                        undo.hidden = true }
                    drawView.setNeedsDisplay()
                }
            } else if drawView.lastLineDraw[drawView.lastLineIndex - 1] == "drawCircle" {
                
            }
        }
    }
    
    @IBAction func redoAction(sender: AnyObject) {
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
    } */
    
    @IBAction func addCircle(sender: AnyObject) {
        selectFunctionalityView.hidden = true
        MyVariables.flag = "drawCircle"
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

