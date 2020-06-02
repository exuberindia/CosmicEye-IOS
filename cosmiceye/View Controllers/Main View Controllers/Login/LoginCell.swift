//
//  LoginCell.swift
//  cosmiceye
//
//  Created by Rachin Allakkot on 21/11/19.
//  Copyright © 2019 Exuber. All rights reserved.
//

import UIKit

class LoginCell: UITableViewCell {
    
    //Declaring views
    @IBOutlet var emailView: UIView!
    @IBOutlet var passwordView: UIView!
    
    
    @IBOutlet var emailTxt: UITextField!
    @IBOutlet var passwordTxt: UITextField!
    
    
    @IBOutlet var emailError: UILabel!
    @IBOutlet var passwordError: UILabel!
    
   
    @IBOutlet var emailErrorHeightConstraint: NSLayoutConstraint!
    @IBOutlet var passwordErrorHeightConstraint: NSLayoutConstraint!
    
    
    
    
    @IBOutlet var showHidePasswordClick: UIView!
    @IBOutlet var showHidePasswordIcon: UIImageView!
    
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var loginTroubleButton: UIButton!
    
    @IBOutlet var rememberClick: UIView!
    @IBOutlet var rememberCheck: UIImageView!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        //Setting boarder
        self.emailView.layer.borderWidth = 1
        self.emailView.layer.borderColor = UIColor(red:188.0/255.0, green:188.0/255.0, blue:188.0/255.0, alpha: 1.0).cgColor
               
                      
        self.passwordView.layer.borderWidth = 1
        self.passwordView.layer.borderColor = UIColor(red:188.0/255.0, green:188.0/255.0, blue:188.0/255.0, alpha: 1.0).cgColor
        
        //Setting Corner
        emailView.layer.cornerRadius = 4
        emailView.clipsToBounds = true
            
        passwordView.layer.cornerRadius = 4
        passwordView.clipsToBounds = true
        
        loginButton.layer.cornerRadius = 4
        loginButton.clipsToBounds = true
        
        loginTroubleButton.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
