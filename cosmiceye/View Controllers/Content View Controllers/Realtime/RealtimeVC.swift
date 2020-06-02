//
//  RealtimeVC.swift
//  cosmiceye
//
//  Created by Rachin Allakkot on 22/11/19.
//  Copyright © 2019 Exuber. All rights reserved.
//

import UIKit
import Charts
import FittedSheets
import SwiftyJSON
import Alamofire
import SDWebImage


class RealtimeVC: UIViewController ,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ChartViewDelegate{
    
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
    
    lazy var noRealTimeView: NoRealTimeView = {
        return NoRealTimeView.instantiateFromNib()
    }()
    
    //Declaring views
    @IBOutlet var containerView: UIView!
    @IBOutlet var audiCollection: UICollectionView!
    @IBOutlet var middleView: UIView!
    @IBOutlet var bottomView: UIView!
    @IBOutlet var bottomContainerView: UIView!
    
    
    @IBOutlet var movieCardBackground: UIView!
 
    @IBOutlet var lineChart: LineChartView!
    
    @IBOutlet var realTimeHeaderDateTime: UILabel!
    
    @IBOutlet var propertySelectClick: UIView!
    @IBOutlet var propertyName: UILabel!
 
    @IBOutlet var movieImage: UIImageView!
    @IBOutlet var movieName: UILabel!
    @IBOutlet var movieLanguage: UILabel!
    
    @IBOutlet var occupancyCount: UILabel!
    @IBOutlet var totalSeatCount: UILabel!
    @IBOutlet var soldSeatCount: UILabel!
    
    //Declaring variables
    var selectedPropertyPosition = -1
    var selectedAudiPosition = 0
    
    //List for storing
    var propertyListJson:JSON = [:]
    var audiListJson:JSON = [:]
    var audiChartJson:JSON = [:]
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()

        hideKeyboardWhenTappedAround()
        
        //Delegate
        self.audiCollection.delegate = self
        self.audiCollection.dataSource = self
        
        
        lineChart.delegate = self
    
        
        //Click Events
        let propertySelectClickTap = UITapGestureRecognizer(target: self, action: #selector(propertySelectClickFunction))
        propertySelectClick.isUserInteractionEnabled = true
        propertySelectClick.addGestureRecognizer(propertySelectClickTap)
        
         let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(swipeRight)

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(swipeLeft)
        
        //Click events
        noInternetView.tryAgainClick.addTarget(self, action:#selector(tryAgainClickTap(_:))
                          , for: .touchUpInside)
               
        serverErrorView.tryAgainClick.addTarget(self, action:#selector(tryAgainClickTap(_:))
               , for: .touchUpInside)
        
        
    }
    
   
    
    override func viewWillAppear(_ animated: Bool) {

        
         //Get Property
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
    

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
         
         let tabBar = self.tabBarController!.tabBar
               
         tabBar.selectionIndicatorImage = UIImage().createSelectionIndicator(
                   color: UIColor(red: 81/255, green: 45/255, blue: 168/255, alpha: 1.0),
                   size: CGSize(width: tabBar.frame.width/CGFloat(tabBar.items!.count), height:  tabBar.frame.height),
                   lineHeight: 2.0).resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
         
        
         self.movieCardBackground.layer.borderWidth = 1
         self.movieCardBackground.layer.borderColor = UIColor(red:234.0/255.0, green:237.0/255.0, blue:243.0/255.0, alpha: 1.0).cgColor
         
         //Setting Corner
         movieCardBackground.layer.cornerRadius = 4
         movieCardBackground.clipsToBounds = true
         
         movieCardBackground.layer.shadowColor = UIColor.gray.cgColor
         movieCardBackground.layer.shadowOffset = CGSize(width: 0, height: 1)
         movieCardBackground.layer.masksToBounds = false
         movieCardBackground.layer.shadowOpacity = 0.3
         movieCardBackground.layer.shadowRadius = 3
         
         movieCardBackground.layer.rasterizationScale = UIScreen.main.scale
         movieCardBackground.layer.shouldRasterize = true
         
        
         
         
     }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if !audiListJson.isEmpty
        {
            if let swipeGesture = gesture as? UISwipeGestureRecognizer {

                switch swipeGesture.direction {
                
                case UISwipeGestureRecognizer.Direction.right:
                    
                    print("Right Guseture")
                    
                    if selectedAudiPosition == 0 {
                        
                        break
                    }
                    else
                    {
                        self.selectedAudiPosition = self.selectedAudiPosition-1
                        let indexPathCurrent = IndexPath(item: self.selectedAudiPosition, section: 0)
                        
                         self.audiCollection.reloadData()
                        
                        self.audiCollection.scrollToItem(at:indexPathCurrent, at: .centeredHorizontally, animated: false)
                        self.audiCollection.setNeedsLayout()
                        
                        //Set Screen
                        self.startSetScreenChartData()
                    }
                    
                   
                    break
                        
                    
                case UISwipeGestureRecognizer.Direction.left:
                    
                    print("left Guseture")
                    
                    if selectedAudiPosition == (self.audiListJson.array?.count)!-1 {
                                       
                        break
                    }
                    else
                    {
                        self.selectedAudiPosition = self.selectedAudiPosition+1
                        let indexPathCurrent = IndexPath(item: self.selectedAudiPosition, section: 0)
                                       
                        self.audiCollection.reloadData()
                                       
                        self.audiCollection.scrollToItem(at:indexPathCurrent, at: .centeredHorizontally, animated: false)
                        self.audiCollection.setNeedsLayout()
                                       
                         //Set Screen
                        self.startSetScreenChartData()
                    }
                    
                    break
                        
                default:
                        break
                }
            }
            
        }

        
    }
    
    
    //Set Property Value
    private func setPropertyValue() {
        
        
        let propertyItem = self.propertyListJson[selectedPropertyPosition]
        propertyName.attributedText = NSAttributedString(string: propertyItem["shortCode"].stringValue, attributes:
        [.underlineStyle: NSUnderlineStyle.single.rawValue])
        
        self.propertySelectClick.isHidden = false
        
        
        let storedPropertyId  = UserDefaults.standard.string(forKey: STORED_PROPERTY_ID)
        self.getScreen(propertyId:storedPropertyId!)
        
    
        
        
    }
    
    //Set Audi Value
    private func setAudiValue() {
        
       
        let currentDateTime = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "d MMM, h:mm a"
        realTimeHeaderDateTime.text = dateFormatter.string(from: currentDateTime)
       
        
        self.audiCollection.reloadData()
        self.audiCollection.setContentOffset(.zero, animated: false)
        
        
        self.audiCollection.isHidden = false
        self.middleView.isHidden = false
        
        
        //Set Screen
        self.startSetScreenChartData()
    
        
    }
    
    //Set Start
    private func startSetScreenChartData() {
        
        let audiItem = audiListJson[self.selectedAudiPosition]
        
        
        if audiItem["movie"]["id"].stringValue.isEmpty
        {
            
            self.bottomView.isHidden = true
            self.bottomContainerView.isHidden = false
            self.audiChartJson = JSON([:])
            self.bottomView.isHidden = true
            self.bottomContainerView.isHidden = false
            
            
            
            
            for subview in self.containerView.subviews {
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
           
            for subview in self.containerView.subviews {
                if (subview.tag == 200) {
                                                          
                    subview.removeFromSuperview()
                }
            }
            
            self.getScreenChartData(screenId: audiItem["screen"]["id"].stringValue, movieId: audiItem["movie"]["id"].stringValue)
        }
        
    }
 
    
    //Set Relatime value
    private func setRealTimeValue() {
        
       
        let audiItem = audiListJson[self.selectedAudiPosition]
        
        if audiItem["movieDisplayName"].stringValue.isEmpty
        {
            self.movieName.text =  audiItem["movie"]["name"].stringValue
           
        }
        else
        {
             self.movieName.text =  audiItem["movieDisplayName"].stringValue
        }
        
        self.movieLanguage.text =  audiItem["movie"]["language"]["name"].stringValue
        
        if audiItem["screen"]["totalSeats"].stringValue.isEmpty
        {
            self.totalSeatCount.text =  "-"
        }
        else
        {
             self.totalSeatCount.text =  audiItem["screen"]["totalSeats"].stringValue
        }
        if audiItem["ticketsCount"].stringValue.isEmpty
        {
            self.soldSeatCount.text =  "-"
        }
        else
        {
            self.soldSeatCount.text =  audiItem["ticketsCount"].stringValue
        }
        
        //Moview Image
        if audiItem["movie"]["imageFileName"].stringValue.isEmpty
        {
            self.movieImage.image = UIImage(named: "ic_default_image.png")
        }
        else
        {
            let movieImageUrl = IMAGE_URL+audiItem["movie"]["imageFileName"].stringValue
            
            let movieImageUrlEncoded = movieImageUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            let callingUrl = URL(string: movieImageUrlEncoded!)
            
            self.movieImage.sd_setImage(with: callingUrl,placeholderImage:UIImage(named: "ic_default_image.png")) { (image, error, cache, urls) in
                if (error != nil) {
                    self.movieImage.image = UIImage(named: "ic_default_image.png")
                } else {
                    self.movieImage.image = image
                }
            }
        }
        
        
        
        
        self.bottomView.isHidden = false
        
        if audiChartJson.isEmpty
        {
            
            self.occupancyCount.text =  "-"
            self.lineChart.clear()
            self.lineChart.noDataText = "Currently no movies playing"
            
        }
        else
        {
            self.occupancyCount.text  = audiChartJson[(self.audiChartJson.array?.count)!-1]["occupancy"].stringValue
            setChartData()
            
        }
        
       
        
    }
    
    //Set Chart
    func setChartData() {
        
         let audiItem = audiListJson[self.selectedAudiPosition]
        
        
        lineChart.highlightValue(nil, callDelegate: false)
        lineChart.chartDescription?.enabled = false
        lineChart.dragEnabled = true
        lineChart.setScaleEnabled(true)
        lineChart.pinchZoomEnabled = true
        
         
        lineChart.rightAxis.enabled = false
        lineChart.legend.enabled = false
        lineChart.xAxis.drawGridLinesEnabled = false
        lineChart.xAxis.labelPosition = XAxis.LabelPosition.bottom
        lineChart.xAxis.drawAxisLineEnabled = false
        lineChart.xAxis.labelTextColor = UIColor(red: 158/255, green: 160/255, blue: 165/255, alpha: 0.75)
        lineChart.xAxis.labelFont = UIFont(name: "Poppins-Regular", size: 13)!
        lineChart.xAxis.valueFormatter = ChartTimeValueFormatter()
         
        let leftAxis = lineChart.leftAxis
        leftAxis.removeAllLimitLines()
        leftAxis.axisMaximum = Double(audiItem["screen"]["totalSeats"].stringValue)!
        leftAxis.axisMinimum =  0
        leftAxis.gridLineDashLengths = [2, 10]
        leftAxis.drawAxisLineEnabled = false
        leftAxis.drawTopYLabelEntryEnabled = true
        leftAxis.labelFont = UIFont(name: "Poppins-Medium", size: 13)!
        leftAxis.labelTextColor = UIColor(red: 29/255, green: 48/255, blue: 65/255, alpha: 1.0)
        
        
         
         let totalRange = Double(audiItem["screen"]["totalSeats"].stringValue)!
         let interval = Double(100)
         leftAxis.setLabelCount(Int(totalRange/interval) + 1, force: true)
         leftAxis.labelPosition = YAxis.LabelPosition.insideChart
        
         let chartMarkerView: ChartMarkerView = (ChartMarkerView.viewFromXib() as? ChartMarkerView)!
         chartMarkerView.chartView = lineChart
         lineChart.marker = chartMarkerView
        
        var entries = [ChartDataEntry]()
        
        if !audiChartJson.isEmpty
        {
            //Start
            for index in 0...(audiChartJson.array?.count)!-1 {
                
                print(audiChartJson[index]["occupancy"].intValue)
                print(audiChartJson[index]["captureTime"].stringValue)
                
                let isoDate = audiChartJson[index]["captureTime"].stringValue
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                dateFormatter.locale = Locale(identifier: "en_US")
                let dateConverted = dateFormatter.date(from:isoDate)!
                let timeInterval = dateConverted.timeIntervalSince1970
                
                let yValue = audiChartJson[index]["occupancy"].intValue
                let xValue = timeInterval
                
                let entry = ChartDataEntry(x: xValue, y: Double(yValue))
                entries.append(entry)
            }
            
        }

        
        let set1 = LineChartDataSet(entries: entries, label: "Show Set")
        set1.drawIconsEnabled = false
        
        
        set1.setColor(UIColor(red: 81/255, green: 45/255, blue: 168/255, alpha: 1.0))
        set1.lineWidth = 3
        set1.mode = .cubicBezier
        set1.drawValuesEnabled = false
        set1.drawCirclesEnabled = false
        set1.highlightColor = UIColor.red
    
        
        
        set1.setCircleColor(.black)
        set1.circleRadius = 3
        set1.drawCircleHoleEnabled = false
        set1.valueFont = .systemFont(ofSize: 9)
        set1.formLineDashLengths = [5, 2.5]
        set1.formLineWidth = 1
        set1.formSize = 15
        
        let gradientColors = [ChartColorTemplates.colorFromString("#FFFFFFFF").cgColor,
                              ChartColorTemplates.colorFromString("#00512DA8").cgColor]
        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!
        
        set1.fillAlpha = 1
        set1.fill = Fill(linearGradient: gradient, angle: 90)
        set1.drawFilledEnabled = true
        
        let data = LineChartData(dataSet: set1)
        
        lineChart.data = data
        
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
            
            //Set Screen  Chart
            self.startSetScreenChartData()
            
        }
        
         
           
    }
    
    //Func - Property
    func getProperty() -> Void {
        
        let currentDateTime = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "d MMM, h:mm a"
        realTimeHeaderDateTime.text = dateFormatter.string(from: currentDateTime)
        
        self.propertyListJson = JSON([:])
        self.audiListJson = JSON([:])
        self.audiChartJson = JSON([:])
        
        self.propertySelectClick.isHidden = true
        
        self.audiCollection.isHidden = true
        self.middleView.isHidden = true
        self.bottomView.isHidden = true
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
    
    //Func - Get Screen
    func getScreen(propertyId:String) -> Void {
        
        self.audiListJson = JSON([:])
        self.audiChartJson = JSON([:])
        self.audiCollection.reloadData()
        
        self.audiCollection.isHidden = true
        self.middleView.isHidden = true
        self.bottomView.isHidden = true
        self.bottomContainerView.isHidden = true

        
        for subview in self.bottomContainerView.subviews {
                   
            if (subview.tag == 200) {
                       
                subview.removeFromSuperview()
            }
        }
        
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
                self.callGetScreenService(propertyId: propertyId)
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
    
    
    //Func - Get Screen Chart
    func getScreenChartData(screenId:String, movieId:String) -> Void {
        
        let currentDateTime = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "d MMM, h:mm a"
        realTimeHeaderDateTime.text = dateFormatter.string(from: currentDateTime)
        
        self.audiChartJson = JSON([:])
        self.bottomView.isHidden = true
        self.bottomContainerView.isHidden = false

       

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
                self.callGetScreenChartService(screenId: screenId, movieId: movieId)
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
    
    //Service - Get Screen
    func callGetScreenService(propertyId:String) -> Void {
           
           //Showing Loading
           showHUD()
           
           let accessTokenId  = UserDefaults.standard.string(forKey: LOGIN_ACCESSTOKEN_ID)
             
           let headers: HTTPHeaders = [
               "Authorization": "Bearer "+accessTokenId!
           ]
           
           print("Screen Headers")
           print(headers)
           print("\n")
     
           
           //Creating request
           let urlString = GET_SCREEN_API+propertyId
           
           print("Screen URL")
           print(urlString)
           print("\n")
           
           let alamoRequest = Alamofire.request(urlString, method: .get,  encoding: URLEncoding.default, headers: headers)
           
           print("Screen Request")
           print(alamoRequest)
           print("\n")
           
           alamoRequest.responseString { responseData in
                   
                   //Checking status code
                   if responseData.response?.statusCode == 200
                   {
                       
                       
                       
                       switch responseData.result
                       {
                       case let .success(value):
                           
                           self.audiListJson = JSON.init(parseJSON: value)
                           
                           
                           //print(self.audiListJson)
                           
                           if self.audiListJson.isEmpty
                           {
                            
                               //Stop loading
                               self.hideHUD()
                            
                               for subview in self.containerView.subviews {
                                   if (subview.tag == 100) {
                                                                          
                                       subview.removeFromSuperview()
                                   }
                                                                      
                               
                               }
                            
                                                           
                            let width = self.containerView.frame.size.width
                            let height = self.containerView.frame.size.height
                            self.noRealTimeView.frame = CGRect(x:0, y: 0, width: width, height: height)
                            self.noRealTimeView.tag = 100
                            self.containerView.addSubview(self.noRealTimeView)
                               
                               
                              
                             
                               
                           }
                           else
                           {
                               
                               for subview in self.containerView.subviews {
                                   
                                   if (subview.tag == 100) {
                                       
                                       subview.removeFromSuperview()
                                   }
                               }
                            
                            self.selectedAudiPosition = 0
                            self.setAudiValue()
                               
                               
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
                                    
                                                                   
                                    let width = self.containerView.frame.size.width
                                    let height = self.containerView.frame.size.height
                                    self.noRealTimeView.frame = CGRect(x:0, y: 0, width: width, height: height)
                                    self.noRealTimeView.tag = 100
                                    self.containerView.addSubview(self.noRealTimeView)
                                       
                                       
                                       
                                   }
                                   else
                                   {
                                       
                                       for subview in self.view.subviews {
                                           
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
    
    
    //Service - Get Screen Chart
    func callGetScreenChartService(screenId: String, movieId: String) -> Void {
           
           //Showing Loading
           showHUD()
           
           let accessTokenId  = UserDefaults.standard.string(forKey: LOGIN_ACCESSTOKEN_ID)
             
           let headers: HTTPHeaders = [
               "Authorization": "Bearer "+accessTokenId!
           ]
           
           print("Screen Chart Headers")
           print(headers)
           print("\n")
     
           
           //Creating request
           let urlString = GET_SCREEN_CHART_API+"screen/"+screenId+"/movieId/"+movieId
           
           print("Screen Chart URL")
           print(urlString)
           print("\n")
           
           let alamoRequest = Alamofire.request(urlString, method: .get,  encoding: URLEncoding.default, headers: headers)
           
           print("Screen Chart Request")
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
                           
                           self.audiChartJson = JSON.init(parseJSON: value)
                   
                           //print(self.audiChartJson)
                           
                           if self.audiChartJson.isEmpty
                           {
                               
                               for subview in self.bottomContainerView.subviews {
                                   if (subview.tag == 200) {
                                                                          
                                       subview.removeFromSuperview()
                                   }
                                                                      
                               
                               }
                            
                            self.setRealTimeValue()
                               
                               
                              
                             
                               
                           }
                           else
                           {
                               
                               for subview in self.bottomContainerView.subviews {
                                   
                                   if (subview.tag == 200) {
                                       
                                       subview.removeFromSuperview()
                                   }
                               }
                            
                            self.setRealTimeValue()
                            
                           
                               
                               
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
                                    
                                    self.setRealTimeValue()
                                       
                                       
                                       
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
       
    
    
    
    
    // MARK: - Collection View view data source
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if self.audiListJson.isEmpty {
            return 0
        }
               
               
        return (self.audiListJson.array?.count)!
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let audiCell = collectionView.dequeueReusableCell(withReuseIdentifier: "RealtimeAudiCollectionCell", for: indexPath as IndexPath) as! RealtimeAudiCollectionCell
        
        //Setting radius
        audiCell.contentBackground.layer.cornerRadius = 4
        audiCell.contentBackground.layer.masksToBounds = true
        
        
        let audiItem = audiListJson[indexPath.row]
        audiCell.audiName.text = audiItem["screen"]["name"].stringValue
        
        
        if selectedAudiPosition == indexPath.row
        {
            audiCell.contentBackground.backgroundColor = UIColor(red: 81/255, green: 45/255, blue: 168/255, alpha: 1.0)
                       
            audiCell.audiName.textColor = UIColor.white
            
            audiCell.contentBackground.layer.borderWidth = 1
            audiCell.contentBackground.layer.borderColor =  UIColor(red: 81/255, green: 45/255, blue: 168/255, alpha: 1.0).cgColor
            
           
        }
        else
        {
            
            audiCell.audiName.textColor = UIColor(red: 62/255, green: 63/255, blue: 66/255, alpha: 1.0)
                       
            audiCell.contentBackground.backgroundColor = UIColor(red: 253/255, green: 253/255, blue: 253/255, alpha: 1.0)
                       
            
            audiCell.contentBackground.layer.borderWidth = 1
            audiCell.contentBackground.layer.borderColor =  UIColor(red: 234/255, green: 237/255, blue: 243/255, alpha: 1.0).cgColor
            
           
        
                   
                  
        }
        
        return audiCell
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 90, height: 70)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
           
       
        self.selectedAudiPosition = indexPath.row
    
    
        let indexPathCurrent = IndexPath(item: self.selectedAudiPosition, section: 0)
        
        self.audiCollection.reloadData()
        
        self.audiCollection.scrollToItem(at:indexPathCurrent, at: .centeredHorizontally, animated: false)
        self.audiCollection.setNeedsLayout()
        
        //Set Screen
        self.startSetScreenChartData()
        
         
           
    }

    

}


