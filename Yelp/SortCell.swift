//
//  SortCell.swift
//  Yelp
//
//  Created by Christine Hong on 2/14/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol SortCellDelegate {
    optional func sortCell(dealCell: SortCell, didChangeValue value: Bool)
}

class SortCell: UITableViewCell {
    
    weak var delegate: SortCellDelegate?
    @IBOutlet weak var sortImageView: UIImageView!
    @IBOutlet weak var sortLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
