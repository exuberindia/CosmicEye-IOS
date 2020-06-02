//
//  ScheduleVC.swift
//  cosmiceye
//
//  Created by Rachin Allakkot on 03/12/19.
//  Copyright © 2019 Exuber. All rights reserved.
//

import UIKit
import SwiftyJSON
import FittedSheets
import Alamofire

class ScheduleVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
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
    @IBOutlet var headerView: UIView!
    
    @IBOutlet var audiSelectClick: UIView!
    @IBOutlet var audiName: UILabel!
    
    
    @IBOutlet var dateSelectClick: UIView!
    @IBOutlet var date: UILabel!
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var scheduleTable: UITableView!
    
    @IBOutlet var bottomContainerView: UIView!
    @IBOutlet var propertySelectClick: UIView!
    @IBOutlet var propertyName: UILabel!
    
    //Declaring variables
    var selectedPropertyPosition = 0
    var selectedAudiPosition = 0
    
    //List for storing
    var propertyListJson:JSON = [:]
    var audiListJson:JSON = [:]
    var scheduleListJson:JSON = [:]
    var scheduleGroupJson:JSON = [:]
    var scheduleListTempJson:JSON = [:]

   
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
    
    private let pullToRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        //Delegate
        scheduleTable.delegate = self
        scheduleTable.dataSource = self
        
        scheduleTable.contentInsetAdjustmentBehavior = .never
        scheduleTable.tableHeaderView = nil
        
        let headerNib = UINib.init(nibName: "ScheduleHeaderView", bundle: Bundle.main)
        scheduleTable.register(headerNib, forHeaderFooterViewReuseIdentifier: "ScheduleHeaderView")

        audiSelectClick.layer.borderWidth = 1
        audiSelectClick.layer.borderColor = UIColor(red:234.0/255.0, green:237.0/255.0, blue:243.0/255.0, alpha: 1.0).cgColor
                     
        //Setting Corner
        audiSelectClick.layer.cornerRadius = 4
        audiSelectClick.clipsToBounds = true
        
        //Pull To Refresh
        pullToRefreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        pullToRefreshControl.tintColor = UIColor(red: 81/255, green: 45/255, blue: 168/255, alpha: 1.0)
        
        if #available(iOS 10.0, *) {
             scheduleTable.refreshControl = pullToRefreshControl
         } else {
             scheduleTable.addSubview(pullToRefreshControl)
         }
                
        
         pullToRefreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
               
        
        //Click Events
        let propertySelectClickTap = UITapGestureRecognizer(target: self, action: #selector(propertySelectClickFunction))
        propertySelectClick.isUserInteractionEnabled = true
        propertySelectClick.addGestureRecognizer(propertySelectClickTap)
        
        let audiSelectClickTap = UITapGestureRecognizer(target: self, action: #selector(audiSelectClickFunction))
        audiSelectClick.isUserInteractionEnabled = true
        audiSelectClick.addGestureRecognizer(audiSelectClickTap)
               
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
        getProperty()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        for subview in self.containerView.subviews {
                   
            if (subview.tag == 100) {
                       
                subview.removeFromSuperview()
            }
        }
        
        for subview in self.bottomContainerView.subviews {
                          
            if (subview.tag == 200) {
                              
                subview.removeFromSuperview()
            }
        }
        
    }
    
  
    
    //Selector Func - Try again click
    @objc private func tryAgainClickTap(_ button: UIButton)
    {
        
        if button.tag == 100
        {
           //Get Property
           getProperty()
               
        }
              
              
        if button.tag == 200
        {
            
            self.setDateValue()
           
        }
              
               
                 
    }
    
    //Func - Pull to refresh
    @objc private func handleRefresh(_ sender: Any)  {
        
        pullToRefreshControl.endRefreshing()
        self.setDateValue()
    }
      
    
    
    
    
    //Set Property Value
    private func setPropertyValue() {
        
        
        let propertyItem = self.propertyListJson[selectedPropertyPosition]
        propertyName.attributedText = NSAttributedString(string: propertyItem["shortCode"].stringValue, attributes:
        [.underlineStyle: NSUnderlineStyle.single.rawValue])
        
        self.propertySelectClick.isHidden = false
        self.headerView.isHidden = false
        
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
    
    private func setAudiValue() {
        

        if !self.scheduleListJson.isEmpty
        {
            for index in 0...(self.scheduleListJson.array?.count)!-1 {
                
                var isFound = false
                
                let scheduleItem = self.scheduleListJson[index]
                
                if !self.audiListJson.isEmpty
                {
                    for indexIn in 0...(self.audiListJson.array?.count)!-1 {
        
                        let audiItem = self.audiListJson[indexIn]
                        
                        if scheduleItem["screen"]["id"].stringValue == audiItem["screen"]["id"].stringValue
                        {
                            isFound = true
                            break
                        }
                        
                    }
                    
                }
  
                if isFound == false
                {
                    
                    var audiScreenItem:JSON = [:]
                    audiScreenItem["name"].string = scheduleItem["screen"]["name"].stringValue
                    audiScreenItem["id"].string = scheduleItem["screen"]["id"].stringValue
                    
                    var audiItem:JSON = [:]
                    audiItem["screen"] = audiScreenItem
                    
                    self.audiListJson.arrayObject?.append(audiItem)
                    

                }
            
            
            }
            
        }
        

    
    }
    
    private func groupScheduleValue() {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "dd MMM yyyy"

        
        self.scheduleGroupJson = JSON([:])
        
        if !self.scheduleListJson.isEmpty
        {
            for index in 0...(self.scheduleListJson.array?.count)!-1 {
                
                let scheduleItem = self.scheduleListJson[index]
                
                let dateScheduleMillis = scheduleItem["startDateTime"].doubleValue
                let dateScheduleVar = Date.init(timeIntervalSince1970: TimeInterval(dateScheduleMillis/1000.0))
                let sheduleDateString = dateFormatter.string(from: dateScheduleVar)
                
                var isFound = false
                
                if !self.scheduleGroupJson.isEmpty
                {
                    
                    for indexIn in 0...(self.scheduleGroupJson.array?.count)!-1 {
                        
                        let groupItem = self.scheduleGroupJson[indexIn]
                        
                        if (groupItem["scheduleDate"].stringValue == sheduleDateString )
                        {
                            isFound = true
                            break
                        }
                        
                    }//Index In
                    
                    
                }//Group Json
                
                if isFound == false
                {
                    
                     var dateItem:JSON = [:]
                     dateItem["scheduleDate"].string = sheduleDateString
                    
                     
                     if scheduleGroupJson.isEmpty
                     {
                         scheduleGroupJson = JSON([dateItem])
                     }
                     else
                     {
                         scheduleGroupJson.arrayObject?.append(dateItem)
                     }
                  
                
                }
                
                
            }//Index
            
        }// Schedule Json
         
        
        if !self.scheduleGroupJson.isEmpty
        {
            for index in 0...(self.scheduleGroupJson.array?.count)!-1 {
                
                var movieListJson = JSON([:])
                let groupItem = self.scheduleGroupJson[index]
                
                if !self.audiListJson.isEmpty
                {
                    
                    for indexIn in 0...(self.audiListJson.array?.count)!-1 {
                        
                        let audiItem = self.audiListJson[indexIn]
                        
                        if !self.scheduleListJson.isEmpty
                        {
                            
                            
                            for indexInIn in 0...(self.scheduleListJson.array?.count)!-1 {
                                
                                let scheduleItem = self.scheduleListJson[indexInIn]
                                
                                let dateScheduleMillis = scheduleItem["startDateTime"].doubleValue
                                let dateScheduleVar = Date.init(timeIntervalSince1970: TimeInterval(dateScheduleMillis/1000.0))
                                let sheduleDateString = dateFormatter.string(from: dateScheduleVar)
                                
                                if (audiItem["screen"]["id"].stringValue == scheduleItem["screen"]["id"].stringValue) &&
                                (groupItem["scheduleDate"].stringValue == sheduleDateString )
                                {
                                    
                                    if movieListJson.isEmpty
                                    {
                                        movieListJson = JSON([scheduleItem])
                                    }
                                    else
                                    {
                                        movieListJson.arrayObject?.append(scheduleItem)
                                    }
                                                        
                                }
                                
                                
                            }
                            
                        }

                        
                    }
                    
                }
                
                
                self.scheduleGroupJson[index]["movieList"] = movieListJson
                
            }
            
           
            
        }

        
        
    }
    
    private func audiValueChanged() {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "dd MMM yyyy"
        
        for subview in self.containerView.subviews {

            if (subview.tag == 100) {

                subview.removeFromSuperview()
            }
        }
        
        for subview in self.bottomContainerView.subviews {

            if (subview.tag == 200) {

                subview.removeFromSuperview()
            }
        }

        self.audiName.text = self.audiListJson[selectedAudiPosition]["screen"]["name"].stringValue

        self.scheduleListTempJson = JSON([:])
        self.scheduleTable.reloadData()

        if selectedAudiPosition == 0
        {
            scheduleListTempJson = scheduleGroupJson
            
            if scheduleListTempJson.isEmpty
            {

                self.noDataView.emptyText.text = "No data available"
                self.noDataView.errorImage.image = UIImage(named: "error_no_data.png")

                let width = self.containerView.frame.size.width
                let height = self.containerView.frame.size.height
                self.noDataView.frame = CGRect(x:0, y: 0, width: width, height: height)
                self.noDataView.tag = 200
                self.containerView.addSubview(self.noDataView)

            }
            else
            {
                self.scheduleTable.reloadData()
                let indexPath = NSIndexPath(row: 0, section: 0)
                self.scheduleTable.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
            }
        }
        else
        {
            
            DispatchQueue.main.async {
                
                
                let selectedAudiId = self.audiListJson[self.selectedAudiPosition]["screen"]["id"].stringValue
                
                if !self.scheduleListJson.isEmpty
                {
                            
                            
                    for index in 0...(self.scheduleListJson.array?.count)!-1 {
                                
                                
                        let scheduleItem = self.scheduleListJson[index]
                                       
                        let dateScheduleMillis = scheduleItem["startDateTime"].doubleValue
                        let dateScheduleVar = Date.init(timeIntervalSince1970: TimeInterval(dateScheduleMillis/1000.0))
                        let sheduleDateString = dateFormatter.string(from: dateScheduleVar)
                        
                        var isFound = false
                                
                                
                        if !self.scheduleListTempJson.isEmpty
                        {
                            for indexIn in 0...(self.scheduleListTempJson.array?.count)!-1 {
                                                  
                                  
                                let groupItem = self.scheduleListTempJson[indexIn]
                                
                                if (groupItem["scheduleDate"].stringValue == sheduleDateString) &&
                                    (groupItem["id"].stringValue == selectedAudiId)
                                    
                                {
                                    isFound = true
                                    break
                                }
                            
                                              
                                              
                            }//Index In
                        
                                            
                          
                                             
                                        
                        }//Group Temp Json
                          
                        if isFound == false
                        {
                            
                             var dateItem:JSON = [:]
                             dateItem["scheduleDate"].string = sheduleDateString
                             dateItem["id"].string = scheduleItem["screen"]["id"].stringValue
                            
                             
                            if self.scheduleListTempJson.isEmpty
                             {
                                self.scheduleListTempJson = JSON([dateItem])
                             }
                             else
                             {
                                self.scheduleListTempJson.arrayObject?.append(dateItem)
                             }
                          
                        
                        }
                                
                                
                                
                            
                    }//Index
                            
                        
                }//Schedule Temp Json
                
                if !self.scheduleListTempJson.isEmpty
                {
                    
                    for index in 0...(self.scheduleListTempJson.array?.count)!-1 {
                        
                        
                        var movieListJson = JSON([:])
                        let groupItem = self.scheduleListTempJson[index]
                        
                        if !self.scheduleListJson.isEmpty
                        {
                            for indexIn in 0...(self.scheduleListJson.array?.count)!-1 {
                                
                                let scheduleItem = self.scheduleListJson[indexIn]
                                
                                let dateScheduleMillis = scheduleItem["startDateTime"].doubleValue
                                let dateScheduleVar = Date.init(timeIntervalSince1970: TimeInterval(dateScheduleMillis/1000.0))
                                let sheduleDateString = dateFormatter.string(from: dateScheduleVar)
                                
                                if (selectedAudiId == scheduleItem["screen"]["id"].stringValue) &&
                                (groupItem["scheduleDate"].stringValue == sheduleDateString )
                                {
                                    
                                    if movieListJson.isEmpty
                                    {
                                        movieListJson = JSON([scheduleItem])
                                    }
                                    else
                                    {
                                        movieListJson.arrayObject?.append(scheduleItem)
                                    }
                                                        
                                }
                                
                            }
                            
                        }
                        
                        if !movieListJson.isEmpty
                        {
                            self.scheduleListTempJson[index]["movieList"] = movieListJson
                        }
                        
                    }
                
                }
                
                if self.scheduleListTempJson.isEmpty
                {

                    self.noDataView.emptyText.text = "No data available"
                    self.noDataView.errorImage.image = UIImage(named: "error_no_data.png")

                    let width = self.containerView.frame.size.width
                    let height = self.containerView.frame.size.height
                    self.noDataView.frame = CGRect(x:0, y: 0, width: width, height: height)
                    self.noDataView.tag = 200
                    self.containerView.addSubview(self.noDataView)

                }
                else
                {
                    self.scheduleTable.reloadData()
                    let indexPath = NSIndexPath(row: 0, section: 0)
                    self.scheduleTable.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
                }
                
            }
  
            
        }


        
        


        
        
    
        
    }
    
    func setDateValue() {
        
        
        
        var selectedDateText = ""
        var startDateText = ""
        var endDateText = ""
        
        if isTodaySelected
        {
            
            
            let currentDate = Date()
            let startDate = currentDate.setDateTime(hour: 0, min: 0, sec: 0, yourDate: currentDate)
            let endDate = currentDate.setDateTime(hour: 23, min: 59, sec: 59, yourDate: currentDate)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM"
                       
            let startDateString = formatter.string(from: startDate!)
            let endDateString = formatter.string(from: endDate!)
            
            selectedDateText = startDateString+" - "+endDateString
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
            let startString = dateFormatter.string(from: startDate!)
            let endString = dateFormatter.string(from: endDate!)
            print(startString)
            print(endString)
            
            
            startDateText = String(Int((startDate!.timeIntervalSince1970)))
            endDateText = String(Int(endDate!.timeIntervalSince1970))
               
               
               
              
               
               
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
                
                let formatter = DateFormatter()
                formatter.dateFormat = "dd MMM"
                           
                let startDateString = formatter.string(from: startDate!)
                let endDateString = formatter.string(from: endDate!)
                
                selectedDateText = startDateString+" - "+endDateString
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
                let startString = dateFormatter.string(from: startDate!)
                let endString = dateFormatter.string(from: endDate!)
                print(startString)
                print(endString)
                
                
                startDateText = String(Int((startDate!.timeIntervalSince1970)))
                endDateText = String(Int(endDate!.timeIntervalSince1970))
                
                
               
            }
            else if components.weekday == 6 {
                
                let lastFriday = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentDate)!
                let lastSunday = currentDate.previous(.sunday)
                
                let startDate = lastFriday.setDateTime(hour: 0, min: 0, sec: 0, yourDate: lastFriday)
                let endDate = lastSunday.setDateTime(hour: 23, min: 59, sec: 59, yourDate: lastSunday)
                
                let formatter = DateFormatter()
                formatter.dateFormat = "dd MMM"
                           
                let startDateString = formatter.string(from: startDate!)
                let endDateString = formatter.string(from: endDate!)
                
                selectedDateText = startDateString+" - "+endDateString
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
                let startString = dateFormatter.string(from: startDate!)
                let endString = dateFormatter.string(from: endDate!)
                print(startString)
                print(endString)
                
                
                startDateText = String(Int((startDate!.timeIntervalSince1970)))
                endDateText = String(Int(endDate!.timeIntervalSince1970))
                   
   
                  
            }else if components.weekday == 7 {
                
                let lastSaturday = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentDate)!
                let lastFriday = lastSaturday.previous(.friday)
                let lastSunday = currentDate.previous(.sunday)
                
                let startDate = lastFriday.setDateTime(hour: 0, min: 0, sec: 0, yourDate: lastFriday)
                let endDate = lastSunday.setDateTime(hour: 23, min: 59, sec: 59, yourDate: lastSunday)
                
                let formatter = DateFormatter()
                formatter.dateFormat = "dd MMM"
                           
                let startDateString = formatter.string(from: startDate!)
                let endDateString = formatter.string(from: endDate!)
                
                selectedDateText = startDateString+" - "+endDateString
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
                let startString = dateFormatter.string(from: startDate!)
                let endString = dateFormatter.string(from: endDate!)
                print(startString)
                print(endString)
                
                
                startDateText = String(Int((startDate!.timeIntervalSince1970)))
                endDateText = String(Int(endDate!.timeIntervalSince1970))
               
            }
            else
            {
                let lastFriday = currentDate.previous(.friday)
                let lastSunday = currentDate.previous(.sunday)
                
                let startDate = lastFriday.setDateTime(hour: 0, min: 0, sec: 0, yourDate: lastFriday)
                let endDate = lastSunday.setDateTime(hour: 23, min: 59, sec: 59, yourDate: lastSunday)
                
                let formatter = DateFormatter()
                formatter.dateFormat = "dd MMM"
                           
                let startDateString = formatter.string(from: startDate!)
                let endDateString = formatter.string(from: endDate!)
                
                selectedDateText = startDateString+" - "+endDateString
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
                let startString = dateFormatter.string(from: startDate!)
                let endString = dateFormatter.string(from: endDate!)
                print(startString)
                print(endString)
                
                
                startDateText = String(Int((startDate!.timeIntervalSince1970)))
                endDateText = String(Int(endDate!.timeIntervalSince1970))
                   
                   
            }
               

        }else if isLastWeekSelected
        {
            
            
            
            let currentDate = Date()
            let calendar = Calendar(identifier: .gregorian)
            let components = calendar.dateComponents([.weekday], from: currentDate)
            
            if components.weekday == 2 {
                
                let startDate = currentDate.setDateTime(hour: 0, min: 0, sec: 0, yourDate: currentDate)
                let endDate = currentDate.setDateTime(hour: 23, min: 59, sec: 59, yourDate: currentDate)
                
                let formatter = DateFormatter()
                formatter.dateFormat = "dd MMM"
                           
                let startDateString = formatter.string(from: startDate!)
                let endDateString = formatter.string(from: endDate!)
                
                selectedDateText = startDateString+" - "+endDateString
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
                let startString = dateFormatter.string(from: startDate!)
                let endString = dateFormatter.string(from: endDate!)
                print(startString)
                print(endString)
                
                
                startDateText = String(Int((startDate!.timeIntervalSince1970)))
                endDateText = String(Int(endDate!.timeIntervalSince1970))
                
                
            }
            else
            {
                
                let lastMonday = currentDate.previous(.monday)
                let startDate = lastMonday.setDateTime(hour: 0, min: 0, sec: 0, yourDate: lastMonday)
                let endDate = currentDate.setDateTime(hour: 23, min: 59, sec: 59, yourDate: currentDate)
                
                let formatter = DateFormatter()
                formatter.dateFormat = "dd MMM"
                           
                let startDateString = formatter.string(from: startDate!)
                let endDateString = formatter.string(from: endDate!)
                           
                selectedDateText = startDateString+" - "+endDateString
                           
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
                let startString = dateFormatter.string(from: startDate!)
                let endString = dateFormatter.string(from: endDate!)
                print(startString)
                print(endString)
                
                
                startDateText = String(Int((startDate!.timeIntervalSince1970)))
                endDateText = String(Int(endDate!.timeIntervalSince1970))
                
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
            
            
            startDateText = String(Int((startDate!.timeIntervalSince1970)))
            endDateText = String(Int(endDate!.timeIntervalSince1970))
              
        }
        
        self.date.text = selectedDateText
 
        
        let storedPropertyId  = UserDefaults.standard.string(forKey: STORED_PROPERTY_ID)!
        getSchedule(propertyId: storedPropertyId, startDate: startDateText, endDate: endDateText)
           
    }
    
    //Selector Func - Property Select Click
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
    
    //Selector Func - Audi Select Click
    @objc private func audiSelectClickFunction() {
        
        let controller = AudiScheduleSheetVC.instantiate()
           
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
            
            if self.selectedAudiPosition != controller.selectedAudiPosition
            {
               
                self.selectedAudiPosition = controller.selectedAudiPosition
                
                self.audiValueChanged()
                
                
            }
        }
        
        controller.selectedAudiPosition = selectedAudiPosition
        controller.audiListJson = audiListJson
        
        
        self.present(sheetController, animated: false, completion: nil)
               
               
    }
    
    //Selector Func - Date Select Click
    @objc private func dateSelectClickFunction() {
        
        let controller = DateScheduleSheetVC.instantiate()
        let sheetController = SheetViewController(controller: controller, sizes:  [ .fixed(472)])
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
        
        
        self.selectedAudiPosition = 0
       
        
        self.propertyListJson = JSON([:])
        self.audiListJson = JSON([:])
        self.scheduleListJson = JSON([:])
        self.scheduleGroupJson = JSON([:])
        self.scheduleListTempJson = JSON([:])
        
        self.scheduleTable.reloadData()
        
        self.propertySelectClick.isHidden = true
        self.headerView.isHidden = true
        self.scheduleTable.isHidden = true
        self.bottomContainerView.isHidden = true

        
       
        
        for subview in self.containerView.subviews {
                   
            if (subview.tag == 100) {
                       
                subview.removeFromSuperview()
            }
        }
        
        for subview in self.bottomContainerView.subviews {
                          
            if (subview.tag == 200) {
                              
                subview.removeFromSuperview()
            }
        }
        

        
        //Checking internet connection
        if Reachability.isConnectedToNetwork()
        {
            //Setting empty background
            let width = self.containerView.frame.size.width
            let height = self.containerView.frame.size.height
            let emptyView = UIView(frame: CGRect(x: 0, y: 0, width:width , height: height))
            emptyView.tag = 100
            self.containerView.addSubview(emptyView)
                                  
            DispatchQueue.main.async {
                
                //Calling Service
                self.callGetPropertyService()
            }
            
        }
        else
        {
            
            //Setting no internet background
            let width = self.containerView.frame.size.width
            let height = self.containerView.frame.size.height
            
           
            self.noInternetView.frame = CGRect(x:0, y: 0, width: width, height: height)
            
            self.noInternetView.tag = 100
            self.noInternetView.tryAgainClick.tag = 100
            self.containerView.addSubview(noInternetView)
            
            
            
            
        }
    }
    
    
    
    //Func - Get Schedule
    func getSchedule(propertyId:String,startDate:String,endDate:String ) -> Void {
        
        
        self.selectedAudiPosition = 0
        self.audiListJson = JSON([:])
        
        var audiAllScreenItem:JSON = [:]
        audiAllScreenItem["name"].string = "All Screens"
        audiAllScreenItem["id"].string = "-1"
        
        var audiAllItem:JSON = [:]
        audiAllItem["screen"] = audiAllScreenItem
        
        
        self.audiListJson = JSON([audiAllItem])
        self.audiName.text = self.audiListJson[selectedAudiPosition]["screen"]["name"].stringValue
        
        self.scheduleListJson = JSON([:])
        self.scheduleGroupJson = JSON([:])
        self.scheduleListTempJson = JSON([:])
        self.scheduleTable.reloadData()
        
        self.scheduleTable.isHidden = true
        self.bottomContainerView.isHidden = false
        
        for subview in self.containerView.subviews {
                   
            if (subview.tag == 100) {
                       
                subview.removeFromSuperview()
            }
        }
        
        for subview in self.bottomContainerView.subviews {
                   
            if (subview.tag == 200) {
                       
                subview.removeFromSuperview()
            }
        }
    
        
        //Checking internet connection
        if Reachability.isConnectedToNetwork()
        {
            //Setting empty background
            let width = self.bottomContainerView.frame.size.width
            let height = self.bottomContainerView.frame.size.height
            let emptyView = UIView(frame: CGRect(x: 0, y: 0, width:width , height: height))
            emptyView.tag = 200
            self.bottomContainerView.addSubview(emptyView)
                                  
            DispatchQueue.main.async {
                
                //Calling Service
                self.callGetScheduleService(propertyId: propertyId, startDate: startDate, endDate: endDate)
            }
            
        }
        else
        {
            //Setting no internet background
            let width = self.bottomContainerView.frame.size.width
            let height = self.bottomContainerView.frame.size.height
            
            self.noInternetView.frame = CGRect(x:0, y: 0, width: width, height: height)
            
            self.noInternetView.tag = 200
            self.noInternetView.tryAgainClick.tag = 200
            self.bottomContainerView.addSubview(noInternetView)
            
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
                    
                    
                    
                    switch responseData.result
                    {
                    case let .success(value):
                        
                        self.propertyListJson = JSON.init(parseJSON: value)
                        
                        
                        //print(self.propertyListJson)
                        
                        if self.propertyListJson.isEmpty
                        {
                            //Stop loading
                            self.hideHUD()
                            
                            for subview in self.containerView.subviews {
                                if (subview.tag == 100) {
                                                                       
                                    subview.removeFromSuperview()
                                }
                                                                   
                            
                            }
                            
                            self.noDataView.emptyText.text = "No data available"
                            self.noDataView.errorImage.image = UIImage(named: "error_no_data.png")
                                                           
                            let width = self.containerView.frame.size.width
                            let height = self.containerView.frame.size.height
                            self.noDataView.frame = CGRect(x:0, y: 0, width: width, height: height)
                            self.noDataView.tag = 100
                            self.containerView.addSubview(self.noDataView)
                   
                            
                        }
                        else
                        {
                            
                            for subview in self.containerView.subviews {
                                
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
                        
                       
                        //Stop loading
                        self.hideHUD()
                        
                        print("Failure")
                        print(error)
                        
                        if let error = error as? AFError {
                            
                            switch error
                            {
                            case .responseSerializationFailed(let reason):
                                if case .inputDataNilOrZeroLength = reason  {
                                    
                                    for subview in self.containerView.subviews {
                                        if (subview.tag == 100) {
                                                                               
                                            subview.removeFromSuperview()
                                        }
                                                                           
                                    
                                    }
                                    
                                    self.noDataView.emptyText.text = "No data available"
                                    self.noDataView.errorImage.image = UIImage(named: "error_no_data.png")
                                                                   
                                    let width = self.containerView.frame.size.width
                                    let height = self.containerView.frame.size.height
                                    self.noDataView.frame = CGRect(x:0, y: 0, width: width, height: height)
                                    self.noDataView.tag = 100
                                    self.containerView.addSubview(self.noDataView)
                                                               
                                    
                                    
                                    
                                }
                                else
                                {
                                    
                                    for subview in self.containerView.subviews {
                                        
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
                                    self.containerView.addSubview(self.serverErrorView)
                                }
                                
                                 break
                                
                            default:
                                
                                for subview in self.containerView.subviews {
                                    
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
                                self.containerView.addSubview(self.serverErrorView)
                                
                                break
                                
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
                            
                            let width = self.containerView.frame.size.width
                            let height = self.containerView.frame.size.height
                            self.serverErrorView.frame = CGRect(x:0, y: 0, width: width, height: height)
                            self.serverErrorView.tag = 100
                            self.serverErrorView.tryAgainClick.tag = 100
                            self.containerView.addSubview(self.serverErrorView)
                            
                            
                            
                        
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
                            for subview in self.containerView.subviews {
                                
                                if (subview.tag == 100) {
                                    
                                    subview.removeFromSuperview()
                                }
                            }
                            
                            self.serverErrorView.errorText.text = "Can't connect Server!"+"\n"+"Error: "+String(describing: responseCode)
                            
                            
                            let width = self.containerView.frame.size.width
                            let height = self.containerView.frame.size.height
                            self.serverErrorView.frame = CGRect(x:0, y: 0, width: width, height: height)
                            self.serverErrorView.tag = 100
                            self.serverErrorView.tryAgainClick.tag = 100
                            self.containerView.addSubview(self.serverErrorView)
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
                        
                        let width = self.containerView.frame.size.width
                        let height = self.containerView.frame.size.height
                        self.serverErrorView.frame = CGRect(x:0, y: 0, width: width, height: height)
                        self.serverErrorView.tag = 100
                        self.serverErrorView.tryAgainClick.tag = 100
                        self.containerView.addSubview(self.serverErrorView)
                        
                    }
                    
                }
            }
           
        
           
    }
    
    
    
    //Service - Schedule
    func callGetScheduleService(propertyId:String,startDate:String,endDate:String) -> Void {
           
           //Showing Loading
           showHUD()
           
           let accessTokenId  = UserDefaults.standard.string(forKey: LOGIN_ACCESSTOKEN_ID)
             
           let headers: HTTPHeaders = [
               "Authorization": "Bearer "+accessTokenId!
           ]
           
           print("Schedule Headers")
           print(headers)
           print("\n")
     
           
           //Creating request
           let urlString = GET_SCHEDULE_API+"property/"+propertyId+"/start-date/"+startDate+"/end-date/"+endDate
           
           print("Schedule URL")
           print(urlString)
           print("\n")
           
           let alamoRequest = Alamofire.request(urlString, method: .get,  encoding: URLEncoding.default, headers: headers)
           
           print("Schedule Request")
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
                           
                           self.scheduleListJson = JSON.init(parseJSON: value)
                           
                           
                           //print(self.scheduleListJson)
                           
                           if self.scheduleListJson.isEmpty
                           {
                               
                               for subview in self.bottomContainerView.subviews {
                                   if (subview.tag == 200) {
                                                                          
                                       subview.removeFromSuperview()
                                   }
                                                                      
                               
                               }
                            
                            self.noDataView.emptyText.text = "No data available"
                            self.noDataView.errorImage.image = UIImage(named: "error_no_data.png")
                                                           
                            let width = self.bottomContainerView.frame.size.width
                            let height = self.bottomContainerView.frame.size.height
                            self.noDataView.frame = CGRect(x:0, y: 0, width: width, height: height)
                            self.noDataView.tag = 200
                            self.bottomContainerView.addSubview(self.noDataView)
                               
                               
                              
                             
                               
                           }
                           else
                           {
                               
                               for subview in self.bottomContainerView.subviews {
                                   
                                   if (subview.tag == 200) {
                                       
                                       subview.removeFromSuperview()
                                   }
                               }
                            
                            self.setAudiValue()
                            self.groupScheduleValue()
                            self.scheduleTable.isHidden = false
                            self.audiValueChanged()
                            
                
                               
                               
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
                                       
                                       for subview in self.bottomContainerView.subviews {
                                           if (subview.tag == 200) {
                                                                                  
                                               subview.removeFromSuperview()
                                           }
                                                                              
                                       
                                       }
                                    
                                    self.noDataView.emptyText.text = "No data available"
                                    self.noDataView.errorImage.image = UIImage(named: "error_no_data.png")
                                                                   
                                    let width = self.bottomContainerView.frame.size.width
                                    let height = self.bottomContainerView.frame.size.height
                                    self.noDataView.frame = CGRect(x:0, y: 0, width: width, height: height)
                                    self.noDataView.tag = 200
                                    self.bottomContainerView.addSubview(self.noDataView)
                                       
                                       
                                       
                                   }
                                   else
                                   {
                                       
                                       for subview in self.bottomContainerView.subviews {
                                           
                                           if (subview.tag == 200) {
                                               
                                               subview.removeFromSuperview()
                                           }
                                       }
                                       
                                       self.serverErrorView.errorText.text = "Something went wrong!"
                                       
                                       let width = self.bottomContainerView.frame.size.width
                                       let height = self.bottomContainerView.frame.size.height
                                       self.serverErrorView.frame = CGRect(x:0, y: 0, width: width, height: height)
                                       self.serverErrorView.tag = 200
                                       self.serverErrorView.tryAgainClick.tag = 200
                                       self.bottomContainerView.addSubview(self.serverErrorView)
                                   }
                                   
                                    break
                                   
                               default:
                                   
                                   for subview in self.bottomContainerView.subviews {
                                       
                                       if (subview.tag == 200) {
                                           
                                           subview.removeFromSuperview()
                                       }
                                   }
                                   
                                   self.serverErrorView.errorText.text = "Something went wrong!"
                                   
                                   let width = self.bottomContainerView.frame.size.width
                                   let height = self.bottomContainerView.frame.size.height
                                   self.serverErrorView.frame = CGRect(x:0, y: 0, width: width, height: height)
                                   self.serverErrorView.tag = 200
                                   self.serverErrorView.tryAgainClick.tag = 200
                                   self.bottomContainerView.addSubview(self.serverErrorView)
                                   
                                   break
                                   
                               }
                               
                           }
                           else
                           {
                               for subview in self.bottomContainerView.subviews {
                                   
                                   if (subview.tag == 200) {
                                       
                                       subview.removeFromSuperview()
                                   }
                               }
                               
                               self.serverErrorView.errorText.text = "Something went wrong!"
                               
                               let width = self.bottomContainerView.frame.size.width
                               let height = self.bottomContainerView.frame.size.height
                               self.serverErrorView.frame = CGRect(x:0, y: 0, width: width, height: height)
                               self.serverErrorView.tag = 200
                               self.serverErrorView.tryAgainClick.tag = 200
                               self.bottomContainerView.addSubview(self.serverErrorView)
                           
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
                               for subview in self.bottomContainerView.subviews {
                                   
                                   if (subview.tag == 200) {
                                       
                                       subview.removeFromSuperview()
                                   }
                               }
                               
                               self.serverErrorView.errorText.text = "Can't connect Server!"+"\n"+"Error: "+String(describing: responseCode)
                               
                               
                               let width = self.bottomContainerView.frame.size.width
                               let height = self.bottomContainerView.frame.size.height
                               self.serverErrorView.frame = CGRect(x:0, y: 0, width: width, height: height)
                               self.serverErrorView.tag = 200
                               self.serverErrorView.tryAgainClick.tag = 200
                               self.bottomContainerView.addSubview(self.serverErrorView)
                           }
                           
                           
                                              
                           
                       }
                       else
                       {
                           
                           for subview in self.bottomContainerView.subviews {
                               
                               if (subview.tag == 200) {
                                   
                                   subview.removeFromSuperview()
                               }
                           }
                           
                           self.serverErrorView.errorText.text = "Something went wrong!"
                           
                           let width = self.bottomContainerView.frame.size.width
                           let height = self.bottomContainerView.frame.size.height
                           self.serverErrorView.frame = CGRect(x:0, y: 0, width: width, height: height)
                           self.serverErrorView.tag = 200
                           self.serverErrorView.tryAgainClick.tag = 200
                           self.bottomContainerView.addSubview(self.serverErrorView)
                           
                       }
                       
                   }
               }
  
           
       }
    
      
    
    
       
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
           return .lightContent
    }

    
    //TableView protocols
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
         //Checking list for empty
        if self.scheduleListTempJson.isEmpty {
            return 0
        }
                                
                                    
        return (self.scheduleListTempJson.array?.count)!
    }
              
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if scheduleListTempJson[section]["movieList"].isEmpty {
            return 0
        }
        
        
        return (scheduleListTempJson[section]["movieList"].array?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Configure the cell...
        let scheduleCell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell", for: indexPath) as! ScheduleCell
        
        
        
        scheduleCell.scheduleMovieBackground.backgroundColor = getScheduleBackgroundColor(rowPosition: indexPath.row,sectionPosition: indexPath.section)
        
        let scheduleList = scheduleListTempJson[indexPath.section]["movieList"].arrayValue
               
        let scheduleItem = scheduleList[indexPath.row]
        
        if scheduleItem["movieDisplayName"].stringValue.isEmpty
        {
            scheduleCell.movieName.text = scheduleItem["movie"]["name"].stringValue
            
        }
        else
        {
            scheduleCell.movieName.text = scheduleItem["movieDisplayName"].stringValue
        }
 
        scheduleCell.movieLanguage.text = scheduleItem["movie"]["language"]["name"].stringValue
        
        let attrsMedium = [NSAttributedString.Key.font :UIFont(name: "Poppins-Medium", size: 13)!, NSAttributedString.Key.foregroundColor : UIColor(red: 62/255, green: 63/255, blue: 66/255, alpha: 1.0)]

        let attrsRegular = [NSAttributedString.Key.font : UIFont(name: "Poppins-Regular", size: 13)!, NSAttributedString.Key.foregroundColor : UIColor(red: 158/255, green: 160/255, blue: 165/255, alpha: 1.0)]
        
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        
        let dateStartMillis = scheduleItem["startDateTime"].doubleValue
        let dateStartVar = Date.init(timeIntervalSince1970: TimeInterval(dateStartMillis/1000.0))
        let audiTimeStartString = dateFormatter.string(from: dateStartVar)
        
        let dateEndMillis = scheduleItem["endDateTime"].doubleValue
        let dateEndVar = Date.init(timeIntervalSince1970: TimeInterval(dateEndMillis/1000.0))
        let audiTimeEndString = dateFormatter.string(from: dateEndVar)
        
        
        
        let attributedStringStartTime = NSMutableAttributedString(string:audiTimeStartString, attributes:attrsMedium)
        let attributedStringEndTime = NSMutableAttributedString(string:" \n"+audiTimeEndString, attributes:attrsRegular)

        attributedStringStartTime.append(attributedStringEndTime)
        scheduleCell.scheduleName.lineBreakMode = .byWordWrapping
        scheduleCell.scheduleName.attributedText = attributedStringStartTime
        
        scheduleCell.audiName.text = scheduleItem["screen"]["name"].stringValue
        
        //Setting Constraints
        if indexPath.row == 0
        {
            scheduleCell.audiNameHeightConstraint.constant = 18
            scheduleCell.audiBottomViewHeightConstraint.constant = 1
            
            scheduleCell.audiNameTopConstraint.constant = 0
            scheduleCell.audiBottomViewTopConstraint.constant = 16
        }
        else
        {
            let indexPathPrevious = indexPath.row-1
            
                
            let scheduleItemPrevious = scheduleList[indexPathPrevious]
            
            let audiIdCurrent = scheduleItem["screen"]["id"].stringValue
            let audiIdPrevious = scheduleItemPrevious["screen"]["id"].stringValue
            
            if audiIdCurrent == audiIdPrevious
            {
                scheduleCell.audiNameHeightConstraint.constant = 0
                scheduleCell.audiBottomViewHeightConstraint.constant = 0
                
                scheduleCell.audiNameTopConstraint.constant = 0
                scheduleCell.audiBottomViewTopConstraint.constant = 0
                
            }
            else
            {
                scheduleCell.audiNameHeightConstraint.constant = 18
                scheduleCell.audiBottomViewHeightConstraint.constant = 1
                
                scheduleCell.audiNameTopConstraint.constant = 24
                scheduleCell.audiBottomViewTopConstraint.constant = 16
            }
            
            
        }
        
        return scheduleCell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
       
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
       
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
               
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ScheduleHeaderView") as! ScheduleHeaderView
        
        let scheduleItem = scheduleListTempJson[section]
        headerView.audiName.text = scheduleItem["scheduleDate"].stringValue
           
                      
        return headerView
    }
       
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 54
           
    }
       
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return .leastNormalMagnitude
    }
    
    
       
       
       
       
       
       
    
    

    

}
