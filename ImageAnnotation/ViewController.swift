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

func delay(#seconds: Double, completion:()->()) {
    let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC) * seconds ))
    
    dispatch_after(popTime, dispatch_get_main_queue()) {
        completion()
    }
}

class ViewController: UIViewController,UIAlertViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPopoverControllerDelegate, UIActionSheetDelegate {
    
    var picker: UIImagePickerController? = UIImagePickerController()
    
    var popover: UIPopoverController? = nil
    
    var rotation: CGFloat = 0.0
    
    var oldButton: UIBarButtonItem?
    
    var colorImage : UIImage = UIImage(named: "White.png") as UIImage!
    var maskImage : UIImage = UIImage(named: "Mask1.png") as UIImage!

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
    
    @IBOutlet weak var btnCancel: UIButton!
    
    @IBOutlet weak var btnSave: UIBarButtonItem!
    
    @IBOutlet weak var drawingWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var drawingHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var shapeView: UIView!
    
    @IBOutlet weak var whiteBackgroungImage: UIImageView!
    
    @IBOutlet weak var undo: UIButton!
    
    @IBOutlet weak var redo: UIButton!
    
    @IBOutlet weak var resultView: UIView!
    
    @IBOutlet weak var mainLineWidthView: UIView!
    
    @IBOutlet weak var mainRotationView: UIView!    
    
    @IBOutlet weak var mainShapeView: UIView!
    
    //Animation
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if MyVariables.flag == "" {
            MyVariables.flag = "drawLine"
        }
        //hide all buttons and views
        colorButton.hidden = true
        functionalityButton.hidden = true
        colorView.hidden = true
        lineWidthView.hidden = true
        mainLineWidthView.hidden = true
        undo.hidden = true
        redo.hidden = true
        rotationView.hidden = true
        mainRotationView.hidden = true
        selectFunctionalityView.hidden = true
        shapeView.hidden = true
        mainShapeView.hidden = true
        cropView.hidden = true
        btnDone.hidden = true
        btnCancel.hidden = true
        whiteBackgroungImage.hidden = true
        //hide save bar button
        oldButton = self.navigationItem.rightBarButtonItem!
        self.navigationItem.rightBarButtonItem = nil
        
        //call the delegate method of ImagePickerController
        picker?.delegate = self
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
                self.openGallery()
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
                popover?.presentPopoverFromRect(btnGallery.frame, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
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
        drawView.textFields = []
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
        mainLineWidthView.hidden = true
        selectFunctionalityView.hidden = true
        rotationView.hidden = true
        mainRotationView.hidden = true
        shapeView.hidden = true
        mainShapeView.hidden = true
        cropView.hidden = true
        btnCancel.hidden = true
        btnDone.hidden = true
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
                self.openGallery()
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
                popover?.presentPopoverFromRect(btnGallery.frame, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
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
    
    func openGallery() {
        picker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            self.presentViewController(picker!, animated: true, completion: nil)
        } else {
            self.presentViewController(picker!, animated: true, completion: nil)
        }
    }
    
    //Show colorView & lineWidthView
    @IBAction func selectColor(sender: AnyObject) {
        if imageView.image != nil {
            
            if colorView.hidden == true {
                
                if MyVariables.flag == "drawOpacityLine"
                {
                    colorView.hidden = false
                } else {
                    colorView.hidden = false
                    lineWidthView.hidden = false
                    mainLineWidthView.hidden = false
                }
                
                colorView.center.y  += drawView.bounds.height
                lineWidthView.center.x -= drawView.bounds.width
                
                UIView.animateWithDuration(0.25, animations: {
                    self.colorView.center.y -= self.drawView.bounds.height
                    self.lineWidthView.center.x += self.drawView.bounds.width
                })
            } else {
                UIView.animateWithDuration(0.25, animations: {
                    self.colorView.center.y += self.drawView.bounds.height
                    self.lineWidthView.center.x -= self.drawView.bounds.width
                    }, completion: {
                        (b:Bool) -> Void in
                        self.colorView.hidden = true
                        self.lineWidthView.hidden = true
                        self.mainLineWidthView.hidden = true
                        self.colorView.center.y  -= self.drawView.bounds.height
                        self.lineWidthView.center.x += self.drawView.bounds.width
                })
            }
            
            if selectFunctionalityView.hidden == false || rotationView.hidden == false || shapeView.hidden == false {
                selectFunctionalityView.hidden = true
                rotationView.hidden = true
                shapeView.hidden = true
                mainRotationView.hidden = true
                mainShapeView.hidden = true
            }
        }
    }
    
    //Show functionalityView
    @IBAction func selectFunctionality(sender: AnyObject) {
        if imageView.image != nil {
            
            if selectFunctionalityView.hidden == true {
                selectFunctionalityView.hidden = false
                
                selectFunctionalityView.center.y  += drawView.bounds.height
                
                UIView.animateWithDuration(0.25, animations: {
                    self.selectFunctionalityView.center.y -= self.drawView.bounds.height
                })
            } else {
                selectFunctionalityView.center.y  -= view.bounds.height
               
                UIView.animateWithDuration(0.25, animations: {
                    self.selectFunctionalityView.center.y += self.view.bounds.height
                    }, completion: { (b:Bool) -> Void in
                        self.selectFunctionalityView.hidden = true
                })
            }
            
            if colorView.hidden == false || lineWidthView.hidden == false || rotationView.hidden == false || shapeView.hidden == false {
                colorView.hidden = true
                lineWidthView.hidden = true
                rotationView.hidden = true
                shapeView.hidden = true
                mainLineWidthView.hidden = true
                mainRotationView.hidden = true
                mainShapeView.hidden = true
            }
        }
    }
    
    //Rotation Methods
    @IBAction func rotationAction(sender: AnyObject) {
        if rotationView.hidden == true {
            rotationView.hidden = false
            mainRotationView.hidden = false
            selectFunctionalityView.hidden = true
            
            rotationView.center.x += drawView.bounds.width
            
            UIView.animateWithDuration(0.25, animations: {
                self.rotationView.center.x -= self.drawView.bounds.width
            })
        } else {
            rotationView.center.y  -= view.bounds.height
           
            UIView.animateWithDuration(0.25, animations: {
                self.rotationView.center.x += self.view.bounds.width
                }, completion: { (b:Bool) -> Void in
                    self.rotationView.hidden = true
                    self.mainRotationView.hidden = true
            })
        }
        
        let image = UIImage(named: "Rotation.png") as UIImage!
        functionalityButton.setImage(image, forState: .Normal)
        MyVariables.flag = ""
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
    
        drawingWidthConstraint.constant = displayWidth
        drawingHeightConstraint.constant = displayHeight
    }
    
    func degreesToRadians(x: CGFloat) -> CGFloat{
        return 3.14 * (x) / 180.0
    }
    
    //Draw line on drawView
    @IBAction func drawLineAction(sender: AnyObject) {
        MyVariables.flag = "drawLine"
        let image = UIImage(named: "FreeLine.png") as UIImage!
        functionalityButton.setImage(image, forState: .Normal)
        UIView.animateWithDuration(0.5, animations: {
            self.selectFunctionalityView.alpha = 0
            }, completion: { (b:Bool) -> Void in
                self.selectFunctionalityView.hidden = true
                self.selectFunctionalityView.alpha = 1
        })
    }
    
    //Draw opacity line on drawView
    @IBAction func drawOpacityLineAction(sender: AnyObject) {
        MyVariables.flag = "drawOpacityLine"
        let image = UIImage(named: "OpacityLine.png") as UIImage!
        functionalityButton.setImage(image, forState: .Normal)
        UIView.animateWithDuration(0.5, animations: {
            self.selectFunctionalityView.alpha = 0
            }, completion: { (b:Bool) -> Void in
                self.selectFunctionalityView.hidden = true
                self.selectFunctionalityView.alpha = 1
        })
    }
    
    //Crop Image methods
    @IBAction func cropImageAction(sender: AnyObject) {
        selectFunctionalityView.hidden = true
        cropView.hidden = false
        btnDone.hidden = false
        btnCancel.hidden = false
        undo.hidden = true
        redo.hidden = true
        whiteBackgroungImage.hidden = true
        colorButton.hidden = true
        functionalityButton.hidden = true

        let image = UIImage(named: "Crop.png") as UIImage!
        functionalityButton.setImage(image, forState: .Normal)
        MyVariables.flag = ""
        // Add runtime PanGestureRecognizer into UIView
        cropView?.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "onPan:"))
        
        // Add runtime PinchGestureRecognizer into UIView
        cropView?.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: "onPinch:"))
        UIView.animateWithDuration(0.5, animations: {
            self.selectFunctionalityView.alpha = 0
            }, completion: { (b:Bool) -> Void in
                self.selectFunctionalityView.hidden = true
                self.selectFunctionalityView.alpha = 1
        })
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
        
        whiteBackgroungImage.hidden = false
        colorButton.hidden = false
        functionalityButton.hidden = false
    }
    
    @IBAction func cancelAction(sender: AnyObject) {
        btnCancel.hidden = true
        cropView.hidden = true
        btnDone.hidden = true
        whiteBackgroungImage.hidden = true
        
        if drawView.strokes.count > 0 || drawView.strokesOpacity.count > 0 || drawView.circles.count > 0 || drawView.rectangles.count > 0 || drawView.straightline_obj.count > 0 {
            undo.hidden = false
        } else {
            undo.hidden = true
        }
        
        if drawView.redoArray.count > 0 {
            redo.hidden = false
        } else {
            redo.hidden = true
        }
        
        colorButton.hidden = false
        functionalityButton.hidden = false
    }
    
    //Add shapes methods
    @IBAction func shapeAction(sender: AnyObject) {
        if shapeView.hidden == true {
            shapeView.hidden = false
            mainShapeView.hidden = false
            selectFunctionalityView.hidden = true
            
            shapeView.center.x += drawView.bounds.width
            
            UIView.animateWithDuration(0.25, animations: {
                self.shapeView.center.x -= self.drawView.bounds.width
            })
        } else {
            shapeView.center.y  -= view.bounds.height
            
            UIView.animateWithDuration(0.25, animations: {
                self.shapeView.center.x += self.view.bounds.width
                }, completion: { (b:Bool) -> Void in
                    self.shapeView.hidden = true
                    self.mainShapeView.hidden = true
            })
        }
        
        let image = UIImage(named: "Circle.png") as UIImage!
        functionalityButton.setImage(image, forState: .Normal)
        MyVariables.flag = ""
    }
    
    @IBAction func addTextAction(sender: AnyObject) {
        MyVariables.flag = "addTextField"
        let image = UIImage(named: "Text.png") as UIImage!
        functionalityButton.setImage(image, forState: .Normal)
        MyVariables.flag = ""
        UIView.animateWithDuration(0.5, animations: {
            self.selectFunctionalityView.alpha = 0
            }, completion: { (b:Bool) -> Void in
                self.selectFunctionalityView.hidden = true
                self.selectFunctionalityView.alpha = 1
        })
    }
    
    @IBAction func addCircle(sender: AnyObject) {
        MyVariables.flag = "drawCircle"
        shapeView.hidden = !shapeView.hidden
        let image = UIImage(named: "Circle.png") as UIImage!
        functionalityButton.setImage(image, forState: .Normal)
        UIView.animateWithDuration(0.5, animations: {
            self.selectFunctionalityView.alpha = 0
            }, completion: { (b:Bool) -> Void in
                self.selectFunctionalityView.hidden = true
                self.selectFunctionalityView.alpha = 1
        })
    }
    
    @IBAction func addRectangle(sender: AnyObject) {
        MyVariables.flag = "drawRectangle"
        shapeView.hidden = !shapeView.hidden 
        let image = UIImage(named: "Rectangle.png") as UIImage!
        functionalityButton.setImage(image, forState: .Normal)
        UIView.animateWithDuration(0.5, animations: {
            self.selectFunctionalityView.alpha = 0
            }, completion: { (b:Bool) -> Void in
                self.selectFunctionalityView.hidden = true
                self.selectFunctionalityView.alpha = 1
        })
    }
    
    @IBAction func drawStraightLine(sender: AnyObject) {
        MyVariables.flag = "drawStraightLine"
        shapeView.hidden = !shapeView.hidden
        let image = UIImage(named: "Line.png") as UIImage!
        functionalityButton.setImage(image, forState: .Normal)
        UIView.animateWithDuration(0.5, animations: {
            self.selectFunctionalityView.alpha = 0
            }, completion: { (b:Bool) -> Void in
                self.selectFunctionalityView.hidden = true
                self.selectFunctionalityView.alpha = 1
        })
    }
    
    //Undo Operation
    @IBAction func undoAction(sender: AnyObject) {
        colorView.hidden = true
        selectFunctionalityView.hidden = true
        lineWidthView.hidden = true
        rotationView.hidden = true
        shapeView.hidden = true
        
        mainLineWidthView.hidden = true
        mainRotationView.hidden = true
        mainShapeView.hidden = true
       
        var removedShapeType = drawView.lastLineDraw.removeLast()
        if drawView.lastLineDraw.count >= 0 {
            if drawView.lastLineDraw.count == 0 {
                undo.hidden = true
                redo.hidden = false
            }
            if drawView.lastLineDraw.count >= 1 {
                redo.hidden = false
                undo.hidden = true
            }
            if removedShapeType == "drawLine" {
                if drawView.strokes.count > 0 {
                    var removedLine = drawView.strokes.removeLast() // removeLast line
                    drawView.redoArray.append(removedLine) // add last removedLine into redoArray
                    drawView.redoshapetypes.append(removedShapeType) // add last removedShape into redoshapetypes
                    drawView.setNeedsDisplay()
                }
            } else if removedShapeType == "drawOpacityLine" {
                if drawView.strokesOpacity.count > 0 {
                    var removedOpacityLine = drawView.strokesOpacity.removeLast() // removeLast Opacityline
                    drawView.redoArray.append(removedOpacityLine) // add last removedOpacityLine into redoArray
                    drawView.redoshapetypes.append(removedShapeType) // add last removedShape into redoshapetypes
                    drawView.setNeedsDisplay()
                }
            } else if removedShapeType == "addTextField" {
                if drawView.textFields.count > 0 {
                    var removedTextField = drawView.textFields.removeLast() // removeLast textField
                    drawView.redoArray.append(removedTextField) // add last removedTextField into redoArray
                    drawView.redoshapetypes.append(removedShapeType) // add last removedShape into redoshapetypes
                    drawView.setNeedsDisplay()
                }
            } else if removedShapeType == "drawCircle" {
                if drawView.circles.count > 0 {
                    var removedCircle = drawView.circles.removeLast() // removeLast circle
                    drawView.redoArray.append(removedCircle) // add last removedCircle into redoArray
                    drawView.redoshapetypes.append(removedShapeType) // add last removedShape into redoshapetypes
                    drawView.setNeedsDisplay()
                }
            } else if removedShapeType == "drawRectangle" {
                if drawView.rectangles.count > 0 {
                    var removedRectangle = drawView.rectangles.removeLast() // removeLast rectangle
                    drawView.redoArray.append(removedRectangle) // add last removedRectangle into redoArray
                    drawView.redoshapetypes.append(removedShapeType) // add last removedShape into redoshapetypes
                    drawView.setNeedsDisplay()
                }
            } else if removedShapeType == "drawStraightLine" {
                if drawView.straightline_obj.count > 0 {
                    var removedStraightLine = drawView.straightline_obj.removeLast() // removeLast line
                    drawView.redoArray.append(removedStraightLine) // add last removedLine into redoArray
                    drawView.redoshapetypes.append(removedShapeType) // add last removedShape into redoshapetypes
                    drawView.setNeedsDisplay()
                }
            }
        }
    }
    
    //Redo Operation
    @IBAction func redoAction(sender: AnyObject) {
        colorView.hidden = true
        selectFunctionalityView.hidden = true
        lineWidthView.hidden = true
        rotationView.hidden = true
        shapeView.hidden = true
        
        mainLineWidthView.hidden = true
        mainRotationView.hidden = true
        mainShapeView.hidden = true
        
        var shapeType:String = drawView.redoshapetypes.removeLast()
        var shape = drawView.redoArray.removeLast()
        drawView.lastLineDraw.append(shapeType)
        
        switch (shapeType){
            case "drawLine":
                drawView.strokes.append(shape as Array<Line>)
            case "drawOpacityLine":
                drawView.strokesOpacity.append(shape as Array<Line>)
            case "addTextField":
                drawView.textFields.append(shape as UITextField)
            case "drawCircle":
                drawView.circles.append(shape as Circle)
            case "drawRectangle":
                drawView.rectangles.append(shape as Rectangle)
            case "drawStraightLine":
                drawView.straightline_obj.append(shape as Array<Line>)
            default:
                println("something wrong")
        }
        self.drawView.setNeedsDisplay()
        
        if drawView.lastLineDraw.count == drawView.tmpcnt || drawView.redoArray.count == 0 {
            redo.hidden = true
        } else {
            //println("Hello")
        }
    }
    
    //Save the result Image into Gallery
    @IBAction func saveImage(sender: AnyObject) {
        var image = takeScreenshot(resultView)
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
    @IBAction func colorAndLineTapped(button: UIButton!) {
       
        var line_width : CGFloat!
        
        whiteBackgroungImage.hidden = false
        
        if(button.titleLabel?.text == "R") {
            drawView.drawColor = UIColor.redColor()
            colorImage = UIImage(named: "Red.png") as UIImage!
        } else if(button.titleLabel?.text == "B") {
            drawView.drawColor = UIColor.blueColor()
            colorImage = UIImage(named: "Blue.png") as UIImage!
        } else if(button.titleLabel?.text == "G") {
            drawView.drawColor = UIColor.greenColor()
            colorImage = UIImage(named: "Green.png") as UIImage!
        } else if(button.titleLabel?.text == "Bl") {
            drawView.drawColor = UIColor.blackColor()
            colorImage = UIImage(named: "Black.png") as UIImage!
        } else if(button.titleLabel?.text == "Y") {
            drawView.drawColor = UIColor.yellowColor()
            colorImage = UIImage(named: "Yellow.png") as UIImage!
        } else if(button.titleLabel?.text == "O") {
            drawView.drawColor = UIColor.orangeColor()
            colorImage = UIImage(named: "Orange.png") as UIImage!
        } else if(button.titleLabel?.text == "W") {
            drawView.drawColor = UIColor.whiteColor()
            colorImage = UIImage(named: "White.png") as UIImage!
        } else if(button.titleLabel?.text == "1") {
            drawView.l_w = 1
            maskImage = UIImage(named: "Mask1.png") as UIImage!
        } else if(button.titleLabel?.text == "2") {
            drawView.l_w = 2
            maskImage = UIImage(named: "Mask2.png") as UIImage!
        } else if(button.titleLabel?.text == "3") {
            drawView.l_w = 3
            maskImage = UIImage(named: "Mask3.png") as UIImage!
        } else if(button.titleLabel?.text == "4") {
            drawView.l_w = 4
            maskImage = UIImage(named: "Mask4.png") as UIImage!
        } else if(button.titleLabel?.text == "5") {
            drawView.l_w = 5
            maskImage = UIImage(named: "Mask5.png") as UIImage!
        }
        
        UIView.animateWithDuration(0.5, animations: {
            self.colorView.alpha = 0
            self.lineWidthView.alpha = 0
            }, completion: { (b:Bool) -> Void in
                self.colorView.hidden = true
                self.lineWidthView.hidden = true
                self.mainLineWidthView.hidden = true
                self.colorView.alpha = 1
                self.lineWidthView.alpha = 1
        })
        
        var img:UIImage = colorImage
        
        var img2 = UIImage.getMaskedArtworkFromPicture(img, withMask: maskImage)
        
        colorButton.setImage(img2, forState: UIControlState.Normal)
    }
}