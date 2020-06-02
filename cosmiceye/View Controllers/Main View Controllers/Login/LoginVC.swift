//
//  LoginVC.swift
//  cosmiceye
//
//  Created by Rachin Allakkot on 21/11/19.
//  Copyright © 2019 Exuber. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import FirebaseMessaging

class LoginVC: UIViewController,UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate {

    //Declaring views
    @IBOutlet var loginTable: UITableView!
    
    var isShowPasswordClicked = false
    var isRememberMeSelected = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         hideKeyboardWhenTappedAround()
  
        //Delegate
        self.loginTable.delegate = self
        self.loginTable.dataSource = self
        
        self.loginTable.reloadData()
        
        //Checking Remember Me  status
        if UserDefaults.standard.object(forKey: IS_REMEMBER_ME_SELECTED) == nil
        {
            self.isRememberMeSelected = false
            
            let indexPath = IndexPath.init(row: 0, section: 0)
            let loginCell = self.loginTable.cellForRow(at: indexPath) as! LoginCell
            
            loginCell.rememberCheck.image = UIImage(named: "ic_checkbox.png")
                
        }
        else
        {
            //Checking Remember Me status
            if UserDefaults.standard.bool(forKey: IS_REMEMBER_ME_SELECTED)
            {
                self.isRememberMeSelected = true
                
                let indexPath = IndexPath.init(row: 0, section: 0)
                let loginCell = self.loginTable.cellForRow(at: indexPath) as! LoginCell
                
                let storedEmail  = UserDefaults.standard.string(forKey: REMEMBER_ME_EMAIL)
                let storedPassword  = UserDefaults.standard.string(forKey: REMEMBER_ME_PASSWORD)
                
                loginCell.emailTxt.text = storedEmail
                loginCell.passwordTxt.text = storedPassword
                
                loginCell.rememberCheck.image = UIImage(named: "ic_checkbox_selected.png")
                        
            }
            else
            {
                self.isRememberMeSelected = false
                
                let indexPath = IndexPath.init(row: 0, section: 0)
                let loginCell = self.loginTable.cellForRow(at: indexPath) as! LoginCell
                
                loginCell.rememberCheck.image = UIImage(named: "ic_checkbox.png")
            
            }
                
                
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
      
        let indexPath = IndexPath.init(row: 0, section: 0)
        let loginCell = self.loginTable.cellForRow(at: indexPath) as! LoginCell
        
        if textField == loginCell.emailTxt {
          
            textField.resignFirstResponder()
            loginCell.passwordTxt.becomeFirstResponder()
       
        } else if textField == loginCell.passwordTxt {
          
            textField.resignFirstResponder()
            
            self.loginButtonClickFunction()
          
       }
      
        return true

        
    }
    
    

    //TableView protocols
       
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Configure the cell...
        let loginCell = tableView.dequeueReusableCell(withIdentifier: "LoginCell", for: indexPath) as! LoginCell
        
        loginCell.emailTxt.delegate = self
        loginCell.passwordTxt.delegate = self
        
        if self.isRememberMeSelected
        {
                       
            loginCell.rememberCheck.image = UIImage(named: "ic_checkbox_selected.png")
                       
        }
        else
        {
            loginCell.rememberCheck.image = UIImage(named: "ic_checkbox.png")
        }

        //Click events
        loginCell.loginButton.addTarget(self, action:#selector(loginButtonClickFunction)
                          , for: .touchUpInside)
        
        loginCell.loginTroubleButton.addTarget(self, action:#selector(loginTroubleButtonClickFunction(_:))
                                 , for: .touchUpInside)
        
        
        
        let showHidePasswordClickTap = UITapGestureRecognizer(target: self, action: #selector(showHidePasswordClickFunction))
        loginCell.showHidePasswordClick.isUserInteractionEnabled = true
        loginCell.showHidePasswordClick.addGestureRecognizer(showHidePasswordClickTap)
        
        let rememberMeClickTap = UITapGestureRecognizer(target: self, action: #selector(rememberMeClickFunction))
        loginCell.rememberClick.isUserInteractionEnabled = true
        loginCell.rememberClick.addGestureRecognizer(rememberMeClickTap)
              
        
        return loginCell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    //Selector Func - Show Hide Password click
    @objc private func showHidePasswordClickFunction() {
        
        let indexPath = IndexPath.init(row: 0, section: 0)
        let loginCell = self.loginTable.cellForRow(at: indexPath) as! LoginCell
        
        if self.isShowPasswordClicked
        {
            self.isShowPasswordClicked = false
            loginCell.showHidePasswordIcon.image = UIImage(named: "EYE-STRIKE")
        }
        else
        {
            self.isShowPasswordClicked = true
            loginCell.showHidePasswordIcon.image = UIImage(named: "EYE")
        }

        loginCell.passwordTxt.isSecureTextEntry.toggle()
        
        //Reloading Table
        self.loginTable.beginUpdates()
        self.loginTable.endUpdates()
        self.loginTable.layer.removeAllAnimations()
        
    }
    
    //Selector Func - Login Trouble Button click
    @objc private func loginTroubleButtonClickFunction(_ button: UIButton)
    {
    }
    
    //Selector Func - Remember me click
    @objc private func rememberMeClickFunction() {
        
        let indexPath = IndexPath.init(row: 0, section: 0)
        let loginCell = self.loginTable.cellForRow(at: indexPath) as! LoginCell
        
        if self.isRememberMeSelected {
            
            self.isRememberMeSelected = false
            loginCell.rememberCheck.image = UIImage(named: "ic_checkbox.png")
            
  
            
        }
        else
        {
            self.isRememberMeSelected = true
            loginCell.rememberCheck.image = UIImage(named: "ic_checkbox_selected.png")
        }
    }
    
    //Selector Func - Login Button Click
    @objc private func loginButtonClickFunction()
    {
        let indexPath = IndexPath.init(row: 0, section: 0)
        let loginCell = self.loginTable.cellForRow(at: indexPath) as! LoginCell
        
        //Hiding keyboard
        loginCell.emailTxt.resignFirstResponder()
        loginCell.passwordTxt.resignFirstResponder()
        
        //Reading input values
        let emailText = loginCell.emailTxt.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let passwordText = loginCell.passwordTxt.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        //Validate text fields
        let validFlag = validateLoginTextFields(emailText: emailText!, passwordText: passwordText!)
        
        if validFlag
        {
            //Login User
            loginUser(emailText: emailText!, passwordText: passwordText!)
        }
              
        
    }
    
    //Func - Validating Login Textfields value
    func validateLoginTextFields(emailText : String, passwordText : String) -> Bool
    {
        let indexPath = IndexPath.init(row: 0, section: 0)
        let loginCell = self.loginTable.cellForRow(at: indexPath) as! LoginCell
        
        var isValid = true
        
        //Checking password field
        if passwordText.isEmpty {
            
            loginCell.passwordError.text = "Please Enter Password"
            loginCell.passwordErrorHeightConstraint.constant = 16
            isValid = false
        }
        else
        {
            loginCell.passwordErrorHeightConstraint.constant = 0
        }
        
        
        //Checking email field
        if emailText.isEmpty {
            
            loginCell.emailError.text = "Please Enter Email"
            loginCell.emailErrorHeightConstraint.constant = 16
            isValid = false
        }
        else
        {
            
            
            if isValidEmail(enteredEmail: emailText)
            {
                 loginCell.emailErrorHeightConstraint.constant = 0
            }
            else
            {
                loginCell.emailError.text = "Please Enter Valid Email"
                loginCell.emailErrorHeightConstraint.constant = 16
                isValid = false
                
            }
            
            
        }
        
        //Reloading Table
        self.loginTable.layer.removeAllAnimations()
        self.loginTable.beginUpdates()
        self.loginTable.endUpdates()
        
        
        print(isValid)
        
    
        return isValid
    }
    
    
    //Func - Login User
    func loginUser(emailText : String, passwordText : String){
        
        //Checking internet connection
        if Reachability.isConnectedToNetwork()
        {
            callLoginUserService(emailText: emailText,passwordText: passwordText)
        }
        else
        {
            self.showErrorMessage(errorMessage: "No Internet Connection")
           
        }
    }
    
    //Func - Get User
    func getUser(){
        
        //Checking internet connection
        if Reachability.isConnectedToNetwork()
        {
            callGetUserService()
        }
        else
        {
            self.showErrorMessage(errorMessage: "No Internet Connection")
           
        }
    }
    
    //Func - Register Device Id
    func registerDeviceId(){
        
        //Checking internet connection
        if Reachability.isConnectedToNetwork()
        {
            callRegisterDeviceIdService()
        }
        else
        {
            self.showErrorMessage(errorMessage: "No Internet Connection")
           
        }
    }
    
    //Service Calls
    
    //Service - Login User
    func callLoginUserService(emailText : String, passwordText : String){
 
        //Showing Loading
        showHUD()
       
        let username = "cosmic-eye-client"
        let password = "cosmic-eye-secret"
        let credentialData = String(format: "%@:%@", username, password).data(using: String.Encoding.utf8)!
        
        let base64Credentials = credentialData.base64EncodedString()
        print(base64Credentials)
        
  
        let headers = [
            "Authorization": "Basic \(base64Credentials)",
            "Accept": "application/json;charset=UTF-8",
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        print("Login Headers")
        print(headers)
        print("\n")
        
        let urlString = LOGIN_API
        
        print("Login URL")
        print(urlString)
        print("\n")
        
        let parameters: Parameters = [
            "username" : emailText,
            "password" : passwordText,
            "grant_type" : "password"
        ]
        
        print("Login Param")
        print(parameters)
        print("\n")
        
        
        let alamoRequest = Alamofire.request(urlString, method: .post,parameters: parameters, encoding: URLEncoding.default, headers: headers)
               
        alamoRequest.responseString { responseData in
            
            //Checking status code
            if responseData.response?.statusCode == 200
            {
                       
                
                       
                switch responseData.result
                {
                    case let .success(value):
                        
                           
                    let loginResponseJson = JSON.init(parseJSON: value)
                            
                    //Final Data
                    print(loginResponseJson)
                    
                    let cosmicEyeDefaults = UserDefaults.standard
                    
                    //Storing into defaults
                    cosmicEyeDefaults.setValue(loginResponseJson["access_token"].stringValue, forKey: LOGIN_ACCESSTOKEN_ID)
                    cosmicEyeDefaults.setValue("-1", forKey: STORED_PROPERTY_ID)
                    cosmicEyeDefaults.synchronize()
                    
                    self.getUser()
                    
                   
     
                           
                  break
                           
                  case let .failure(error):
                    
                  //Stop loading
                  self.hideHUD()
                           
                  print("Failure")
                  print(error)
                  self.showErrorMessage(errorMessage: "Email or Password is Incorrect")
                  
                           
                  break
                           
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
                        self.showErrorMessage(errorMessage: "Email or Password is Incorrect")
                    }
                    else
                    {
                        self.showErrorMessage(errorMessage: "Can\'t connect Server! Error:"+String(describing: responseCode))
                    }
                           
                           
                }
                else
                {
                    self.showErrorMessage(errorMessage: "Something went wrong!")
                    
                           
                }
                       
            }
                                        
                                 
        }
               
  
                                           
        
    }
    
    
    //Service -  Get User
    func callGetUserService(){
    
            //Showing Loading
            showHUD()
          
            let accessTokenId  = UserDefaults.standard.string(forKey: LOGIN_ACCESSTOKEN_ID)
                       
            let headers: HTTPHeaders = [
                "Authorization": "Bearer "+accessTokenId!
            ]
                     
            print("Get User Headers")
            print(headers)
            print("\n")
               
                     
            //Creating request
            let urlString = GET_USER_API
                     
            print("Get User URL")
            print(urlString)
            print("\n")
                     
            let alamoRequest = Alamofire.request(urlString, method: .get,  encoding: URLEncoding.default, headers: headers)
                     
            print("Get User Request")
            print(alamoRequest)
            print("\n")
           
           
                  
           alamoRequest.responseString { responseData in
               
               //Checking status code
               if responseData.response?.statusCode == 200
               {
                          
                  
                          
                   switch responseData.result
                   {
                       case let .success(value):
                              
                       let userResponseJson = JSON.init(parseJSON: value)
                               
                       //Final Data
                       print(userResponseJson)
                       
                       let cosmicEyeDefaults = UserDefaults.standard
                       
                       //Storing into defaults
                       cosmicEyeDefaults.setValue(userResponseJson.rawString()!, forKey: LOGIN_RESPONSE)
                       cosmicEyeDefaults.synchronize()
                       
                       
                       self.registerDeviceId()
                 
        
                              
                     break
                              
                     case let .failure(error):
                        
                     //Stop loading
                     self.hideHUD()
                              
                     print("Failure")
                     print(error)
                     self.showErrorMessage(errorMessage: "Something went wrong!")
                     
                              
                     break
                              
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
                           self.showErrorMessage(errorMessage: "Unauthorized or Invalid access token")
                       }
                       else
                       {
                           self.showErrorMessage(errorMessage: "Can\'t connect Server! Error:"+String(describing: responseCode))
                       }
                              
                              
                   }
                   else
                   {
                       self.showErrorMessage(errorMessage: "Something went wrong!")
                       
                              
                   }
                          
               }
                                           
                                    
           }
                  
     
                                              
           
       }
    
    
    //Service - Register Device Id
    func callRegisterDeviceIdService(){
    
        //Showing Loading
        showHUD()
          
        let accessTokenId  = UserDefaults.standard.string(forKey: LOGIN_ACCESSTOKEN_ID)
       
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer "+accessTokenId!
        ]
        
        print("Register Device Headers")
        print(headers)
        print("\n")
        
        let urlString = REGISTER_DEVICE_API
        
        print("Register Device URL")
        print(urlString)
        print("\n")
        
        var firebaseToken  = ""
        
        if let token = Messaging.messaging().fcmToken {
         
            firebaseToken = token
        }
        
        let parameters: Parameters = [
            "deviceId" : firebaseToken,
            "platform" : "iOS"
            
        ]
        
        print("Register Param")
        print(parameters)
        print("\n")
        
        let alamoRequest = Alamofire.request(urlString, method: .post,parameters: parameters, encoding: JSONEncoding.default, headers: headers)
        
        alamoRequest.responseString { responseData in
               
            
               //Checking status code
               if responseData.response?.statusCode == 200
               {
                
                     
                
                    //Stop loading
                    self.hideHUD()
                
                
                    switch responseData.result
                    {
                                   
                    case let .success(value):
                                          
                    let deviceRegisterJson = JSON.init(parseJSON: value)
                                           
                    //Final Data
                    print(deviceRegisterJson)
                    
                    let cosmicEyeDefaults = UserDefaults.standard
                    
                    if self.isRememberMeSelected {
                        
                        let indexPath = IndexPath.init(row: 0, section: 0)
                        let loginCell = self.loginTable.cellForRow(at: indexPath) as! LoginCell
                        
                        let emailText = loginCell.emailTxt.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                        let passwordText = loginCell.passwordTxt.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        cosmicEyeDefaults.setValue(true, forKey: IS_REMEMBER_ME_SELECTED)
                        cosmicEyeDefaults.setValue(emailText!, forKey: REMEMBER_ME_EMAIL)
                        cosmicEyeDefaults.setValue(passwordText!, forKey: REMEMBER_ME_PASSWORD)
                        
                    }
                    else
                    {
                         cosmicEyeDefaults.setValue(false, forKey: IS_REMEMBER_ME_SELECTED)
                    }
                    
                    
                    
                    cosmicEyeDefaults.setValue(true, forKey: IS_TODAY_SELECTED)
                    cosmicEyeDefaults.setValue(false, forKey: IS_WEEKEND_SELECTED)
                    cosmicEyeDefaults.setValue(false, forKey: IS_LASTWEEK_SELECTED)
                    
                   
                    
                    cosmicEyeDefaults.setValue(false, forKey: IS_START_DATE_SELECTED)
                    cosmicEyeDefaults.setValue(false, forKey: IS_END_DATE_SELECTED)
                    
                    cosmicEyeDefaults.setValue("", forKey: SELECTED_START_DATE_STRING)
                    cosmicEyeDefaults.setValue("", forKey: SELECTED_END_DATE_STRING)
                    
               
                    cosmicEyeDefaults.setValue(true, forKey: IS_LOGGED_IN)
                    cosmicEyeDefaults.synchronize()
                                   
                    //Going to Home
                    let storyboard = UIStoryboard(name: "Content", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "HomeScreen")
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                             
                    
                                          
                    break
                                          
                    case let .failure(error):
                                 
                                          
                    print("Failure")
                    print(error)
                    self.showErrorMessage(errorMessage: "Something went wrong!")
                                 
                                          
                    break
                                          
                    }
                     
                   
                          
                }
                else
                {
                   //Stop loading
                   self.hideHUD()
                          
                   //Checking status
                   if let responseCode = responseData.response?.statusCode
                   {
                    
                       print(responseCode)
                       
                       if responseCode == 400 || responseCode == 401
                       {
                           self.showErrorMessage(errorMessage: "Unauthorized or Invalid access token")
                       }
                       else
                       {
                           self.showErrorMessage(errorMessage: "Can\'t connect Server! Error:"+String(describing: responseCode))
                       }
                              
                              
                   }
                   else
                   {
                       self.showErrorMessage(errorMessage: "Something went wrong!")
                       
                              
                   }
                          
               }
                                           
                                    
           }
                  
                  
        
                                
           
    }
       
       
       

}
