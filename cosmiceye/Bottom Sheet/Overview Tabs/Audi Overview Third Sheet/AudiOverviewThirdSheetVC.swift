//
//  AudiOverviewThirdSheetVC.swift
//  cosmiceye
//
//  Created by Rachin Allakkot on 02/12/19.
//  Copyright © 2019 Exuber. All rights reserved.
//

import UIKit
import SwiftyJSON

class AudiOverviewThirdSheetVC: UIViewController {
    
    
   
    @IBOutlet var audiOverviewThirdSheetTable: UITableView!
    
    var selectedAudiPosition = 0
    var audiListJson:JSON = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
        self.audiOverviewThirdSheetTable.delegate = self
        self.audiOverviewThirdSheetTable.dataSource = self
        
        self.sheetViewController?.handleScrollView(self.audiOverviewThirdSheetTable)
              
    }
    
    static func instantiate() -> AudiOverviewThirdSheetVC {
        return UIStoryboard(name: "BottomSheet", bundle: nil).instantiateViewController(withIdentifier: "AudiOverviewThirdSheetScreen") as! AudiOverviewThirdSheetVC
    }
    
    @objc private func contentClickFunction(sender:UITapGestureRecognizer) {
           
           let indexSelected = sender.view?.tag
           selectedAudiPosition = indexSelected!
           
           self.sheetViewController?.dismiss(animated: false)
           
           //Reloading Table
           self.audiOverviewThirdSheetTable.beginUpdates()
           self.audiOverviewThirdSheetTable.endUpdates()
           self.audiOverviewThirdSheetTable.layer.removeAllAnimations()
       }
    

    

}

extension AudiOverviewThirdSheetVC: UITableViewDelegate, UITableViewDataSource {
      

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.audiListJson.isEmpty {
            return 0
        }
        
        
        return (self.audiListJson.array?.count)!
    }
          
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let audiCell = tableView.dequeueReusableCell(withIdentifier: "AudiOverviewThirdSheetCell", for: indexPath) as! AudiOverviewThirdSheetCell
        
        let audiItem = audiListJson[indexPath.row]
        audiCell.audiName.text = audiItem["screen"]["name"].stringValue
        
        if selectedAudiPosition == indexPath.row
        {
            audiCell.accessoryType = .checkmark
        }
        else
        {
            audiCell.accessoryType = .none
        }
        
        audiCell.contentBackground.tag = indexPath.row
        
        let contentClickTap = UITapGestureRecognizer(target: self, action: #selector(contentClickFunction))
        audiCell.contentBackground.isUserInteractionEnabled = true
        audiCell.contentBackground.addGestureRecognizer(contentClickTap)
        
        return audiCell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
       
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat{
           return UITableView.automaticDimension
    }
        
        
}

