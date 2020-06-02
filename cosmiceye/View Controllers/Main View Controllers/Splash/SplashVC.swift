//
//  SplashVC.swift
//  cosmiceye
//
//  Created by Rachin Allakkot on 21/11/19.
//  Copyright © 2019 Exuber. All rights reserved.
//

import UIKit
import FirebaseCrashlytics

class SplashVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()


       DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(5000)) {
            
            //Check and Proceed
            self.checkAndProceed()
        }
    }
    

    //Fun - Checking user defaults
    func checkAndProceed()  {
        
        //Checking Login status
        if UserDefaults.standard.object(forKey: IS_LOGGED_IN) == nil
        {
            //Going to LoginSignUp
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let vc = storyboard.instantiateViewController(withIdentifier: "LoginScreen")
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
        else
        {
            //Checking Login status
            if UserDefaults.standard.bool(forKey: IS_LOGGED_IN)
            {
                //Going to Home
                let storyboard = UIStoryboard(name: "Content", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "HomeScreen")
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
                
            }
            else
            {
                //Going to LoginSignUp
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "LoginScreen")
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }
        }
        
        
    }
    
   
}
