//
//  AudiScheduleSheetCell.swift
//  cosmiceye
//
//  Created by Rachin Allakkot on 03/12/19.
//  Copyright © 2019 Exuber. All rights reserved.
//

import UIKit

class AudiScheduleSheetCell: UITableViewCell {
    
    @IBOutlet var contentBackground: UIView!
    @IBOutlet var audiName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
