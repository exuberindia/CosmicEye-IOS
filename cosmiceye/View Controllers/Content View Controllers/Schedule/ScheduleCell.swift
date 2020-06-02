//
//  ScheduleCell.swift
//  cosmiceye
//
//  Created by Rachin Allakkot on 03/12/19.
//  Copyright © 2019 Exuber. All rights reserved.
//

import UIKit

class ScheduleCell: UITableViewCell {
    
    //Declaring views
    @IBOutlet var contentBackground: UIView!
    
    @IBOutlet var scheduleName: UILabel!
    @IBOutlet var scheduleMovieBackground: UIView!
    
    
    @IBOutlet var movieName: UILabel!
    @IBOutlet var movieLanguage: UILabel!
    
    @IBOutlet var audiName: UILabel!
    
    @IBOutlet var audiNameHeightConstraint: NSLayoutConstraint!
    @IBOutlet var audiBottomViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var audiNameTopConstraint: NSLayoutConstraint!
    @IBOutlet var audiBottomViewTopConstraint: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //Setting Corner
        scheduleMovieBackground.layer.cornerRadius = 4
        scheduleMovieBackground.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
