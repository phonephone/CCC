//
//  RankingAll.swift
//  CCC
//
//  Created by Truk Karawawattana on 11/1/2565 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD

enum RankingMode {
    case all
    case week
}

class RankingAll: UIViewController {
    
    var rankingJSON: JSON?
    var myRankJSON: JSON?
    
    var rankingMode: RankingMode?
    
    var allApiName: String = ""
    var myApiName: String = ""
    
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var myName: UILabel!
    @IBOutlet weak var myCalories: UILabel!
    
    @IBOutlet weak var myTableView: UITableView!
    
    var ordinalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .ordinal
        return formatter
    }()
    
    var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("RANKING \(rankingMode!)")
        
        if rankingMode == .all {
            allApiName = "rangking/all"
            myApiName = "rangking/user"
        }
        else {
            allApiName = "rangking/allWeek"
            myApiName = "rangking/userWeek"
        }
        
        // TableView
        self.myTableView.delegate = self
        self.myTableView.dataSource = self
        self.myTableView.backgroundColor = .clear
        //self.myTableView.tableFooterView = UIView(frame: .zero)
        self.myTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.myTableView.frame.size.width, height: 1))
        
        
//        let ordinalStr = ordinalFormatter.string(from: NSNumber(value: Int.random(in: 1..<10)))
//        let name = randomString(length: Int.random(in: 5..<12))
//        //cell.cellName.text = "\(ordinalStr!) \(name)"
//
//        let attString:NSMutableAttributedString = NSMutableAttributedString(string: "\(ordinalStr!) \(name)", attributes: [.font:UIFont.Prompt_Bold(ofSize: 17)])
//        attString.setAttributes([.font:UIFont.Prompt_Bold(ofSize: 14),.baselineOffset:5], range: NSRange(location:ordinalStr!.count-2,length:2))
//        myName.attributedText = attString
//
//        let randomInt = Int.random(in: 1000..<50000)
//        myCalories.text = numberFormatter.string(from: NSNumber(value: randomInt))
        
        loadRanking()
        loadMyRanking()
    }
    
    func loadRanking() {
        let parameters:Parameters = [:]
        loadRequest(method:.get, apiName:allApiName, authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                //print("SUCCESS RANKING ALL\(json)")

                self.rankingJSON = json["data"]
                self.myTableView.reloadData()
            }
        }
    }
    
    func loadMyRanking() {
        let parameters:Parameters = ["user_id":SceneDelegate.GlobalVariables.userID]
        loadRequest(method:.post, apiName:myApiName, authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS MY RANKING\(json)")
                
                self.myRankJSON = json["data"]
                self.updateMyUI()
            }
        }
    }
    
    func updateMyUI() {
        myImageView.sd_setImage(with: URL(string:myRankJSON!["pictureUrl"].stringValue), placeholderImage: UIImage(named: "icon_profile"))
        
        let ordinalStr = ordinalFormatter.string(from: NSNumber(value: myRankJSON!["rangking"].intValue))
        let name = myRankJSON!["name"].stringValue
        //cell.cellName.text = "\(ordinalStr!) \(name)"
        
        let attString:NSMutableAttributedString = NSMutableAttributedString(string: "\(ordinalStr!) \(name)", attributes: [.font:UIFont.Prompt_Bold(ofSize: 17)])
        attString.setAttributes([.font:UIFont.Prompt_Bold(ofSize: 14),.baselineOffset:5], range: NSRange(location:ordinalStr!.count-2,length:2))
        myName.attributedText = attString
        //myName.text = self.myRankJSON!["name"].stringValue
        myCalories.text = myRankJSON!["kcal"].stringValue
    }
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
}

// MARK: - UITableViewDataSource

extension RankingAll: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (rankingJSON != nil) {
            return rankingJSON!.count
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95//self.myTableView.frame.height/6
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RankingCell", for: indexPath) as! RankingCell
        
        let cellArray = rankingJSON![indexPath.item]
        
        let nameFont = UIFont.Prompt_Regular(ofSize: 14)
        let ordinalFont = UIFont.Prompt_Regular(ofSize: 12)
        cell.cellCalories.font = UIFont.Prompt_Bold(ofSize: 18)
        
        cell.cellBackground.backgroundColor = .white
        cell.cellName.textColor = .textDarkGray
        cell.cellCalories.textColor = .textDarkGray
        cell.cellKCal.textColor = .textDarkGray
        
        cell.cellImage.sd_setImage(with: URL(string:cellArray["pictureUrl"].stringValue), placeholderImage: UIImage(named: "icon_profile"))
        
        let ordinalStr = ordinalFormatter.string(from: NSNumber(value: cellArray["rangking"].intValue))
        let name = cellArray["name"].stringValue
        //cell.cellName.text = "\(ordinalStr!) \(name)"
        
        let attString:NSMutableAttributedString = NSMutableAttributedString(string: "\(ordinalStr!) \(name)", attributes: [.font:nameFont])
        attString.setAttributes([.font:ordinalFont,.baselineOffset:5], range: NSRange(location:ordinalStr!.count-2,length:2))
        cell.cellName.attributedText = attString
        
        cell.cellCalories.text = cellArray["kcal"].stringValue
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension RankingAll: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
