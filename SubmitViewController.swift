//
//  SubmitViewController.swift
//  OnTheMap
//
//  Created by Felipe Kuhn on 1/22/16.
//  Copyright © 2016 Knorrium. All rights reserved.
//

import UIKit
import MapKit

class SubmitViewController: UIViewController, MKMapViewDelegate {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var txtLocation: UITextField!
    
    @IBAction func submitLocation(sender: AnyObject) {
        if (txtLocation.text != nil && txtLocation.text != "") {
            var geocoder = CLGeocoder()
            geocoder.geocodeAddressString(txtLocation.text!, completionHandler: {(placemarks: [CLPlacemark]?, error: NSError?) -> Void in
                
              if error == nil && placemarks!.count > 0 {
                self.requestMediaURL() { success, mediaURL in
                    
                    if (success) {
                        let placemark = placemarks![0]
                        let location = placemark.location!
                        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 20000, 20000)
                        self.mapView.setRegion(coordinateRegion, animated: true)
                        var studentInfo = StudentInformation(dictionary: [
                            "uniqueKey": self.appDelegate.loggedUser.uniqueKey,
                            "firstName": self.appDelegate.loggedUser.firstName!,
                            "lastName": self.appDelegate.loggedUser.lastName!,
                            "latitude": location.coordinate.latitude,
                            "longitude": location.coordinate.longitude,
                            "mediaURL": mediaURL!
                            ])
                        print(studentInfo)
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = location.coordinate
                        annotation.title = "\(studentInfo.firstName!) \(studentInfo.lastName!)"
                        annotation.subtitle = studentInfo.mediaURL
                        
                        self.mapView.removeAnnotations(self.mapView.annotations)
                        self.mapView.addAnnotation(annotation)
                        
                    }
                }
                
                }
              else {
                let alertController = UIAlertController(title: "On The Map", message:
                    "There was an error while trying to fetch the address information", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                dispatch_async(dispatch_get_main_queue(), {
                    self.presentViewController(alertController, animated: true, completion: nil)
                })

                }
            })
        }
        
    }
    
    func requestMediaURL(completionHandler: (success: Bool, mediaURL: String?) -> Void){
        print("REQUESTING MEDIA URL")
        var alertController:UIAlertController?
        alertController = UIAlertController(title: "Enter Text",
            message: "Enter some text below",
            preferredStyle: .Alert)
        
        alertController!.addTextFieldWithConfigurationHandler(
            {(textField: UITextField!) in
                textField.placeholder = "Enter something"
        })
        
        let action = UIAlertAction(title: "Submit",
            style: UIAlertActionStyle.Default,
            handler: {[weak self]
                (paramAction:UIAlertAction!) in
                if let textFields = alertController?.textFields{
                    let theTextFields = textFields as [UITextField]
                    let enteredText = theTextFields[0].text
                    print(enteredText)
//                    self!.displayLabel.text = enteredText
                    self!.appDelegate.loggedUser.mediaURL = enteredText
                    completionHandler(success: true, mediaURL: enteredText)
                }
            })
        
        alertController?.addAction(action)
        self.presentViewController(alertController!, animated: true, completion: {})
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("Submit Location View")
        mapView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {});
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
