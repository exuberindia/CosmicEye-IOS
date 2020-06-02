//
//  NotificationCell.swift
//  cosmiceye
//
//  Created by Rachin Allakkot on 03/12/19.
//  Copyright © 2019 Exuber. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {
    
    
    @IBOutlet var contentBackground: UIView!
    
    @IBOutlet var notificationIcon: UIImageView!
    @IBOutlet var notificationHeader: UILabel!
    
    @IBOutlet var notificationDescription: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
