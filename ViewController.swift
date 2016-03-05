//
//  ViewController.swift
//  SOAPWebServiceDemo
//
//  Created by Panther on 02/11/15.
//  Copyright (c) 2015 Panther. All rights reserved.
//
// referance link - http://webindream.com/soap-with-swift/
//Use SOAP 1.2

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, SOAPWebApiRequestDelegate {
    
    var soapWebApiRequest: SOAPWebApiRequest?
    
    @IBOutlet weak var studentRollNo : UITextField!
    @IBOutlet weak var txtRollNo: UITextField!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtMoNo: UITextField!
    @IBOutlet weak var txtM1: UITextField!
    @IBOutlet weak var txtM2: UITextField!
    @IBOutlet weak var txtM3: UITextField!
    @IBOutlet weak var txtTotal: UITextField!
    @IBOutlet weak var txtAvg: UITextField!
    @IBOutlet weak var txtStudentId: UITextField!
    @IBOutlet weak var txtMarksheetId: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        studentRollNo.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func submitAction(sender : AnyObject) {
        
        if !studentRollNo.text.isEmpty {
            var rollno: Int = studentRollNo.text.toInt()!
            
            soapWebApiRequest = SOAPWebApiRequest()
            soapWebApiRequest!.delegate = self
            soapWebApiRequest!.getStudentDetail(rollno)
        }
        else {
            UIAlertView(title: "", message: "Please enter endrollment number", delegate: nil, cancelButtonTitle: "OK").show()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // SOAPWebApiRequestDelegate
    func processResponse(responseObj: AnyObject) {
        
        println(responseObj)
        
        if responseObj.count > 0 {
        
            if let result = responseObj as? NSDictionary {
                //println(result)
                if let response = result["getStudentDetailResponse"] as? Dictionary<String, AnyObject> {
                    if let studentDetail = response["getStudentDetailResult"] as? Dictionary<String, AnyObject> {
                        txtStudentId.text = studentDetail["id"] as! String
                        txtRollNo.text = studentDetail["roll_no"] as! String
                        txtName.text = studentDetail["name"] as! String
                        txtMoNo.text = studentDetail["mo_no"] as! String
                        
                        if let marksheetDetail = studentDetail["marksheet"] as? Dictionary<String, AnyObject> {
                            txtMarksheetId.text = marksheetDetail["id"] as! String
                            txtM1.text = marksheetDetail["m1"] as! String
                            txtM2.text = marksheetDetail["m2"] as! String
                            txtM3.text = marksheetDetail["m3"] as! String
                            txtTotal.text = marksheetDetail["total"] as! String
                            txtAvg.text = marksheetDetail["avg"] as! String
                        }
                    }
                }
            }
        }
    }
    
    func processError() {
        UIAlertView(title: "Error", message: "Problem to retrive data.", delegate: nil, cancelButtonTitle: "OK").show()
    }
    
    // TextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}