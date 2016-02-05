//
//  ViewController.swift
//  MyUdemySQLProject
//
//  Created by Igor on 10.01.16.
//  Copyright © 2016 com.igor. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var userEmailAddressTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signInButtonTapped(sender: AnyObject) {
        
        let userEmailAddress = userEmailAddressTextField.text
        let userPassword = userPasswordTextField.text
        
        if(userEmailAddress!.isEmpty || userPassword!.isEmpty){
            //display an alert message
            var myAlert = UIAlertController(title: "Alert", message: "All fields are required to fill in", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            myAlert.addAction(okAction)
            self.presentViewController(myAlert, animated: true, completion: nil)
            return
        }
        //use HTTPS on production machine
        let myUrl = NSURL(string: "http://magento.cologne/SwiftAppAndMySQL/scripts/userSignIn.php");
        let request = NSMutableURLRequest(URL:myUrl!);
        request.HTTPMethod = "POST";
        
        // pass user credentials
        
        let postString = "userEmail=\(userEmailAddress!)&userPassword=\(userPassword!)"
        
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding);
        
        NSURLSession.sharedSession().dataTaskWithRequest(request,
            completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                
                
                dispatch_async(dispatch_get_main_queue()){
                    
                    if error != nil {
                        //display an alert message
                        var myAlert = UIAlertController(title: "Alert", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                        myAlert.addAction(okAction)
                        self.presentViewController(myAlert, animated: true, completion: nil)
                        return
                    }
                    
                    var err: NSError?
                    let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) as? NSDictionary
                    
                    if let parseJSON = json {
                        var userId = parseJSON["userId"] as? String
                        
                        if (userId != nil){
                        //do not store sensible information *** for sensible generate key chain
                        NSUserDefaults.standardUserDefaults().setObject(parseJSON["userFirstName"], forKey: "userFirstName")
                        NSUserDefaults.standardUserDefaults().setObject(parseJSON["userLastName"], forKey: "userLastName")
                        NSUserDefaults.standardUserDefaults().setObject(parseJSON["userId"], forKey: "userId")
                        NSUserDefaults.standardUserDefaults().synchronize()
                            //go to the login area
                            let mainPage = self.storyboard?.instantiateViewControllerWithIdentifier("MainPageViewController")
                                as! MainPageViewController
                            let mainPageNav = UINavigationController(rootViewController: mainPage)
                            let appDelegate = UIApplication.sharedApplication().delegate
                            appDelegate?.window??.rootViewController = mainPageNav
                            
                            
                        } else {
                            let userMessage = parseJSON["message"] as? String
                            //display an alert message
                            var myAlert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.Alert)
                            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                            myAlert.addAction(okAction)
                            self.presentViewController(myAlert, animated: true, completion: nil)
                            return
                        }
                    }
                }
        }).resume()
        
        
        
    }
    
}

