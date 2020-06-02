//
//  ProfileVC.swift
//  cosmiceye
//
//  Created by Rachin Allakkot on 04/12/19.
//  Copyright © 2019 Exuber. All rights reserved.
//

import UIKit
import SwiftyJSON
import FittedSheets
import Alamofire
import SDWebImage

class ProfileVC: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
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
    @IBOutlet var headerView: UIView!
    @IBOutlet var profileTable: UITableView!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var profileName: UILabel!
    
    
    //Declaring variables
    var selectedPropertyPosition = 0
    
    //List for storing
    var propertyListJson:JSON = [:]
    
    var expandedSectionHeaderNumber: Int = -1
    var sectionNames: Array<String> = []
    var sectionImages: Array<String> = []
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Delegate
        profileTable.delegate = self
        profileTable.dataSource = self
        
        let headerNib = UINib.init(nibName: "ProfileHeaderView", bundle: Bundle.main)
        profileTable.register(headerNib, forHeaderFooterViewReuseIdentifier: "ProfileHeaderView")
        
        sectionNames = [ "", "", "Properties","Support","Logout"]
        sectionImages = [ "USER-GREY", "PHONE-GREY", "FLAG-GREY","QUESTION-GREY","POWER-GREY"]
        
        //Setting Corner
        profileImage.layer.cornerRadius = 4
        profileImage.clipsToBounds = true
        
        
        
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
        
        self.getProperty()
        

        
           
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        for subview in self.containerView.subviews {
            if (subview.tag == 100) {
                                                   
                subview.removeFromSuperview()
            }
                                               
        
        }
    }
    
    //Selector Func - Try again click
    @objc private func tryAgainClickTap(_ button: UIButton)
    {
        self.getProperty()
         
    }
    
    //Set Property Value
    private func setPropertyValue() {
        
        let userJson = loadUserJSONDefaults()
        
        let propertyItem = self.propertyListJson[selectedPropertyPosition]
        propertyName.attributedText = NSAttributedString(string: propertyItem["shortCode"].stringValue, attributes:
        [.underlineStyle: NSUnderlineStyle.single.rawValue])
        
        self.profileName.text  = propertyItem["entity"]["name"].stringValue
        
        sectionNames[0] = userJson["email"].stringValue
        sectionNames[1] = userJson["phoneNumber"].stringValue
        
        //Moview Image
        if propertyItem["entity"]["imageFileName"].stringValue.isEmpty
        {
            self.profileImage.image = UIImage(named: "ic_default_image.png")
        }
        else
        {
            let profileImageUrl = IMAGE_URL+propertyItem["entity"]["imageFileName"].stringValue
            
            let profileImageUrlEncoded = profileImageUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            let callingUrl = URL(string: profileImageUrlEncoded!)
            
            self.profileImage.sd_setImage(with: callingUrl,placeholderImage:UIImage(named: "ic_default_image.png")) { (image, error, cache, urls) in
                if (error != nil) {
                    self.profileImage.image = UIImage(named: "ic_default_image.png")
                } else {
                    self.profileImage.image = image
                }
            }
        }
      
        self.propertySelectClick.isHidden = true
        self.profileTable.tableHeaderView = headerView
        self.profileTable.isHidden = false
        self.profileTable.reloadData()
        
        
    
    }
    
    func showLogoutConfirmation() {
    
        let alert = UIAlertController(title: "Are you sure you want to logout?", message: nil, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Logout", style: .default, handler: { action in
            
             self.logoutApp()
                        
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true)
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
        
      
        self.propertySelectClick.isHidden = true
        self.profileTable.tableHeaderView = nil
        self.profileTable.isHidden = true
        
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
                            
                            //Stop loading
                            self.hideHUD()
                            
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
           return .lightContent
    }
    
    
    
    
    
    //TableView protocols
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
                                
        if self.propertyListJson.isEmpty {
            return 0
        }
        
        return sectionNames.count
    }
              
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (self.expandedSectionHeaderNumber == section) {
           
            if section == 2
            {
                //Checking list for empty
                if self.propertyListJson.isEmpty {
                    return 0
                }
                                        
                                            
                return (self.propertyListJson.array?.count)!
            }
            
            if section == 3
            {
                return 1
            }
        }
        
        
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 2
        {
            // Configure the cell...
            let propertyCell = tableView.dequeueReusableCell(withIdentifier: "ProfilePropertyCell", for: indexPath) as! ProfilePropertyCell
            
            let propertyItem = propertyListJson[indexPath.row]
            propertyCell.propertyName.text = propertyItem["shortCode"].stringValue+" - "+propertyItem["name"].stringValue
            
            return propertyCell
            
        }
        else
        {
            // Configure the cell...
            let supportCell = tableView.dequeueReusableCell(withIdentifier: "ProfileSupportCell", for: indexPath) as! ProfileSupportCell
            
            supportCell.supportText.text = "Contact +91 9740611225 for any queries"
            
            //Click Events
            let supportClickTap = UITapGestureRecognizer(target: self, action: #selector(supportClickFunction))
            supportCell.supportText.isUserInteractionEnabled = true
            supportCell.supportText.addGestureRecognizer(supportClickTap)
            
            return supportCell
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
       
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
                  
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ProfileHeaderView") as! ProfileHeaderView
           
        
        headerView.headerName.text = sectionNames[section]
        headerView.headerIcon.image = UIImage(named: sectionImages[section])
        
        
        if section == 2 || section == 3
        {
            
            headerView.arrowIcon.isHidden = false
            if section == expandedSectionHeaderNumber
            {
                headerView.arrowIcon.image = UIImage(named: "ARROW-DOWN-GREY")
            }
            else
            {
                headerView.arrowIcon.image = UIImage(named: "ARROW-NEXT-GREY")
            }
        }
        else
        {
            headerView.arrowIcon.isHidden = true
        }
              
                         
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 56
           
    }
       
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
         let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        
        // make headers touchable
        header.tag = section
        let headerTapGesture = UITapGestureRecognizer()
        headerTapGesture.addTarget(self, action: #selector(sectionHeaderWasTouched(_:)))
        header.addGestureRecognizer(headerTapGesture)
        
        
        
        
    }
    
    
    
    @objc private func sectionHeaderWasTouched(_ sender: UITapGestureRecognizer) {
        
        let headerView = sender.view as! UITableViewHeaderFooterView
        let section    = headerView.tag
        
        
        if section == 2 || section == 3
        {
            if self.expandedSectionHeaderNumber == -1
            {
                self.expandedSectionHeaderNumber = section
                tableViewExpandSection(section)
            }
            else
            {
                if (self.expandedSectionHeaderNumber == section)
                {
                    tableViewCollapeSection(section )
                }
                else
                {
                    
                    tableViewCollapeSection(self.expandedSectionHeaderNumber)
                    tableViewExpandSection(section)
                }
            }
        }
        
        if section == 1
        {
            supportCallFunction()
        }
        
        
        if section == 4
        {
            showLogoutConfirmation()
        }
    }
    
    func tableViewCollapeSection(_ section: Int) {
        
       
        
        self.expandedSectionHeaderNumber = -1;
        if section == 2
        {
            var indexesPath = [IndexPath]()
            for i in 0 ..< (self.propertyListJson.array?.count)! {
                let index = IndexPath(row: i, section: section)
                indexesPath.append(index)
            }
            self.profileTable.beginUpdates()
            self.profileTable.deleteRows(at: indexesPath, with: UITableView.RowAnimation.fade)
            self.profileTable.endUpdates()
        }
        else if section == 3
        {
            var indexesPath = [IndexPath]()
            let index = IndexPath(row: 0, section: section)
            indexesPath.append(index)
            
            self.profileTable.beginUpdates()
            self.profileTable.deleteRows(at: indexesPath, with: UITableView.RowAnimation.fade)
            self.profileTable.endUpdates()
        }
       
        
        self.profileTable.reloadSections([section], with: .none)
        
        
    }
    
    func tableViewExpandSection(_ section: Int) {
        
        if section == 2
        {
            var indexesPath = [IndexPath]()
            
            for i in 0 ..< (self.propertyListJson.array?.count)! {
                let index = IndexPath(row: i, section: section)
                indexesPath.append(index)
            }
            self.expandedSectionHeaderNumber = section
            self.profileTable.beginUpdates()
            self.profileTable.insertRows(at: indexesPath, with: UITableView.RowAnimation.fade)
            self.profileTable.endUpdates()
                       
        }
        else if section == 3
        {
            var indexesPath = [IndexPath]()
            
            let index = IndexPath(row: 0, section: section)
            indexesPath.append(index)
            self.expandedSectionHeaderNumber = section
            self.profileTable.beginUpdates()
            self.profileTable.insertRows(at: indexesPath, with: UITableView.RowAnimation.fade)
            self.profileTable.endUpdates()
        }
       
        
        self.profileTable.reloadSections([section], with: .none)
        
        
    }
    
    //Func - Calling Phone
    private func supportCallFunction() {
        
        if let phoneCallURL = URL(string: "telprompt://\(+919740611225)") {

            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                if #available(iOS 10.0, *) {
                    application.open(phoneCallURL, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                     application.openURL(phoneCallURL as URL)

                }
            }
            else
            {
                showErrorMessage(errorMessage: "Cannot open dialer. Please call manually")
            }
        }
        else
        {
            showErrorMessage(errorMessage: "Cannot open dialer. Please call manually")
        }
        
    }
    
    //Func - Calling Phone
    @objc private func supportClickFunction(_ sender: UITapGestureRecognizer) {
        
        
        print("Clicked")
        
        if let phoneCallURL = URL(string: "telprompt://\(+919740611225)") {

            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                if #available(iOS 10.0, *) {
                    application.open(phoneCallURL, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                     application.openURL(phoneCallURL as URL)

                }
            }
            else
            {
                showErrorMessage(errorMessage: "Cannot open dialer. Please call manually")
            }
        }
        else
        {
            showErrorMessage(errorMessage: "Cannot open dialer. Please call manually")
        }
        
    }
    
   
    
}
    
    
    

   


