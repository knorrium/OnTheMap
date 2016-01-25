//
//  ViewController.swift
//  OnTheMap
//
//  Created by Felipe Kuhn on 12/19/15.
//  Copyright © 2015 Knorrium. All rights reserved.
//

import UIKit

import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit

class ViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    var udacityLogin: UdacityLogin?

    
    @IBOutlet weak var txtLogin: UITextField!
    @IBOutlet weak var txtPassword: UITextField!

    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func loginButtonAction(sender: UIButton) {
        
        if ((txtLogin.text!.isEmpty || txtPassword.text!.isEmpty)) {
            let alertController = UIAlertController(title: "On The Map", message:
                "Please fill both the username and password fields.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
            return
        } else {
            print("WILL LOG IN")
//            UdacityLogin.sharedInstance.login(txtLogin.text!, password: txtPassword.text!)
//            UdacityLogin.sharedInstance.login(txtLogin.text!, password: txtPassword.text!)(username, password: password) { (success, errorMessage) in
            UdacityLogin.sharedInstance.login(txtLogin.text!, password: txtPassword.text!) {
                (success, errorMessage) in
//                self.setFormState(false, errorMessage: errorMessage)
                if success {
                    print("Success")
                    dispatch_async(dispatch_get_main_queue(), {
                        self.performSegueWithIdentifier("mainView", sender: sender)
                    })
                } else {
                    print("Failure")
                    let alertController = UIAlertController(title: "On The Map", message:
                        "\(errorMessage!)", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }

                }
            }

            
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "mainView" {
            if let destinationVC = segue.destinationViewController as? MainTabViewController{

            }
        }
    }
    
    @IBOutlet weak var signupLink: UIButton!
    @IBAction func signupLinkAction(sender: UIButton) {
        let url : NSURL
        url = NSURL(string: "https://www.udacity.com/account/auth#!/signin")!
        UIApplication.sharedApplication().openURL(url)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        addGradient()
        udacityLogin = UdacityLogin.sharedInstance
        let loginButton = FBSDKLoginButton()
//        loginButton.readPermissions = ["public_profile", "email", "user_friends",]
        loginButton.delegate = self
        loginButton.center = self.view.center;
        loginButton.frame.origin.y = signupLink.frame.origin.y + signupLink.frame.height + 20;
        self.view.addSubview(loginButton);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func addGradient(){
        // Source: http://stackoverflow.com/questions/24380535/how-to-apply-gradient-to-background-view-of-ios-swift-app
        
        let gradient:CAGradientLayer = CAGradientLayer()
        gradient.frame.size = self.view.frame.size
        gradient.colors = [UIColor.orangeColor().colorWithAlphaComponent(0.5).CGColor,UIColor.orangeColor().CGColor] //Or any colors
        self.view.layer.insertSublayer(gradient, atIndex: 0)
        
    }

    
    // Facebook delegate methods
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("Coming back from Facebook signin")
        print("Error: \(error)")
        print("result: \(result) isCancelled: \(result.isCancelled) token: \(result.token)")
        print("declinedPermissions: \(result.declinedPermissions) grantedPermissions: \(result.grantedPermissions)")
        
        if ((error) != nil)
        {
            print(error.description);
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email")
            {
                // Do work
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    
    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                print("fetched user: \(result)")
                let userName : NSString = result.valueForKey("name") as! NSString
                print("User Name is: \(userName)")
                let userEmail : NSString = result.valueForKey("email") as! NSString
                print("User Email is: \(userEmail)")
            }
        })
    }
    
}

