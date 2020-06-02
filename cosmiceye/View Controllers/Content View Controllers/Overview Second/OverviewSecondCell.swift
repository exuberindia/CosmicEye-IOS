//
//  OverviewSecondCell.swift
//  cosmiceye
//
//  Created by Rachin Allakkot on 02/12/19.
//  Copyright © 2019 Exuber. All rights reserved.
//

import UIKit

class OverviewSecondCell: UITableViewCell {
    
    //Declaring views
    @IBOutlet var contentBackground: UIView!
    @IBOutlet var movieImage: UIImageView!
    
    @IBOutlet var movieName: UILabel!
    @IBOutlet var audiAndTime: UILabel!
    
    
    @IBOutlet var movieOccupancy: UILabel!
    
    @IBOutlet var movieTotalOccupancy: UILabel!
    @IBOutlet var movieTotalShows: UILabel!
    
       

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        audiAndTime.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
