//
//  StudentLocations.swift
//  OnTheMap
//
//  Created by Felipe Kuhn on 2/1/16.
//  Copyright © 2016 Knorrium. All rights reserved.
//

import UIKit

class StudentLocations {
    static var students: [StudentInformation] = []
    
    class func append(student : StudentInformation ) {
        students.append(student)
    }
}
