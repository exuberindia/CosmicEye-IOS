//
//  HomeTabVC.swift
//  cosmiceye
//
//  Created by Rachin Allakkot on 25/05/20.
//  Copyright © 2020 Exuber. All rights reserved.
//

import UIKit
import Alamofire

class HomeTabVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        
        DispatchQueue.main.async {
            
            Alamofire.SessionManager.default.session.invalidateAndCancel()
            Alamofire.SessionManager.default.session.getAllTasks { (tasks) in

                tasks.forEach({$0.cancel()})
            }
        }
        

                
        
    }
    

    
}
