//
//  PlacesTableViewCell.swift
//  OnTheMap
//
//  Created by Felipe Kuhn on 1/31/16.
//  Copyright © 2016 Knorrium. All rights reserved.
//

import UIKit
import MapKit

class PlacesTableViewCell: UITableViewCell {

    @IBOutlet weak var labelLocation: UILabel!
    @IBOutlet weak var labelURL: UILabel!
    @IBOutlet weak var labelUser: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
