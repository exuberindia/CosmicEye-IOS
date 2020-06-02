//
//  Config.swift
//  cosmiceye
//
//  Created by Rachin Allakkot on 21/11/19.
//  Copyright © 2019 Exuber. All rights reserved.
//

import UIKit
import Foundation
import SwiftyJSON
import KRProgressHUD
import KRActivityIndicatorView
import GSMessages

// HUD VIEW (customizable by editing the code below)
var hudView = UIView()
var horizontalHudView = UIView()
var animImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))

//Func - Validating Email
 func isValidEmail(enteredEmail:String) -> Bool {
     
     let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
     let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
     return emailPredicate.evaluate(with: enteredEmail)
 }


//Func - Profile JSON
 public func loadProfileJSONDefaults() -> JSON {
     
     let cosmicEyeDefaults = UserDefaults.standard
     let stringJSON = cosmicEyeDefaults.value(forKey: LOGIN_RESPONSE) as! String
     let reloadedJson = JSON.init(parseJSON: stringJSON)
     
     return reloadedJson
 }
 

//Func - Profile JSON
public func getScheduleBackgroundColor(rowPosition: Int, sectionPosition: Int) -> UIColor {
    
    var rowIndex = rowPosition
    
    if rowPosition >= 5
    {
        rowIndex = (rowPosition)%5
    }
  
    
   
   print(rowIndex)
    
    if rowIndex == 4 {
        
        
        return UIColor(red: 230/255, green: 73/255,  blue: 45/255,  alpha: 0.2)
        
    }
    else if rowIndex == 3 {
        
         
         return UIColor(red: 103/255, green: 88/255,  blue: 243/255,  alpha: 0.1)
        
    }
    else if rowIndex == 2 {
        
        
        return UIColor(red: 246/255, green: 171/255,  blue: 47/255,  alpha: 0.1)
        
    }
    else if rowIndex == 1 {
        
        
        return UIColor(red: 22/255, green: 101/255,  blue: 216/255,  alpha: 0.1)
        
    }
    else  {
        
        
        return UIColor(red: 52/255, green: 170/255,  blue: 68/255,  alpha: 0.1)
        
    }
    
    
    
   
}


//Func - Proprty JSON
public func loadUserJSONDefaults() -> JSON {
    
    let cosmicEyeDefaults = UserDefaults.standard
    let stringJSON = cosmicEyeDefaults.value(forKey: LOGIN_RESPONSE) as! String
    let reloadedJson = JSON.init(parseJSON: stringJSON)
    
    return reloadedJson
}

extension UIViewController {
    
    func showHUD() {
        
        DispatchQueue.main.async {
            
            hudView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
            hudView.backgroundColor = UIColor.clear
            hudView.alpha = 1.0
            
            let imagesArr = ["h0", "h1", "h2", "h3", "h4", "h5", "h6", "h7", "h8", "h9"]
            var images : [UIImage] = []
            for i in 0..<imagesArr.count {
                images.append(UIImage(named: imagesArr[i])!)
            }
            animImage.animationImages = images
            animImage.animationDuration = 0.7
            animImage.center = hudView.center
            hudView.addSubview(animImage)
            animImage.startAnimating()
            
            self.view.addSubview(hudView)
        }
        
    }
    
    func hideHUD() {
        
        DispatchQueue.main.async {
            
            hudView.removeFromSuperview()
        }
          
    }
    
    
    public func logoutApp() {
     
       let cosmicEyeDefaults = UserDefaults.standard
        
        var isRememberMeSelected = false
        var rememberMeEmail = ""
        var rememberMePassword = ""

        //Checking Remember me  status
        if cosmicEyeDefaults.object(forKey: IS_REMEMBER_ME_SELECTED) != nil
        {
              //Checking Remember Me status
              if cosmicEyeDefaults.bool(forKey: IS_REMEMBER_ME_SELECTED)
              {
                  isRememberMeSelected = true

                  rememberMeEmail  = UserDefaults.standard.string(forKey: REMEMBER_ME_EMAIL)!
                  rememberMePassword  = UserDefaults.standard.string(forKey: REMEMBER_ME_PASSWORD)!


              }
        }

       let dictionary = cosmicEyeDefaults.dictionaryRepresentation()
           dictionary.keys.forEach { key in

             cosmicEyeDefaults.removeObject(forKey: key)
       }
        
        cosmicEyeDefaults.setValue(isRememberMeSelected, forKey: IS_REMEMBER_ME_SELECTED)
        cosmicEyeDefaults.setValue(rememberMeEmail, forKey: REMEMBER_ME_EMAIL)
        cosmicEyeDefaults.setValue(rememberMePassword, forKey: REMEMBER_ME_PASSWORD)

       

       cosmicEyeDefaults.synchronize()

      //Going to LoginSignUp
       let storyboard = UIStoryboard(name: "Main", bundle: nil)
       
       let vc = storyboard.instantiateViewController(withIdentifier: "LoginScreen")
       vc.modalPresentationStyle = .fullScreen
       self.present(vc, animated: true, completion: nil)
        
       
    }

}

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)

        if let nav = self.navigationController {
            nav.view.endEditing(true)
        }
    }
}

extension UIViewController {
    
    //Func - Error Message
    func showErrorMessage(errorMessage: String){
        
        GSMessage.font = UIFont(name: "Poppins-Medium", size: 16)!
        GSMessage.errorBackgroundColor   = UIColor(red: 255/255, green: 0/255,  blue: 0/255,  alpha: 1.0)
        
        self.showMessage(errorMessage, type: .error)
        
        

    }
    
    //Func - Error Message
    func showInfoMessage(errorMessage: String){
           
        GSMessage.font = UIFont(name: "Poppins-Medium", size: 16)!
        GSMessage.errorBackgroundColor   = UIColor(red: 255/255, green: 0/255,  blue: 0/255,  alpha: 1.0)
                  
        self.showMessage(errorMessage, type: .info)
           
    }
    
}


extension UIImage {
    
    func createSelectionIndicator(color: UIColor, size: CGSize, lineHeight: CGFloat) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: size.width, height: lineHeight))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}


extension UIView {

  
  func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
    
    layer.masksToBounds = false
    layer.shadowColor = color.cgColor
    layer.shadowOpacity = opacity
    layer.shadowOffset = offSet
    layer.shadowRadius = radius

    layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
    layer.shouldRasterize = true
    layer.rasterizationScale = scale ? UIScreen.main.scale : 1
  }
}

extension Date {
    
    public func setDateTime(hour: Int, min: Int, sec: Int, yourDate: Date, timeZoneAbbrev: String = "UTC") -> Date? {
        
        let x: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        let cal = Calendar.current
        var components = cal.dateComponents(x, from: yourDate)

        //components.timeZone = TimeZone(abbreviation: timeZoneAbbrev)
        components.hour = hour
        components.minute = min
        components.second = sec

        return cal.date(from: components)
    }
    
    func previous(_ weekday: Weekday, considerToday: Bool = false) -> Date {
      return get(.previous,
                 weekday,
                 considerToday: considerToday)
    }
    
    func getWeekDaysInEnglish() -> [String] {
      var calendar = Calendar(identifier: .gregorian)
      calendar.locale = Locale(identifier: "en_US_POSIX")
      return calendar.weekdaySymbols
    }
    
    func get(_ direction: SearchDirection,
             _ weekDay: Weekday,
             considerToday consider: Bool = false) -> Date {

      let dayName = weekDay.rawValue

      let weekdaysName = getWeekDaysInEnglish().map { $0.lowercased() }

      assert(weekdaysName.contains(dayName), "weekday symbol should be in form \(weekdaysName)")

      let searchWeekdayIndex = weekdaysName.firstIndex(of: dayName)! + 1

      let calendar = Calendar(identifier: .gregorian)

      if consider && calendar.component(.weekday, from: self) == searchWeekdayIndex {
        return self
      }

      var nextDateComponent = calendar.dateComponents([.hour, .minute, .second], from: self)
      nextDateComponent.weekday = searchWeekdayIndex

      let date = calendar.nextDate(after: self,
                                   matching: nextDateComponent,
                                   matchingPolicy: .nextTime,
                                   direction: direction.calendarSearchDirection)

      return date!
    }

    enum Weekday: String {
      case monday, tuesday, wednesday, thursday, friday, saturday, sunday
    }

    enum SearchDirection {
      case next
      case previous

      var calendarSearchDirection: Calendar.SearchDirection {
        switch self {
        case .next:
          return .forward
        case .previous:
          return .backward
        }
      }
    }
}





