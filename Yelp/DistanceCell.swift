//
//  DistanceCell.swift
//  Yelp
//
//  Created by Christine Hong on 2/14/16.
//  Copyright © 2016 Christine Hong. All rights reserved.
//

import UIKit

@objc protocol DistanceDelegate {
    optional func distanceCell(distanceCell: DistanceCell, didChangeValue value: Bool)
}

class DistanceCell: UITableViewCell {
    
     weak var delegate: DistanceDelegate?
    @IBOutlet weak var distanceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
