//
//  OverviewThirdCell.swift
//  cosmiceye
//
//  Created by Rachin Allakkot on 03/12/19.
//  Copyright © 2019 Exuber. All rights reserved.
//

import UIKit

class OverviewThirdCell: UITableViewCell {
    
    //Declaring views
    @IBOutlet var movieName: UILabel!
    @IBOutlet var movieShow: UILabel!
    @IBOutlet var movieOccupancy: UILabel!
    @IBOutlet var bottomViewHeightConstraint: NSLayoutConstraint!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
