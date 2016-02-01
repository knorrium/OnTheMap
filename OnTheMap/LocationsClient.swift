//
//  LocationsClient.swift
//  OnTheMap
//
//  Created by Felipe Kuhn on 1/25/16.
//  Copyright © 2016 Knorrium. All rights reserved.
//

import UIKit

class LocationsClient: NSObject {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    static let sharedInstance = LocationsClient()
    
    var session: NSURLSession
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }

    
    func fetchLocations(completionHandler: (success: Bool, errorMessage: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation?order=-updatedAt")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
        if error != nil {
            completionHandler(success: false, errorMessage: "There was an error while fetching the location data")
        } else {
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)

                if let location = parsedResult["results"] as? [NSDictionary] {
                   for studentInfo in location {
                        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                        appDelegate.students.append(StudentInformation(dictionary: studentInfo))
                    }
                }
                completionHandler(success: true, errorMessage: nil)
            } catch {
                completionHandler(success: false, errorMessage: "Error parsing JSON data")
            }
        }
    }
        task.resume()
    }
    
    func postLocation(student: StudentInformation, completionHandler: (success: Bool, errorMessage: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        
        request.HTTPMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\" : \"\(student.uniqueKey)\", \"firstName\" : \"\(student.firstName!)\", \"lastName\" : \"\(student.lastName!)\",\"mapString\" : \"\(student.mapString!)\", \"mediaURL\" : \"\(student.mediaURL!)\", \"latitude\" : \(student.latitude!), \"longitude\" : \(student.longitude!)}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            if error != nil {
                completionHandler(success: false, errorMessage: error?.description)
            } else {
                do {
                    let parsedResult: AnyObject!
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                    completionHandler(success: true, errorMessage: nil)
                } catch {
                    completionHandler(success: false, errorMessage: "Error parsing JSON data")
                }
            }
        }
        task.resume()
    }
}
