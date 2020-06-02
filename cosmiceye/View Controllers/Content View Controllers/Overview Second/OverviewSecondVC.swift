//
//  OverviewSecondVC.swift
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

class OverviewSecondVC: UIViewController , IndicatorInfoProvider, UITableViewDelegate, UITableViewDataSource{
    
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
    
    @IBOutlet var movieSelectClick: UIView!
    @IBOutlet var movieName: UILabel!
    
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var overviewSecondTable: UITableView!
    
    //Declaring variables
    var selectedPropertyPosition = -1
    var propertyListJson:JSON = [:]
    
    var selectedMoviePosition = 0
    var movieListJson:JSON = [:]
    var overviewListJson:JSON = [:]
    var overviewListTempJson:JSON = [:]
    
    
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
       overviewSecondTable.delegate = self
       overviewSecondTable.dataSource = self
       
       movieSelectClick.layer.borderWidth = 1
       movieSelectClick.layer.borderColor = UIColor(red:234.0/255.0, green:237.0/255.0, blue:243.0/255.0, alpha: 1.0).cgColor
       
             
       //Setting Corner
       movieSelectClick.layer.cornerRadius = 4
       movieSelectClick.clipsToBounds = true
       
       
        if !self.propertyListJson.isEmpty
        {
            self.setDateValue()
               
        }
        
        //Pull To Refresh
        pullToRefreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        pullToRefreshControl.tintColor = UIColor(red: 81/255, green: 45/255, blue: 168/255, alpha: 1.0)
        
        if #available(iOS 10.0, *) {
            overviewSecondTable.refreshControl = pullToRefreshControl
        } else {
            overviewSecondTable.addSubview(pullToRefreshControl)
        }
                   
           
        pullToRefreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
       
       //Click events
       let movieSelectClickTap = UITapGestureRecognizer(target: self, action: #selector(movieSelectClickFunction))
       movieSelectClick.isUserInteractionEnabled = true
       movieSelectClick.addGestureRecognizer(movieSelectClickTap)
       
        
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
    
    private func setMovieValue() {
        
        if !self.overviewListJson.isEmpty
        {
            for index in 0...(self.overviewListJson.array?.count)!-1 {
                
                var isFound = false
                
                let overviewItem = self.overviewListJson[index]
                
                if !self.movieListJson.isEmpty
                {
                    for indexIn in 0...(self.movieListJson.array?.count)!-1 {
           
                        let movieItem = self.movieListJson[indexIn]
                        
                        if overviewItem["movieId"].stringValue == movieItem["id"].stringValue
                        {
                            isFound = true
                            break
                        }
                        
                    }
                    
                }
    
                if isFound == false
                {
                    
                    var movieItem:JSON = [:]
                    movieItem["name"].string = overviewItem["movieName"].stringValue
                    movieItem["id"].string = overviewItem["movieId"].stringValue
                    
                    
                    self.movieListJson.arrayObject?.append(movieItem)
                }
       
            
            }
            
        }
        
        
    }
    
    private func movieValueChanged() {
        
        for subview in self.containerView.subviews {
                   
            if (subview.tag == 100) {
                       
                subview.removeFromSuperview()
            }
        }
        
        self.movieName.text = self.movieListJson[selectedMoviePosition]["name"].stringValue
        
        self.overviewListTempJson = JSON([:])
        
        if selectedMoviePosition == 0
        {
            overviewListTempJson = overviewListJson
        }
        else
        {
            if !overviewListJson.isEmpty
            {
                let selectedMovieId = self.movieListJson[selectedMoviePosition]["id"].stringValue
                
                for index in 0...(self.overviewListJson.array?.count)!-1 {
                    
                    let overviewItem = self.overviewListJson[index]
                    
                    if overviewItem["movieId"].stringValue == selectedMovieId
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
            self.overviewSecondTable.reloadData()
            let indexPath = NSIndexPath(row: 0, section: 0)
            self.overviewSecondTable.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
        }
        
    }
    
    func setDateValue() {
        
        
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
        getOverviewMovies(propertyId: storedPropertyId, startDate: startDateText, endDate: endDateText)
    }
    
    //Selector Func - Movie Select Click
    @objc private func movieSelectClickFunction() {
        
        let controller = MovieOverviewSecondSheetVC.instantiate()
           
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
            
            if self.selectedMoviePosition != controller.selectedMoviePosition
            {
               
                self.selectedMoviePosition = controller.selectedMoviePosition
                
                self.movieValueChanged()
                
                
            }
        }
        
        controller.selectedMoviePosition = selectedMoviePosition
        controller.movieListJson = movieListJson
        
        
        self.present(sheetController, animated: false, completion: nil)
               
               
    }
    
    
    //Func - Get Over View
    func getOverviewMovies(propertyId:String,startDate:String,endDate:String ) -> Void {
        
        
        self.selectedMoviePosition = 0
        self.movieListJson = JSON([:])
        
        var movieAllItem:JSON = [:]
        movieAllItem["name"].string = "All Movies"
        movieAllItem["id"].string = "-1"
        
        
        self.movieListJson = JSON([movieAllItem])
        self.movieName.text = self.movieListJson[selectedMoviePosition]["name"].stringValue
        
        self.overviewListJson = JSON([:])
        self.overviewListTempJson = JSON([:])
        self.overviewSecondTable.reloadData()
        
        self.overviewSecondTable.isHidden = true
        
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
                self.callGetOverviewMoviesService(propertyId: propertyId, startDate: startDate, endDate: endDate)
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
    
    //Service - Get Movies
    func callGetOverviewMoviesService(propertyId:String,startDate:String,endDate:String) -> Void {
        
        //Showing Loading
        showHUD()
        
        let accessTokenId  = UserDefaults.standard.string(forKey: LOGIN_ACCESSTOKEN_ID)
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer "+accessTokenId!
        ]
                     
        print("Overview Movies Headers")
        print(headers)
        print("\n")
               
                     
        //Creating request
        let urlString = GET_OVERVIEW_MOVIES_API+"property/"+propertyId+"/start-date/"+startDate+"/end-date/"+endDate
                     
        print("Overview Movies URL")
        print(urlString)
        print("\n")
                     
        let alamoRequest = Alamofire.request(urlString, method: .get,  encoding: URLEncoding.default, headers: headers)
                     
        print("Overview Movies Request")
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
                     
                     self.setMovieValue()
                     self.overviewSecondTable.isHidden = false
                     self.movieValueChanged()
                 
                        
                        
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
        
        return IndicatorInfo(title: "Movies")
    }

    
    
    //TableView protocols
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        
        //Checking list for empty
        if self.overviewListTempJson.isEmpty {
            return 0
        }
    
        
        return (self.overviewListTempJson.array?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Configure the cell...
        let overviewSecondCell = tableView.dequeueReusableCell(withIdentifier: "OverviewSecondCell", for: indexPath) as! OverviewSecondCell
        
        let movieItem = overviewListTempJson[indexPath.row]
        
        overviewSecondCell.movieName.text = movieItem["movieName"].stringValue
        
        
        //Moview Image
        if movieItem["movieImg"].stringValue.isEmpty
        {
            overviewSecondCell.movieImage.image = UIImage(named: "ic_default_image.png")
        }
        else
        {
            let movieImageUrl = IMAGE_URL+movieItem["movieImg"].stringValue
            
            let movieImageUrlEncoded = movieImageUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            let callingUrl = URL(string: movieImageUrlEncoded!)
            
            overviewSecondCell.movieImage.sd_setImage(with: callingUrl,placeholderImage:UIImage(named: "ic_default_image.png")) { (image, error, cache, urls) in
                if (error != nil) {
                    overviewSecondCell.movieImage.image = UIImage(named: "ic_default_image.png")
                } else {
                    overviewSecondCell.movieImage.image = image
                }
            }
        }
        
               
        
        
        let attrsSemiBold13 = [NSAttributedString.Key.font :UIFont(name: "Poppins-SemiBold", size: 13)!, NSAttributedString.Key.foregroundColor : UIColor(red: 62/255, green: 63/255, blue: 66/255, alpha: 1.0)]
        
       let attrsSemiBold14 = [NSAttributedString.Key.font :UIFont(name: "Poppins-SemiBold", size: 14)!, NSAttributedString.Key.foregroundColor : UIColor(red: 62/255, green: 63/255, blue: 66/255, alpha: 1.0)]

        let attrsRegular = [NSAttributedString.Key.font : UIFont(name: "Poppins-Regular", size: 13)!, NSAttributedString.Key.foregroundColor : UIColor(red: 158/255, green: 160/255, blue: 165/255, alpha: 1.0)]

        let attributedStringOccupancy1 = NSMutableAttributedString(string:movieItem["totalOccupancy"].stringValue, attributes:attrsSemiBold13)
        let attributedStringOccupancy2 = NSMutableAttributedString(string:" Occupancy", attributes:attrsRegular)

        attributedStringOccupancy1.append(attributedStringOccupancy2)
        overviewSecondCell.movieOccupancy.attributedText = attributedStringOccupancy1
        
        
       
        let attributedStringSOccupancyTotal1 = NSMutableAttributedString(string:movieItem["totalSeatsCapacity"].stringValue, attributes:attrsSemiBold14)
        let attributedStringOccupancyTotal2 = NSMutableAttributedString(string:" Total Occupancy", attributes:attrsRegular)
        
        attributedStringSOccupancyTotal1.append(attributedStringOccupancyTotal2)
        overviewSecondCell.movieTotalOccupancy.attributedText = attributedStringSOccupancyTotal1
        
        
       let attributedStringShows1 = NSMutableAttributedString(string:movieItem["totalShows"].stringValue, attributes:attrsSemiBold14)
       let attributedStringShows2 = NSMutableAttributedString(string:" Shows", attributes:attrsRegular)
              
        attributedStringShows1.append(attributedStringShows2)
        overviewSecondCell.movieTotalShows.attributedText = attributedStringShows1
        
       
        
        return overviewSecondCell
        
        
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
