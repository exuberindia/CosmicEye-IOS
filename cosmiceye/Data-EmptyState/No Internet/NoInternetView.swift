//
//  NoInternetView.swift
//  cosmiceye
//
//  Created by Rachin Allakkot on 03/01/20.
//  Copyright © 2020 Exuber. All rights reserved.
//

import UIKit

class NoInternetView: UIView {

   //Decalaring Views
    @IBOutlet weak var tryAgainClick: UIButton!
    @IBOutlet weak var errorText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //Setting Corner
        tryAgainClick.layer.cornerRadius = 4
        tryAgainClick.clipsToBounds = true
    
        
    }
    
    class func instantiateFromNib() -> NoInternetView{
        return Bundle.main.loadNibNamed("NoInternetView", owner: nil, options: nil)!.first as! NoInternetView
    }

}
