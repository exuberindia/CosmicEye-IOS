//
//  OverviewVC.swift
//  cosmiceye
//
//  Created by Rachin Allakkot on 28/11/19.
//  Copyright © 2019 Exuber. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SwiftyJSON
import FittedSheets
import Alamofire

class OverviewVC: ButtonBarPagerTabStripViewController {
    
    
    //Initialising variables
    lazy var noInternetView: NoInternetView = {
        return NoInternetView.instantiateFromNib()
    }()
    
    lazy var serverErrorView: ServerErrorView = {
        return ServerErrorView.instantiateFromNib()
    }()
    
    
    lazy var noDataView: NoDataView = {
        return NoDataView.instantiateFromNib()
    }()
    
    
    //Declaring views
    @IBOutlet var errorContainer: UIView!
    @IBOutlet var propertySelectClick: UIView!
    @IBOutlet var propertyName: UILabel!
    
    @IBOutlet var dateSelectClick: UIView!
    @IBOutlet var date: UILabel!
    
    //Declaring variables
    var selectedPropertyPosition = 0
    
    //List for storing
    var propertyListJson:JSON = [:]
    
    
    //Declaring varibles
    var isTodaySelected = false
    var isWeekendSelected = false
    var isLastWeekSelected = false
    
    var selectedStartDate:Date!
    var selectedEndDate:Date!
    
    var isStarDateSelected = false
    var isEndDateSelected = false
    
    var selectedStartDateString = ""
    var selectedEndDateString = ""
    
    override func viewDidLoad() {
   
        
        
        // change selected bar color
         settings.style.buttonBarBackgroundColor = UIColor(red: 253/255, green: 253/255, blue: 253/255, alpha: 1.0)
         settings.style.buttonBarItemBackgroundColor = UIColor(red: 253/255, green: 253/255, blue: 253/255, alpha: 1.0)
         settings.style.selectedBarBackgroundColor = UIColor(red: 81/255, green: 45/255, blue: 168/255, alpha: 1.0)
         
        
         settings.style.selectedBarHeight = 2.0
         settings.style.buttonBarMinimumLineSpacing = 0
         settings.style.buttonBarItemTitleColor = UIColor(red: 158/255, green: 160/255, blue: 165/255, alpha: 1.0)
         settings.style.buttonBarItemsShouldFillAvailableWidth = true
         settings.style.buttonBarLeftContentInset = 0
         settings.style.buttonBarRightContentInset = 0
         settings.style.buttonBarHeight = 66
         
         
         changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
             guard changeCurrentIndex == true else { return }
             oldCell?.label.textColor = UIColor(red: 158/255, green: 160/255, blue: 165/255, alpha: 1.0)
             oldCell?.label.font = UIFont(name: "Poppins-Regular", size: 16)!
             newCell?.label.textColor = UIColor(red: 81/255, green: 45/255, blue: 168/255, alpha: 1.0)
             newCell?.label.font = UIFont(name: "Poppins-SemiBold", size: 18)!
         }
        
        super.viewDidLoad()
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        //Click Events
        let propertySelectClickTap = UITapGestureRecognizer(target: self, action: #selector(propertySelectClickFunction))
        propertySelectClick.isUserInteractionEnabled = true
        propertySelectClick.addGestureRecognizer(propertySelectClickTap)
        
        let dateSelectClickkTap = UITapGestureRecognizer(target: self, action: #selector(dateSelectClickFunction))
        dateSelectClick.isUserInteractionEnabled = true
        dateSelectClick.addGestureRecognizer(dateSelectClickkTap)
        
        //Click events
        noInternetView.tryAgainClick.addTarget(self, action:#selector(tryAgainClickTap(_:))
                          , for: .touchUpInside)
               
        serverErrorView.tryAgainClick.addTarget(self, action:#selector(tryAgainClickTap(_:))
               , for: .touchUpInside)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.date.text = ""
        
        //Get Property
        self.getProperty()
            
        
        
              
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        for subview in self.errorContainer.subviews {
                   
            if (subview.tag == 100) {
                       
                subview.removeFromSuperview()
            }
        }
        
        
    }
    

    override var preferredStatusBarStyle: UIStatusBarStyle {
           return .lightContent
    }
    
    //Selector Func - Try again click
    @objc private func tryAgainClickTap(_ button: UIButton)
    {
        //Get Property
        self.getProperty()
        
        
         
           
    }
    
    //Set Property Value
    func setPropertyValue() {
    
        let propertyItem = self.propertyListJson[selectedPropertyPosition]
        propertyName.attributedText = NSAttributedString(string: propertyItem["shortCode"].stringValue, attributes:
        [.underlineStyle: NSUnderlineStyle.single.rawValue])
        
        self.propertySelectClick.isHidden = false
        self.buttonBarView.isHidden = false
        self.containerView.isHidden = false
        
        
        
        self.isTodaySelected = UserDefaults.standard.bool(forKey: IS_TODAY_SELECTED)
        self.isWeekendSelected = UserDefaults.standard.bool(forKey: IS_WEEKEND_SELECTED)
        self.isLastWeekSelected = UserDefaults.standard.bool(forKey: IS_LASTWEEK_SELECTED)
        
        if let startDate = UserDefaults.standard.object(forKey: SELECTED_START_DATE) as? Date {
          self.selectedStartDate = startDate
        }
        
        if let endDate = UserDefaults.standard.object(forKey: SELECTED_END_DATE) as? Date {
          self.selectedEndDate = endDate
        }

        self.isStarDateSelected = UserDefaults.standard.bool(forKey: IS_START_DATE_SELECTED)
        self.isEndDateSelected = UserDefaults.standard.bool(forKey: IS_END_DATE_SELECTED)
        
        self.selectedStartDateString = UserDefaults.standard.string(forKey: SELECTED_START_DATE_STRING)!
        self.selectedEndDateString = UserDefaults.standard.string(forKey: SELECTED_END_DATE_STRING)!
        
        self.setDateValue()
    
        
        
        
       
    }
    
    private func setDateValue() {
        
        var selectedDateText = ""
        
        if isTodaySelected
        {
            
            let currentDate = Date()
            let startDate = currentDate.setDateTime(hour: 0, min: 0, sec: 0, yourDate: currentDate)
            let endDate = currentDate.setDateTime(hour: 23, min: 59, sec: 59, yourDate: currentDate)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM"
            let startString = dateFormatter.string(from: startDate!)
            let endString = dateFormatter.string(from: endDate!)
            
            selectedDateText = startString+" - "+endString
            
    
            
        }else if isWeekendSelected
        {
            
            
            let currentDate = Date()
            let calendar = Calendar(identifier: .gregorian)
            let components = calendar.dateComponents([.weekday], from: currentDate)
            
            
            if components.weekday == 1 {
               
                let lastSunday = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentDate)!
                let lastFriday = lastSunday.previous(.friday)
                
                let startDate = lastFriday.setDateTime(hour: 0, min: 0, sec: 0, yourDate: lastFriday)
                let endDate = lastSunday.setDateTime(hour: 23, min: 59, sec: 59, yourDate: lastSunday)
                
               let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd MMM"
                let startString = dateFormatter.string(from: startDate!)
                let endString = dateFormatter.string(from: endDate!)
                
                selectedDateText = startString+" - "+endString
                
                
                
               
            }else if components.weekday == 6 {
                
                
                let lastFriday = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentDate)!
                let lastSunday = currentDate.previous(.sunday)
                
                let startDate = lastFriday.setDateTime(hour: 0, min: 0, sec: 0, yourDate: lastFriday)
                let endDate = lastSunday.setDateTime(hour: 23, min: 59, sec: 59, yourDate: lastSunday)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd MMM"
                let startString = dateFormatter.string(from: startDate!)
                let endString = dateFormatter.string(from: endDate!)
                
                selectedDateText = startString+" - "+endString
                
               
               
            }else
            
            if components.weekday == 7 {
                 
                let lastSaturday = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentDate)!
                let lastFriday = lastSaturday.previous(.friday)
                let lastSunday = currentDate.previous(.sunday)
                
                let startDate = lastFriday.setDateTime(hour: 0, min: 0, sec: 0, yourDate: lastFriday)
                let endDate = lastSunday.setDateTime(hour: 23, min: 59, sec: 59, yourDate: lastSunday)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd MMM"
                let startString = dateFormatter.string(from: startDate!)
                let endString = dateFormatter.string(from: endDate!)
                
                selectedDateText = startString+" - "+endString
                
                
            }
            else
            {
                let lastFriday = currentDate.previous(.friday)
                let lastSunday = currentDate.previous(.sunday)
                
                let startDate = lastFriday.setDateTime(hour: 0, min: 0, sec: 0, yourDate: lastFriday)
                let endDate = lastSunday.setDateTime(hour: 23, min: 59, sec: 59, yourDate: lastSunday)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd MMM"
                let startString = dateFormatter.string(from: startDate!)
                let endString = dateFormatter.string(from: endDate!)
                
                selectedDateText = startString+" - "+endString
                
                
            }
            
            
     
            
        }else if isLastWeekSelected
        {
            
            let currentDate = Date()
            let calendar = Calendar(identifier: .gregorian)
            let components = calendar.dateComponents([.weekday], from: currentDate)

            if components.weekday == 2 {
                
                let startDate = currentDate.setDateTime(hour: 0, min: 0, sec: 0, yourDate: currentDate)
                let endDate = currentDate.setDateTime(hour: 23, min: 59, sec: 59, yourDate: currentDate)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd MMM"
                let startString = dateFormatter.string(from: startDate!)
                let endString = dateFormatter.string(from: endDate!)
                
                selectedDateText = startString+" - "+endString
                
                
                
                
                
            }
            else
            {
                
                let lastMonday = currentDate.previous(.monday)
                let startDate = lastMonday.setDateTime(hour: 0, min: 0, sec: 0, yourDate: lastMonday)
                let endDate = currentDate.setDateTime(hour: 23, min: 59, sec: 59, yourDate: currentDate)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd MMM"
                let startString = dateFormatter.string(from: startDate!)
                let endString = dateFormatter.string(from: endDate!)
                
                selectedDateText = startString+" - "+endString
                
                
                
                
            }
            
           
        }
        else
        {
            
      
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM"
            
            let startDateString = formatter.string(from: selectedStartDate)
            let endDateString = formatter.string(from: selectedEndDate)
            
            selectedDateText = startDateString+" - "+endDateString
            
            let startDate = selectedStartDate.setDateTime(hour: 0, min: 0, sec: 0, yourDate: selectedStartDate)
            let endDate = selectedEndDate.setDateTime(hour: 23, min: 59, sec: 59, yourDate: selectedEndDate)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
            let startString = dateFormatter.string(from: startDate!)
            let endString = dateFormatter.string(from: endDate!)
            print(startString)
            print(endString)
            
            
        }
        
    
        self.date.text = selectedDateText
        
        self.reloadPagerTabStripView()
        

            
        
    }
    
    //Selector Func - property Select Click
    @objc private func propertySelectClickFunction() {
        
        let controller = PropertySheetVC.instantiate()
    
        let sheetController = SheetViewController(controller: controller, sizes:  [ .halfScreen, .fullScreen])
        sheetController.adjustForBottomSafeArea = true
        sheetController.blurBottomSafeArea = false
        sheetController.dismissOnBackgroundTap = true
        sheetController.extendBackgroundBehindHandle = true
        sheetController.topCornersRadius = 10
        
        sheetController.willDismiss = { _ in
            
            print("Will dismiss")
            
           
           
            
        }
        sheetController.didDismiss = { _ in
            print("Did dismiss")
            
            if self.selectedPropertyPosition != controller.selectedPropertyPosition
            {
               
                  self.selectedPropertyPosition = controller.selectedPropertyPosition
                
                  let  storedPropertyId = self.propertyListJson[self.selectedPropertyPosition]["id"].stringValue
                
                  let cosmicEyeDefaults = UserDefaults.standard
                  cosmicEyeDefaults.setValue(storedPropertyId, forKey: STORED_PROPERTY_ID)
                 
                  cosmicEyeDefaults.synchronize()
                  
                  self.setPropertyValue()
            }
        }
        
        controller.selectedPropertyPosition = selectedPropertyPosition
        controller.propertyListJson = propertyListJson
        
        
        self.present(sheetController, animated: false, completion: nil)
        
                  
        
        
    }
    
    
    //Selector Func - Date Select Click
    @objc private func dateSelectClickFunction() {
        
        let controller = DateOverviewSheetVC.instantiate()
        
        let sheetController = SheetViewController(controller: controller, sizes:  [ .fixed(616)])
        sheetController.adjustForBottomSafeArea = true
        sheetController.blurBottomSafeArea = false
        sheetController.dismissOnBackgroundTap = false
        sheetController.extendBackgroundBehindHandle = true
        sheetController.topCornersRadius = 10
        
        
        sheetController.willDismiss = { _ in
                   
            print("Will dismiss")
            
                   
                  
        }
        
        sheetController.didDismiss = { _ in
            print("Did dismiss")
            
            if controller.isApplyButtonClicked
            {
                
                self.isTodaySelected = controller.isTodaySelected
                self.isWeekendSelected = controller.isWeekendSelected
                self.isLastWeekSelected = controller.isLastWeekSelected
                self.selectedStartDate = controller.selectedStartDate
                self.selectedEndDate = controller.selectedEndDate
                self.isStarDateSelected = controller.isStarDateSelected
                self.isEndDateSelected = controller.isEndDateSelected
                self.selectedStartDateString = controller.selectedStartDateString
                self.selectedEndDateString = controller.selectedEndDateString
                
                
    
                
                let cosmicEyeDefaults = UserDefaults.standard
                
                cosmicEyeDefaults.setValue(self.isTodaySelected, forKey: IS_TODAY_SELECTED)
                cosmicEyeDefaults.setValue(self.isWeekendSelected, forKey: IS_WEEKEND_SELECTED)
                cosmicEyeDefaults.setValue(self.isLastWeekSelected, forKey: IS_LASTWEEK_SELECTED)
                
                cosmicEyeDefaults.setValue(self.selectedStartDate, forKey: SELECTED_START_DATE)
                cosmicEyeDefaults.setValue(self.selectedEndDate, forKey: SELECTED_END_DATE)
                
                cosmicEyeDefaults.setValue(self.isStarDateSelected, forKey: IS_START_DATE_SELECTED)
                cosmicEyeDefaults.setValue(self.isEndDateSelected, forKey: IS_END_DATE_SELECTED)
                
                cosmicEyeDefaults.setValue(self.selectedStartDateString, forKey: SELECTED_START_DATE_STRING)
                cosmicEyeDefaults.setValue(self.selectedEndDateString, forKey: SELECTED_END_DATE_STRING)
                
                cosmicEyeDefaults.synchronize()
                
                self.setDateValue()
            }
            
        }
        
        controller.isTodaySelected = self.isTodaySelected
        controller.isWeekendSelected = self.isWeekendSelected
        controller.isLastWeekSelected = self.isLastWeekSelected
        controller.selectedStartDate = self.selectedStartDate
        controller.selectedEndDate = self.selectedEndDate
        controller.isStarDateSelected = self.isStarDateSelected
        controller.isEndDateSelected = self.isEndDateSelected
        controller.selectedStartDateString = self.selectedStartDateString
        controller.selectedEndDateString = self.selectedEndDateString
                   
        self.present(sheetController, animated: false, completion: nil)
                  
               
        
    }
    
    //Func - Property
    func getProperty() -> Void {
        
  
        self.propertyListJson = JSON([:])
        
        self.propertySelectClick.isHidden = true
        self.buttonBarView.isHidden = true
        self.containerView.isHidden = true
       
      
        
        for subview in self.errorContainer.subviews {
                   
            if (subview.tag == 100) {
                       
                subview.removeFromSuperview()
            }
        }
  
        
        //Checking internet connection
        if Reachability.isConnectedToNetwork()
        {
            //Setting empty background
            let width = self.errorContainer.frame.size.width
            let height = self.errorContainer.frame.size.height
            let emptyView = UIView(frame: CGRect(x: 0, y: 0, width:width , height: height))
            emptyView.tag = 100
            self.errorContainer.addSubview(emptyView)
                                  
            
            DispatchQueue.main.async {
                
                //Calling Service
                self.callGetPropertyService()
            }
            
        }
        else
        {
            
            //Setting no internet background
            let width = self.errorContainer.frame.size.width
            let height = self.errorContainer.frame.size.height
            
           
            self.noInternetView.frame = CGRect(x:0, y: 0, width: width, height: height)
            
            self.noInternetView.tag = 100
            self.noInternetView.tryAgainClick.tag = 100
            self.errorContainer.addSubview(noInternetView)
            
            
            
            
        }
    }
    
    //Service - Property
    func callGetPropertyService() -> Void {
           
           //Showing Loading
           showHUD()
           
           let accessTokenId  = UserDefaults.standard.string(forKey: LOGIN_ACCESSTOKEN_ID)
             
           let headers: HTTPHeaders = [
               "Authorization": "Bearer "+accessTokenId!
           ]
           
           print("Property List Headers")
           print(headers)
           print("\n")
           
           
           
           //Creating request
           let urlString = GET_PROPERTY_API
           
           print("Property List URL")
           print(urlString)
           print("\n")
           
           let alamoRequest = Alamofire.request(urlString, method: .get,  encoding: URLEncoding.default, headers: headers)
           
           print("Property List Request")
           print(alamoRequest)
           print("\n")
           
           alamoRequest.responseString { responseData in
                   
                   //Checking status code
                   if responseData.response?.statusCode == 200
                   {
                       //Stop loading
                       self.hideHUD()
                       
                       
                       switch responseData.result
                       {
                       case let .success(value):
                           
                           self.propertyListJson = JSON.init(parseJSON: value)
                           
                           
                           //print(self.propertyListJson)
                           
                           if self.propertyListJson.isEmpty
                           {
                               
                               for subview in self.errorContainer.subviews {
                                   if (subview.tag == 100) {
                                                                          
                                       subview.removeFromSuperview()
                                   }
                                                                      
                               
                               }
                               
                               self.noDataView.emptyText.text = "No data available"
                               self.noDataView.errorImage.image = UIImage(named: "error_no_data.png")
                                                              
                               let width = self.errorContainer.frame.size.width
                               let height = self.errorContainer.frame.size.height
                               self.noDataView.frame = CGRect(x:0, y: 0, width: width, height: height)
                               self.noDataView.tag = 100
                               self.errorContainer.addSubview(self.noDataView)
                      
                               
                           }
                           else
                           {
                               
                               for subview in self.errorContainer.subviews {
                                   
                                   if (subview.tag == 100) {
                                       
                                       subview.removeFromSuperview()
                                   }
                               }
                               
                               
                               //Setting Property Id
                               var storedPropertyId  = UserDefaults.standard.string(forKey: STORED_PROPERTY_ID)
                               self.selectedPropertyPosition = -1
                               
                               if storedPropertyId == "-1"
                               {
                                   
                                   storedPropertyId = self.propertyListJson[0]["id"].stringValue
                                   self.selectedPropertyPosition = 0
                                   
                                   
                               }
                               else
                               {
                                   
                                   if !self.propertyListJson.isEmpty
                                   {
                                       for index in 0...(self.propertyListJson.array?.count)!-1 {
                                           
                                           let propertyItem = self.propertyListJson[index]
                                           
                                           if propertyItem["id"].stringValue == storedPropertyId
                                           {
                                               storedPropertyId = self.propertyListJson[index]["id"].stringValue
                                               self.selectedPropertyPosition = index
                                               break
                                           }
                                       }
                                       
                                   }
                                   
                               }
                               
                               
                               let cosmicEyeDefaults = UserDefaults.standard
                               cosmicEyeDefaults.setValue(storedPropertyId, forKey: STORED_PROPERTY_ID)
                               cosmicEyeDefaults.setValue(true, forKey: IS_LOGGED_IN)
                               
                               self.setPropertyValue()
                    
                               
                           }
                           
                           break
                           
                       case let .failure(error):
                           
                          
                           print("Failure")
                           print(error)
                           
                           if let error = error as? AFError {
                               
                               switch error
                               {
                               case .responseSerializationFailed(let reason):
                                   if case .inputDataNilOrZeroLength = reason  {
                                       
                                       for subview in self.errorContainer.subviews {
                                           if (subview.tag == 100) {
                                                                                  
                                               subview.removeFromSuperview()
                                           }
                                                                              
                                       
                                       }
                                       
                                       self.noDataView.emptyText.text = "No data available"
                                       self.noDataView.errorImage.image = UIImage(named: "error_no_data.png")
                                                                      
                                       let width = self.errorContainer.frame.size.width
                                       let height = self.errorContainer.frame.size.height
                                       self.noDataView.frame = CGRect(x:0, y: 0, width: width, height: height)
                                       self.noDataView.tag = 100
                                       self.errorContainer.addSubview(self.noDataView)
                                                                  
                                       
                                       
                                       
                                   }
                                   else
                                   {
                                       
                                       for subview in self.errorContainer.subviews {
                                           
                                           if (subview.tag == 100) {
                                               
                                               subview.removeFromSuperview()
                                           }
                                       }
                                       
                                       self.serverErrorView.errorText.text = "Something went wrong!"
                                       
                                       let width = self.errorContainer.frame.size.width
                                       let height = self.containerView.frame.size.height
                                       self.serverErrorView.frame = CGRect(x:0, y: 0, width: width, height: height)
                                       self.serverErrorView.tag = 100
                                       self.serverErrorView.tryAgainClick.tag = 100
                                       self.errorContainer.addSubview(self.serverErrorView)
                                   }
                                   
                                    break
                                   
                               default:
                                   
                                   for subview in self.errorContainer.subviews {
                                       
                                       if (subview.tag == 100) {
                                           
                                           subview.removeFromSuperview()
                                       }
                                   }
                                   
                                   self.serverErrorView.errorText.text = "Something went wrong!"
                                   
                                   let width = self.containerView.frame.size.width
                                   let height = self.containerView.frame.size.height
                                   self.serverErrorView.frame = CGRect(x:0, y: 0, width: width, height: height)
                                   self.serverErrorView.tag = 100
                                   self.serverErrorView.tryAgainClick.tag = 100
                                   self.errorContainer.addSubview(self.serverErrorView)
                                   
                                   break
                                   
                               }
                               
                           }
                           else
                           {
                               for subview in self.errorContainer.subviews {
                                   
                                   if (subview.tag == 100) {
                                       
                                       subview.removeFromSuperview()
                                   }
                               }
                               
                               self.serverErrorView.errorText.text = "Something went wrong!"
                               
                               let width = self.errorContainer.frame.size.width
                               let height = self.errorContainer.frame.size.height
                               self.serverErrorView.frame = CGRect(x:0, y: 0, width: width, height: height)
                               self.serverErrorView.tag = 100
                               self.serverErrorView.tryAgainClick.tag = 100
                               self.errorContainer.addSubview(self.serverErrorView)
                               
                               
                               
                           
                           }
                           
                       }
                       
                       
                   }
                       
                   else
                   {
                       //Stop loading
                       self.hideHUD()
                       
                       //Checking status
                       if let responseCode = responseData.response?.statusCode
                       {
                           
                           if responseCode == 400 || responseCode == 401
                           {
                               
                               self.logoutApp()
                           }
                           else
                           {
                               for subview in self.errorContainer.subviews {
                                   
                                   if (subview.tag == 100) {
                                       
                                       subview.removeFromSuperview()
                                   }
                               }
                               
                               self.serverErrorView.errorText.text = "Can't connect Server!"+"\n"+"Error: "+String(describing: responseCode)
                               
                               
                               let width = self.errorContainer.frame.size.width
                               let height = self.errorContainer.frame.size.height
                               self.serverErrorView.frame = CGRect(x:0, y: 0, width: width, height: height)
                               self.serverErrorView.tag = 100
                               self.serverErrorView.tryAgainClick.tag = 100
                               self.errorContainer.addSubview(self.serverErrorView)
                           }
                           
                           
                                              
                           
                       }
                       else
                       {
                           
                           for subview in self.containerView.subviews {
                               
                               if (subview.tag == 100) {
                                   
                                   subview.removeFromSuperview()
                               }
                           }
                           
                           self.serverErrorView.errorText.text = "Something went wrong!"
                           
                           let width = self.errorContainer.frame.size.width
                           let height = self.errorContainer.frame.size.height
                           self.serverErrorView.frame = CGRect(x:0, y: 0, width: width, height: height)
                           self.serverErrorView.tag = 100
                           self.serverErrorView.tryAgainClick.tag = 100
                           self.errorContainer.addSubview(self.serverErrorView)
                           
                       }
                       
                   }
               }
    
           
           
       }
  
    
    // MARK: - PagerTabStripDataSource
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        
        let child1 = UIStoryboard.init(name: "Content", bundle: nil).instantiateViewController(withIdentifier: "OverviewFirstScreen") as! OverviewFirstVC
        
        child1.propertyListJson = self.propertyListJson
        
        child1.isTodaySelected = self.isTodaySelected
        child1.isWeekendSelected = self.isWeekendSelected
        child1.isLastWeekSelected = self.isLastWeekSelected
        child1.selectedStartDate = self.selectedStartDate
        child1.selectedEndDate = self.selectedEndDate
        child1.isStarDateSelected = self.isStarDateSelected
        child1.isEndDateSelected = self.isEndDateSelected
        child1.selectedStartDateString = self.selectedStartDateString
        child1.selectedEndDateString = self.selectedEndDateString
            

        let child2 = UIStoryboard.init(name: "Content", bundle: nil).instantiateViewController(withIdentifier: "OverviewSecondScreen") as! OverviewSecondVC
        
        child2.propertyListJson = self.propertyListJson
        
        child2.isTodaySelected = self.isTodaySelected
        child2.isWeekendSelected = self.isWeekendSelected
        child2.isLastWeekSelected = self.isLastWeekSelected
        child2.selectedStartDate = self.selectedStartDate
        child2.selectedEndDate = self.selectedEndDate
        child2.isStarDateSelected = self.isStarDateSelected
        child2.isEndDateSelected = self.isEndDateSelected
        child2.selectedStartDateString = self.selectedStartDateString
        child2.selectedEndDateString = self.selectedEndDateString
        
        let child3 = UIStoryboard.init(name: "Content", bundle: nil).instantiateViewController(withIdentifier: "OverviewThirdScreen") as! OverviewThirdVC
        
        child3.propertyListJson = self.propertyListJson
        
        child3.isTodaySelected = self.isTodaySelected
        child3.isWeekendSelected = self.isWeekendSelected
        child3.isLastWeekSelected = self.isLastWeekSelected
        child3.selectedStartDate = self.selectedStartDate
        child3.selectedEndDate = self.selectedEndDate
        child3.isStarDateSelected = self.isStarDateSelected
        child3.isEndDateSelected = self.isEndDateSelected
        child3.selectedStartDateString = self.selectedStartDateString
        child3.selectedEndDateString = self.selectedEndDateString
           
        
        return [child1, child2, child3]
        
    }

       

}
