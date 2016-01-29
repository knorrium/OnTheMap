//
//  LocationInfo.swift
//  OnTheMap
//
//  Created by Felipe Kuhn on 1/25/16.
//  Copyright © 2016 Knorrium. All rights reserved.
//

import UIKit

struct StudentInformation {

    var uniqueKey:String
    var firstName:String?
    var lastName:String?
    var mediaURL:String?
    var latitude:Double?
    var longitude:Double?
    var mapString:String?
    var createdAt:String?
    var updatedAt:String?
    var objectId:String?

    init(dictionary: NSDictionary) {
        
        uniqueKey = dictionary["uniqueKey"] as! String!
        firstName = dictionary["firstName"] as! String!
        lastName = dictionary["lastName"] as? String
        mediaURL = dictionary["mediaURL"] as? String
        latitude = dictionary["latitude"] as? Double
        longitude = dictionary["longitude"] as? Double
        mapString = dictionary["mapString"] as? String
        objectId = dictionary["objectId"] as! String!
        createdAt = dictionary["createdAt"] as? String
        updatedAt = dictionary["updatedAt"] as? String
    }
}
