//
//  ChartMarkerView.swift
//  cosmiceye
//
//  Created by Rachin Allakkot on 26/11/19.
//  Copyright © 2019 Exuber. All rights reserved.
//

import UIKit
import Charts
import FittedSheets



class ChartMarkerView: MarkerView {
    
    @IBOutlet var markerContentBackground: UIView!
  
    @IBOutlet var markerBubbleBackground: UIView!
    @IBOutlet var occupancySeats: UILabel!
    @IBOutlet var occupancyDateTime: UILabel!
    
    private let dateFormatter = DateFormatter()
   
    
    override open func awakeFromNib() {
        
        
                      
        
        
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "MMM d, h:mm a"
        
        markerContentBackground.layer.shadowColor = UIColor.gray.cgColor
        markerContentBackground.layer.shadowOffset = CGSize(width: 0, height: 1)
        markerContentBackground.layer.masksToBounds = false
        markerContentBackground.layer.shadowOpacity = 0.3
        markerContentBackground.layer.shadowRadius = 3
        
        markerContentBackground.layer.rasterizationScale = UIScreen.main.scale
        markerContentBackground.layer.shouldRasterize = true
        
        
        markerBubbleBackground.layer.cornerRadius = markerBubbleBackground.frame.height / 2
        markerBubbleBackground.clipsToBounds = true
        
        markerBubbleBackground.layer.borderWidth = 3
        markerBubbleBackground.layer.borderColor = UIColor.white.cgColor
        
        self.offset.x = -self.frame.size.width/2
        self.offset.y = -self.frame.size.height+12
    }
    
    public override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        
        occupancySeats.text = String.init(format: "%d", Int(round(entry.y)))+" Seats"
        
        let date = Date(timeIntervalSince1970: entry.x)
        occupancyDateTime.text = dateFormatter.string(from: date)
           
        layoutIfNeeded()
        
        
        
       
    }
    
    

}

