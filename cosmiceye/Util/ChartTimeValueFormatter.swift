//
//  ChartTimeValueFormatter.swift
//  cosmiceye
//
//  Created by Rachin Allakkot on 27/11/19.
//  Copyright © 2019 Exuber. All rights reserved.
//

import Foundation
import Charts

public class ChartTimeValueFormatter: NSObject ,IAxisValueFormatter {
    
    private let dateFormatter = DateFormatter()
    
    override init() {
        super.init()
        
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }

}
