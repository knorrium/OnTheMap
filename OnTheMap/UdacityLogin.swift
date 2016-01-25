//
//  UdacityLogin.swift
//  OnTheMap
//
//  Created by Felipe Kuhn on 1/9/16.
//  Copyright © 2016 Knorrium. All rights reserved.
//

import Foundation
import UIKit

class UdacityLogin: NSObject {
    static let sharedInstance = UdacityLogin()
    
    var session: NSURLSession
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }

    func login(username: NSString, password: NSString, completionHandler: (success: Bool, errorMessage: String?) -> Void) {
        print("[UdacityLogin] - login")

        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        
        request.HTTPMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
//        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            if error != nil {
                print("Error")
                if error?.domain == NSURLErrorDomain && error?.code == NSURLErrorNotConnectedToInternet {
                    completionHandler(success: false, errorMessage: "The Internet connection appears to be offline." )
                } else {
                    completionHandler(success: false, errorMessage: "An unknown error occured")
                }

                
            } else {
                
                let parsedResult: AnyObject!
                do {
                    let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
                    print(NSString(data: newData, encoding: NSUTF8StringEncoding))
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)

                    if (parsedResult["status"]! !== nil) {
                        if (parsedResult["status"].description == "403") {
                            completionHandler(success: false, errorMessage: parsedResult["error"].description)
                        }
                    } else {
                        completionHandler(success: true, errorMessage: nil)
                    }
                } catch {
                    print("Could not parse the data as JSON: '\(data)'")
                }
                

            }
            


            
        }
        
        task.resume()
        
        
    }
    
    func logout() {
        print("LOGGING OUT")
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
        
//        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                print("[UdacityLogin] - Error logging out")
                return
            }
            
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            print(NSString(data: newData, encoding: NSUTF8StringEncoding))
        }
        task.resume()
    }

}