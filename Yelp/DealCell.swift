//
//  DealCell.swift
//  Yelp
//
//  Created by Christine Hong on 2/14/16.
//  Copyright © 2016 Christine Hong. All rights reserved.
//

import UIKit

@objc protocol DealCellDelegate {
    optional func dealCell(dealCell: DealCell, didChangeValue value: Bool)
}

class DealCell: UITableViewCell {
    
    @IBOutlet weak var dealSwitch: UISwitch!
    
    weak var delegate: DealCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        dealSwitch.addTarget(self, action: "dealSwitchValueChanged", forControlEvents: UIControlEvents.ValueChanged)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func dealSwitchValueChanged() {
        delegate?.dealCell?(self, didChangeValue: dealSwitch.on)
    }


}
