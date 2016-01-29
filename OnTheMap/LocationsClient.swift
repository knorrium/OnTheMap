//
//  LocationsClient.swift
//  OnTheMap
//
//  Created by Felipe Kuhn on 1/25/16.
//  Copyright © 2016 Knorrium. All rights reserved.
//

import UIKit

class LocationsClient: NSObject {

    static let sharedInstance = LocationsClient()
    
    var session: NSURLSession
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }

    
    func fetchLocations(completionHandler: (success: Bool, errorMessage: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
        if error != nil { // Handle error...
            completionHandler(success: false, errorMessage: "There was an error while fetching the location data")
        } else {
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
//                print(parsedResult)
                if let location = parsedResult["results"] as? [NSDictionary] {
                   for studentInfo in location {
//                        print(studentInfo)
                        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                        appDelegate.students.append(StudentInformation(dictionary: studentInfo))
//                        print(appDelegate.students.count)
                    }
                }
                
                
                
                completionHandler(success: true, errorMessage: nil)
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                completionHandler(success: false, errorMessage: "Error parsing JSON data")
            }
//                print(NSString(data: data?, encoding: NSUTF8StringEncoding))
            }
        }
        task.resume()
    }
    
    func postLocation() {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        
        request.HTTPMethod = "POST"
        
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.HTTPBody = "{\"uniqueKey\": \"1234\", \"firstName\": \"John\", \"lastName\": \"Doe\",\"mapString\": \"Mountain View, CA\", \"mediaURL\": \"https://udacity.com\",\"latitude\": 37.386052, \"longitude\": -122.083851}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            if error != nil { // Handle error…
                return
            } else {
                print(data)
                //                print(NSString(data: data, encoding: NSUTF8StringEncoding))
            }
        }
        task.resume()
    }
}
