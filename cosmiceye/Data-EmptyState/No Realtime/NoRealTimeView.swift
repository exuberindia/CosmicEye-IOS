//
//  NoRealTimeView.swift
//  cosmiceye
//
//  Created by Rachin Allakkot on 29/05/20.
//  Copyright © 2020 Exuber. All rights reserved.
//

import UIKit

class NoRealTimeView: UIView {

    class func instantiateFromNib() -> NoRealTimeView{
        return Bundle.main.loadNibNamed("NoRealTimeView", owner: nil, options: nil)!.first as! NoRealTimeView
    }

}
