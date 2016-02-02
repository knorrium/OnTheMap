//
//  UdacityLogin.swift
//  OnTheMap
//
//  Created by Felipe Kuhn on 1/9/16.
//  Copyright © 2016 Knorrium. All rights reserved.
//

import Foundation
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class UdacityLogin: NSObject {

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    static let sharedInstance = UdacityLogin()
    
    var session: NSURLSession
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }

    func login(username: NSString, password: NSString, completionHandler: (success: Bool, errorMessage: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            if error != nil {
                if error?.domain == NSURLErrorDomain && error?.code == NSURLErrorNotConnectedToInternet {
                    completionHandler(success: false, errorMessage: "The Internet connection appears to be offline." )
                } else {
                    completionHandler(success: false, errorMessage: "An unknown error occured")
                }
            } else {
                let parsedResult: AnyObject!
                do {
                    let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
                    if (parsedResult["status"]! !== nil) {
                        completionHandler(success: false, errorMessage: parsedResult.valueForKeyPath("error")?.description)
                    } else {
                        let userId = parsedResult.valueForKeyPath("account.key") as! String
                        self.appDelegate.loggedUser.uniqueKey = userId
                        self.getUserdata(userId)

                        completionHandler(success: true, errorMessage: nil)
                    }
                } catch {

                }
            }
        }
        task.resume()
    }
    
    func logout() {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()

        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                return
            }
            
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
        }
        task.resume()
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        StudentLocations.students.removeAll()
    }

    
    func loginWithFacebook(token: NSString, completionHandler: (success: Bool, errorMessage: String?) -> Void){
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"facebook_mobile\": {\"access_token\": \"\(token);\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            if error != nil {
                completionHandler(success: false, errorMessage: error?.description)
            } else {

                let parsedResult: AnyObject!

                do {
                    let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
                    
                    if (parsedResult["status"]! !== nil) {
                        completionHandler(success: false, errorMessage: parsedResult.valueForKeyPath("error")?.description)
                    } else {
                        let userId = parsedResult.valueForKeyPath("account.key") as! String
                        self.appDelegate.loggedUser.uniqueKey = userId
                        self.getUserdata(userId)

                        completionHandler(success: true, errorMessage: nil)
                    }
                } catch {

                }
            }
        }
        task.resume()
    }
    
    func getUserdata(userId: String) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/" + userId)!)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            if error != nil {
                return
            } else {
                
                let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
                do {
                    let parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)

                    let userId = parsedResult.valueForKeyPath("user.key") as? String
                    let firstName = parsedResult.valueForKeyPath("user.first_name") as? String
                    let lastName = parsedResult.valueForKeyPath("user.last_name") as? String
                    
                    self.appDelegate.loggedUser.firstName = firstName
                    self.appDelegate.loggedUser.lastName = lastName
                }
                catch {

                }
            }
            
        }
        
        task.resume()
    }
    
    func getUserLocation(userId: String) {
        let urlString = "https://api.parse.com/1/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22" + userId + "%22%7D"
        let url = NSURL(string: urlString)
        
        let request = NSMutableURLRequest(URL: url!)
        
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            if error != nil {
                return
            } else {
                
            }
        }
        task.resume()
    }
}