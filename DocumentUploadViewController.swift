//
//  DocumentUploadViewController.swift
//  AnyDojo
//
//  Created byTelext Systems on 12/06/15.
//  Copyright (c) 2015 Telenext Systems. All rights reserved.
//

import UIKit
import AssetsLibrary
import MediaPlayer
import MessageUI

class DocumentUploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate, WebApiRequestDelegate, ArchiveUploadManagerDelegate,DownloadManagerForFileDetailDelegate, DownloadManagerForArchiveFileDelegate, FileUploadManagerDelegate, MFMailComposeViewControllerDelegate {
    
    let driveService : GTLServiceDrive =  GTLServiceDrive()
    var driveFiles: Array<GTLDriveFile>?
    var fetcher: GTMHTTPFetcher?
    var hud: MBProgressHUD?
    var picker: UIImagePickerController? = UIImagePickerController()
    var popover: UIPopoverController? = nil
    var currentDojo: DojoData?
    var isNewDojo: Bool = false
    var googleDriveData: GoogleDriveDataViewController?
    var documentUploadTableViewCell: DocumentUploadTableViewCell?
    var filePath: String?
    var documentIndexPath: NSIndexPath?
    var count: Int = 0
    var fileManager = NSFileManager.defaultManager()
    var error : NSError?
    var moviePlayer: MPMoviePlayerController?
    var sendFileName: String?
    var sendFilePath: String?

    //let progressIndicatorView = CircularLoaderView(frame: CGRectZero)
    
    //TODO: Remove this variable once simultaneous download/upload is enabled
    var tableViewIndex: Int = -1

    var webapirequestObjectForDownload: WebApiRequest?
    var webapirequestObjectForDelete: WebApiRequest?
    
    @IBOutlet weak var uploadDataTableView: UITableView!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var galleryButton: UIButton!
    @IBOutlet weak var googleDriveButton: UIButton!
    @IBOutlet weak var doneButtonForDocumentsHide: UIButton!
    @IBOutlet weak var shareButon: UIButton!
    // sheldon 08/17 show Done for SHARED_CODE dojo, Next for dojo that needs invite
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var screenTitleLabel: UILabel!
    @IBOutlet weak var moviePlayerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filePath = AppData.sharedInstance.documentDirectory as String
        
        webapirequestObjectForDownload = WebApiRequest()
        webapirequestObjectForDownload!.tag = 1
        webapirequestObjectForDownload!.delegate = self
        
        webapirequestObjectForDelete = WebApiRequest()
        webapirequestObjectForDelete!.tag = 2
        webapirequestObjectForDelete!.delegate = self
        
        if (isNewDojo) {
            backButton.hidden = true
        }
        else {
            doneButton.hidden = true
        }
    
        if currentDojo!.fileDetails == nil {
            currentDojo!.fileDetails = []
        }
        
        if currentDojo!.archiveFiles == nil {
            currentDojo!.archiveFiles = []
        }
        
        if currentDojo!.status == "ENDED" {
            // sheldon 08/25 modify title and hide upload buttons for ended class
            screenTitleLabel.text = "My Class Archive"
            // hide upload buttons so user cannot upload more docs to classes that ended
            cameraButton.hidden = true
            galleryButton.hidden = true
            googleDriveButton.hidden = true
        }
    
        webapirequestObjectForDownload!.downloadDocuments(currentDojo!.id.toInt()!)
        self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        ArchiveUploadManager.sharedInstance.delegate = self
        FileUploadManager.sharedInstance.delegate = self
        DownloadManagerForFileDetail.sharedInstance.delegate = self
        DownloadManagerForArchiveFile.sharedInstance.delegate = self
    }
    
    override func viewWillDisappear(animated: Bool) {
        ArchiveUploadManager.sharedInstance.delegate = nil
        FileUploadManager.sharedInstance.delegate = nil
        DownloadManagerForFileDetail.sharedInstance.delegate = nil
        DownloadManagerForArchiveFile.sharedInstance.delegate = nil
    }

    @IBAction func logoButtonTouched(sender: UIButton) {
        AppData.sharedInstance.drawerController.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }
    
    @IBAction func pressBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func pressDone(sender: AnyObject) {
        webView.loadRequest(NSURLRequest(URL: NSURL(string: "about:blank")!))
        webView.hidden = true
        imageView.hidden = true
        moviePlayerView.hidden = true
        // sheldon: stop playing if the mp4 archive is playing
        if (moviePlayer != nil) {
            moviePlayer?.stop()
            moviePlayer?.view.removeFromSuperview()
        }
        doneButtonForDocumentsHide.hidden = true
        shareButon.hidden = true
    }
    
    @IBAction func pressShare(sender: AnyObject) {
        if(MFMailComposeViewController.canSendMail()) {
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            mailComposer.delegate = self
            
            //Set the subject and message of the email
            mailComposer.setSubject("AnyDojo document")
            mailComposer.setMessageBody("Please find attachment", isHTML: false)
            
            //Attach the file
            if let filePath = sendFilePath {
                println(filePath)
                println("File path loaded.")
                var mimetype: String?
                if let fileData = NSData(contentsOfFile: filePath) {
                    println("File data loaded.")
                    var pathextension = sendFileName!.pathExtension
                    if pathextension == "png" {
                        mimetype = "image/png"
                    }
                    else if pathextension == "jpg" {
                        mimetype = "image/jpg"
                    }
                    else if pathextension == "jpeg" {
                        mimetype = "image/jpeg"
                    }
                    else if pathextension == "pdf" {
                        mimetype = "application/pdf"
                    }
                    else if pathextension == "mp4" {
                        mimetype = "video/mp4"
                    }
                    mailComposer.addAttachmentData(fileData, mimeType: mimetype, fileName: sendFileName)
                }
            }
            else {
                var alert = UIAlertView(title: "",
                    message: "Your device cannot send emails.",
                    delegate: nil,
                    cancelButtonTitle: nil, otherButtonTitles: "OK")
                alert.show()
            }
            self.presentViewController(mailComposer, animated: true, completion: nil)
        }
    }
    
    //MARK- : MFMailComposeViewControllerDelegate
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        switch result.value {
            case MFMailComposeResultCancelled.value:
                NSLog("Cancelled")
                break
            case MFMailComposeResultSaved.value:
                NSLog("Saved")
                break
            case MFMailComposeResultSent.value:
                NSLog("Sent")
                var alert = UIAlertView(title: "",
                    message: AppConstants.MSG_Sendmail,
                    delegate: nil,
                    cancelButtonTitle: nil, otherButtonTitles: "OK")
                alert.show()
                break
            case MFMailComposeResultFailed.value:
                NSLog("Failed")
                var alert = UIAlertView(title: "",
                    message: AppConstants.MSG_FailedMail,
                    delegate: nil,
                    cancelButtonTitle: nil, otherButtonTitles: "OK")
                alert.show()
                break
            default:
                NSLog("Status Unknown")
                break
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func openCamere(sender: AnyObject) {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera))
        {
            picker!.allowsEditing = false
            picker!.delegate = self
            picker!.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(picker!, animated: true, completion: nil)
        }
        else
        {
            //no camera
            var alert: UIAlertView = UIAlertView()
            alert.title = "No Camera"
            alert.message = AppConstants.MSG_NoCamera
            alert.addButtonWithTitle("OK")
            alert.show()
        }
    }
    
    @IBAction func openGallery(sender: AnyObject) {
        picker!.allowsEditing = false
        picker!.sourceType = .PhotoLibrary
        picker!.delegate = self
        popover = UIPopoverController(contentViewController: picker!)
        popover?.presentPopoverFromRect(galleryButton.frame, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject])
    {
        let filedetail = ImagePickerUtils.imagePickerController(picker, popover: self.popover, info: info, currentDojo: self.currentDojo)
        
        if filedetail != nil {
            dispatch_async(dispatch_get_main_queue(), {
                self.uploadDataTableView.reloadData()
            })
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // save data locally and load FileDetail object
    func saveImageInDojoFolder(compressedImage: NSData, filePath: String, fileName: String) {
        
        var filedetail: FileDetail = FileDetail()
        filedetail.dojoId = currentDojo!.id.toInt()!
        filedetail.lastModified = NSDate()
        filedetail.fileSize = Float(compressedImage.length)
        
        if (compressedImage.writeToFile(((AppData.sharedInstance.documentDirectory) as String) + "\(filePath)/\(fileName)", atomically: true)) {
            filedetail.fileName = fileName
            filedetail.filePath = (filePath) + "/" + (fileName)
            // mark as to be uploaded
            filedetail.fileStatus = FileDetailStatus.ToBeUploaded.rawValue
            self.currentDojo!.fileDetails!.append(filedetail)
            self.tableViewIndex = self.currentDojo!.fileDetails!.count - 1
            let image = UIImage(data: compressedImage)

            //upload the image
            FileUploadManager.sharedInstance.documentUploadStart(filedetail)
            AppData.sharedInstance.classDocDic["\(currentDojo!.id)"] = self.currentDojo!.fileDetails
            AppData.sharedInstance.saveDocumentData()
        }
    }
    
    /*//create dictionary of fileDetails data
    func createDocuDirArray(filedetails: Array<FileDetail>) -> NSArray {
        var documentDataDict: NSMutableDictionary?
        var retval: NSMutableArray = NSMutableArray()
        for var i = 0; i < filedetails.count; i++ {
            documentDataDict = NSMutableDictionary()
            documentDataDict!.setValue(filedetails[i].dojoId, forKey: "dojoId")
            documentDataDict!.setValue(filedetails[i].fileName, forKey: "fileName")
            documentDataDict!.setValue(filedetails[i].lastModified, forKey: "lastModified")
            documentDataDict!.setValue(filedetails[i].fileSize, forKey: "fileSize")
            documentDataDict!.setValue(filedetails[i].filePath, forKey: "filePath")
            documentDataDict!.setValue(filedetails[i].fileStatus, forKey: "fileStatus")
            documentDataDict!.setValue(filedetails[i].serverId, forKey: "serverId")
            retval.addObject(documentDataDict!)
        }
        
        return retval
    }*/
    
    //MARK:- tableViewDelegate methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            if currentDojo!.fileDetails!.count > 0 {
                return currentDojo!.fileDetails!.count
            }
        }
        else if section == 1 {
            if currentDojo?.archiveFiles?.count > 0 {
                return currentDojo!.archiveFiles!.count
            }
        }
        return 0
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0 {
            return "My Uploads (\(self.currentDojo!.fileDetails!.count))"
        }
        else {
            return "Archives (\(self.currentDojo!.archiveFiles!.count))"
        }
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.textLabel.textAlignment = NSTextAlignment.Center
        header.textLabel.text = self.tableView(tableView, titleForHeaderInSection:section) // need this to avoid all caps in title
        header.textLabel.font = UIFont.systemFontOfSize(16)
        
        if section == 1 {
            header.contentView.backgroundColor = UIColor(red: 237/255, green: 231/255, blue: 246/255, alpha: 1)
            header.textLabel.textColor = UIColor(red: 103/255, green: 58/255, blue: 173/255, alpha: 1)
        } else if section == 0 {
            header.contentView.backgroundColor = UIColor(red: 252/255, green: 228/255, blue: 236/255, alpha: 1)
            header.textLabel.textColor = UIColor(red: 233/255, green: 30/255, blue: 99/255, alpha: 1)
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = uploadDataTableView.dequeueReusableCellWithIdentifier("Cell",forIndexPath: indexPath) as! DocumentUploadTableViewCell

        if indexPath.section == 0 {
            currentDojo!.fileDetails![indexPath.row].tableViewIndex = indexPath.row
            
            cell.fileNameLabel.text = currentDojo!.fileDetails![indexPath.row].fileName
            // sheldon 08/15 switch from the default icon to new pdf icon for pdf file
            let filePath = currentDojo!.fileDetails![indexPath.row].filePath
            if (filePath != nil && filePath!.lowercaseString.rangeOfString(".pdf") != nil && filePath!.lowercaseString.rangeOfString(".pdf", options:NSStringCompareOptions.BackwardsSearch)!.endIndex == filePath!.endIndex) {
                cell.fileIconImageView.image = UIImage(named: "icon_document_pdf")
            }
            else {
                cell.fileIconImageView.image = UIImage(named: "icon_document_image")
            }
            
            var strDate = AppData.sharedInstance.formatterWSDatetime.stringFromDate(currentDojo!.fileDetails![indexPath.row].lastModified!)
            
            cell.lastModifiedLabel.text = strDate
            if currentDojo!.fileDetails![indexPath.row].fileSize >= 1048576 {
                cell.fileSizeLabel.text = String(format: "%.2f MB", arguments: [(((currentDojo!.fileDetails![indexPath.row].fileSize)! / 1024.0) / 1024.0)])
            }
            else {
                cell.fileSizeLabel.text = String(format: "%.2f KB", arguments: [((currentDojo!.fileDetails![indexPath.row].fileSize)! / 1024.0)])
            }
            
            cell.fileStatusLabel.text = currentDojo!.fileDetails![indexPath.row].fileStatus

            /*//Re-upload fileDetail that fileStatusLabel is "Uploading Failed" and "ToBeUploaded"
            if cell.fileStatusLabel.text == FileDetailStatus.UploadFailed.rawValue || cell.fileStatusLabel.text == FileDetailStatus.ToBeUploaded.rawValue {
                //Reupload that document that fileStatusLabel is "Uploading Failed"
                FileUploadManager.sharedInstance.documentUploadStart(currentDojo!.fileDetails![indexPath.row])
            }*/
        }
        
        else if indexPath.section == 1 {
            currentDojo!.archiveFiles![indexPath.row].tableViewIndex = indexPath.row
            
            cell.fileNameLabel.text = currentDojo!.archiveFiles![indexPath.row].fileName
            if currentDojo!.archiveFiles![indexPath.row].fileType == "ARCHIVED_VIDEO" {
                cell.fileIconImageView.image = UIImage(named: "icon_document_video")
            } else {
                cell.fileIconImageView.image = UIImage(named: "icon_document_pdf")
            }
            var strDate = AppData.sharedInstance.formatterWSDatetime.stringFromDate(currentDojo!.archiveFiles![indexPath.row].lastModified!)
            
            cell.lastModifiedLabel.text = strDate
            if currentDojo!.archiveFiles![indexPath.row].fileSize >= 1048576 {
                cell.fileSizeLabel.text = String(format: "%.2f MB", arguments: [(((currentDojo!.archiveFiles![indexPath.row].fileSize)! / 1024.0) / 1024.0)])
            }
            else {
                cell.fileSizeLabel.text = String(format: "%.2f KB", arguments: [((currentDojo!.archiveFiles![indexPath.row].fileSize)! / 1024.0)])
            }

            cell.fileStatusLabel.text = currentDojo!.archiveFiles![indexPath.row].fileStatus
            
            /*//Re-upload archive that fileStatusLabel is "Uploading Failed", "ToBeUploaded"
            if cell.fileStatusLabel.text == ArchiveStatus.UploadingFailed.rawValue || cell.fileStatusLabel.text == ArchiveStatus.ToBeUploaded.rawValue {
                cell.fileStatusLabel.text = ArchiveStatus.Uploading.rawValue
                ArchiveUploadManager.sharedInstance.startUploading(currentDojo!.archiveFiles![indexPath.row])
            } */
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var url : NSURL!
        
        // sheldon: Make "Done" button in webView or imageView always visible, instead of showing up after a tap
        if indexPath.section == 0 {
            if currentDojo!.fileDetails![indexPath.row].fileStatus == FileDetailStatus.Synced.rawValue || currentDojo!.fileDetails![indexPath.row].fileStatus == FileDetailStatus.Uploading.rawValue || currentDojo!.fileDetails![indexPath.row].fileStatus == FileDetailStatus.ToBeUploaded.rawValue {
                var filePathForDocuments = ((AppData.sharedInstance.documentDirectory) as String) + "/LocalAssets/Dojo/\(self.currentDojo!.id)/UserFiles/" + currentDojo!.fileDetails![indexPath.row].fileName!
                
                url = NSURL(fileURLWithPath: filePathForDocuments)
                
                var filePath = currentDojo!.fileDetails![indexPath.row].filePath
                
                sendFileName = currentDojo!.fileDetails![indexPath.row].fileName
                sendFilePath = filePathForDocuments
                
                if (filePath != nil && filePath!.lowercaseString.rangeOfString(".pdf") != nil && filePath!.lowercaseString.rangeOfString(".pdf", options:NSStringCompareOptions.BackwardsSearch)!.endIndex == filePath!.endIndex)
                {
                    webView.delegate = self
                    webView.loadRequest(NSURLRequest(URL: url))
                    webView.hidden = false
                    doneButtonForDocumentsHide.hidden = false
                    shareButon.hidden = false
                }
                else {
                    imageView.hidden = false
                    imageView.image = UIImage(data: NSData(contentsOfFile: filePathForDocuments)!, scale: UIScreen.mainScreen().scale)
                    doneButtonForDocumentsHide.hidden = false
                    shareButon.hidden = false
                }
            }
            else {
                var alert = UIAlertView(title: "",
                    message: AppConstants.MSG_StillFileIsDownloading,
                    delegate: nil,
                    cancelButtonTitle: nil, otherButtonTitles: "OK")
                alert.show()
            }
        }
        else if indexPath.section == 1 {
            if currentDojo!.archiveFiles![indexPath.row].fileStatus == ArchiveStatus.Synced.rawValue || currentDojo!.archiveFiles![indexPath.row].fileStatus == ArchiveStatus.Uploading.rawValue || currentDojo!.archiveFiles![indexPath.row].fileStatus == ArchiveStatus.ToBeUploaded.rawValue {
                if currentDojo!.archiveFiles![indexPath.row].fileName!.pathExtension == "mp4" {
                    self.moviePlayerView.hidden = false
                    let filePathForArchiveVideo = ((AppData.sharedInstance.documentDirectory) as String) + "/LocalAssets/Dojo/\(self.currentDojo!.id)/Archives/" + currentDojo!.archiveFiles![indexPath.row].fileName!
                    
                    sendFileName = currentDojo!.archiveFiles![indexPath.row].fileName
                    sendFilePath = filePathForArchiveVideo
                    
                    let url = NSURL.fileURLWithPath(filePathForArchiveVideo)
                    self.moviePlayer = MPMoviePlayerController(contentURL: url)
                    self.moviePlayer!.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - 20) // sheldon: -20 to leave room for status bar
                    self.moviePlayer!.initialPlaybackTime = 2.0
                    self.moviePlayerView.addSubview(moviePlayer!.view)
                    self.moviePlayer!.fullscreen = false
                    self.moviePlayer!.controlStyle = .Embedded
                }
                else {
                    var filePathForArchiveDocument = ((AppData.sharedInstance.documentDirectory) as String) + "/LocalAssets/Dojo/\(self.currentDojo!.id)/Archives/" + currentDojo!.archiveFiles![indexPath.row].fileName!
                    
                    sendFileName = currentDojo!.archiveFiles![indexPath.row].fileName
                    sendFilePath = filePathForArchiveDocument
                    
                    url = NSURL(fileURLWithPath: filePathForArchiveDocument)
                    webView.delegate = self
                    webView.loadRequest(NSURLRequest(URL: url))
                    webView.hidden = false
                }
            }
            else {
                var alert = UIAlertView(title: "",
                    message: AppConstants.MSG_StillFileIsDownloading,
                    delegate: nil,
                    cancelButtonTitle: nil, otherButtonTitles: "OK")
                alert.show()
            }
            
            doneButtonForDocumentsHide.hidden = false
            shareButon.hidden = false
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 {
            fileManager.removeItemAtPath((AppData.sharedInstance.documentDirectory as String) + currentDojo!.fileDetails![indexPath.row].filePath!, error: nil)
            
            var fileDetailToBeDeleted = currentDojo!.fileDetails!.removeAtIndex(indexPath.row) as? FileDetail
            
            AppData.sharedInstance.classDocDic["\(currentDojo!.id)"] = self.currentDojo!.fileDetails
            AppData.sharedInstance.saveDocumentData()
            
            self.uploadDataTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            
            if (fileDetailToBeDeleted != nil && fileDetailToBeDeleted!.serverId != nil) {
                webapirequestObjectForDelete!.deleteDocument(self.currentDojo!.id.toInt()!, authCode: AppData.sharedInstance.userdata!.authCode!, id: fileDetailToBeDeleted!.serverId!.integerValue)
            }
        }
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        
        if indexPath.section == 1 {
            return UITableViewCellEditingStyle.None
        }
        else {
            return UITableViewCellEditingStyle.Delete
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        (segue.destinationViewController as! SendInvitaionsViewController).currentDojo = currentDojo
    }

    //integrateGoogleDrive
    @IBAction func intigrateGoogleDrive(sender: AnyObject) {
        var googleDriveDataController = self.storyboard?.instantiateViewControllerWithIdentifier("GoogleDriveDataController") as! GoogleDriveDataViewController
        
        googleDriveDataController.documentUploadViewController = self
        
        var googleDriveDataNavigationController = UINavigationController(rootViewController: googleDriveDataController)
        
        googleDriveDataNavigationController.modalPresentationStyle = UIModalPresentationStyle.PageSheet
        self.presentViewController(googleDriveDataNavigationController, animated: true, completion: nil)
    }
    
    //Download the file form googleDrive
    func downloadFileContentWithService(service: GTLServiceDrive, filedetail: FileDetail, completionBlock: (NSData!, NSError!) -> Void) {
        
        fetcher = driveService.fetcherService.fetcherWithURLString(filedetail.googleDriveFileDetail!.downloadUrl)
        filedetail.fileStatus = FileDetailStatus.Downloading.rawValue
        AppData.sharedInstance.classDocDic["\(filedetail.dojoId)"] = self.currentDojo!.fileDetails
        AppData.sharedInstance.saveDocumentData()
        self.uploadDataTableView.reloadData()
        
        fetcher?.beginFetchWithCompletionHandler( {(data: NSData!, error: NSError!) -> Void in
            if error == nil {
                
                //create a dir
                self.filePath = ((AppData.sharedInstance.documentDirectory) as String) + "/LocalAssets/Dojo/\(self.currentDojo!.id)/UserFiles/"
                
                if !self.fileManager.createDirectoryAtPath(self.filePath!,
                    withIntermediateDirectories: true,
                    attributes: nil,
                    error: &self.error) {
                        println("Failed to create dir: \(self.error!.localizedDescription)")
                }
                
                //Success
                var string: String = "/LocalAssets/Dojo/\(self.currentDojo!.id)/UserFiles"
                data.writeToFile(self.filePath! + filedetail.googleDriveFileDetail!.originalFilename, atomically: true)
                
                filedetail.filePath = string + "/" + filedetail.googleDriveFileDetail!.originalFilename
                //filedetail.fileStatus = FileDetailStatus.ToBeUploaded.rawValue
                
                completionBlock(data, nil)
                dispatch_async(dispatch_get_main_queue(), {
                    self.uploadDataTableView.reloadData()
                })
                // sheldon 09/07 just need to mark as to be uploaded, don't have to do it now
                FileUploadManager.sharedInstance.documentUploadStart(filedetail)
            }
            else {
                //Error occure
                //filedetail.fileStatus = AppData.sharedInstance._downloadFailFileDetailStatus.rawValue
                filedetail.fileStatus = FileDetailStatus.DownloadFailed.rawValue
                completionBlock(nil, error)
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // sheldon 07/18
    func processResponse(responseObj: AnyObject, tag: Int) {
        var returnCode: Int = (responseObj.valueForKey("returnCode") as! NSNumber).integerValue
        var returnMessage: String = (responseObj.valueForKey("returnMessage") as! String)
        if returnCode == 0 {
            if tag == 1 {
                if responseObj.valueForKey("documents") != nil {
                    AppData.sharedInstance.populateDojoFileDetailFromJSONArray(responseObj.valueForKey("documents") as! Array<Dictionary<String, AnyObject>>, dojo: self.currentDojo!)
                    
                    dispatch_sync(dispatch_get_main_queue(), {
                        self.uploadDataTableView.reloadData()
                        self.hud!.hide(true)
                    })
                }
            }
            else if tag == 2 {
                //TODO: delete document webservice
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), {
                self.hud!.hide(true)
                if (tag == 1) {
                    var alert = UIAlertView(title: "",
                        message: AppConstants.MSG_FailedDownloadDocument,
                        delegate: nil,
                        cancelButtonTitle: nil, otherButtonTitles: "OK")
                    alert.show()
                }
                else if tag == 2 {
                    var alert = UIAlertView(title: "",
                        message: AppConstants.MSG_FailedDeleteDocument,
                        delegate: nil,
                        cancelButtonTitle: nil, otherButtonTitles: "OK")
                    alert.show()
                }
            })
        }
    }
    
    func processError(error: NSError, tag: Int) -> Void {
        dispatch_async(dispatch_get_main_queue(), {
            self.hud!.hide(true)
            if (tag == 1) {
                var alert = UIAlertView(title: "",
                    message: AppConstants.MSG_FailedDownloadDocument,
                    delegate: nil,
                    cancelButtonTitle: nil, otherButtonTitles: "OK")
                alert.show()
            }
            else if tag == 2 {
                var alert = UIAlertView(title: "",
                    message: AppConstants.MSG_FailedDeleteDocument,
                    delegate: nil,
                    cancelButtonTitle: nil, otherButtonTitles: "OK")
                alert.show()
            }
        })
    }
    
    // sheldon 08/17 go back to class list
    @IBAction func btnDonePressed(sender: AnyObject) {
        if (self.navigationController!.viewControllers[0].isKindOfClass(ClassesViewController)) {
            // make sure when it is popped, the data is refreshed
            (self.navigationController?.viewControllers[0] as! ClassesViewController).refresh = true
        }
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    //MARK: - ArchiveUploadManagerDelegate
    func uploadFinished(file: ArchiveFile) {
        //code to change status of cell corresponding to archivefile cell to Uploaded
        if self.currentDojo!.id.toInt() == file.dojoId {
            for i in 0..<currentDojo!.archiveFiles!.count {
                if currentDojo!.archiveFiles![i].fileName == file.fileName {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.uploadDataTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: i, inSection: 1)], withRowAnimation: UITableViewRowAnimation.Fade)
                    })
                }
            }
        }

        //telenextsystems 11/16
        //No need to update stored status from here because it gets updated from ArchiveUploadManager.processResponse.
        //If there is any issue pls report it
        
//        AppData.sharedInstance.classArchiveDic["\(file.dojoId)"] = self.currentDojo!.archiveFiles!
//        AppData.sharedInstance.saveArchiveData()
    }
    
    func uploadFailed(file: ArchiveFile) {
        //code to change status of cell corresponding to archivefile cell to Uploading Failed
        if self.currentDojo!.id.toInt() == file.dojoId {
            for i in 0..<currentDojo!.archiveFiles!.count {
                if currentDojo!.archiveFiles![i].fileName == file.fileName {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.uploadDataTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: i, inSection: 1)], withRowAnimation: UITableViewRowAnimation.Fade)
                    })
                }
            }
        }
    }
    
    //MARK: - FileUploadManagerDelegate
    func documentUploadFinished(file: FileDetail) {
        //code to change status of cell corresponding to archivefile cell to Uploaded
        if self.currentDojo!.id.toInt() == file.dojoId {
            for i in 0..<currentDojo!.fileDetails!.count {
                if currentDojo!.fileDetails![i].fileName == file.fileName {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.uploadDataTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: i, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
                    })
                }
            }
        }
        
        //telenextsystems 11/16
        //No need to update stored status from here because it gets updated from DocumentUploadManager.processResponse.
        //If there is any issue pls report it
        
        // sheldon: update stored fileDetails becauser serverId has been updated
//        AppData.sharedInstance.classDocDic["\(currentDojo!.id)"] = self.currentDojo!.fileDetails
//        AppData.sharedInstance.saveDocumentData()
    }
    
    func documentUploadFailed(file: FileDetail) {
        //code to change status of cell corresponding to archivefile cell to Uploading Failed
        if self.currentDojo!.id.toInt() == file.dojoId {
            for i in 0..<currentDojo!.fileDetails!.count {
                if currentDojo!.fileDetails![i].fileName == file.fileName {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.uploadDataTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: i, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
                    })
                }
            }
        }
    }
    
    //MARK: - DownloadManagerForFileDetailDelegate
    func downloadFileFinished(file: FileDetail) {
        file.fileStatus = FileDetailStatus.Synced.rawValue
        AppData.sharedInstance.classDocDic["\(self.currentDojo!.id)"] = self.currentDojo!.fileDetails
        AppData.sharedInstance.saveDocumentData()
        dispatch_sync(dispatch_get_main_queue(), {
            self.uploadDataTableView.reloadData()
        })
    }
    
    func downloadFileFailed(file: FileDetail) {
        file.fileStatus = FileDetailStatus.DownloadFailed.rawValue
        AppData.sharedInstance.classDocDic["\(self.currentDojo!.id)"] = self.currentDojo!.fileDetails
        AppData.sharedInstance.saveDocumentData()
        dispatch_sync(dispatch_get_main_queue(), {
            self.uploadDataTableView.reloadData()
        })
    }
    
    //MARK: - DownloadManagerForArchiveFileDelegate
    func downloadArchiveFinished(file: ArchiveFile) {
        file.fileStatus = ArchiveStatus.Synced.rawValue
        AppData.sharedInstance.classArchiveDic["\(self.currentDojo!.id)"] = self.currentDojo!.archiveFiles
        AppData.sharedInstance.saveArchiveData()
        dispatch_sync(dispatch_get_main_queue(), {
            self.uploadDataTableView.reloadData()
        })
    }
    
    func downloadArchiveFailed(file: ArchiveFile) {
        file.fileStatus = ArchiveStatus.DownloadFailed.rawValue
        AppData.sharedInstance.classArchiveDic["\(self.currentDojo!.id)"] = self.currentDojo!.archiveFiles
        AppData.sharedInstance.saveArchiveData()
        dispatch_sync(dispatch_get_main_queue(), {
            self.uploadDataTableView.reloadData()
        })
    }
}