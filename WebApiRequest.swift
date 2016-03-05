//
//  WebApiRequest.swift
//  AnyDojo
//
//  Created by Telenext Systems on 01/07/15.
//  Copyright (c) 2015 Telenext Systems. All rights reserved.
//

import Foundation

@objc protocol WebApiRequestDelegate {
    optional func processResponse(responseObj: AnyObject) -> Void
    optional func processResponse(responseObj: AnyObject, tag: Int) -> Void
    optional func processResponse(responseObj: AnyObject, tag: Int, obj: AnyObject) -> Void
    optional func processError(error: NSError) -> Void
    optional func processError(error: NSError, tag: Int) -> Void
    optional func processError(error: NSError, tag: Int, obj: AnyObject) -> Void
}

class WebApiRequest: NSObject, NSURLSessionDelegate {
    var urlsession: NSURLSession?
    var documentUploadViewController: DocumentUploadViewController?
    weak var delegate: WebApiRequestDelegate?
    var queue: NSOperationQueue = NSOperationQueue();
    var object: AnyObject?
    var tag: Int = -1
    
    override init(){
        super.init()
        let sessionConfig: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration();
        sessionConfig.HTTPAdditionalHeaders = Dictionary(dictionaryLiteral: (("Content-Type", "application/json")))
        urlsession = NSURLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil);
    }
    
    func validateTeacher(code: String) -> Void {
        var urlString: String = AppConstants.WebServiceUrl
        urlString += AppConstants.WS_TeacherValidation
        println("URL String: \(urlString)")
        var parameter: String = "{authCode:\"\(code)\",uuid:\"\(AppData.sharedInstance.uuidString)\"}"
        var request: NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPBody = parameter.dataUsingEncoding(NSUTF8StringEncoding)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        println("HTTP Body: \(request.HTTPBody?.length)");
        println("Request Body: \(parameter)")
        request.HTTPMethod = "POST"
        
        self.performServerTask(request, data: parameter.dataUsingEncoding(NSUTF8StringEncoding)!)
    }
    
    func validateStudent(code: String) -> Void {
        var urlString: String = AppConstants.WebServiceUrl
        urlString += AppConstants.WS_StudentValidation
        println("URL String: \(urlString)")
        var parameter: String = "{studentCode:\"\(code)\",uuid:\"\(AppData.sharedInstance.uuidString)\"}"
        var request: NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPBody = parameter.dataUsingEncoding(NSUTF8StringEncoding)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        println("HTTP Body: \(request.HTTPBody?.length)");
        println("Request Body: \(parameter)")
        request.HTTPMethod = "POST"
        
        self.performServerTask(request, data: parameter.dataUsingEncoding(NSUTF8StringEncoding)!)
    }
    
    // sheldon 08/22 get username from full name
    func username(authCode: String, fullName: String) -> Void {
        var urlString: String = AppConstants.WebServiceUrl
        urlString += AppConstants.WS_Username
        var parameter: String = "{fullName:\"\(fullName)\",authCode:\"\(authCode)\"}"
        sendJsonRequest(urlString, parameter: parameter)
    }
    
    // sheldon 07/18 pass authCode not user id because user id cannot be authenticated, authCode can
    func getDojoList(authCode: String) -> Void {
        var urlString: String = AppConstants.WebServiceUrl
        urlString += AppConstants.WS_DojoList
        var parameter: String = "{authCode:\(authCode)}"
        var request: NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPBody = parameter.dataUsingEncoding(NSUTF8StringEncoding)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        println("HTTP Body: \(request.HTTPBody?.length)");
        println("Request Body: \(parameter)")
        request.HTTPMethod = "POST"
        self.performServerTask(request, data: parameter.dataUsingEncoding(NSUTF8StringEncoding)!)
    }
    
    // sheldon 07/25 pass authCode not user id because user id cannot be authenticated, authCode can
    func getEndedDojoList(authCode: String) -> Void {
        var urlString: String = AppConstants.WebServiceUrl
        urlString += AppConstants.WS_EndedDojoList
        var parameter: String = "{authCode:\(authCode)}"
        var request: NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPBody = parameter.dataUsingEncoding(NSUTF8StringEncoding)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        println("HTTP Body: \(request.HTTPBody?.length)");
        println("Request Body: \(parameter)")
        request.HTTPMethod = "POST"
        self.performServerTask(request, data: parameter.dataUsingEncoding(NSUTF8StringEncoding)!)
    }
    
    // sheldon 07/12 add repeat as a parameter
    func createNewDojo(description: String, maxNumberOfStudents: Int, startTime: NSDate, durationInMin: Int, timeZone: String, repeatFrequency: String, type: String) {
        var urlString: String = AppConstants.WebServiceUrl
        urlString += AppConstants.WS_CreateDojo
        
        // sheldon 07/12 add repeatFrequency in json if repeatFrequency is not empty string.
        // add all request must send authCode
        let repeatString = count(repeatFrequency) > 0 ? ",repeatFrequency:\"\(repeatFrequency)\"" : ""
        
        var parameter: String = "{authCode:\(AppData.sharedInstance.userdata!.authCode!),description:\"\(description)\",maxNumberOfStudents:\(maxNumberOfStudents),startTime:\"\(AppData.sharedInstance.formatterWSDatetime.stringFromDate(startTime))\",durationInMin:\(durationInMin),timeZone:\"\(timeZone)\",dojoType:\"\(type)\"\(repeatString)}"
        
        sendJsonRequest(urlString, parameter: parameter)
    }
    
    // sheldon 07/29 update dojo
    func updateDojo(description: String, maxNumberOfStudents: Int, startTime: NSDate, durationInMin: Int, timeZone: String, repeatFrequency: String, type: String, dojoId: String) {
        var urlString: String = AppConstants.WebServiceUrl
        urlString += AppConstants.WS_UpdateDojo
        
        let repeatString = count(repeatFrequency) > 0 ? ",repeatFrequency:\"\(repeatFrequency)\"" : ""
        
        var parameter: String = "{authCode:\(AppData.sharedInstance.userdata!.authCode!),description:\"\(description)\",maxNumberOfStudents:\(maxNumberOfStudents),startTime:\"\(AppData.sharedInstance.formatterWSDatetime.stringFromDate(startTime))\",durationInMin:\(durationInMin),timeZone:\"\(timeZone)\",dojoType:\"\(type)\"\(repeatString), dojo:{id:\(dojoId)}}"
        
        sendJsonRequest(urlString, parameter: parameter)
    }
    
    //delete Dojo
    func deleteDojo(dojoId: Int,authCode: String) {
        var urlString: String = AppConstants.WebServiceUrl
        urlString += AppConstants.WS_DeleteDojo
        
        var parameter: String = "{dojo:{id:\(dojoId)},authCode:\"\(authCode)\"}"
        var request: NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPBody = parameter.dataUsingEncoding(NSUTF8StringEncoding)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        println("HTTP Body: \(request.HTTPBody?.length)");
        println("Request Body: \(parameter)")
        request.HTTPMethod = "POST"
        
        self.performServerTask(request, data: parameter.dataUsingEncoding(NSUTF8StringEncoding)!)
    }
    
    
    //enter Dojo
    func enterClass(dojoId: Int, authCode: String, data: String = "TEST") {
        var urlString: String = AppConstants.WebServiceUrl
        urlString += AppConstants.WS_EnterClass
        
        //data:”…”
        var parameter: String = "{dojo:{id:\(dojoId)},authCode:\"\(authCode)\",data:\"\(data)\",deviceId:\"\(AppData.sharedInstance.uuidString)\"}"
        var request: NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPBody = parameter.dataUsingEncoding(NSUTF8StringEncoding)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        println("HTTP Body: \(request.HTTPBody?.length)");
        println("Request Body: \(parameter)")
        request.HTTPMethod = "POST"
        
        self.performServerTask(request, data: parameter.dataUsingEncoding(NSUTF8StringEncoding)!)
    }
    
    func leaveClass(count: Int, dojoId: Int, authCode: String) {
        var urlString: String = AppConstants.WebServiceUrl
        urlString += AppConstants.WS_LeaveClass
        
        var parameter: String = "{dojo:{id:\(dojoId), numberOfCurrentStudents:\(count)},authCode:\"\(authCode)\"}"
        var request: NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPBody = parameter.dataUsingEncoding(NSUTF8StringEncoding)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        println("HTTP Body: \(request.HTTPBody?.length)");
        println("Request Body: \(parameter)")
        request.HTTPMethod = "POST"
        
        self.performServerTask(request, data: parameter.dataUsingEncoding(NSUTF8StringEncoding)!)
    }
    
    // ping class
    func pingDojoSession(dojo: DojoData, ended: Bool = false) {
        var urlString: String = AppConstants.WebServiceUrl
        urlString += AppConstants.WS_PingDojoSession
        let dojoSessionString = dojo.dojoSessionId != nil ? ",dojoSessionId:\(dojo.dojoSessionId!)" : ""
        //data:”…”
        var parameter: String = "{dojo:{id:\(dojo.id)},authCode:\"\(AppData.sharedInstance.userdata!.authCode!)\"\(dojoSessionString),deviceId:\"\(AppData.sharedInstance.uuidString)\",ended:\(ended)}"
        var request: NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPBody = parameter.dataUsingEncoding(NSUTF8StringEncoding)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        println("HTTP Body: \(request.HTTPBody?.length)");
        println("Request Body: \(parameter)")
        request.HTTPMethod = "POST"
        
        self.performServerTask(request, data: parameter.dataUsingEncoding(NSUTF8StringEncoding)!)
    }
    
    // sheldon 08/14 support validate student entered class code to add new class to student
    func addSharedClassByCode(code: String) {
        var urlString: String = AppConstants.WebServiceUrl
        urlString += AppConstants.WS_AddSharedClass
        println("URL String: \(urlString)")
        var parameter: String = "{studentCode:\"\(code)\",uuid:\"\(AppData.sharedInstance.uuidString)\",authCode:\"\(AppData.sharedInstance.userdata!.authCode!)\"}"
        var request: NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPBody = parameter.dataUsingEncoding(NSUTF8StringEncoding)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        println("HTTP Body: \(request.HTTPBody?.length)");
        println("Request Body: \(parameter)")
        request.HTTPMethod = "POST"
        
        self.performServerTask(request, data: parameter.dataUsingEncoding(NSUTF8StringEncoding)!)
    }
    
    //{dojo:{id:2},emails:{emsi1@email.com,email2@emai.com....}}
    
    func sendInvite(dojoId: Int, emailAddresses: String) {
        var urlString: String = AppConstants.WebServiceUrl
        urlString += AppConstants.WS_SendInvite
        
        var parameter: String = "{dojo:{id:\(dojoId)},emailAddresses:\"\(emailAddresses)\"}"
        var request: NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPBody = parameter.dataUsingEncoding(NSUTF8StringEncoding)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        println("HTTP Body: \(request.HTTPBody?.length)");
        println("Request Body: \(parameter)")
        request.HTTPMethod = "POST"
        self.performServerTask(request, data: parameter.dataUsingEncoding(NSUTF8StringEncoding)!)
    }
    
    func uploadAvatar(id: NSString, img: UIImage){
        var urlString: String = AppConstants.WebServiceUrl
        urlString += AppConstants.WS_UploadAvatar
        
        let boundary = generateBoundary()
        // sheldon 07/10 use a fake file name with extension (extension is required on the server)
        let fileName = "avatar.png"
        
        var request: NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPBody = photoDataToFormData(UIImagePNGRepresentation(img), boundary: boundary, fileName: fileName, jsonBody: nil)
        // sheldon 07/10 set content-type to multipart
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = "POST"
        
        self.performServerTask(request, data: request.HTTPBody!)
    }
    
    func downloadDocuments(dojoId: Int, obj: AnyObject? = nil) {
        //{dojo:{id:20},authCode:"a6g7r2"}
        var urlString: String = AppConstants.WebServiceUrl
        urlString += AppConstants.WS_DownloadDocs
        self.object = obj
        var parameter: String = "{authCode:\"\(AppData.sharedInstance.userdata!.authCode!)\",dojo:{id:\(dojoId)}}"
        
        var request: NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPBody = parameter.dataUsingEncoding(NSUTF8StringEncoding)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        println("HTTP Body: \(request.HTTPBody?.length)");
        println("Request Body: \(parameter)")
        request.HTTPMethod = "POST"
        
        self.performServerTask(request, data: parameter.dataUsingEncoding(NSUTF8StringEncoding)!)
    }
    
    
    //temporarily added for downloading documents for student
    func dojoDownloadDocuments() {
        //{dojo:{id:20},authCode:"a6g7r2"}
        var urlString: String = AppConstants.WebServiceUrl
        urlString += AppConstants.WS_DownloadDocs
        
        var parameter: String = "{authCode:\"a6g7r2\",dojo:{id:32}}"
        
        var request: NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPBody = parameter.dataUsingEncoding(NSUTF8StringEncoding)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        println("HTTP Body: \(request.HTTPBody?.length)");
        println("Request Body: \(parameter)")
        request.HTTPMethod = "POST"
        
        self.performServerTask(request, data: parameter.dataUsingEncoding(NSUTF8StringEncoding)!)
    }
    
    enum DocumentType {
        case PDF, PNG
    }
    
    func uploadDocuments(dojoId: Int, fileUrl: NSURL, fileName: String, obj: AnyObject? = nil , isArchive: Bool = false, tags: String = ""){
        self.object = obj
        var urlString: String = AppConstants.WebServiceUrl
        urlString += AppConstants.WS_UploadDocuments
        
        let boundary = generateBoundary()
        // use a fake file name with extension (extension is required on the server)
        //let fileName = fileDetails.
        let data: NSData! = NSData(contentsOfURL: fileUrl)

        var request: NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        
        if (data != nil) {
            if isArchive {
                assert(fileUrl.pathExtension! == "pdf" || fileUrl.pathExtension == "PDF", "Archive document file extension is wrong")
            
                request.HTTPBody = photoDataToFormData(data, boundary: boundary, fileName: fileName, jsonBody: "{dojo:{id:\(dojoId)},type:\"ARCHIVED_PDF\",tag:\"\(tags)\"}")
            }
            else {
                if fileUrl.pathExtension! == "pdf" || fileUrl.pathExtension == "PDF" {
                    request.HTTPBody = photoDataToFormData(data, boundary: boundary, fileName: fileName, jsonBody: "{dojo:{id:\(dojoId)},type:\"PDF\"}")
                }
                else {
                    request.HTTPBody = photoDataToFormData(data, boundary: boundary, fileName: fileName, jsonBody: "{dojo:{id:\(dojoId)},type:\"IMAGE\"}")
                //ARCHIVED_PDF, ARCHIVED_VIDEO
                }
            }

            // set content-type to multipart
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.HTTPMethod = "POST"
        
            self.performServerTask(request, data: request.HTTPBody!)
        }
    }
    
    //unused function as of now
    //can be used to upload image directly without storing it to file system
    //this function should be reviewed first before using it again
    func uploadDocuments(dojoId: Int, img: UIImage, fileName: String, obj: AnyObject? = nil) {
        self.object = obj
        var urlString: String = AppConstants.WebServiceUrl
        urlString += AppConstants.WS_UploadDocuments
        
        //let fileName = "document.png"

        let boundary = generateBoundary()
        // use a fake file name with extension (extension is required on the server)
        //let fileName = fileDetails.
        let data: NSData! = UIImagePNGRepresentation(img)
        
        var request: NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPBody = photoDataToFormData(data, boundary: boundary, fileName: fileName, jsonBody: "{dojo:{id:\(dojoId)},type:\"IMAGE\"}")
        // set content-type to multipart
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = "POST"
        
        self.performServerTask(request, data: request.HTTPBody!)
    }
    
    //pushToken
    func registerPushNotificationToken(authCode: String, pushToken: String) {
        var urlString: String = AppConstants.WebServiceUrl
        urlString += AppConstants.WS_PushToken
        
        var parameter: String = "{authCode:\"\(authCode)\",pushToken:\"\(pushToken)\"}"
        var request: NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPBody = parameter.dataUsingEncoding(NSUTF8StringEncoding)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        println("HTTP Body: \(request.HTTPBody?.length)");
        println("Request Body: \(parameter)")
        request.HTTPMethod = "POST"
        
        self.performServerTask(request, data: parameter.dataUsingEncoding(NSUTF8StringEncoding)!)
    }
    
    //delete a Document
    func deleteDocument(dojoId: Int,authCode: String, id: Int) {
        var urlString: String = AppConstants.WebServiceUrl
        urlString += AppConstants.WS_DeleteDocument
        
        var parameter: String = "{dojo:{id:\(dojoId)},authCode:\"\(authCode)\",id:\"\(id)\"}"
        var request: NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPBody = parameter.dataUsingEncoding(NSUTF8StringEncoding)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        println("HTTP Body: \(request.HTTPBody?.length)");
        println("Request Body: \(parameter)")
        request.HTTPMethod = "POST"
        
        self.performServerTask(request, data: parameter.dataUsingEncoding(NSUTF8StringEncoding)!)
    }
    
    //get dojos for a subject
    func requestDojo(subjectId: Int, excludedTeacherUsernames: Array<String>? = nil) {
        var urlString: String = AppConstants.WebServiceUrl
        urlString += AppConstants.WS_RequestDojo
        
        var excludedTeacherUsernamesStr = ""
        if excludedTeacherUsernames != nil {
            excludedTeacherUsernamesStr = ",excludedTeacherUsernames:["
            for var i=0; i<excludedTeacherUsernames!.count; i++ {
                if (i == excludedTeacherUsernames!.count - 1) {
                    excludedTeacherUsernamesStr = "\(excludedTeacherUsernamesStr)\"\(excludedTeacherUsernames![i])\"]"
                } else {
                    excludedTeacherUsernamesStr = "\(excludedTeacherUsernamesStr)\"\(excludedTeacherUsernames![i])\","
                }
            }
        }
        var parameter: String = "{subjectId:\(subjectId),authCode:\"\(AppData.sharedInstance.userdata!.authCode!)\"\(excludedTeacherUsernamesStr)}"
        var request: NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPBody = parameter.dataUsingEncoding(NSUTF8StringEncoding)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        println("HTTP Body: \(request.HTTPBody?.length)");
        println("Request Body: \(parameter)")
        request.HTTPMethod = "POST"
        
        self.performServerTask(request, data: parameter.dataUsingEncoding(NSUTF8StringEncoding)!)
    }
    
    func generateBoundary() -> String
    {
        return "Boundary-\(NSUUID().UUIDString)"
    }
    
    // change signature to allow jsonbody to be passed sheldon 07/18
    func photoDataToFormData(data:NSData,boundary:String,fileName:String, jsonBody:String?) -> NSData {
        var fullData = NSMutableData()
        // sheldon 07/18 add json
        if jsonBody != nil {
            fullData.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            fullData.appendData("Content-Disposition: form-data;name=\"json\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            fullData.appendData("Content-Type: application/json\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            fullData.appendData("\(jsonBody!)\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        }
        // append authCode
        fullData.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        fullData.appendData("Content-Disposition: form-data;name=\"authCode\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        fullData.appendData("Content-Type: text/plain\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        fullData.appendData("\(AppData.sharedInstance.userdata!.authCode!)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        // 1 - Boundary should start with --
        let lineOne = "--" + boundary + "\r\n"
        fullData.appendData(lineOne.dataUsingEncoding(
            NSUTF8StringEncoding,
            allowLossyConversion: false)!)
        
        // 2
        let lineTwo = "Content-Disposition: form-data; name=\"uploadFile\"; filename=\"" + fileName + "\"\r\n"
        NSLog(lineTwo)
        fullData.appendData(lineTwo.dataUsingEncoding(
            NSUTF8StringEncoding,
            allowLossyConversion: false)!)
        
        // 3
        let lineThree = "Content-Type: image/png\r\n\r\n"
        fullData.appendData(lineThree.dataUsingEncoding(
            NSUTF8StringEncoding,
            allowLossyConversion: false)!)
        
        // 4
        fullData.appendData(data)
        
        // 5
        let lineFive = "\r\n"
        fullData.appendData(lineFive.dataUsingEncoding(
            NSUTF8StringEncoding,
            allowLossyConversion: false)!)
        
        // 6 - The end. Notice -- at the start and at the end
        let lineSix = "--" + boundary + "--\r\n"
        fullData.appendData(lineSix.dataUsingEncoding(
            NSUTF8StringEncoding,
            allowLossyConversion: false)!)
        
        return fullData
    }
    
    func pdfDataToFormData(data:NSData,boundary:String,fileName:String, jsonBody:String?) -> NSData {
        var fullData = NSMutableData()
        // sheldon 07/18 add json
        if jsonBody != nil {
            fullData.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            fullData.appendData("Content-Disposition: form-data;name=\"json\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            fullData.appendData("Content-Type: application/json\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            fullData.appendData("\(jsonBody!)\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        }
        
        // 1 - Boundary should start with --
        let lineOne = "--" + boundary + "\r\n"
        fullData.appendData(lineOne.dataUsingEncoding(
            NSUTF8StringEncoding,
            allowLossyConversion: false)!)
        
        // 2
        let lineTwo = "Content-Disposition: form-data; name=\"uploadFile\"; filename=\"" + fileName + "\"\r\n"
        NSLog(lineTwo)
        fullData.appendData(lineTwo.dataUsingEncoding(
            NSUTF8StringEncoding,
            allowLossyConversion: false)!)
        
        // 3
        let lineThree = "Content-Type: application/pdf\r\n\r\n"
        fullData.appendData(lineThree.dataUsingEncoding(
            NSUTF8StringEncoding,
            allowLossyConversion: false)!)
        
        // 4
        fullData.appendData(data)
        
        // 5
        let lineFive = "\r\n"
        fullData.appendData(lineFive.dataUsingEncoding(
            NSUTF8StringEncoding,
            allowLossyConversion: false)!)
        
        // 6 - The end. Notice -- at the start and at the end
        let lineSix = "--" + boundary + "--\r\n"
        fullData.appendData(lineSix.dataUsingEncoding(
            NSUTF8StringEncoding,
            allowLossyConversion: false)!)
        
        return fullData
    }
    
    private func sendJsonRequest(urlString: String, parameter: String) {
        
        var request: NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPBody = parameter.dataUsingEncoding(NSUTF8StringEncoding)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        println("HTTP Body: \(request.HTTPBody?.length)");
        println("Request Body: \(parameter)")
        request.HTTPMethod = "POST"
        
        self.performServerTask(request, data: parameter.dataUsingEncoding(NSUTF8StringEncoding)!)
    }
    
    private func performServerTask(request: NSURLRequest, data: NSData) {
        
        println("Request URL: \(request.URL!)")
        urlsession!.dataTaskWithRequest(request, completionHandler:
            {(data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
                if error == nil {
                    var responsestring = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Response string: \(responsestring)");
                    var errorInJSONSerialization: NSError? = nil
                    let responseObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &errorInJSONSerialization)
                    println(responseObject)
                    
                    if errorInJSONSerialization == nil {
                        if (self.object != nil) {
                            println(self.delegate)
                            //self.testdelegate?.test()
                            self.delegate?.processResponse!(responseObject!, tag: self.tag, obj: self.object!)
                        }
                        else
                        {
                            if (self.tag == -1) {
                                self.delegate?.processResponse?(responseObject!)
                            }
                            else{
                                self.delegate?.processResponse?(responseObject!, tag: self.tag)
                            }
                        }
                    }
                    else{
                        if (self.object != nil) {
                            self.delegate?.processError?(errorInJSONSerialization!, tag: self.tag, obj: self.object!)
                        }
                        else
                        {
                            if (self.tag == -1) {
                                self.delegate?.processError?(errorInJSONSerialization!)
                            }
                            else {
                                self.delegate?.processError?(errorInJSONSerialization!, tag: self.tag)
                            }
                        }
                    }
                }
                else {
                    if (self.object != nil) {
                        self.delegate?.processError?(error!, tag: self.tag, obj: self.object!)
                    }
                    else {
                        if (self.tag == -1) {
                            self.delegate?.processError?(error!)
                        }
                        else
                        {
                            self.delegate?.processError?(error!, tag: self.tag)
                        }
                    }
                }
        }).resume()
    }
    
    private func performServerTask(request: NSURLRequest, fileUrl: NSURL){
        println("Request URL: \(request.URL!)")
        urlsession!.uploadTaskWithRequest(request, fromFile: fileUrl, completionHandler:
            {(data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
                if error == nil{
                    var responsestring = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Response string: \(responsestring)");
                    var errorInJSONSerialization: NSError? = nil
                    let responseObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &errorInJSONSerialization)
                    println(responseObject)
                    
                    if errorInJSONSerialization == nil{
                        if (self.tag == -1){
                            self.delegate?.processResponse?(responseObject!)
                        }
                        else{
                            self.delegate?.processResponse?(responseObject!, tag: self.tag)
                        }
                    }
                    else{
                        self.delegate?.processError!(errorInJSONSerialization!)
                    }
                }
                else {
                    self.delegate?.processError!(error!)
                }
        }).resume()
    }
}
