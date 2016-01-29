//
//  StudentMapAnnotation.swift
//  OnTheMap
//
//  Created by Felipe Kuhn on 1/28/16.
//  Copyright © 2016 Knorrium. All rights reserved.
//

import UIKit
import MapKit

class StudentMapAnnotation: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var subtitle: String?
    
    init(title: String, coordinate: CLLocationCoordinate2D, subtitle: String) {
        self.title = title
        self.coordinate = coordinate
        self.subtitle = subtitle
    }
}