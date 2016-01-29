//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Felipe Kuhn on 1/22/16.
//  Copyright © 2016 Knorrium. All rights reserved.
//

import UIKit

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var applicationDelegate: AppDelegate?
    var students: [StudentInformation]?
    
    @IBAction func logoutAction(sender: UIBarButtonItem) {
        UdacityLogin.sharedInstance.logout()
        dismissViewControllerAnimated(true, completion: {});
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("Table View")
        applicationDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        students = applicationDelegate?.students
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Value2, reuseIdentifier: nil)
        
        let student = students![indexPath.row]

        cell.textLabel?.text = student.firstName
        cell.detailTextLabel?.text = student.mediaURL
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let students = students {
            if let mediaURL = students[indexPath.row].mediaURL, cell = tableView.cellForRowAtIndexPath(indexPath) {
                // Super hacky attempt to fix malformed URLs
                var url = mediaURL
                if (url.hasPrefix("http") == false) {
                    url = "http://" + url
                }
                
                if (url.hasPrefix("http")) {
                    // Source: https://www.hackingwithswift.com/example-code/system/how-to-open-a-url-in-safari
                    if let navigationUrl = NSURL(string: url) {
                        UIApplication.sharedApplication().openURL(navigationUrl)
                    }
                }
            }
        }
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
