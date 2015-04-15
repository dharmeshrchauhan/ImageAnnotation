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
    
    var oldButton: UIBarButtonItem?

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
    
    @IBOutlet weak var blurView: UIView!
    
    @IBOutlet weak var btnDone: UIButton!
    
    @IBOutlet weak var btnDone1: UIButton!
    
    @IBOutlet weak var btnCancel: UIButton!
    
    @IBOutlet weak var btnSave: UIBarButtonItem!
    
    @IBOutlet weak var drawingWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var drawingHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var shapeView: UIView!
    
    @IBOutlet weak var undo: UIButton!
    
    @IBOutlet weak var redo: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //hide all buttons and views
        colorButton.hidden = true
        functionalityButton.hidden = true
        colorView.hidden = true
        lineWidthView.hidden = true
        undo.hidden = true
        redo.hidden = true
        rotationView.hidden = true
        selectFunctionalityView.hidden = true
        shapeView.hidden = true
        cropView.hidden = true
        blurView.hidden = true
        btnDone.hidden = true
        btnDone1.hidden = true
        btnCancel.hidden = true
        //hide save bar button
        oldButton = self.navigationItem.rightBarButtonItem!
        self.navigationItem.rightBarButtonItem = nil
        
        //call the delegate method of ImagePickerController
        picker?.delegate = self
//        var img:UIImage = UIImage(contentsOfFile: NSBundle.mainBundle().pathForResource("docement", ofType: "png")!)!
//        
//        var img2 = img.imageByClearingWhitePixels()
//        
//        imageView.image = img2
//        
//        return;
    }
    
    //Take image form Gallery
    @IBAction func selectPhotoAction(sender: AnyObject) {
        //for iOS 8
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
        //for iOS 7
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
    
    //ImagePicker delegate method
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]!)
    {
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        var tempImage: UIImage=(info[UIImagePickerControllerOriginalImage] as UIImage)
        
        //sets the selected image to imageView
        imageView.image = tempImage
        
        //set the imageView size as same as drawView size
        let scaleFactorX =  imageView.frame.size.width / imageView.image!.size.width
        let scaleFactorY =  imageView.frame.size.height / imageView.image!.size.height
        let scaleFactor = (scaleFactorX < scaleFactorY ? scaleFactorX : scaleFactorY)
        
        let displayWidth: CGFloat = imageView.image!.size.width * scaleFactor
        let displayHeight: CGFloat = imageView.image!.size.height * scaleFactor
        
        NSLog("ImageviewWidth: \(imageView.frame.size.width), ImageviewHeight: \(imageView.frame.size.height)")
        NSLog("DisplayWidth: \(displayWidth), DisplayHeight: \(displayHeight)")
        
        drawingWidthConstraint.constant = displayWidth
        drawingHeightConstraint.constant = displayHeight
        
        //reset all the containt if new image is selected
        drawView.strokes = []
        drawView.strokesOpacity = []
        drawView.lastLineDraw = []
        drawView.circles = []
        drawView.rectangles = []
        MyVariables.flag = ""
        rotation = 0
        self.imageView.transform = CGAffineTransformMakeRotation(degreesToRadians(rotation))
        
        colorButton.hidden = false
        functionalityButton.hidden = false
        
        undo.hidden = true
        redo.hidden = true
        label.hidden = true
        btnGallery.hidden = true
        colorView.hidden = true
        lineWidthView.hidden = true
        selectFunctionalityView.hidden = true
        rotationView.hidden = true
        shapeView.hidden = true
        blurView.hidden = true
        cropView.hidden = true
        btnCancel.hidden = true
        btnDone.hidden = true
        btnDone1.hidden = true
        self.navigationItem.rightBarButtonItem = oldButton
        
        drawView.setNeedsDisplay()
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func btnImagePickerClicked(sender: AnyObject) {
        //for iOS 8
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
            if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                popover=UIPopoverController(contentViewController: alert)
            }
        }
        //for iOS 7
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
    
    //ImagePicker delegate method
    func actionSheet(actionSheet: UIActionSheet!, clickedButtonAtIndex buttonIndex: Int){
        
        var sourceType:UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.Camera
        
        if (buttonIndex == 0) {
            if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) //Camera not available
            {
                //                let alert = UIAlertView(title: "No Camera", message: "Sorry, this device has no camera", delegate: self, cancelButtonTitle: "Cancel")
                //                alert.show()
                sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            }
            self.displayImagepicker(sourceType)
        } else if (buttonIndex == 1) {
            sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.displayImagepicker(sourceType)
        }
    }
    
    func displayImagepicker(sourceType:UIImagePickerControllerSourceType) {
        var imagePicker:UIImagePickerController = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func openCamera() {
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
    
    func openGallary() {
        picker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            self.presentViewController(picker!, animated: true, completion: nil)
        } else {
            popover=UIPopoverController(contentViewController: picker!)
        }
    }
    
    //Show colorView & lineWidthView
    @IBAction func selectColor(sender: AnyObject) {
        if imageView.image != nil {
            
            if MyVariables.flag == "drawOpacityLine" {
                colorView.hidden = !colorView.hidden
            } else {
                colorView.hidden = !colorView.hidden
                lineWidthView.hidden = !lineWidthView.hidden
            }
            
            if selectFunctionalityView.hidden == false || rotationView.hidden == false || shapeView.hidden == false {
                selectFunctionalityView.hidden = true
                rotationView.hidden = true
                shapeView.hidden = true
            }
        }
    }
    
    //Show functionalityView
    @IBAction func selectFunctionality(sender: AnyObject) {
        if imageView.image != nil {
            selectFunctionalityView.hidden = !selectFunctionalityView.hidden
            if colorView.hidden == false || lineWidthView.hidden == false || rotationView.hidden == false || shapeView.hidden == false {
                colorView.hidden = true
                lineWidthView.hidden = true
                rotationView.hidden = true
                shapeView.hidden = true
            }
        }
    }
    
    //Rotation Methods
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
    
    //Draw line on drawView
    @IBAction func drawLineAction(sender: AnyObject) {
        selectFunctionalityView.hidden = true
        MyVariables.flag = "drawLine"
    }
    
    //Draw opacity line on drawView
    @IBAction func drawOpacityLineAction(sender: AnyObject) {
        selectFunctionalityView.hidden = true
        MyVariables.flag = "drawOpacityLine"
    }
    
    //Crop Image methods
    @IBAction func cropImageAction(sender: AnyObject) {
        selectFunctionalityView.hidden = true
        cropView.hidden = false
        btnDone.hidden = false
        btnCancel.hidden = false
        undo.hidden = true
        redo.hidden = true
        colorButton.hidden = true
        functionalityButton.hidden = true
        //imageView.backgroundColor = UIColor.grayColor()
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
        btnCancel.hidden = true
        redo.hidden = true
        undo.hidden = true
        colorButton.hidden = false
        functionalityButton.hidden = false
    }
    
    @IBAction func cancelAction(sender: AnyObject) {
        btnCancel.hidden = true
        cropView.hidden = true
        btnDone.hidden = true
        btnDone1.hidden = true
        blurView.hidden = true
        undo.hidden = false
        redo.hidden = false
        colorButton.hidden = false
        functionalityButton.hidden = false
    }
    
    //Blur Image methods
    @IBAction func blurImageAction(sender: AnyObject) {
        selectFunctionalityView.hidden = true
        blurView.hidden = false
        btnDone1.hidden = false
        btnCancel.hidden = false
        colorButton.hidden = true
        functionalityButton.hidden = true
        
        // Add runtime PanGestureRecognizer into UIView
        blurView?.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "onPan:"))
        
        // Add runtime PinchGestureRecognizer into UIView
        blurView?.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: "onPinch:"))
    }
    
    @IBAction func doneAction1(sender: AnyObject) {
        // 1
        var blurStyle = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        // 2
        blurView = UIVisualEffectView(effect: blurStyle)
        drawView.setNeedsDisplay()
        
        //blurView.hidden = true
        btnDone1.hidden = true
        btnCancel.hidden = true
        colorButton.hidden = false
        functionalityButton.hidden = false
    }
    
    //Add shapes methods
    @IBAction func shapeAction(sender: AnyObject) {
        shapeView.hidden = false
        selectFunctionalityView.hidden = !selectFunctionalityView.hidden
    }
    
    @IBAction func addTextAction(sender: AnyObject) {
        selectFunctionalityView.hidden = true
        MyVariables.flag = "addTextView"
    }
    
    @IBAction func addCircle(sender: AnyObject) {
        selectFunctionalityView.hidden = true
        MyVariables.flag = "drawCircle"
        shapeView.hidden = !shapeView.hidden
    }
    
    @IBAction func addRectangle(sender: AnyObject) {
        selectFunctionalityView.hidden = true
        MyVariables.flag = "drawRectangle"
        shapeView.hidden = !shapeView.hidden
    }
    
    @IBAction func addArrow(sender: AnyObject) {
        selectFunctionalityView.hidden = true
        MyVariables.flag = "drawArrow"
        shapeView.hidden = !shapeView.hidden
    }
    
    //Undo Operation
    @IBAction func undoAction(sender: AnyObject) {
        var removedShapeType = drawView.lastLineDraw.removeLast()
        if drawView.lastLineIndex != 0 {
            if removedShapeType == "drawLine" {
                if drawView.strokes.count > 0 {
                    //add to redoArray
                    var removedLine = drawView.strokes.removeLast();
                    drawView.redoArray.append(removedLine)
                    drawView.redoshapetypes.append(removedShapeType)
                    
                    //drawView.redoshapetypes
                    //undo
                    drawView.arrayIndex--
                    if drawView.lastLineIndex == 0 {
                        undo.hidden = true
                        redo.hidden = false
                    }
                    if drawView.lastLineIndex >= 1 {
                        redo.hidden = false
                        undo.hidden = true
                    }
                    drawView.setNeedsDisplay()
                }
            } else if removedShapeType == "drawOpacityLine" {
                if drawView.strokesOpacity.count > 0 {
                    //add to redoArray
                    var removedOpacityLine = drawView.strokesOpacity.removeLast()
                    drawView.redoArray.append(removedOpacityLine)
                    drawView.redoshapetypes.append(removedShapeType)
                    //undo
                    drawView.arrayIndex1--
                    if drawView.lastLineIndex == 0 {
                        undo.hidden = true
                        redo.hidden = false
                    }
                    if drawView.lastLineIndex >= 1 {
                        redo.hidden = false
                        undo.hidden = true
                    }
                    drawView.setNeedsDisplay()
                }
            } else if removedShapeType == "drawCircle" {
                if drawView.circles.count > 0 {
                    //add to redoArray
                    var removedCircle = drawView.circles.removeLast()
                    drawView.redoArray.append(removedCircle)
                    drawView.redoshapetypes.append(removedShapeType)
                    //undo
                    if drawView.lastLineIndex == 0 {
                        undo.hidden = true
                        redo.hidden = false
                    }
                    if drawView.lastLineIndex >= 1 {
                        redo.hidden = false
                        undo.hidden = true
                    }
                }
                drawView.setNeedsDisplay()
            } else if removedShapeType == "drawRectangle" {
                if drawView.rectangles.count > 0 {
                    //add to redoArray
                    var removedRectangle = drawView.rectangles.removeLast()
                    drawView.redoArray.append(removedRectangle)
                    drawView.redoshapetypes.append(removedShapeType)
                    //undo
                    if drawView.lastLineIndex == 0 {
                        undo.hidden = true
                        redo.hidden = false
                    }
                    if drawView.lastLineIndex >= 1 {
                        redo.hidden = false
                        undo.hidden = true
                    }
                }
                drawView.setNeedsDisplay()
            }
        }
    }
    
    //Redo Operation
    @IBAction func redoAction(sender: AnyObject) {
        
        var shapeType:String = drawView.redoshapetypes.removeLast()
        var shape = drawView.redoArray.removeLast()
        drawView.lastLineDraw.append(shapeType)
        
        switch (shapeType){
            case "drawLine":
                drawView.strokes.append(shape as Array<Line>)
            case "drawOpacityLine":
                drawView.strokesOpacity.append(shape as Array<Line>)
            case "drawCircle":
                drawView.circles.append(shape as CGRect)
            case "drawRectangle":
                drawView.rectangles.append(shape as CGRect)
            default:
                println("something wrong")
        }
        self.drawView.setNeedsDisplay()
    }
    
    //Save the result Image into Gallery
    @IBAction func saveImage(sender: AnyObject) {
        var image = takeScreenshot(drawView)
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
            UIAlertView(title: "Success", message: "Image successfully saved to Camera Roll", delegate: nil, cancelButtonTitle: "Close").show()
        }
    }
    
    //Gestute Methods
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
        
        if(button.titleLabel?.text == "R") {
            color = UIColor.redColor()
            let image = UIImage(named: "Red.png") as UIImage!
            colorButton.setImage(image, forState: .Normal)
        } else if(button.titleLabel?.text == "B") {
            color = UIColor.blueColor()
            let image = UIImage(named: "Blue.png") as UIImage!
            colorButton.setImage(image, forState: .Normal)
        } else if(button.titleLabel?.text == "G") {
            color = UIColor.greenColor()
            let image = UIImage(named: "Green.png") as UIImage!
            colorButton.setImage(image, forState: .Normal)
        } else if(button.titleLabel?.text == "Bl") {
            color = UIColor.blackColor()
            let image = UIImage(named: "Black.png") as UIImage!
            colorButton.setImage(image, forState: .Normal)
        } else if(button.titleLabel?.text == "Y") {
            color = UIColor.yellowColor()
            let image = UIImage(named: "Yellow.png") as UIImage!
            colorButton.setImage(image, forState: .Normal)
        } else if(button.titleLabel?.text == "O") {
            color = UIColor.orangeColor()
            let image = UIImage(named: "Orange.png") as UIImage!
            colorButton.setImage(image, forState: .Normal)
        } else if(button.titleLabel?.text == "W") {
            color = UIColor.whiteColor()
            let image = UIImage(named: "White.png") as UIImage!
            colorButton.setImage(image, forState: .Normal)
        }
        
        drawView.drawColor = color
        if MyVariables.flag == "drawOpacityLine" {
            colorView.hidden = !colorView.hidden
        } else {
            colorView.hidden = !colorView.hidden
            lineWidthView.hidden = !lineWidthView.hidden
        }
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
        } else if(button.titleLabel?.text == "5") {
            line_width = 5
        }
        
        drawView.l_w = line_width
        lineWidthView.hidden = !lineWidthView.hidden
        colorView.hidden = !colorView.hidden
    }
}