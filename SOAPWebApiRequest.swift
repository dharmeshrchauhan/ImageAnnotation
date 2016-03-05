//
//  SOAPWebApiRequest.swift
//  SOAPWebServiceDemo
//
//  Created by Sagar Nandha on 26/11/15.
//  Copyright (c) 2015 Panther. All rights reserved.
//

import Foundation

@objc protocol SOAPWebApiRequestDelegate {
    optional func processResponse(responseObj: AnyObject) -> Void
    optional func processError() -> Void
}

class SOAPWebApiRequest: NSObject, NSURLConnectionDelegate {
    
    var delegate: SOAPWebApiRequestDelegate?
    var mutableData: NSMutableData  = NSMutableData.alloc()
    var dataDictionary: NSDictionary?
    
    func getStudentDetail(rollno: Int) -> Void {
        
        //var soapMessage = "<?xml version=\"1.0\" encoding=\"utf-8\"?><soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\"><soap12:Body><getStudentDetail xmlns=\"http://tempuri.org/\"><roll_no>\(rollno)</roll_no></getStudentDetail></soap12:Body></soap12:Envelope>"
        
        var soapMessage = String(contentsOfFile: NSBundle.mainBundle().pathForResource("GetStudentDetail.xml", ofType: nil)!, encoding: NSUTF8StringEncoding, error: nil)!
        soapMessage = String(format: soapMessage, arguments: [rollno])
        
        var urlString = "http://192.168.0.60:10001/Service.asmx"
        
        var url = NSURL(string: urlString)
        
        var theRequest = NSMutableURLRequest(URL: url!)
        
        var data = soapMessage.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        var msgLength = data!.length
        
        theRequest.addValue("application/soap+xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        theRequest.addValue(String(msgLength), forHTTPHeaderField: "Content-Length")
        theRequest.HTTPMethod = "POST"
        theRequest.HTTPBody = data
        
        var connection = NSURLConnection(request: theRequest, delegate: self, startImmediately: true)
        connection!.start()
        
        if (connection == true) {
            var mutableData : Void = NSMutableData.initialize()
        }
    }
    
    // NSURLConnectionDelegate
    func connection(connection: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {
        mutableData.length = 0
    }
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        mutableData.appendData(data)
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        print(error)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        var string: String = NSString(data: mutableData, encoding: NSUTF8StringEncoding) as! String
        
        dataDictionary = NSDictionary(XMLData: mutableData)
        
        println(dataDictionary!["soap:Body"])
        
        if dataDictionary != nil {
            self.delegate?.processResponse!(dataDictionary!["soap:Body"]!)
        }
        else {
            self.delegate?.processError!()
        }
    }
}