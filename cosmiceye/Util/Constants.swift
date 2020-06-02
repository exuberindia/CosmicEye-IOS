//
//  Constants.swift
//  cosmiceye
//
//  Created by Rachin Allakkot on 21/11/19.
//  Copyright © 2019 Exuber. All rights reserved.
//

import UIKit
import Foundation

//USER DEFAULT KEYS
let IS_LOGGED_IN = "is_logged_in_V1-02"

let LOGIN_RESPONSE = "login_response"
let LOGIN_ACCESSTOKEN_ID = "login_access_token_id"
let FIREBASE_INSTANCE_ID = "firebase_instance_id"

let IS_REMEMBER_ME_SELECTED = "is_remember_me_selected"
let REMEMBER_ME_EMAIL = "remember_me_email"
let REMEMBER_ME_PASSWORD = "remember_me_password"

let STORED_PROPERTY_ID = "stored_property_id"

let STORED_PROPERTY_POSITION = "stored_property_position"


let IS_PROPERTY_STORED = "is_property_stored"
let STORED_PROPERTY_LIST = "stored_property_list"


let IS_TODAY_SELECTED = "is_today_selected"
let IS_WEEKEND_SELECTED = "is_weekend_selected"
let IS_LASTWEEK_SELECTED = "is_lastweek_selected"

let SELECTED_START_DATE = "selected_start_date"
let SELECTED_END_DATE = "selected_end_date"

let IS_START_DATE_SELECTED = "is_start_date_selected"
let IS_END_DATE_SELECTED = "is_end_date_selected"

let SELECTED_START_DATE_STRING = "selected_start_date_string"
let SELECTED_END_DATE_STRING = "selected_end_date_string"


let BASE_URL = "https://api.cosmiceye.in/"
let IMAGE_URL = "https://s3-us-west-1.amazonaws.com/dev-cosmic-eye-images/"


let LOGIN_API = BASE_URL+"auth-service/auth-service/oauth/token"
let GET_USER_API = BASE_URL+"user-service/user-service/logged-in"
let REGISTER_DEVICE_API = BASE_URL+"user-service/user-service/devices"

let GET_PROPERTY_API = BASE_URL+"property-service/property/logged-in"
let GET_SCREEN_API = BASE_URL+"schedule-service/time-slot/movies/property/"
let GET_SCREEN_CHART_API = BASE_URL+"dashboard-data-query-service/data-query-service/"

let GET_OVERVIEW_OVERVIEW_API = BASE_URL+"schedule-service/time-slot/time-slot-analytics/"
let GET_OVERVIEW_MOVIES_API = BASE_URL+"schedule-service/time-slot/movies/"
let GET_OVERVIEW_SCREENS_API = BASE_URL+"schedule-service/time-slot/screens/"

let GET_SCHEDULE_API = BASE_URL+"schedule-service/time-slot/"

let GET_NOTIFICATION_API = BASE_URL+"notification-service/notification-service/getNotifications"












