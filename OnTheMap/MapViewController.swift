//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Felipe Kuhn on 1/22/16.
//  Copyright © 2016 Knorrium. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var map: MKMapView!
    var locationManager: CLLocationManager!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var activityIndicator = UIActivityIndicatorView()
    
    @IBAction func logoutAction(sender: AnyObject) {
        UdacityLogin.sharedInstance.logout()
        dismissViewControllerAnimated(true, completion: {});
    }

    //Source: http://www.raywenderlich.com/90971/introduction-mapkit-swift-tutorial
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        map.setRegion(coordinateRegion, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("Map View")

        map.delegate = self
        
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization();
        
//        var CLAuthStatus = CLLocationManager.authorizationStatus()
//        print("[MapView] - CLAuthStatus " + CLAuthStatus.rawValue.description)
//        if(CLAuthStatus == CLAuthorizationStatus.NotDetermined) {
//            print("[MapView] - Requesting Location")
//            locationManager.requestAlwaysAuthorization();
//            locationManager.requestWhenInUseAuthorization()
//            locationManager.requestLocation()
//        } else {
//            print("[MapView] - Requesting Location")
//        }
        
//        if (CLLocationManager.locationServicesEnabled())
//        {
//            print("[MapView] Location Enabled")
//            locationManager.delegate = self
//            locationManager.desiredAccuracy = kCLLocationAccuracyBest
//            locationManager.requestAlwaysAuthorization()
//            locationManager.startUpdatingLocation()
//        } else {
//            print("[MapView] Location DISABLED")
//        }
        print("[MapVieWController] LOADED")
        var myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        myActivityIndicator.center = self.view.center
        myActivityIndicator.startAnimating()
        self.view.addSubview(myActivityIndicator)

        LocationsClient.sharedInstance.fetchLocations() { (success, errorMessage) in
            print("[FetchLocations] START")
//            print(success)
//            print(errorMessage)
            if success {
                print("[FetchLocations] Success")
            } else {
                print("[FetchLocations] Failure")
            }
            print("[FetchLocations] END")

            for studentInformation in self.appDelegate.students {
//                print(studentInformation)
//                print(studentInformation.latitude)
//                print(studentInformation.longitude)
                if (studentInformation.latitude != nil && studentInformation.longitude != nil) {
//                    print("[MapViewController] - InsertPin")

                    let coordinate = CLLocationCoordinate2D(
                        latitude: studentInformation.latitude as! Double!,
                        longitude: studentInformation.longitude as! Double!
                    )
                    let title = studentInformation.firstName! + " " + studentInformation.lastName!
                    let subtitle = studentInformation.mediaURL
                    let annotation = StudentMapAnnotation(title: title, coordinate: coordinate, subtitle: subtitle!)
//                    self.map.addAnnotation(annotation)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.map.addAnnotation(annotation)
                    }
                }
            }

        }
                myActivityIndicator.stopAnimating()
    }
    

    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        print(error.description)
    }

    //Source: https://www.hackingwithswift.com/read/19/2/up-and-running-with-mapkit
    //Source: https://www.hackingwithswift.com/read/19/3/annotations-and-accessory-views-mkpinannotationview
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        // 1
        let identifier = "StudentMapAnnotation"
        
        // 2
        if annotation.isKindOfClass(StudentMapAnnotation.self) {
            // 3
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
            
            if annotationView == nil {
                //4
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView!.canShowCallout = true
                
                // 5
                let btn = UIButton(type: .DetailDisclosure)
                annotationView!.rightCalloutAccessoryView = btn
            } else {
                // 6
                annotationView!.annotation = annotation
            }
            
            return annotationView
        }
        
        // 7
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
    
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        print("didChangeAuthorizationStatus")
        switch status {
        case .NotDetermined:
            locationManager.requestAlwaysAuthorization()
            break
        case .AuthorizedWhenInUse:
            locationManager.startUpdatingLocation()
            break
        case .AuthorizedAlways:
            locationManager.startUpdatingLocation()
            break
        case .Restricted:
            // restricted by e.g. parental controls. User can't enable Location Services
            break
        case .Denied:
            // user denied your app access to Location Services, but can grant access from Settings.app
            break
        default:
            break
        }
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        print("[MapView/LocationManager] didUpdateLocations")
        let location = locations.last! as CLLocation
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        print("[MapView/LocationManager] " + region.center.latitude.description + " " + region.center.longitude.description)
        self.map.setRegion(region, animated: true)
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
