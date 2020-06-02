//
//  DateOverviewFirstSheetVC.swift
//  cosmiceye
//
//  Created by Rachin Allakkot on 29/11/19.
//  Copyright © 2019 Exuber. All rights reserved.
//

import UIKit
import FSCalendar

class DateOverviewFirstSheetVC: UIViewController , FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance{
    
    
    fileprivate lazy var calendarDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM, yyyy"
        return formatter
    }()
    
    
    @IBOutlet var dateSheetScrollView: UIScrollView!
    
    @IBOutlet var todayButton: UIButton!
    @IBOutlet var weekendButton: UIButton!
    @IBOutlet var lastWeekButton: UIButton!
    
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var applyButton: UIButton!
    
    
    @IBOutlet var startDateClick: UIView!
    @IBOutlet var startDateHeader: UILabel!
    @IBOutlet var startDateSelected: UILabel!
    
    
    @IBOutlet var endDateClick: UIView!
    @IBOutlet var endDateHeader: UILabel!
    @IBOutlet var endDateSelected: UILabel!
    
    @IBOutlet var dateSelectCalendar: FSCalendar!
    
    //Declaring varibles
    var isTodaySelected = false
    var isWeekendSelected = false
    var isLastWeekSelected = false
    
    var isStarDateSelected = false
    var isEndDateSelected = false
    
    var isApplyButtonClicked = false
    
    var selectedStartDateString = ""
    var selectedEndDateString = ""
  
    var selectedStartDate:Date!
    var selectedEndDate:Date!
    var selectedDateRange:[String]!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.sheetViewController?.handleScrollView(self.dateSheetScrollView)
        
        dateSelectCalendar.delegate = self
        dateSelectCalendar.dataSource = self
        
        dateSelectCalendar.firstWeekday = 1
        dateSelectCalendar.scrollDirection = .vertical
        
        dateSelectCalendar.today = nil
        dateSelectCalendar.appearance.headerTitleFont = UIFont(name: "Poppins-SemiBold", size: 16)!
        dateSelectCalendar.appearance.headerTitleColor = UIColor(red: 62/255, green: 63/255, blue: 66/255, alpha: 1.0)
        
        dateSelectCalendar.appearance.weekdayTextColor = UIColor(red: 62/255.0, green: 63/255.0, blue: 66/255.0, alpha: 0.5)
        dateSelectCalendar.appearance.weekdayFont = UIFont(name: "Poppins-Regular", size: 13)!
        dateSelectCalendar.appearance.titleTodayColor = UIColor.black
        dateSelectCalendar.appearance.caseOptions = [.weekdayUsesUpperCase]
        
               
        dateSelectCalendar.appearance.selectionColor = UIColor(red: 81/255.0, green: 48/255.0, blue: 168/255.0, alpha: 1.0)
        
        startDateHeader.textColor = UIColor(red: 62/255, green: 63/255, blue: 66/255, alpha: 1.0)
        startDateSelected.textColor = UIColor(red: 62/255, green: 63/255, blue: 66/255, alpha: 1.0)
        
        endDateHeader.textColor = UIColor(red: 62/255, green: 63/255, blue: 66/255, alpha: 1.0)
        endDateSelected.textColor = UIColor(red: 62/255, green: 63/255, blue: 66/255, alpha: 1.0)
         
       
        
        //Setting radius
        todayButton.layer.cornerRadius = 4
        todayButton.layer.masksToBounds = true
        
        weekendButton.layer.cornerRadius = 4
        weekendButton.layer.masksToBounds = true
        
        lastWeekButton.layer.cornerRadius = 4
        lastWeekButton.layer.masksToBounds = true
        
        applyButton.layer.cornerRadius = 4
        applyButton.layer.masksToBounds = true
        
        
        
        if isTodaySelected {
            
            todayButton.backgroundColor = UIColor(red: 81/255, green: 45/255, blue: 168/255, alpha: 1.0)
                       
            todayButton.setTitleColor(UIColor.white, for: .normal)
            
            todayButton.layer.borderWidth = 1
            todayButton.layer.borderColor =  UIColor(red: 81/255, green: 45/255, blue: 168/255, alpha: 1.0).cgColor
            
            let currentDate = Date()
            let startDate = currentDate.setDateTime(hour: 0, min: 0, sec: 0, yourDate: currentDate)
            let endDate = currentDate.setDateTime(hour: 23, min: 59, sec: 59, yourDate: currentDate)
                       
                
            let startString = calendarDateFormatter.string(from: startDate!)
            let endString = calendarDateFormatter.string(from: endDate!)
            
            startDateSelected.attributedText = NSAttributedString(string: startString, attributes:
                                  [.underlineStyle: NSUnderlineStyle.single.rawValue])
            endDateSelected.attributedText = NSAttributedString(string: endString, attributes:
            [.underlineStyle: NSUnderlineStyle.single.rawValue])
            
            selectedDateRange = self.generateDatesArrayBetweenTwoDates(startDate:startDate! , endDate: endDate!)
            
                       
            
        }
        else
        {
             
            todayButton.backgroundColor = UIColor(red: 253/255, green: 253/255, blue: 253/255, alpha: 1.0)
            
            todayButton.setTitleColor( UIColor(red: 62/255, green: 63/255, blue: 66/255, alpha: 1.0), for: .normal)
           
            
            todayButton.layer.borderWidth = 1
            todayButton.layer.borderColor =  UIColor(red: 234/255, green: 237/255, blue: 243/255, alpha: 1.0).cgColor
                                  
                      
        }
        
        if isWeekendSelected {
            
            weekendButton.backgroundColor = UIColor(red: 81/255, green: 45/255, blue: 168/255, alpha: 1.0)
            weekendButton.setTitleColor(UIColor.white, for: .normal)
            
            weekendButton.layer.borderWidth = 1
            weekendButton.layer.borderColor =  UIColor(red: 81/255, green: 45/255, blue: 168/255, alpha: 1.0).cgColor
            
            let currentDate = Date()
            let calendar = Calendar(identifier: .gregorian)
            let components = calendar.dateComponents([.weekday], from: currentDate)
            
            
            if components.weekday == 1 {
               
                let lastSunday = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentDate)!
                let lastFriday = lastSunday.previous(.friday)
                
                let startDate = lastFriday.setDateTime(hour: 0, min: 0, sec: 0, yourDate: lastFriday)
                let endDate = lastSunday.setDateTime(hour: 23, min: 59, sec: 59, yourDate: lastSunday)
                
                let startString = calendarDateFormatter.string(from: startDate!)
                let endString = calendarDateFormatter.string(from: endDate!)
                
                startDateSelected.attributedText = NSAttributedString(string: startString, attributes:
                                      [.underlineStyle: NSUnderlineStyle.single.rawValue])
                endDateSelected.attributedText = NSAttributedString(string: endString, attributes:
                [.underlineStyle: NSUnderlineStyle.single.rawValue])
                
                selectedDateRange = self.generateDatesArrayBetweenTwoDates(startDate:startDate! , endDate: endDate!)
                
                
               
            }else if components.weekday == 6 {
                
                
                let lastFriday = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentDate)!
                let lastSunday = currentDate.previous(.sunday)
                
                let startDate = lastFriday.setDateTime(hour: 0, min: 0, sec: 0, yourDate: lastFriday)
                let endDate = lastSunday.setDateTime(hour: 23, min: 59, sec: 59, yourDate: lastSunday)
                
                let startString = calendarDateFormatter.string(from: startDate!)
                let endString = calendarDateFormatter.string(from: endDate!)
                
                startDateSelected.attributedText = NSAttributedString(string: startString, attributes:
                                      [.underlineStyle: NSUnderlineStyle.single.rawValue])
                endDateSelected.attributedText = NSAttributedString(string: endString, attributes:
                [.underlineStyle: NSUnderlineStyle.single.rawValue])
                
                selectedDateRange = self.generateDatesArrayBetweenTwoDates(startDate:startDate! , endDate: endDate!)
              
               
               
            }else
            
            if components.weekday == 7 {
                 
                let lastSaturday = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentDate)!
                let lastFriday = lastSaturday.previous(.friday)
                let lastSunday = currentDate.previous(.sunday)
                
                let startDate = lastFriday.setDateTime(hour: 0, min: 0, sec: 0, yourDate: lastFriday)
                let endDate = lastSunday.setDateTime(hour: 23, min: 59, sec: 59, yourDate: lastSunday)
                
                let startString = calendarDateFormatter.string(from: startDate!)
                let endString = calendarDateFormatter.string(from: endDate!)
                
                startDateSelected.attributedText = NSAttributedString(string: startString, attributes:
                                      [.underlineStyle: NSUnderlineStyle.single.rawValue])
                endDateSelected.attributedText = NSAttributedString(string: endString, attributes:
                [.underlineStyle: NSUnderlineStyle.single.rawValue])
                
                selectedDateRange = self.generateDatesArrayBetweenTwoDates(startDate:startDate! , endDate: endDate!)
                
                
                
              
                
            }
            else
            {
                let lastFriday = currentDate.previous(.friday)
                let lastSunday = currentDate.previous(.sunday)
                
                let startDate = lastFriday.setDateTime(hour: 0, min: 0, sec: 0, yourDate: lastFriday)
                let endDate = lastSunday.setDateTime(hour: 23, min: 59, sec: 59, yourDate: lastSunday)
                
                let startString = calendarDateFormatter.string(from: startDate!)
                let endString = calendarDateFormatter.string(from: endDate!)
                
                startDateSelected.attributedText = NSAttributedString(string: startString, attributes:
                                      [.underlineStyle: NSUnderlineStyle.single.rawValue])
                endDateSelected.attributedText = NSAttributedString(string: endString, attributes:
                [.underlineStyle: NSUnderlineStyle.single.rawValue])
                
                selectedDateRange = self.generateDatesArrayBetweenTwoDates(startDate:startDate! , endDate: endDate!)
                
               
                
            }
            
        }
        else
        {
             
            weekendButton.backgroundColor = UIColor(red: 253/255, green: 253/255, blue: 253/255, alpha: 1.0)
            weekendButton.setTitleColor( UIColor(red: 62/255, green: 63/255, blue: 66/255, alpha: 1.0), for: .normal)
           
            
            weekendButton.layer.borderWidth = 1
            weekendButton.layer.borderColor =  UIColor(red: 234/255, green: 237/255, blue: 243/255, alpha: 1.0).cgColor
                                  
                      
        }
        
        if isLastWeekSelected {
            
            lastWeekButton.backgroundColor = UIColor(red: 81/255, green: 45/255, blue: 168/255, alpha: 1.0)
            lastWeekButton.setTitleColor(UIColor.white, for: .normal)
            
            lastWeekButton.layer.borderWidth = 1
            lastWeekButton.layer.borderColor =  UIColor(red: 81/255, green: 45/255, blue: 168/255, alpha: 1.0).cgColor
            
            
            let currentDate = Date()
            let calendar = Calendar(identifier: .gregorian)
            let components = calendar.dateComponents([.weekday], from: currentDate)

            if components.weekday == 2 {
                
                let startDate = currentDate.setDateTime(hour: 0, min: 0, sec: 0, yourDate: currentDate)
                let endDate = currentDate.setDateTime(hour: 23, min: 59, sec: 59, yourDate: currentDate)
                
                let startString = calendarDateFormatter.string(from: startDate!)
                let endString = calendarDateFormatter.string(from: endDate!)
                
                startDateSelected.attributedText = NSAttributedString(string: startString, attributes:
                                      [.underlineStyle: NSUnderlineStyle.single.rawValue])
                endDateSelected.attributedText = NSAttributedString(string: endString, attributes:
                [.underlineStyle: NSUnderlineStyle.single.rawValue])
                
                selectedDateRange = self.generateDatesArrayBetweenTwoDates(startDate:startDate! , endDate: endDate!)
                
                
            }
            else
            {
                
                let lastMonday = currentDate.previous(.monday)
                let startDate = lastMonday.setDateTime(hour: 0, min: 0, sec: 0, yourDate: lastMonday)
                let endDate = currentDate.setDateTime(hour: 23, min: 59, sec: 59, yourDate: currentDate)
                
                let startString = calendarDateFormatter.string(from: startDate!)
                let endString = calendarDateFormatter.string(from: endDate!)
                
                startDateSelected.attributedText = NSAttributedString(string: startString, attributes:
                                      [.underlineStyle: NSUnderlineStyle.single.rawValue])
                endDateSelected.attributedText = NSAttributedString(string: endString, attributes:
                [.underlineStyle: NSUnderlineStyle.single.rawValue])
                
                selectedDateRange = self.generateDatesArrayBetweenTwoDates(startDate:startDate! , endDate: endDate!)
                
            }
            
        }
        else
        {
             
            lastWeekButton.backgroundColor = UIColor(red: 253/255, green: 253/255, blue: 253/255, alpha: 1.0)
            lastWeekButton.setTitleColor( UIColor(red: 62/255, green: 63/255, blue: 66/255, alpha: 1.0), for: .normal)
           
            
            lastWeekButton.layer.borderWidth = 1
            lastWeekButton.layer.borderColor =  UIColor(red: 234/255, green: 237/255, blue: 243/255, alpha: 1.0).cgColor
                                  
                      
        }
        
        
        
        if isStarDateSelected
        {
            
            startDateSelected.attributedText = NSAttributedString(string: self.calendarDateFormatter.string(from: selectedStartDate), attributes:
                       [.underlineStyle: NSUnderlineStyle.single.rawValue])
            
        }
        
        
        if isEndDateSelected
        {
            
            endDateSelected.attributedText = NSAttributedString(string: self.calendarDateFormatter.string(from: selectedEndDate), attributes:
                                  [.underlineStyle: NSUnderlineStyle.single.rawValue])
            selectedDateRange = self.generateDatesArrayBetweenTwoDates(startDate:selectedStartDate , endDate: selectedEndDate)
        }
        
        
        
        dateSelectCalendar.reloadData()
        
        
        
        
       
        
        
    }
    
    static func instantiate() -> DateOverviewFirstSheetVC {
        return UIStoryboard(name: "BottomSheet", bundle: nil).instantiateViewController(withIdentifier: "DateOverviewFirstSheetScreen") as! DateOverviewFirstSheetVC
    }
    
    
       
    //Func - Today Date Click
    @IBAction func todayButtonClickFunction(_ sender: Any) {
        
         //Deselecting Top Date
        isWeekendSelected = false
        isLastWeekSelected = false
        
         //Deselecting Start Date and End Date
        isStarDateSelected = false
        isEndDateSelected = false
        
        selectedStartDateString = ""
        selectedEndDateString = ""
        
        selectedDateRange = [String]()
        
        //Deselecting Dates on Calendar
        if selectedStartDate != nil {
            
            dateSelectCalendar.deselect(selectedStartDate)
            selectedStartDate = nil
        }
        
        if selectedEndDate != nil {
            
            dateSelectCalendar.deselect(selectedEndDate)
            selectedEndDate = nil
        }
        
        dateSelectCalendar.reloadData()
        
        
        //Setting Today
        if isTodaySelected
        {
            isTodaySelected = false
            
            todayButton.backgroundColor = UIColor(red: 253/255, green: 253/255, blue: 253/255, alpha: 1.0)
            todayButton.setTitleColor( UIColor(red: 62/255, green: 63/255, blue: 66/255, alpha: 1.0), for: .normal)
            todayButton.layer.borderColor =  UIColor(red: 234/255, green: 237/255, blue: 243/255, alpha: 1.0).cgColor
            
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "- - -", attributes:
                                     [.underlineStyle: NSUnderlineStyle.single.rawValue])
            attributeString.removeAttribute(NSAttributedString.Key.underlineStyle, range: NSMakeRange(0, attributeString.length))
            startDateSelected.attributedText = attributeString
            endDateSelected.attributedText = attributeString
        }
        else
        {
            isTodaySelected = true
            
            todayButton.backgroundColor = UIColor(red: 81/255, green: 45/255, blue: 168/255, alpha: 1.0)
            todayButton.setTitleColor(UIColor.white, for: .normal)
            todayButton.layer.borderColor =  UIColor(red: 81/255, green: 45/255, blue: 168/255, alpha: 1.0).cgColor
            
            let currentDate = Date()
            let startDate = currentDate.setDateTime(hour: 0, min: 0, sec: 0, yourDate: currentDate)
            let endDate = currentDate.setDateTime(hour: 23, min: 59, sec: 59, yourDate: currentDate)
                       
                
            let startString = calendarDateFormatter.string(from: startDate!)
            let endString = calendarDateFormatter.string(from: endDate!)
            
            startDateSelected.attributedText = NSAttributedString(string: startString, attributes:
                                  [.underlineStyle: NSUnderlineStyle.single.rawValue])
            endDateSelected.attributedText = NSAttributedString(string: endString, attributes:
            [.underlineStyle: NSUnderlineStyle.single.rawValue])
            
            selectedDateRange = self.generateDatesArrayBetweenTwoDates(startDate:startDate! , endDate: endDate!)
            
            dateSelectCalendar.reloadData()
                   
            
            
            
        }
        
        
        //Setting Gray Background to other Buttons
        weekendButton.backgroundColor = UIColor(red: 253/255, green: 253/255, blue: 253/255, alpha: 1.0)
        weekendButton.setTitleColor( UIColor(red: 62/255, green: 63/255, blue: 66/255, alpha: 1.0), for: .normal)
        weekendButton.layer.borderColor =  UIColor(red: 234/255, green: 237/255, blue: 243/255, alpha: 1.0).cgColor
        
        lastWeekButton.backgroundColor = UIColor(red: 253/255, green: 253/255, blue: 253/255, alpha: 1.0)
        lastWeekButton.setTitleColor( UIColor(red: 62/255, green: 63/255, blue: 66/255, alpha: 1.0), for: .normal)
        lastWeekButton.layer.borderColor =  UIColor(red: 234/255, green: 237/255, blue: 243/255, alpha: 1.0).cgColor
        
       
        
    }
    
    //Func - Weekend Date Click
    @IBAction func weekendButtonClickFunction(_ sender: Any) {
        
        //Deselecting Top Date
        isTodaySelected = false
        isLastWeekSelected = false
        
        //Deselecting Start Date and End Date
        isStarDateSelected = false
        isEndDateSelected = false
        
        selectedStartDateString = ""
        selectedEndDateString = ""
        
        selectedDateRange = [String]()
        
       
        //Deselecting Dates on Calendar
        if selectedStartDate != nil {
            
            dateSelectCalendar.deselect(selectedStartDate)
        }
        
        if selectedEndDate != nil {
            
            dateSelectCalendar.deselect(selectedEndDate)
        }
        dateSelectCalendar.reloadData()
        
        
        //Setting Weekend
        if isWeekendSelected
        {
            isWeekendSelected = false
                       
            weekendButton.backgroundColor = UIColor(red: 253/255, green: 253/255, blue: 253/255, alpha: 1.0)
            weekendButton.setTitleColor( UIColor(red: 62/255, green: 63/255, blue: 66/255, alpha: 1.0), for: .normal)
            weekendButton.layer.borderColor =  UIColor(red: 234/255, green: 237/255, blue: 243/255, alpha: 1.0).cgColor
            
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "- - -", attributes:
                                     [.underlineStyle: NSUnderlineStyle.single.rawValue])
            attributeString.removeAttribute(NSAttributedString.Key.underlineStyle, range: NSMakeRange(0, attributeString.length))
            startDateSelected.attributedText = attributeString
            endDateSelected.attributedText = attributeString
            
        }
        else
        {
            isWeekendSelected = true
                       
            weekendButton.backgroundColor = UIColor(red: 81/255, green: 45/255, blue: 168/255, alpha: 1.0)
            weekendButton.setTitleColor(UIColor.white, for: .normal)
            weekendButton.layer.borderColor =  UIColor(red: 81/255, green: 45/255, blue: 168/255, alpha: 1.0).cgColor
            
            let currentDate = Date()
            let calendar = Calendar(identifier: .gregorian)
            let components = calendar.dateComponents([.weekday], from: currentDate)
            
            
            if components.weekday == 1 {
               
                let lastSunday = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentDate)!
                let lastFriday = lastSunday.previous(.friday)
                
                let startDate = lastFriday.setDateTime(hour: 0, min: 0, sec: 0, yourDate: lastFriday)
                let endDate = lastSunday.setDateTime(hour: 23, min: 59, sec: 59, yourDate: lastSunday)
                
                let startString = calendarDateFormatter.string(from: startDate!)
                let endString = calendarDateFormatter.string(from: endDate!)
                
                startDateSelected.attributedText = NSAttributedString(string: startString, attributes:
                                      [.underlineStyle: NSUnderlineStyle.single.rawValue])
                endDateSelected.attributedText = NSAttributedString(string: endString, attributes:
                [.underlineStyle: NSUnderlineStyle.single.rawValue])
                
                selectedDateRange = self.generateDatesArrayBetweenTwoDates(startDate:startDate! , endDate: endDate!)
                
                dateSelectCalendar.reloadData()
                
                
               
            }else if components.weekday == 6 {
                
                
                let lastFriday = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentDate)!
                let lastSunday = currentDate.previous(.sunday)
                
                let startDate = lastFriday.setDateTime(hour: 0, min: 0, sec: 0, yourDate: lastFriday)
                let endDate = lastSunday.setDateTime(hour: 23, min: 59, sec: 59, yourDate: lastSunday)
                
                let startString = calendarDateFormatter.string(from: startDate!)
                let endString = calendarDateFormatter.string(from: endDate!)
                
                startDateSelected.attributedText = NSAttributedString(string: startString, attributes:
                                      [.underlineStyle: NSUnderlineStyle.single.rawValue])
                endDateSelected.attributedText = NSAttributedString(string: endString, attributes:
                [.underlineStyle: NSUnderlineStyle.single.rawValue])
                
                selectedDateRange = self.generateDatesArrayBetweenTwoDates(startDate:startDate! , endDate: endDate!)
                
                dateSelectCalendar.reloadData()
              
               
               
            }else
            
            if components.weekday == 7 {
                 
                let lastSaturday = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentDate)!
                let lastFriday = lastSaturday.previous(.friday)
                let lastSunday = currentDate.previous(.sunday)
                
                let startDate = lastFriday.setDateTime(hour: 0, min: 0, sec: 0, yourDate: lastFriday)
                let endDate = lastSunday.setDateTime(hour: 23, min: 59, sec: 59, yourDate: lastSunday)
                
                let startString = calendarDateFormatter.string(from: startDate!)
                let endString = calendarDateFormatter.string(from: endDate!)
                
                startDateSelected.attributedText = NSAttributedString(string: startString, attributes:
                                      [.underlineStyle: NSUnderlineStyle.single.rawValue])
                endDateSelected.attributedText = NSAttributedString(string: endString, attributes:
                [.underlineStyle: NSUnderlineStyle.single.rawValue])
                
                selectedDateRange = self.generateDatesArrayBetweenTwoDates(startDate:startDate! , endDate: endDate!)
                
                dateSelectCalendar.reloadData()
                
              
                
            }
            else
            {
                let lastFriday = currentDate.previous(.friday)
                let lastSunday = currentDate.previous(.sunday)
                
                let startDate = lastFriday.setDateTime(hour: 0, min: 0, sec: 0, yourDate: lastFriday)
                let endDate = lastSunday.setDateTime(hour: 23, min: 59, sec: 59, yourDate: lastSunday)
                
                let startString = calendarDateFormatter.string(from: startDate!)
                let endString = calendarDateFormatter.string(from: endDate!)
                
                startDateSelected.attributedText = NSAttributedString(string: startString, attributes:
                                      [.underlineStyle: NSUnderlineStyle.single.rawValue])
                endDateSelected.attributedText = NSAttributedString(string: endString, attributes:
                [.underlineStyle: NSUnderlineStyle.single.rawValue])
                
                selectedDateRange = self.generateDatesArrayBetweenTwoDates(startDate:startDate! , endDate: endDate!)
                
                dateSelectCalendar.reloadData()
                
               
                
            }
        }
        
       
        //Setting Gray Background to other Buttons
        todayButton.backgroundColor = UIColor(red: 253/255, green: 253/255, blue: 253/255, alpha: 1.0)
        todayButton.setTitleColor( UIColor(red: 62/255, green: 63/255, blue: 66/255, alpha: 1.0), for: .normal)
        todayButton.layer.borderColor =  UIColor(red: 234/255, green: 237/255, blue: 243/255, alpha: 1.0).cgColor
        
        lastWeekButton.backgroundColor = UIColor(red: 253/255, green: 253/255, blue: 253/255, alpha: 1.0)
        lastWeekButton.setTitleColor( UIColor(red: 62/255, green: 63/255, blue: 66/255, alpha: 1.0), for: .normal)
        lastWeekButton.layer.borderColor =  UIColor(red: 234/255, green: 237/255, blue: 243/255, alpha: 1.0).cgColor
        
        
        
        
        
    }
    
    //Func - Last Week Click
    @IBAction func lastWeekButtonClickFunction(_ sender: Any) {
        
        //Deselecting Top Date
        isTodaySelected = false
        isWeekendSelected = false
        
        //Deselecting Start Date and End Date
        isStarDateSelected = false
        isEndDateSelected = false
        
        selectedStartDateString = ""
        selectedEndDateString = ""

        selectedDateRange = [String]()
        
        
        //Deselecting Dates on Calendar
        if selectedStartDate != nil {
            
            dateSelectCalendar.deselect(selectedStartDate)
            selectedStartDate = nil
        }
        
        if selectedEndDate != nil {
            
            dateSelectCalendar.deselect(selectedEndDate)
            selectedEndDate = nil
        }
        
        dateSelectCalendar.reloadData()
        
        //Setting Last week
        if isLastWeekSelected
        {
            isLastWeekSelected = false
            
            lastWeekButton.backgroundColor = UIColor(red: 253/255, green: 253/255, blue: 253/255, alpha: 1.0)
            lastWeekButton.setTitleColor( UIColor(red: 62/255, green: 63/255, blue: 66/255, alpha: 1.0), for: .normal)
            lastWeekButton.layer.borderColor =  UIColor(red: 234/255, green: 237/255, blue: 243/255, alpha: 1.0).cgColor
            
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "- - -", attributes:
                                     [.underlineStyle: NSUnderlineStyle.single.rawValue])
            attributeString.removeAttribute(NSAttributedString.Key.underlineStyle, range: NSMakeRange(0, attributeString.length))
            startDateSelected.attributedText = attributeString
            endDateSelected.attributedText = attributeString
            
            
        }
        else
        {
            isLastWeekSelected = true
            
            lastWeekButton.backgroundColor = UIColor(red: 81/255, green: 45/255, blue: 168/255, alpha: 1.0)
            lastWeekButton.setTitleColor(UIColor.white, for: .normal)
            lastWeekButton.layer.borderColor =  UIColor(red: 81/255, green: 45/255, blue: 168/255, alpha: 1.0).cgColor
            
            let currentDate = Date()
            let calendar = Calendar(identifier: .gregorian)
            let components = calendar.dateComponents([.weekday], from: currentDate)

            if components.weekday == 2 {
                
                let startDate = currentDate.setDateTime(hour: 0, min: 0, sec: 0, yourDate: currentDate)
                let endDate = currentDate.setDateTime(hour: 23, min: 59, sec: 59, yourDate: currentDate)
                
                let startString = calendarDateFormatter.string(from: startDate!)
                let endString = calendarDateFormatter.string(from: endDate!)
                
                startDateSelected.attributedText = NSAttributedString(string: startString, attributes:
                                      [.underlineStyle: NSUnderlineStyle.single.rawValue])
                endDateSelected.attributedText = NSAttributedString(string: endString, attributes:
                [.underlineStyle: NSUnderlineStyle.single.rawValue])
                
                selectedDateRange = self.generateDatesArrayBetweenTwoDates(startDate:startDate! , endDate: endDate!)
                
                dateSelectCalendar.reloadData()
                
                
            }
            else
            {
                
                let lastMonday = currentDate.previous(.monday)
                let startDate = lastMonday.setDateTime(hour: 0, min: 0, sec: 0, yourDate: lastMonday)
                let endDate = currentDate.setDateTime(hour: 23, min: 59, sec: 59, yourDate: currentDate)
                
                let startString = calendarDateFormatter.string(from: startDate!)
                let endString = calendarDateFormatter.string(from: endDate!)
                
                startDateSelected.attributedText = NSAttributedString(string: startString, attributes:
                                      [.underlineStyle: NSUnderlineStyle.single.rawValue])
                endDateSelected.attributedText = NSAttributedString(string: endString, attributes:
                [.underlineStyle: NSUnderlineStyle.single.rawValue])
                
                selectedDateRange = self.generateDatesArrayBetweenTwoDates(startDate:startDate! , endDate: endDate!)
                
                dateSelectCalendar.reloadData()
                
            }
            
        }
        
        //Setting Gray Background to other Buttons
        todayButton.backgroundColor = UIColor(red: 253/255, green: 253/255, blue: 253/255, alpha: 1.0)
        todayButton.setTitleColor( UIColor(red: 62/255, green: 63/255, blue: 66/255, alpha: 1.0), for: .normal)
        todayButton.layer.borderColor =  UIColor(red: 234/255, green: 237/255, blue: 243/255, alpha: 1.0).cgColor
        
        weekendButton.backgroundColor = UIColor(red: 253/255, green: 253/255, blue: 253/255, alpha: 1.0)
        weekendButton.setTitleColor( UIColor(red: 62/255, green: 63/255, blue: 66/255, alpha: 1.0), for: .normal)
        weekendButton.layer.borderColor =  UIColor(red: 234/255, green: 237/255, blue: 243/255, alpha: 1.0).cgColor
        
        
        
        
    }
    
    @IBAction func cancelBuutonClick(_ sender: Any) {
        
        self.sheetViewController?.dismiss(animated: false)
        
    }
    
    @IBAction func applyButtonClick(_ sender: Any) {
        
        
        if isTodaySelected == false && isWeekendSelected == false && isLastWeekSelected == false && isStarDateSelected == false &&  isEndDateSelected == false
        {
            
           self.showErrorMessage(errorMessage: "Select a date to proceed")
            
        }
        else
        {
            if isStarDateSelected == true &&  isEndDateSelected == false
            {
                isEndDateSelected = true
                selectedEndDate = selectedStartDate
                selectedEndDateString = self.calendarDateFormatter.string(from: selectedStartDate)
                
                isApplyButtonClicked = true
                self.sheetViewController?.dismiss(animated: false)
            }
            else
            {
                isApplyButtonClicked = true
                self.sheetViewController?.dismiss(animated: false)
            }
                           
            
        }
        
        
    }
    
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("Did select date \(self.calendarDateFormatter.string(from: date))")
        
        //Deselecting Top Date
        isTodaySelected = false
        isWeekendSelected = false
        isLastWeekSelected = false
                   
                   
        //Setting Gray Background to other Buttons
        todayButton.backgroundColor = UIColor(red: 253/255, green: 253/255, blue: 253/255, alpha: 1.0)
        todayButton.setTitleColor( UIColor(red: 62/255, green: 63/255, blue: 66/255, alpha: 1.0), for: .normal)
        todayButton.layer.borderColor =  UIColor(red: 234/255, green: 237/255, blue: 243/255, alpha: 1.0).cgColor
        
        weekendButton.backgroundColor = UIColor(red: 253/255, green: 253/255, blue: 253/255, alpha: 1.0)
        weekendButton.setTitleColor( UIColor(red: 62/255, green: 63/255, blue: 66/255, alpha: 1.0), for: .normal)
        weekendButton.layer.borderColor =  UIColor(red: 234/255, green: 237/255, blue: 243/255, alpha: 1.0).cgColor
        
        lastWeekButton.backgroundColor = UIColor(red: 253/255, green: 253/255, blue: 253/255, alpha: 1.0)
        lastWeekButton.setTitleColor( UIColor(red: 62/255, green: 63/255, blue: 66/255, alpha: 1.0), for: .normal)
        lastWeekButton.layer.borderColor =  UIColor(red: 234/255, green: 237/255, blue: 243/255, alpha: 1.0).cgColor
                   
        
        if isStarDateSelected == false {
            
            
           isStarDateSelected = true
           selectedStartDate = date
           selectedStartDateString = self.calendarDateFormatter.string(from: date)
           
           startDateSelected.attributedText = NSAttributedString(string: self.calendarDateFormatter.string(from: date), attributes:
           [.underlineStyle: NSUnderlineStyle.single.rawValue])
           
           selectedEndDate = nil
           selectedDateRange = [String]()
            
           isEndDateSelected = false
           selectedEndDateString = ""
            
            endDateSelected.attributedText = NSAttributedString(string: self.calendarDateFormatter.string(from: date), attributes:
            [.underlineStyle: NSUnderlineStyle.single.rawValue])
           
            
           self.dateSelectCalendar.reloadData()
            
            
        }
        else if isEndDateSelected == false
        {
            if(date <= selectedStartDate)
            {
                isStarDateSelected = true
                selectedStartDate = date
                selectedStartDateString = self.calendarDateFormatter.string(from: date)
                
                startDateSelected.attributedText = NSAttributedString(string: self.calendarDateFormatter.string(from: date), attributes:
                [.underlineStyle: NSUnderlineStyle.single.rawValue])
                
                selectedEndDate = nil
                selectedDateRange = [String]()
                 
                isEndDateSelected = false
                selectedEndDateString = ""
                
                endDateSelected.attributedText = NSAttributedString(string: self.calendarDateFormatter.string(from: date), attributes:
                [.underlineStyle: NSUnderlineStyle.single.rawValue])
                
                 
                self.dateSelectCalendar.reloadData()
                          
                
            }
            else
            {
                isEndDateSelected = true
                selectedEndDate = date
                selectedEndDateString = self.calendarDateFormatter.string(from: date)
                
                endDateSelected.attributedText = NSAttributedString(string: self.calendarDateFormatter.string(from: date), attributes:
                           [.underlineStyle: NSUnderlineStyle.single.rawValue])
                
                 selectedDateRange = self.generateDatesArrayBetweenTwoDates(startDate:selectedStartDate , endDate: selectedEndDate)
                
                self.dateSelectCalendar.reloadData()
                
            }
            
            
        }
        else if isStarDateSelected && isEndDateSelected
        {
            
            isStarDateSelected = true
            selectedStartDate = date
            selectedStartDateString = self.calendarDateFormatter.string(from: date)
            
            startDateSelected.attributedText = NSAttributedString(string: self.calendarDateFormatter.string(from: date), attributes:
            [.underlineStyle: NSUnderlineStyle.single.rawValue])
            
            
            selectedDateRange = [String]()
             
            isEndDateSelected = false
            selectedEndDateString = ""
            
            endDateSelected.attributedText = NSAttributedString(string: self.calendarDateFormatter.string(from: date), attributes:
            [.underlineStyle: NSUnderlineStyle.single.rawValue])
            
            
             
            self.dateSelectCalendar.reloadData()
                      
    
            
            
        }
        
       
        
       
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool
    {
        return true
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        
        if isStarDateSelected
        {
            let calandarDate = self.calendarDateFormatter.string(from: date)
            
            
            if calandarDate == selectedStartDateString
            {
              
                print(calandarDate)
              
                print(selectedStartDateString)
                return  UIColor.white
            }
            
            if calandarDate == selectedEndDateString
            {
              
                print(calandarDate)
              
                print(selectedStartDateString)
                return  UIColor.white
            }
            
            
        }
        else
        {
            if selectedDateRange != nil && !selectedDateRange.isEmpty
            {
                for indexIn in 0..<selectedDateRange.count
                {
                    let calandarDateIn = self.calendarDateFormatter.string(from: date)
                    
                    if calandarDateIn == selectedDateRange[indexIn]
                    {
                        if indexIn == 0
                        {
                            return  UIColor.white
                        }
                        else if indexIn == selectedDateRange.count-1
                        {
                            return  UIColor.white
                        }
                        
                        
                    }
                }
            }
            
        }
        
         return nil
        
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        
        if isStarDateSelected
        {
            let calandarDate = self.calendarDateFormatter.string(from: date)
            
            
            if calandarDate == selectedStartDateString
            {
               print("Calandar Date")
                print(calandarDate)
                print("Selected Date")
                print(selectedStartDateString)
                return  UIColor(red: 81/255, green: 45/255, blue: 168/255, alpha: 1.0)
            }
            
            
        }
        
        if isEndDateSelected
        {
            
            if !selectedDateRange.isEmpty
            {
                
                let calandarDateIn = self.calendarDateFormatter.string(from: date)
                
                if calandarDateIn == selectedEndDateString
                {
                    return  UIColor(red: 81/255, green: 45/255, blue: 168/255, alpha: 1.0)
                }
                else
                {
                    for indexIn in 0..<selectedDateRange.count
                    {
                       
                        if calandarDateIn == selectedDateRange[indexIn]
                        {
                            return  UIColor(red: 81/255, green: 45/255, blue: 168/255, alpha: 0.15)
                        }
                    }
                }
                
                
            }
            
            
        }
        else
        {
            
            if selectedDateRange != nil && !selectedDateRange.isEmpty
            {
                for indexIn in 0..<selectedDateRange.count
                {
                    let calandarDateIn = self.calendarDateFormatter.string(from: date)
                    
                    if calandarDateIn == selectedDateRange[indexIn]
                    {
                        if indexIn == 0
                        {
                            return  UIColor(red: 81/255, green: 45/255, blue: 168/255, alpha: 1.0)
                        }
                        else if indexIn == selectedDateRange.count-1
                        {
                            return  UIColor(red: 81/255, green: 45/255, blue: 168/255, alpha: 1.0)
                        }
                        else
                        {
                            return  UIColor(red: 81/255, green: 45/255, blue: 168/255, alpha: 0.15)
                        }
                        
                    }
                }
            }
            
        }
        
        
       
        
        return nil
        
     }
    
    //Func - Two Dates
    func generateDatesArrayBetweenTwoDates(startDate: Date , endDate:Date) ->[String]
    {
        var datesArray: [String] =  [String]()
        var startDate = startDate
        let calendar = Calendar.current

        
        
        while startDate <= endDate {
            
            let holidayDateString = calendarDateFormatter.string(from: startDate)
            datesArray.append(holidayDateString)
            startDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
            
        }
        return datesArray
    }
    
    
    
    
    
}
