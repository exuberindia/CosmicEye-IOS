//
//  OverviewThirdVC.swift
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

class OverviewThirdVC: UIViewController, IndicatorInfoProvider, UITableViewDelegate, UITableViewDataSource {
    
    
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
    @IBOutlet var overviewThirdTable: UITableView!
       
    
    //Declaring variables
    var propertyListJson:JSON = [:]
    var audiListJson:JSON = [:]
    var overviewListJson:JSON = [:]
    var overviewListTempJson:JSON = [:]
    
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
        overviewThirdTable.delegate = self
        overviewThirdTable.dataSource = self
        
        overviewThirdTable.contentInsetAdjustmentBehavior = .never
        overviewThirdTable.tableHeaderView = nil
        
        
        
        let headerNib = UINib.init(nibName: "OverviewScreenHeaderView", bundle: Bundle.main)
        overviewThirdTable.register(headerNib, forHeaderFooterViewReuseIdentifier: "OverviewScreenHeaderView")
        
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
            overviewThirdTable.refreshControl = pullToRefreshControl
        } else {
            overviewThirdTable.addSubview(pullToRefreshControl)
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
        
        if !self.overviewListJson.isEmpty
        {
            for index in 0...(self.overviewListJson.array?.count)!-1 {
                
                var isFound = false
                
                let overviewItem = self.overviewListJson[index]
                
                if !self.audiListJson.isEmpty
                {
                    for indexIn in 0...(self.audiListJson.array?.count)!-1 {
                        
                        
                        let audiItem = self.audiListJson[indexIn]
                        
                        if overviewItem["screenId"].stringValue == audiItem["screen"]["id"].stringValue
                        {
                            isFound = true
                            break
                        }
                        
                    }
                    
                }
    
                if isFound == false
                {
                    
                    var audiScreenItem:JSON = [:]
                    audiScreenItem["name"].string = overviewItem["screenName"].stringValue
                    audiScreenItem["id"].string = overviewItem["screenId"].stringValue
                    
                    var audiItem:JSON = [:]
                    audiItem["screen"] = audiScreenItem
                    
                    self.audiListJson.arrayObject?.append(audiItem)
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
                    
                    if overviewItem["screenId"].stringValue == selectedAudiId
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
            self.overviewThirdTable.reloadData()
            let indexPath = NSIndexPath(row: 0, section: 0)
            self.overviewThirdTable.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
        }
           
           
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
        getOverviewScreen(propertyId: storedPropertyId, startDate: startDateText, endDate: endDateText)
            
        
    }
    
    //Selector Func - Audi Select Click
    @objc private func audiSelectClickFunction() {
        
        let controller = AudiOverviewThirdSheetVC.instantiate()
           
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
    func getOverviewScreen(propertyId:String,startDate:String,endDate:String ) -> Void {
        
        
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
        self.overviewThirdTable.reloadData()
        
        self.overviewThirdTable.isHidden = true
        
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
                self.callGetOverviewScreenService(propertyId: propertyId, startDate: startDate, endDate: endDate)
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
    func callGetOverviewScreenService(propertyId:String,startDate:String,endDate:String) -> Void {
           
           //Showing Loading
           showHUD()
           
           let accessTokenId  = UserDefaults.standard.string(forKey: LOGIN_ACCESSTOKEN_ID)
             
           let headers: HTTPHeaders = [
               "Authorization": "Bearer "+accessTokenId!
           ]
           
           print("Overview Screens Headers")
           print(headers)
           print("\n")
     
           
           //Creating request
           let urlString = GET_OVERVIEW_SCREENS_API+"property/"+propertyId+"/start-date/"+startDate+"/end-date/"+endDate
           
           print("Overview Screens URL")
           print(urlString)
           print("\n")
           
           let alamoRequest = Alamofire.request(urlString, method: .get,  encoding: URLEncoding.default, headers: headers)
           
           print("Overview Screens Request")
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
                            self.overviewThirdTable.isHidden = false
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
        
        return IndicatorInfo(title: "Screens")
    }
    

    
    
    //TableView protocols
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        //Checking list for empty
        if self.overviewListTempJson.isEmpty {
            return 0
        }
                  
                      
        return (self.overviewListTempJson.array?.count)!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if overviewListTempJson[section]["movieList"].isEmpty {
                   return 0
        }
        
        return (overviewListTempJson[section]["movieList"].array?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Configure the cell...
        let overviewThirdCell = tableView.dequeueReusableCell(withIdentifier: "OverviewThirdCell", for: indexPath) as! OverviewThirdCell
        
        let overViewListJson = overviewListTempJson[indexPath.section]["movieList"].arrayValue
        
        

        let screenItem = overViewListJson[indexPath.row]
        
        if screenItem["movieDisplayName"].stringValue.isEmpty
        {
            overviewThirdCell.movieName.text =  screenItem["name"].stringValue
           
        }
        else
        {
             overviewThirdCell.movieName.text =  screenItem["movieDisplayName"].stringValue
        }
               

        
        overviewThirdCell.movieShow.text = screenItem["totalShows"].stringValue

        let attrsMedium = [NSAttributedString.Key.font :UIFont(name: "Poppins-Medium", size: 14)!, NSAttributedString.Key.foregroundColor : UIColor(red: 62/255, green: 63/255, blue: 66/255, alpha: 1.0)]

        let attrsRegular = [NSAttributedString.Key.font : UIFont(name: "Poppins-Regular", size: 14)!, NSAttributedString.Key.foregroundColor : UIColor(red: 158/255, green: 160/255, blue: 165/255, alpha: 1.0)]
        
        var totalOccupancy = screenItem["totalOccupancy"].stringValue
        if totalOccupancy.isEmpty
        {
            totalOccupancy = "-"
        }
        
        var totalSeats = screenItem["totalSeatsCapacity"].stringValue
        if totalSeats.isEmpty
        {
            totalSeats = "-"
        }

        let attributedStringOccupancy1 = NSMutableAttributedString(string:totalOccupancy, attributes:attrsMedium)
        let attributedStringOccupancy2 = NSMutableAttributedString(string:" /"+totalSeats, attributes:attrsRegular)

        attributedStringOccupancy1.append(attributedStringOccupancy2)
        overviewThirdCell.movieOccupancy.attributedText = attributedStringOccupancy1


        if indexPath.row == (overviewListTempJson[indexPath.section]["movieList"].array?.count)!-1
        {
            if indexPath.section == (self.overviewListJson.array?.count)!-1
            {
                overviewThirdCell.bottomViewHeightConstraint.constant = 16
            }
            else
            {
                overviewThirdCell.bottomViewHeightConstraint.constant = 25
            }

        }
        else
        {

            overviewThirdCell.bottomViewHeightConstraint.constant = 0
        }
        
        return overviewThirdCell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            
    
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "OverviewScreenHeaderView") as! OverviewScreenHeaderView
                   
        let overViewItem = overviewListTempJson[section]
        headerView.audiName.text = overViewItem["screenName"].stringValue
        
                   
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 89
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0
    }
    
    
}
