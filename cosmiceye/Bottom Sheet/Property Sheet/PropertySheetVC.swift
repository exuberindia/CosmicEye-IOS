//
//  PropertySheetVC.swift
//  cosmiceye
//
//  Created by Rachin Allakkot on 28/11/19.
//  Copyright © 2019 Exuber. All rights reserved.
//

import UIKit
import SwiftyJSON

class PropertySheetVC: UIViewController {
    
    
    @IBOutlet var propertySheetTable: UITableView!
    
    var selectedPropertyPosition = 0
    var propertyListJson:JSON = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.propertySheetTable.delegate = self
        self.propertySheetTable.dataSource = self
        
        self.sheetViewController?.handleScrollView(self.propertySheetTable)
    }
    
    static func instantiate() -> PropertySheetVC {
        return UIStoryboard(name: "BottomSheet", bundle: nil).instantiateViewController(withIdentifier: "PropertySheetScreen") as! PropertySheetVC
    }
        

    //Selector Func - Content Click
    @objc private func contentClickFunction(sender:UITapGestureRecognizer) {
        
        let indexSelected = sender.view?.tag
        selectedPropertyPosition = indexSelected!
        
        self.sheetViewController?.dismiss(animated: false)
        
        //Reloading Table
        self.propertySheetTable.beginUpdates()
        self.propertySheetTable.endUpdates()
        self.propertySheetTable.layer.removeAllAnimations()
    }
        
}

extension PropertySheetVC: UITableViewDelegate, UITableViewDataSource {
          
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.propertyListJson.isEmpty {
            return 0
        }
        
        
        return (self.propertyListJson.array?.count)!
    }
          
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let propertyCell = tableView.dequeueReusableCell(withIdentifier: "PropertySheetCell", for: indexPath) as! PropertySheetCell
        
        let propertyItem = propertyListJson[indexPath.row]
        propertyCell.propertyName.text = propertyItem["shortCode"].stringValue+" - "+propertyItem["name"].stringValue
        
        if selectedPropertyPosition == indexPath.row
        {
            propertyCell.accessoryType = .checkmark
        }
        else
        {
            propertyCell.accessoryType = .none
        }
        
        propertyCell.contentBackground.tag = indexPath.row
        
        let contentClickTap = UITapGestureRecognizer(target: self, action: #selector(contentClickFunction))
        propertyCell.contentBackground.isUserInteractionEnabled = true
        propertyCell.contentBackground.addGestureRecognizer(contentClickTap)
        
        return propertyCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
       
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat{
           return UITableView.automaticDimension
    }
    
    
}




