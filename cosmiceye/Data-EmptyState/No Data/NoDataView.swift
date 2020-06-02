//
//  NoDataView.swift
//  cosmiceye
//
//  Created by Rachin Allakkot on 03/01/20.
//  Copyright © 2020 Exuber. All rights reserved.
//

import UIKit

class NoDataView: UIView {

    @IBOutlet var errorImage: UIImageView!
    @IBOutlet var emptyText: UILabel!
    
    class func instantiateFromNib() -> NoDataView{
        return Bundle.main.loadNibNamed("NoDataView", owner: nil, options: nil)!.first as! NoDataView
    }

}
