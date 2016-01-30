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
    var fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
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
            UdacityLogin.sharedInstance.login(txtLogin.text!, password: txtPassword.text!) {
                (success, errorMessage) in
                if success {
                    print("Success")
                    self.showMapViewController()
                } else {
                    print("Failure")
                    let alertController = UIAlertController(title: "On The Map", message:
                        "\(errorMessage!)", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                    dispatch_async(dispatch_get_main_queue(), {
                        self.presentViewController(alertController, animated: true, completion: nil)
                    })
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
        loginButton.readPermissions = ["public_profile", "email", "user_friends",]
        loginButton.delegate = self
        loginButton.center = self.view.center;
        loginButton.frame.origin.y = signupLink.frame.origin.y + signupLink.frame.height + 20;
        self.view.addSubview(loginButton);

        fbLoginManager.loginBehavior = FBSDKLoginBehavior.SystemAccount
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
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
            print("[FACEBOOK] - Error")
            print(error.description);
        }
        else if result.isCancelled {
            print("[FACEBOOK] - Cancelled")
        }
        else {
            print("[FACEBOOK] - Else")
            print("[FACEBOOK] - Else/Result " + result.description)
            if result.grantedPermissions.contains("email") {
                getFBUserData()
                print("[FACEBOOK] - Else/Token: " + FBSDKAccessToken.currentAccessToken().tokenString)
                UdacityLogin.sharedInstance.loginWithFacebook(FBSDKAccessToken.currentAccessToken().tokenString) {
                    (success, errorMessage) in
                    if (success) {
                        print("[FACEBOOK] - Successful Login")
                        self.showMapViewController()
                    } else {
                        print("[FACEBOOK] - Error during login")
                        let alertController = UIAlertController(title: "On The Map", message:
                            "\(errorMessage!)", preferredStyle: UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                        dispatch_async(dispatch_get_main_queue(), {
                            self.presentViewController(alertController, animated: true, completion: nil)
                        })

                    }
                }
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    
    func showMapViewController() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let viewController:UIViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MainTabView") as! MainTabViewController
            self.presentViewController(viewController, animated: true, completion: nil)
        })
    }
    
    func getFBUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            if ((error) != nil)
            {
                print("Error: \(error)")
            }
            else
            {
                print("fetched user: \(result)")
                
                let userName : NSString = result.valueForKey("name") as! NSString
                let uniqueKey : String = result.valueForKey("id") as! String
                self.appDelegate.loggedUser.uniqueKey = uniqueKey
                print(self.appDelegate.loggedUser)
                print("User Name is: \(userName)")
            }
        })
    }
    
}

