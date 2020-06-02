//
//  NotificationsVC.swift
//  cosmiceye
//
//  Created by Rachin Allakkot on 03/12/19.
//  Copyright © 2019 Exuber. All rights reserved.
//

import UIKit
import SwiftyJSON
import FittedSheets
import Alamofire

class NotificationsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
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
    @IBOutlet var propertySelectClick: UIView!
    @IBOutlet var propertyName: UILabel!
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var notificationTable: UITableView!
    
    //Declaring variables
    var selectedPropertyPosition = 0
    
    private let pullToRefreshControl = UIRefreshControl()
    
    //List for storing
    var propertyListJson:JSON = [:]
    var notificationListJson:JSON = [:]
    var notificationGroupListJson:JSON = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        //Delegate
        notificationTable.delegate = self
        notificationTable.dataSource = self
        
        notificationTable.contentInsetAdjustmentBehavior = .never
        notificationTable.tableHeaderView = nil
        
        self.propertySelectClick.isHidden = true
        
        //Pull To Refresh
        pullToRefreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        pullToRefreshControl.tintColor = UIColor(red: 81/255, green: 45/255, blue: 168/255, alpha: 1.0)
    
        if #available(iOS 10.0, *) {
            notificationTable.refreshControl = pullToRefreshControl
        } else {
            notificationTable.addSubview(pullToRefreshControl)
        }
               
       
        pullToRefreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        
        
        //Click Events
        let propertySelectClickTap = UITapGestureRecognizer(target: self, action: #selector(propertySelectClickFunction))
        propertySelectClick.isUserInteractionEnabled = true
        propertySelectClick.addGestureRecognizer(propertySelectClickTap)
        
        //Click events
        noInternetView.tryAgainClick.addTarget(self, action:#selector(tryAgainClickTap(_:))
                                 , for: .touchUpInside)
                      
        serverErrorView.tryAgainClick.addTarget(self, action:#selector(tryAgainClickTap(_:))
                      , for: .touchUpInside)

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
    
        self.getNotification()
        
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        for subview in self.containerView.subviews {
                   
            if (subview.tag == 100) {
                       
                subview.removeFromSuperview()
            }
        }
        
        for subview in self.containerView.subviews {
                          
            if (subview.tag == 200) {
                              
                subview.removeFromSuperview()
            }
        }
    }
    
    //Selector Func - Try again click
    @objc private func tryAgainClickTap(_ button: UIButton)
    {
        
        self.getNotification()
        
         
    }
    
    //Func - Pull to refresh
    @objc private func handleRefresh(_ sender: Any)  {
        
        pullToRefreshControl.endRefreshing()
        getNotification()
    }
    
    //Set Property Value
    private func setPropertyValue() {
        
        
        let propertyItem = self.propertyListJson[selectedPropertyPosition]
        propertyName.attributedText = NSAttributedString(string: propertyItem["shortCode"].stringValue, attributes:
        [.underlineStyle: NSUnderlineStyle.single.rawValue])
        
        self.propertySelectClick.isHidden = false
        
        
        getNotification()
        
    
    }
    
    //Set Property Value
    private func setNotificationValue() {
        
        DispatchQueue.main.async {
            
            self.notificationGroupListJson = JSON([:])
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US")
            dateFormatter.dateFormat = "MM/dd/yyyy"
            
            if !self.notificationListJson.isEmpty
            {
                
                for index in 0...(self.notificationListJson.array?.count)!-1 {
                    
                    let notificationItem = self.notificationListJson[index]
                    
                    let dateNotificatioMillis = notificationItem["createdDate"].doubleValue
                    let dateNotificationtVar = Date.init(timeIntervalSince1970: TimeInterval(dateNotificatioMillis/1000.0))
                    
                    let notificationDateString = dateFormatter.string(from: dateNotificationtVar)
                    
                    
                    var isFound = false
                    
                    if !self.notificationGroupListJson.isEmpty
                    {
                        for indexIn in 0...(self.notificationGroupListJson.array?.count)!-1 {
                            
                            let groupItem = self.notificationGroupListJson[indexIn]
                            
                            if groupItem["createdDate"].stringValue == notificationDateString
                            {
                                isFound = true
                                break
                                
                            }
                            
                            
                        }
                    }
                    
                    if isFound == false
                    {
                        
                        var groupItem:JSON = [:]
                        groupItem["createdDate"].string = notificationDateString
                        
                        
                        let currentDate = Date()
                        let currentDateString = dateFormatter.string(from: currentDate)
                        print("Today Date")
                        print(currentDateString)
                        
                        if currentDateString == notificationDateString
                        {
                            groupItem["displayDate"].string = "Today"
                        }
                        else
                        {
                            
                            let now = Calendar.current.dateComponents(in: .current, from: Date())

                            
                            let yesterday = DateComponents(year: now.year, month: now.month, day: now.day! - 1)
                            let dateYesterday = Calendar.current.date(from: yesterday)!
                            let yesterdayDateString = dateFormatter.string(from: dateYesterday)
                            
                            if yesterdayDateString == notificationDateString
                            {
                                
                                groupItem["displayDate"].string = "Yesterday"
                            }
                            else
                            {
                                 
                                let dateFormatterDisplay = DateFormatter()
                                dateFormatterDisplay.locale = Locale(identifier: "en_US")
                                dateFormatterDisplay.dateFormat = "d MMM, yyyy"
                                
                               
                                groupItem["displayDate"].string = dateFormatterDisplay.string(from: dateNotificationtVar)
                                       
                                
                            }
                            
                            
                        }
                        
                        if self.notificationGroupListJson.isEmpty
                        {
                            self.notificationGroupListJson = JSON([groupItem])
                        }
                        else
                        {
                            self.notificationGroupListJson.arrayObject?.append(groupItem)
                        }
                 
                    }
                    
                    
                    
                    
                }
                
            }
            
            
            if !self.notificationGroupListJson.isEmpty
            {
                
                for index in 0...(self.notificationGroupListJson.array?.count)!-1 {
                  
                         
                    let groupItem = self.notificationGroupListJson[index]
                
                    var tempJson:JSON = [:]
                    
                    if !self.notificationListJson.isEmpty
                    {
                        for indexIn in 0...(self.notificationListJson.array?.count)!-1 {
                                
                            let notificationItem = self.notificationListJson[indexIn]
                                
                            let dateNotificatioMillis = notificationItem["createdDate"].doubleValue
                            let dateNotificationtVar = Date.init(timeIntervalSince1970: TimeInterval(dateNotificatioMillis/1000.0))
                                
                            let notificationDateString = dateFormatter.string(from: dateNotificationtVar)
                                
                            if groupItem["createdDate"].stringValue == notificationDateString
                            {
                                
                                if tempJson.isEmpty
                                {
                                    tempJson = JSON([notificationItem])
                                }
                                else
                                {
                                    tempJson.arrayObject?.append(notificationItem)
                                }
                                
                            }
                        
                            
                        }
                             
                        self.notificationGroupListJson[index]["notificationList"] =  JSON(tempJson)
                        
                    }
                    
                }
                
            }
            
            
            //print(self.notificationGroupListJson)
            
            
            self.notificationTable.reloadData()
            
        }
        
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
    
    
    
    
    
    //Func - Property
    func getProperty() -> Void {
     
        self.propertyListJson = JSON([:])
        self.notificationListJson = JSON([:])
     
        self.notificationTable.reloadData()
        
      
        self.propertySelectClick.isHidden = true
        self.notificationTable.isHidden = true
    
        
        for subview in self.containerView.subviews {
                   
            if (subview.tag == 100) {
                       
                subview.removeFromSuperview()
            }
        }
        
        for subview in self.containerView.subviews {
                          
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
                                  
            
            //Calling Service
            callGetPropertyService()
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
    
    //Func - Notification
    func getNotification() -> Void {
     
        
        self.notificationListJson = JSON([:])
        self.notificationGroupListJson = JSON([:])
        self.notificationTable.reloadData()
        
        self.notificationTable.isHidden = true

        
        for subview in self.containerView.subviews {
                          
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
            emptyView.tag = 200
            self.containerView.addSubview(emptyView)
                                  
            
            DispatchQueue.main.async {
                
                //Calling Service
                self.callGetNotificationService()
            }
            
        }
        else
        {
            
            //Setting no internet background
            let width = self.containerView.frame.size.width
            let height = self.containerView.frame.size.height
            
           
            self.noInternetView.frame = CGRect(x:0, y: 0, width: width, height: height)
            
            self.noInternetView.tag = 200
            self.noInternetView.tryAgainClick.tag = 200
            self.containerView.addSubview(noInternetView)
            
            
            
            
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
                        
                        if responseCode == 400
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
    
    //Service - Notification
    func callGetNotificationService() -> Void {
        
        //Showing Loading
        showHUD()
        
        let accessTokenId  = UserDefaults.standard.string(forKey: LOGIN_ACCESSTOKEN_ID)
          
        let headers: HTTPHeaders = [
            "Authorization": "Bearer "+accessTokenId!
        ]
        
        print("Notification List Headers")
        print(headers)
        print("\n")
        
        
        
        //Creating request
        let urlString = GET_NOTIFICATION_API
        
        print("Notification List URL")
        print(urlString)
        print("\n")
        
        let alamoRequest = Alamofire.request(urlString, method: .get,  encoding: URLEncoding.default, headers: headers)
        
        print("Notification List Request")
        print(alamoRequest)
        print("\n")
        
        alamoRequest.responseString { responseData in
                
                //Checking status code
                if responseData.response?.statusCode == 200
                {
                    
                    
                    
                    switch responseData.result
                    {
                    case let .success(value):
                        
                        self.notificationListJson = JSON.init(parseJSON: value)
                        
                        
                        //print(self.notificationListJson)
                        
                        if self.notificationListJson.isEmpty
                        {
                            //Stop loading
                            self.hideHUD()
                            
                            for subview in self.containerView.subviews {
                                if (subview.tag == 200) {
                                                                       
                                    subview.removeFromSuperview()
                                }
                                                                   
                            
                            }
                            
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
                            //Stop loading
                            self.hideHUD()
                            
                            for subview in self.containerView.subviews {
                                
                                if (subview.tag == 200) {
                                    
                                    subview.removeFromSuperview()
                                }
                            }
                            
                     
                            self.setNotificationValue()
                            self.notificationTable.isHidden = false
                 
                            
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
                                        if (subview.tag == 200) {
                                                                               
                                            subview.removeFromSuperview()
                                        }
                                                                           
                                    
                                    }
                                    
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
                                    
                                    for subview in self.containerView.subviews {
                                        
                                        if (subview.tag == 200) {
                                            
                                            subview.removeFromSuperview()
                                        }
                                    }
                                    
                                    self.serverErrorView.errorText.text = "Something went wrong!"
                                    
                                    let width = self.containerView.frame.size.width
                                    let height = self.containerView.frame.size.height
                                    self.serverErrorView.frame = CGRect(x:0, y: 0, width: width, height: height)
                                    self.serverErrorView.tag = 200
                                    self.serverErrorView.tryAgainClick.tag = 200
                                    self.containerView.addSubview(self.serverErrorView)
                                }
                                
                                 break
                                
                            default:
                                
                                for subview in self.containerView.subviews {
                                    
                                    if (subview.tag == 200) {
                                        
                                        subview.removeFromSuperview()
                                    }
                                }
                                
                                self.serverErrorView.errorText.text = "Something went wrong!"
                                
                                let width = self.containerView.frame.size.width
                                let height = self.containerView.frame.size.height
                                self.serverErrorView.frame = CGRect(x:0, y: 0, width: width, height: height)
                                self.serverErrorView.tag = 200
                                self.serverErrorView.tryAgainClick.tag = 200
                                self.containerView.addSubview(self.serverErrorView)
                                
                                break
                                
                            }
                            
                        }
                        else
                        {
                            for subview in self.containerView.subviews {
                                
                                if (subview.tag == 200) {
                                    
                                    subview.removeFromSuperview()
                                }
                            }
                            
                            self.serverErrorView.errorText.text = "Something went wrong!"
                            
                            let width = self.containerView.frame.size.width
                            let height = self.containerView.frame.size.height
                            self.serverErrorView.frame = CGRect(x:0, y: 0, width: width, height: height)
                            self.serverErrorView.tag = 200
                            self.serverErrorView.tryAgainClick.tag = 200
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
                        
                        if responseCode == 400
                        {
                            
                            self.logoutApp()
                        }
                        else
                        {
                            for subview in self.containerView.subviews {
                                
                                if (subview.tag == 200) {
                                    
                                    subview.removeFromSuperview()
                                }
                            }
                            
                            self.serverErrorView.errorText.text = "Can't connect Server!"+"\n"+"Error: "+String(describing: responseCode)
                            
                            
                            let width = self.containerView.frame.size.width
                            let height = self.containerView.frame.size.height
                            self.serverErrorView.frame = CGRect(x:0, y: 0, width: width, height: height)
                            self.serverErrorView.tag = 200
                            self.serverErrorView.tryAgainClick.tag = 200
                            self.containerView.addSubview(self.serverErrorView)
                        }
                        
                        
                                           
                        
                    }
                    else
                    {
                        
                        for subview in self.containerView.subviews {
                            
                            if (subview.tag == 200) {
                                
                                subview.removeFromSuperview()
                            }
                        }
                        
                        self.serverErrorView.errorText.text = "Something went wrong!"
                        
                        let width = self.containerView.frame.size.width
                        let height = self.containerView.frame.size.height
                        self.serverErrorView.frame = CGRect(x:0, y: 0, width: width, height: height)
                        self.serverErrorView.tag = 200
                        self.serverErrorView.tryAgainClick.tag = 200
                        self.containerView.addSubview(self.serverErrorView)
                        
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
        if self.notificationListJson.isEmpty {
            return 0
        }
        
        if self.notificationGroupListJson.isEmpty {
            return 0
        }


        return (self.notificationGroupListJson.array?.count)!
        
        
    }
              
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.notificationListJson.isEmpty {
            return 0
        }
        
        if self.notificationGroupListJson.isEmpty {
            return 0
        }
        
        if self.notificationGroupListJson[section]["notificationList"].isEmpty {
            return 0
        }

        
        return (notificationGroupListJson[section]["notificationList"].array?.count)!
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           
        // Configure the cell...
        let notificationCell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
    
                      
        let notificationItem = self.notificationGroupListJson[indexPath.section]["notificationList"][indexPath.row]
        
        notificationCell.notificationHeader.text = notificationItem["title"].stringValue
        notificationCell.notificationDescription.text = notificationItem["message"].stringValue
        
        
        return notificationCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        let notifiicationItem = notificationGroupListJson[section]
        return notifiicationItem["displayDate"].stringValue
    }


    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {

        
        let header = view as? UITableViewHeaderFooterView
        header?.tintColor =  UIColor(red: 253/255, green: 253/255, blue: 253/255, alpha: 1.0)
        header?.backgroundView?.backgroundColor = UIColor(red: 253/255, green: 253/255, blue: 253/255, alpha: 1.0)
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
