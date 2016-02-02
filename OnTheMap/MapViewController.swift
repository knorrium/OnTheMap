//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Felipe Kuhn on 1/22/16.
//  Copyright © 2016 Knorrium. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBAction func refreshAction(sender: AnyObject) {
        StudentLocations.students.removeAll()
        map.removeAnnotations(map.annotations)
        fetchStudentLocations()
    }
    
    @IBOutlet weak var map: MKMapView!
    var locationManager: CLLocationManager!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var activityIndicator = UIActivityIndicatorView()
    
    @IBAction func logoutAction(sender: AnyObject) {
        UdacityLogin.sharedInstance.logout()
        dismissViewControllerAnimated(true, completion: {});
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        map.delegate = self

        fetchStudentLocations()
    }
    
    func fetchStudentLocations() {
        var myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        myActivityIndicator.center = self.view.center
        myActivityIndicator.startAnimating()
        self.view.addSubview(myActivityIndicator)
        
        LocationsClient.sharedInstance.fetchLocations() { (success, errorMessage) in
            if success {
                for studentInformation in StudentLocations.students {
                    if (studentInformation.latitude != nil && studentInformation.longitude != nil) {
                        
                        let coordinate = CLLocationCoordinate2D(
                            latitude: studentInformation.latitude as! Double!,
                            longitude: studentInformation.longitude as! Double!
                        )
                        let title = studentInformation.firstName! + " " + studentInformation.lastName!
                        let subtitle = studentInformation.mediaURL
                        let annotation = StudentMapAnnotation(title: title, coordinate: coordinate, subtitle: subtitle!)
                        dispatch_async(dispatch_get_main_queue()) {
                            self.map.addAnnotation(annotation)
                        }
                    }
                }
            } else {

            }
        }
        myActivityIndicator.stopAnimating()

    }

    //Source: https://www.hackingwithswift.com/read/19/2/up-and-running-with-mapkit
    //Source: https://www.hackingwithswift.com/read/19/3/annotations-and-accessory-views-mkpinannotationview
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        let identifier = "StudentMapAnnotation"
        
        if annotation.isKindOfClass(StudentMapAnnotation.self) {
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
            
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView!.canShowCallout = true
                
                let btn = UIButton(type: .DetailDisclosure)
                annotationView!.rightCalloutAccessoryView = btn
            } else {
                annotationView!.annotation = annotation
            }
            
            return annotationView
        }
        return nil
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        let student = view.annotation as! StudentMapAnnotation
        let placeName = student.title
        var placeInfo = student.subtitle?.lowercaseString
        
        // Super hacky attempt to fix malformed URLs
        if (placeInfo != nil && placeInfo?.hasPrefix("http") == false) {
            placeInfo = "http://" + placeInfo!
        }

        if (placeInfo!.hasPrefix("http")) {
            // Source: https://www.hackingwithswift.com/example-code/system/how-to-open-a-url-in-safari
            if let url = NSURL(string: placeInfo!) {
                UIApplication.sharedApplication().openURL(url)
            }
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func enterLocation(sender: AnyObject) {
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
