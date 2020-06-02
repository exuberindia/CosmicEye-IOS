//
//  OverviewFirstVC.swift
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

class OverviewFirstVC: UIViewController,IndicatorInfoProvider, UITableViewDelegate, UITableViewDataSource {

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
    

   
    @IBOutlet var containerView: UIView!
    @IBOutlet var overviewFirstTable: UITableView!
    
    //Declaring variables
    var propertyListJson:JSON = [:]
    var audiListJson:JSON = [:]
    var overviewListJson:JSON = [:]
    var overviewListTempJson:JSON = [:]
    var overviewGroupListJson:JSON = [:]
 
    var selectedAudiPosition = 0
   
    
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
        overviewFirstTable.delegate = self
        overviewFirstTable.dataSource = self
        
        overviewFirstTable.contentInsetAdjustmentBehavior = .never
        overviewFirstTable.tableHeaderView = nil
        
        
        audiSelectClick.layer.borderWidth = 1
        audiSelectClick.layer.borderColor = UIColor(red:234.0/255.0, green:237.0/255.0, blue:243.0/255.0, alpha: 1.0).cgColor
        
              
        //Setting Corner
        audiSelectClick.layer.cornerRadius = 4
        audiSelectClick.clipsToBounds = true
        
        
        if !self.propertyListJson.isEmpty
        {
           
            self.setDateValue()
               
        }
        
        //Pull To Refresh
        pullToRefreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        pullToRefreshControl.tintColor = UIColor(red: 81/255, green: 45/255, blue: 168/255, alpha: 1.0)
           
        if #available(iOS 10.0, *) {
             overviewFirstTable.refreshControl = pullToRefreshControl
         } else {
             overviewFirstTable.addSubview(pullToRefreshControl)
         }
                
        
         pullToRefreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        
        
        //Click events
        let audiSelectClickTap = UITapGestureRecognizer(target: self, action: #selector(audiSelectClickFunction))
        audiSelectClick.isUserInteractionEnabled = true
        audiSelectClick.addGestureRecognizer(audiSelectClickTap)
        
        
        noInternetView.tryAgainClick.addTarget(self, action:#selector(tryAgainClickTap(_:))
                                 , for: .touchUpInside)
                      
        serverErrorView.tryAgainClick.addTarget(self, action:#selector(tryAgainClickTap(_:))
                      , for: .touchUpInside)
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
    }
       
    
    //Selector Func - Try again click
    @objc private func tryAgainClickTap(_ button: UIButton)
    {
        
        self.setDateValue()
    
           
    }
    
    //Func - Pull to refresh
    @objc private func handleRefresh(_ sender: Any)  {
        
        pullToRefreshControl.endRefreshing()
        self.setDateValue()
    }
    
    
    private func setAudiValue() {
        
        
        DispatchQueue.main.async {
            
            if !self.overviewListJson.isEmpty
            {
                
                for index in 0...(self.overviewListJson.array?.count)!-1 {
                    
                    var isFound = false
                    
                    let overviewItem = self.overviewListJson[index]
                    
                    if !self.audiListJson.isEmpty
                    {
                        for indexIn in 0...(self.audiListJson.array?.count)!-1 {
                            
                            
                            let audiItem = self.audiListJson[indexIn]
                            
                            if overviewItem["timeSlot"]["screen"]["id"].stringValue == audiItem["screen"]["id"].stringValue
                            {
                                isFound = true
                                break
                            }
                            
                        }
                        
                    }

                    
                    if isFound == false
                    {
                        
                        var audiScreenItem:JSON = [:]
                        audiScreenItem["name"].string = overviewItem["timeSlot"]["screen"]["name"].stringValue
                        audiScreenItem["id"].string = overviewItem["timeSlot"]["screen"]["id"].stringValue
                        
                        var audiItem:JSON = [:]
                        audiItem["screen"] = audiScreenItem
                        
                        self.audiListJson.arrayObject?.append(audiItem)
                    }
                    
                  
                
                }
                
            }
        }
        
        
        
   
    }
    
    private func audiValueChanged() {
        

        for subview in self.containerView.subviews {
                   
            if (subview.tag == 100) {
                       
                subview.removeFromSuperview()
            }
        }
        
        self.audiName.text = self.audiListJson[selectedAudiPosition]["screen"]["name"].stringValue
        
        self.overviewListTempJson = JSON([:])

        if selectedAudiPosition == 0
        {
            overviewListTempJson = overviewListJson
        }
        else
        {
            
            if !overviewListJson.isEmpty
            {
                let selectedAudiId = self.audiListJson[selectedAudiPosition]["screen"]["id"].stringValue
                
                for index in 0...(self.overviewListJson.array?.count)!-1 {
                    
                    let overviewItem = self.overviewListJson[index]
                    
                    if overviewItem["timeSlot"]["screen"]["id"].stringValue == selectedAudiId
                    {
                        if overviewListTempJson.isEmpty
                        {
                            overviewListTempJson = JSON([overviewItem])
                        }
                        else
                        {
                            overviewListTempJson.arrayObject?.append(overviewItem)
                        }
                    }
                }
                
            }
        }
        
        
        if overviewListTempJson.isEmpty
        {
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
            self.groupOverViewData()
           
        }
        
    
        
    }
    
    private func groupOverViewData() {
        
        
        
        self.overviewGroupListJson = JSON([:])
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        if !self.overviewListTempJson.isEmpty
        {
            
            for index in 0...(self.overviewListTempJson.array?.count)!-1 {
                
                let overviewItem = self.overviewListTempJson[index]
                
                let dateOverviewMillis = overviewItem["timeSlot"]["startDateTime"].doubleValue
                let dateOverviewVar = Date.init(timeIntervalSince1970: TimeInterval(dateOverviewMillis/1000.0))
                
                let overviewDateString = dateFormatter.string(from: dateOverviewVar)
                
                
                var isFound = false
                
                if !overviewGroupListJson.isEmpty
                {
                    for indexIn in 0...(overviewGroupListJson.array?.count)!-1 {
                        
                        let groupItem = self.overviewGroupListJson[indexIn]
                        
                        if groupItem["createdDate"].stringValue == overviewDateString
                        {
                            isFound = true
                            break
                            
                        }
                    }
                }
                
                if isFound == false
                {
                    
                    var groupItem:JSON = [:]
                    groupItem["createdDate"].string = overviewDateString
                    
                    let dateFormatterDisplay = DateFormatter()
                    dateFormatterDisplay.locale = Locale(identifier: "en_US")
                    dateFormatterDisplay.dateFormat = "d MMM, yyyy"
                     
                    
                     groupItem["displayDate"].string = dateFormatterDisplay.string(from: dateOverviewVar)
                    
                    
                    
                    
                    if overviewGroupListJson.isEmpty
                    {
                        overviewGroupListJson = JSON([groupItem])
                    }
                    else
                    {
                        overviewGroupListJson.arrayObject?.append(groupItem)
                    }
             
                }
       
                
            }
            
        }
        
        
    
        
        
        if !self.overviewGroupListJson.isEmpty
        {
            
            for index in 0...(self.overviewGroupListJson.array?.count)!-1 {
                
                let groupItem = self.overviewGroupListJson[index]
                
                var tempJson:JSON = [:]
                
                if !self.overviewListTempJson.isEmpty
                {
                    
                    for indexIn in 0...(self.overviewListTempJson.array?.count)!-1 {
                        
                        let overviewItem = self.overviewListTempJson[indexIn]
                                           
                        let dateOverviewMillis = overviewItem["timeSlot"]["startDateTime"].doubleValue
                        let dateOverviewVar = Date.init(timeIntervalSince1970: TimeInterval(dateOverviewMillis/1000.0))
                                           
                        let overviewDateString = dateFormatter.string(from: dateOverviewVar)
                        
                        if groupItem["createdDate"].stringValue == overviewDateString
                        {
                            
                            if tempJson.isEmpty
                            {
                                tempJson = JSON([overviewItem])
                            }
                            else
                            {
                                tempJson.arrayObject?.append(overviewItem)
                            }
                            
                        }
                                        
                    
                    }
                    
                    overviewGroupListJson[index]["overviewList"] =  JSON(tempJson)
                    
                }
             
                 
            }
            
        }
        
        
             
        //print(overviewGroupListJson)
             
             
        self.overviewFirstTable.reloadData()
        let indexPath = NSIndexPath(row: 0, section: 0)
        self.overviewFirstTable.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
        
        
    }
        
    
    
    
    
    private func setDateValue() {
        
        var startDateText = ""
        var endDateText = ""
        
        
        if isTodaySelected
        {
            
            let currentDate = Date()
            let startDate = currentDate.setDateTime(hour: 0, min: 0, sec: 0, yourDate: currentDate)
            let endDate = currentDate.setDateTime(hour: 23, min: 59, sec: 59, yourDate: currentDate)
            
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
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
                let startString = dateFormatter.string(from: startDate!)
                let endString = dateFormatter.string(from: endDate!)
                print(startString)
                print(endString)
                
                
                startDateText = String(Int((startDate!.timeIntervalSince1970)))
                endDateText = String(Int(endDate!.timeIntervalSince1970))
                
                
               
            }else if components.weekday == 6 {
                
                
                let lastFriday = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentDate)!
                let lastSunday = currentDate.previous(.sunday)
                
                let startDate = lastFriday.setDateTime(hour: 0, min: 0, sec: 0, yourDate: lastFriday)
                let endDate = lastSunday.setDateTime(hour: 23, min: 59, sec: 59, yourDate: lastSunday)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
                let startString = dateFormatter.string(from: startDate!)
                let endString = dateFormatter.string(from: endDate!)
                print(startString)
                print(endString)
                
                
                startDateText = String(Int((startDate!.timeIntervalSince1970)))
                endDateText = String(Int(endDate!.timeIntervalSince1970))
               
               
            }else
            
            if components.weekday == 7 {
                 
                let lastSaturday = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentDate)!
                let lastFriday = lastSaturday.previous(.friday)
                let lastSunday = currentDate.previous(.sunday)
                
                let startDate = lastFriday.setDateTime(hour: 0, min: 0, sec: 0, yourDate: lastFriday)
                let endDate = lastSunday.setDateTime(hour: 23, min: 59, sec: 59, yourDate: lastSunday)
                
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
        
    
        let storedPropertyId  = UserDefaults.standard.string(forKey: STORED_PROPERTY_ID)!
        getOverviewOverview(propertyId: storedPropertyId, startDate: startDateText, endDate: endDateText)
            
        
    }
    
    //Selector Func - Audi Select Click
    @objc private func audiSelectClickFunction() {
        
        let controller = AudiOverviewFirstSheetVC.instantiate()
           
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
        controller.audiListJson = self.audiListJson
        
        
        self.present(sheetController, animated: false, completion: nil)
               
               
    }
    
    
    
    //Func - Get Over View
    func getOverviewOverview(propertyId:String,startDate:String,endDate:String ) -> Void {
        
        self.selectedAudiPosition = 0
        self.audiListJson = JSON([:])
        
        var audiAllScreenItem:JSON = [:]
        audiAllScreenItem["name"].string = "All Screens"
        audiAllScreenItem["id"].string = "-1"
        
        var audiAllItem:JSON = [:]
        audiAllItem["screen"] = audiAllScreenItem
        
        
        self.audiListJson = JSON([audiAllItem])
        self.audiName.text = self.audiListJson[selectedAudiPosition]["screen"]["name"].stringValue
        
        
        self.overviewListJson = JSON([:])
        self.overviewListTempJson = JSON([:])
        self.overviewGroupListJson = JSON([:])
        self.overviewFirstTable.reloadData()
        
        self.overviewFirstTable.isHidden = true
        
        for subview in self.containerView.subviews {
                   
            if (subview.tag == 100) {
                       
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
                self.callGetOverviewOverviewService(propertyId: propertyId, startDate: startDate, endDate: endDate)
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
    
    
    
    
    
    //Service - Get Screen
    func callGetOverviewOverviewService(propertyId:String,startDate:String,endDate:String) -> Void {
           
           //Showing Loading
           showHUD()
           
           let accessTokenId  = UserDefaults.standard.string(forKey: LOGIN_ACCESSTOKEN_ID)
             
           let headers: HTTPHeaders = [
               "Authorization": "Bearer "+accessTokenId!
           ]
           
           print("Overview Overview Headers")
           print(headers)
           print("\n")
     
           
           //Creating request
           let urlString = GET_OVERVIEW_OVERVIEW_API+"property/"+propertyId+"/start-date/"+startDate+"/end-date/"+endDate
           
           print("Overview Overview URL")
           print(urlString)
           print("\n")
           
           let alamoRequest = Alamofire.request(urlString, method: .get,  encoding: URLEncoding.default, headers: headers)
           
           print("Overview Overview Request")
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
                           
                           self.overviewListJson = JSON.init(parseJSON: value)
                           
                           
                           //print(self.overviewListJson)
                           
                           if self.overviewListJson.isEmpty
                           {
                               
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
                            
                            self.setAudiValue()
                            self.overviewFirstTable.isHidden = false
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
    
    
    
    
    
    
    // MARK: - IndicatorInfoProvider

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        
        return IndicatorInfo(title: "Overview")
    }

    
    
    //TableView protocols
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if self.overviewListTempJson.isEmpty {
            return 0
        }
        
        if self.overviewGroupListJson.isEmpty {
            return 0
        }


        return (self.overviewGroupListJson.array?.count)!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if self.overviewListTempJson.isEmpty {
            return 0
        }
        
        if self.overviewGroupListJson.isEmpty {
            return 0
        }
        
        if self.overviewGroupListJson[section]["overviewList"].isEmpty {
            return 0
        }

        
        return (overviewGroupListJson[section]["overviewList"].array?.count)!
        
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Configure the cell...
        let overviewFirstCell = tableView.dequeueReusableCell(withIdentifier: "OverviewFirstCell", for: indexPath) as! OverviewFirstCell
        
        let overviewItem = overviewGroupListJson[indexPath.section]["overviewList"][indexPath.row]
        
        if overviewItem["timeSlot"]["movieDisplayName"].stringValue.isEmpty
        {
            overviewFirstCell.movieName.text =  overviewItem["timeSlot"]["movie"]["name"].stringValue
           
        }
        else
        {
             overviewFirstCell.movieName.text =  overviewItem["timeSlot"]["movieDisplayName"].stringValue
        }
        
        
        //Moview Image
        if overviewItem["timeSlot"]["movie"]["imageFileName"].stringValue.isEmpty
        {
            overviewFirstCell.movieImage.image = UIImage(named: "ic_default_image.png")
        }
        else
        {
            let movieImageUrl = IMAGE_URL+overviewItem["timeSlot"]["movie"]["imageFileName"].stringValue
            
            let movieImageUrlEncoded = movieImageUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            let callingUrl = URL(string: movieImageUrlEncoded!)
            
            overviewFirstCell.movieImage.sd_setImage(with: callingUrl,placeholderImage:UIImage(named: "ic_default_image.png")) { (image, error, cache, urls) in
                if (error != nil) {
                    overviewFirstCell.movieImage.image = UIImage(named: "ic_default_image.png")
                } else {
                    overviewFirstCell.movieImage.image = image
                }
            }
        }
        
 
        
        let dateMillis = overviewItem["timeSlot"]["startDateTime"].doubleValue
        let dateVar = Date.init(timeIntervalSince1970: TimeInterval(dateMillis/1000.0))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        let audiTimeString = dateFormatter.string(from: dateVar)
        
        overviewFirstCell.audiTime.text = overviewItem["timeSlot"]["screen"]["name"].stringValue+"  |  "+audiTimeString
               
        
        
        let attrsSemiBold13 = [NSAttributedString.Key.font :UIFont(name: "Poppins-SemiBold", size: 13)!, NSAttributedString.Key.foregroundColor : UIColor(red: 62/255, green: 63/255, blue: 66/255, alpha: 1.0)]
        
       let attrsSemiBold14 = [NSAttributedString.Key.font :UIFont(name: "Poppins-SemiBold", size: 14)!, NSAttributedString.Key.foregroundColor : UIColor(red: 62/255, green: 63/255, blue: 66/255, alpha: 1.0)]

        let attrsRegular = [NSAttributedString.Key.font : UIFont(name: "Poppins-Regular", size: 13)!, NSAttributedString.Key.foregroundColor : UIColor(red: 158/255, green: 160/255, blue: 165/255, alpha: 1.0)]
        
        var maxOccupancy = overviewItem["maxOccupancy"].stringValue
        if maxOccupancy.isEmpty
        {
            maxOccupancy = "-"
        }
        
        let attributedStringOccupancy1 = NSMutableAttributedString(string:maxOccupancy, attributes:attrsSemiBold13)
        let attributedStringOccupancy2 = NSMutableAttributedString(string:" Occupancy", attributes:attrsRegular)

        attributedStringOccupancy1.append(attributedStringOccupancy2)
        overviewFirstCell.movieOccupancy.attributedText = attributedStringOccupancy1
        
        var totalSeats = overviewItem["timeSlot"]["screen"]["totalSeats"].stringValue
         if totalSeats.isEmpty
         {
             totalSeats = "-"
         }
         
         
        let attributedStringSeatTotal1 = NSMutableAttributedString(string:totalSeats, attributes:attrsSemiBold14)
        let attributedStringSeatTotal2 = NSMutableAttributedString(string:" Total Seats", attributes:attrsRegular)
               
        attributedStringSeatTotal1.append(attributedStringSeatTotal2)
        overviewFirstCell.movieTotalSeats.attributedText = attributedStringSeatTotal1
        
        
        var soldSeats = overviewItem["timeSlot"]["ticketsCount"].stringValue
        if soldSeats.isEmpty
        {
            soldSeats = "-"
        }
       
        let attributedStringSeatSold1 = NSMutableAttributedString(string:soldSeats, attributes:attrsSemiBold14)
        let attributedStringSeatSold2 = NSMutableAttributedString(string:" Sold Seats", attributes:attrsRegular)
        
        attributedStringSeatSold1.append(attributedStringSeatSold2)
        overviewFirstCell.movieSoldSeats.attributedText = attributedStringSeatSold1
        
        
        
       
        
        return overviewFirstCell
        
        
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        let overviewItem = overviewGroupListJson[section]
        return overviewItem["displayDate"].stringValue
    }


    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {

        let header = view as? UITableViewHeaderFooterView
        header?.textLabel?.font = UIFont(name: "Poppins-Medium", size: 14)!
        header?.textLabel?.textColor = UIColor(red: 62/255, green: 63/255, blue: 66/255, alpha: 1.0)
        header?.textLabel?.text = header?.textLabel!.text!.capitalized
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36

    }
       
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return .leastNormalMagnitude
    }
    


}
