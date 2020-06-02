//
//  MovieOverviewSecondSheetVC.swift
//  cosmiceye
//
//  Created by Rachin Allakkot on 02/12/19.
//  Copyright © 2019 Exuber. All rights reserved.
//

import UIKit
import SwiftyJSON

class MovieOverviewSecondSheetVC: UIViewController {

    @IBOutlet var movieOverviewSecondSheetTable: UITableView!
    
    var selectedMoviePosition = 0
    var movieListJson:JSON = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.movieOverviewSecondSheetTable.delegate = self
        self.movieOverviewSecondSheetTable.dataSource = self
                     
        self.sheetViewController?.handleScrollView(self.movieOverviewSecondSheetTable)
    }
    
    static func instantiate() -> MovieOverviewSecondSheetVC {
        return UIStoryboard(name: "BottomSheet", bundle: nil).instantiateViewController(withIdentifier: "MovieOverviewSecondSheetScreen") as! MovieOverviewSecondSheetVC
    }
    
    @objc private func contentClickFunction(sender:UITapGestureRecognizer) {
           
           let indexSelected = sender.view?.tag
           selectedMoviePosition = indexSelected!
           
           self.sheetViewController?.dismiss(animated: false)
           
           //Reloading Table
           self.movieOverviewSecondSheetTable.beginUpdates()
           self.movieOverviewSecondSheetTable.endUpdates()
           self.movieOverviewSecondSheetTable.layer.removeAllAnimations()
       }

}
    


extension MovieOverviewSecondSheetVC: UITableViewDelegate, UITableViewDataSource {
      

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.movieListJson.isEmpty {
            return 0
        }
        
        
        return (self.movieListJson.array?.count)!
    }
          
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let movieCell = tableView.dequeueReusableCell(withIdentifier: "MovieOverviewSecondSheetCell", for: indexPath) as! MovieOverviewSecondSheetCell
        
        let movieItem = movieListJson[indexPath.row]
        movieCell.movieName.text = movieItem["name"].stringValue
        
        if selectedMoviePosition == indexPath.row
        {
            movieCell.accessoryType = .checkmark
        }
        else
        {
            movieCell.accessoryType = .none
        }
        
        movieCell.contentBackground.tag = indexPath.row
        
        let contentClickTap = UITapGestureRecognizer(target: self, action: #selector(contentClickFunction))
        movieCell.contentBackground.isUserInteractionEnabled = true
        movieCell.contentBackground.addGestureRecognizer(contentClickTap)
        
        return movieCell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
       
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat{
           return UITableView.automaticDimension
    }
        
        
}
