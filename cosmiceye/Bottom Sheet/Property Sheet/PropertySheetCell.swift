//
//  PropertySheetCell.swift
//  cosmiceye
//
//  Created by Rachin Allakkot on 28/11/19.
//  Copyright © 2019 Exuber. All rights reserved.
//

import UIKit

class PropertySheetCell: UITableViewCell {
    
    //Declaring views
    @IBOutlet var contentBackground: UIView!
    @IBOutlet var propertyName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
