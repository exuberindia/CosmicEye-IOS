//
//  OverviewFirstCell.swift
//  cosmiceye
//
//  Created by Rachin Allakkot on 29/11/19.
//  Copyright © 2019 Exuber. All rights reserved.
//

import UIKit

class OverviewFirstCell: UITableViewCell {
    
    //Declaring views
    @IBOutlet var contentBackground: UIView!
    @IBOutlet var movieImage: UIImageView!
    
    @IBOutlet var movieName: UILabel!
    @IBOutlet var audiTime: UILabel!
    
    @IBOutlet var movieOccupancy: UILabel!
    @IBOutlet var movieTotalSeats: UILabel!
    @IBOutlet var movieSoldSeats: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
