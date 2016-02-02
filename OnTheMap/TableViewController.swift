//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Felipe Kuhn on 1/22/16.
//  Copyright © 2016 Knorrium. All rights reserved.
//

import UIKit
import MapKit

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    
    @IBAction func refreshAction(sender: AnyObject) {
        StudentLocations.students.removeAll()
        tableView.reloadData()

        LocationsClient.sharedInstance.fetchLocations() { (success, errorMessage) in
            if success {
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
            } else {
                let alertController = UIAlertController(title: "On The Map", message:
                    errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                dispatch_async(dispatch_get_main_queue(), {
                    self.presentViewController(alertController, animated: true, completion: nil)
                })
            }
        }
    }
    
    @IBAction func logoutAction(sender: UIBarButtonItem) {
        UdacityLogin.sharedInstance.logout()
        dismissViewControllerAnimated(true, completion: {});
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentLocations.students.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let student = StudentLocations.students[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath) as! PlacesTableViewCell

        cell.labelUser.text = "\(student.firstName!) \(student.lastName!)"
        cell.labelURL.text = "\(student.mediaURL!)"
        cell.labelLocation.text = "\(student.mapString!)"

        let center = CLLocationCoordinate2D(latitude: student.latitude!, longitude: student.longitude!)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))

        let dropPin = MKPointAnnotation()
        dropPin.coordinate = center
        dropPin.title = student.mapString!
        cell.mapView.addAnnotation(dropPin)
        
        cell.mapView.setRegion(region, animated: false)
        
        return cell

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let mediaURL = StudentLocations.students[indexPath.row].mediaURL, cell = tableView.cellForRowAtIndexPath(indexPath) {
            // Super hacky attempt to fix malformed URLs
            var url = mediaURL
            if (url.hasPrefix("http") == false) {
                url = "http://" + url
            }
            
            if (url.hasPrefix("http")) {
                // Source: https://www.hackingwithswift.com/example-code/system/how-to-open-a-url-in-safari
                if let navigationUrl = NSURL(string: url) {
                    UIApplication.sharedApplication().openURL(navigationUrl)
                } else {
                    let alertController = UIAlertController(title: "On The Map", message:
                        "The URL provided by the student is invalid", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                    dispatch_async(dispatch_get_main_queue(), {
                        self.presentViewController(alertController, animated: true, completion: nil)
                    })
                }
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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