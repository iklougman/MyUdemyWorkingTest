//
//  SignUpViewController.swift
//  MyUdemySQLProject
//
//  Created by Igor on 12.01.16.
//  Copyright © 2016 com.igor. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    @IBOutlet weak var userPasswordRepeatTextField: UITextField!
    @IBOutlet weak var userFirstNameTextField: UITextField!
    @IBOutlet weak var userLastNameTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    @IBOutlet weak var signUpButtonTapped: UIButton!
    
    @IBAction func signUpButtonTapped(sender: AnyObject) {
        let userEmailAddress = userEmailTextField.text
        let userPassword = userPasswordTextField.text
        let userPasswordRepeat = userPasswordRepeatTextField.text
        let userFirstName = userFirstNameTextField.text
        let userLastName = userLastNameTextField.text
        
        if(userPassword != userPasswordRepeat){
            displayAlertMessage("Password do not match")
            return
        }
        
        //check if every single field is empty
        if(userEmailAddress!.isEmpty || userPassword!.isEmpty || userFirstName!.isEmpty || userLastName!.isEmpty){
            //display alert message
            displayAlertMessage("All field are required to fill in")
            return
        }
        
        //create HUD stats bar
        
        let spinningActivity = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        spinningActivity.labelText = "Loading"
        spinningActivity.detailsLabelText = "Please wait"
        
        // ******* sent HTTP POST to server *******
        
        let myUrl = NSURL(string: "http://magento.cologne/SwiftAppAndMySQL/scripts/registerUser.php");
        let request = NSMutableURLRequest(URL:myUrl!);
        request.HTTPMethod = "POST";
        
        // pass user credentials
        
        let postString = "userEmail=\(userEmailAddress!)&userFirstName=\(userFirstName!)&userLastName=\(userLastName!)&userPassword=\(userPassword!)"
        
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding);
        
        //get session to send HTTP
        
        NSURLSession.sharedSession().dataTaskWithRequest(request,
            completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                
                
                dispatch_async(dispatch_get_main_queue()){
                    
                        spinningActivity.hide(true)
                    
                    if error != nil {
                        self.displayAlertMessage(error!.localizedDescription)
                        return
                    }
                    
                    var err: NSError?
                    let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) as? NSDictionary
                    if let parseJSON = json {
                        var userId = parseJSON["userId"] as? String
                        
                        if (userId != nil){
                            
                            var myAlert = UIAlertController(title: "Alert", message: "Registration successful", preferredStyle: UIAlertControllerStyle.Alert);
                            
                            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default){(action) in
                                self.dismissViewControllerAnimated(true, completion: nil)
                                
                            }
                            myAlert.addAction(okAction);
                            self.presentViewController(myAlert, animated: true, completion: nil)
                            
                        } else {
                            let errorMessage = parseJSON["message"] as? String
                            if (errorMessage != nil) {
                                self.displayAlertMessage(errorMessage!)
                            }
                        }
                    }
                }
        }).resume()
        
    }
    
    func displayAlertMessage(userMessage:String){
        var myAlert = UIAlertController(title: "Alert", message:
            userMessage, preferredStyle: UIAlertControllerStyle.Alert);
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        myAlert.addAction(okAction);
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
