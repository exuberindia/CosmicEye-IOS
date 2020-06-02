//
//  AudiOverviewFirstSheetVC.swift
//  cosmiceye
//
//  Created by Rachin Allakkot on 07/01/20.
//  Copyright © 2020 Exuber. All rights reserved.
//

import UIKit
import SwiftyJSON

class AudiOverviewFirstSheetVC: UIViewController {

    @IBOutlet var audiOverviewFirstSheetTable: UITableView!
 
    var selectedAudiPosition = 0
    var audiListJson:JSON = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Came")
        print(audiListJson)

        self.audiOverviewFirstSheetTable.delegate = self
        self.audiOverviewFirstSheetTable.dataSource = self
               
        self.sheetViewController?.handleScrollView(self.audiOverviewFirstSheetTable)
    }
    
    static func instantiate() -> AudiOverviewFirstSheetVC {
        return UIStoryboard(name: "BottomSheet", bundle: nil).instantiateViewController(withIdentifier: "AudiOverviewFirstSheetScreen") as! AudiOverviewFirstSheetVC
    }
    
    @objc private func contentClickFunction(sender:UITapGestureRecognizer) {
           
           let indexSelected = sender.view?.tag
           selectedAudiPosition = indexSelected!
           
           self.sheetViewController?.dismiss(animated: false)
           
           //Reloading Table
           self.audiOverviewFirstSheetTable.beginUpdates()
           self.audiOverviewFirstSheetTable.endUpdates()
           self.audiOverviewFirstSheetTable.layer.removeAllAnimations()
       }

    }

extension AudiOverviewFirstSheetVC: UITableViewDelegate, UITableViewDataSource {
      

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.audiListJson.isEmpty {
            return 0
        }
        
        
        return (self.audiListJson.array?.count)!
    }
          
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let audiCell = tableView.dequeueReusableCell(withIdentifier: "AudiOverviewFirstSheetCell", for: indexPath) as! AudiOverviewFirstSheetCell
        
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

