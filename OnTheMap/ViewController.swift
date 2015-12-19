//
//  ViewController.swift
//  OnTheMap
//
//  Created by Felipe Kuhn on 12/19/15.
//  Copyright © 2015 Knorrium. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        addGradient()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func addGradient(){
        // Source: http://stackoverflow.com/questions/24380535/how-to-apply-gradient-to-background-view-of-ios-swift-app
        
        let gradient:CAGradientLayer = CAGradientLayer()
        gradient.frame.size = self.view.frame.size
        gradient.colors = [UIColor.orangeColor().colorWithAlphaComponent(0.5).CGColor,UIColor.orangeColor().CGColor] //Or any colors
        self.view.layer.insertSublayer(gradient, atIndex: 0)
        
    }

}

