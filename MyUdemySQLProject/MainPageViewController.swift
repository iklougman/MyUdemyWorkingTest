//
//  MainPageViewController.swift
//  MyUdemySQLProject
//
//  Created by Igor on 15.01.16.
//  Copyright © 2016 com.igor. All rights reserved.
//

import UIKit

class MainPageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var userFullNameLabel: UILabel!
    @IBOutlet weak var profilePhotoImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // Do any additional setup after loading the view.
        
        let userFirstName = NSUserDefaults.standardUserDefaults().stringForKey("userFirstName")
        let userLastName = NSUserDefaults.standardUserDefaults().stringForKey("userLastName")
        var userFullName = userFirstName! + " " + userLastName!
        userFullNameLabel.text = userFullName
        
        if(profilePhotoImageView.image == nil){
        
            let userId = NSUserDefaults.standardUserDefaults().stringForKey("userId")
            let imageUrl = NSURL(string: "http://magento.cologne/SwiftAppAndMySQL/profile-pictures/\(userId!)/user-profile.jpg")
            //asynchronous image loading
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                
                let imageData = NSData(contentsOfURL: imageUrl!)
                
                if(imageData != nil){
                    dispatch_async(dispatch_get_main_queue(),{
                        self.profilePhotoImageView.image = UIImage(data: imageData!)
                    })
                }
                
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func selectProfilePhotoButtonTapped(sender: AnyObject) {
        var myImagePicker = UIImagePickerController()
        myImagePicker.delegate = self
        myImagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        self.presentViewController(myImagePicker, animated: true, completion: nil)
        
    }
    
    //function form UIImagePickerControllerDelegate
    // image is set
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
        profilePhotoImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.dismissViewControllerAnimated(true, completion: nil)
        //spinning HUD
        
        let spinningActivity = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        spinningActivity.labelText = "Loading"
        spinningActivity.detailsLabelText = "Please wait"

        
        myImageUploadRequest()
    }
    
    func myImageUploadRequest(){
        let myUrl = NSURL(string: "http://magento.cologne/SwiftAppAndMySQL/scripts/imageUpload.php")
        let request = NSMutableURLRequest(URL:myUrl!);
        request.HTTPMethod = "POST";
        //use this place to pass information to the image
        let userId:String? = NSUserDefaults.standardUserDefaults().stringForKey("userId")
        let param = ["userId" : userId!]
        let boundary = generateBoundaryString()
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let imageData = UIImageJPEGRepresentation(profilePhotoImageView.image!, 1)
        
        if(imageData==nil) {return}
        
        request.HTTPBody = createBodyWithParameters(param, filePathKey: "file", imageDataKey: imageData!, boundary: boundary)
        
        NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            
            dispatch_async(dispatch_get_main_queue()){
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            }
            
            if error != nil {
                // Display an alert message
                return
            }
            
            do {
                
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as? NSDictionary
                
                dispatch_async(dispatch_get_main_queue())
                    {
                        
                        if let parseJSON = json {
                            // let userId = parseJSON["userId"] as? String
                            // Display an alert message
                            let userMessage = parseJSON["message"] as? String
                            self.displayAlertMessage(userMessage!)
                        } else {
                            // Display an alert message
                            let userMessage = "Could not upload image at this time"
                            self.displayAlertMessage(userMessage)
                        }
                }
            } catch {
                print(error)
            }
            
        }).resume()
        
    }
    
    @IBAction func signOutButtonTapped(sender: AnyObject) {
        
        NSUserDefaults.standardUserDefaults().removeObjectForKey("userFirstName")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("userLastName")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("userId")
        NSUserDefaults.standardUserDefaults().synchronize()
        let signInPage = self.storyboard?.instantiateViewControllerWithIdentifier("ViewController") as! ViewController
        let signInNav = UINavigationController(rootViewController: signInPage)
        
        let appDelegate = UIApplication.sharedApplication().delegate
        appDelegate?.window??.rootViewController = signInNav
    }
    // create body message -> mutable data -> will be set as http request
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData {
        let body = NSMutableData();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        
        let filename = "user-profile.jpg"
        
        let mimetype = "image/jpg"
        
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        body.appendData(imageDataKey)
        body.appendString("\r\n")
        
        
        
        body.appendString("--\(boundary)--\r\n")
        
        return body
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().UUIDString)"
    }
    
    func displayAlertMessage(userMessage:String){
        var myAlert = UIAlertController(title: "Alert", message:
            userMessage, preferredStyle: UIAlertControllerStyle.Alert);
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        myAlert.addAction(okAction);
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
}

extension NSMutableData {
    
    func appendString(string: String) {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        appendData(data!)
    }
}
