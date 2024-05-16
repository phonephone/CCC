//
//  ChallengeRank_2.swift
//  CCC
//
//  Created by Truk Karawawattana on 27/9/2566 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD

class ChallengeRank_2: UIViewController {
    
    var challengeJSON : JSON?
    var rankingJSON : JSON?
    
    var newHeight:CGFloat?
    
    @IBOutlet weak var myScrollView: UIScrollView!
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var coverImageHeight: NSLayoutConstraint!
    
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var joinLabel: UILabel!
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userRankLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userCalLabel: UILabel!
    
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
        
        myScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        // TableView
        self.myTableView.delegate = self
        self.myTableView.dataSource = self
        self.myTableView.backgroundColor = .clear
        //self.myTableView.tableFooterView = UIView(frame: .zero)
        self.myTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.myTableView.frame.size.width, height: 1))
        
        coverImageHeight.constant = 150//newHeight ?? 192
        
        coverImage.sd_setImage(with: URL(string:challengeJSON!["cover_img"].stringValue), placeholderImage: UIImage(named: "icon_1024"), completed: { (image, error, cacheType, url) in
            guard image != nil else {
                return
            }
//            let ratio = image!.size.width / image!.size.height
//            let newHeight = self.coverImage.frame.width / ratio
//            self.coverImageHeight.constant = newHeight
            self.coverImage.isHidden = false
        })
        
        titleLabel.text = challengeJSON!["competition_name"].stringValue
        nameLabel.text = challengeJSON!["project_name"].stringValue
        dateLabel.text = "\(challengeJSON!["start_date"].stringValue) - \(challengeJSON!["end_date"].stringValue)"
        
        joinLabel.text = "\(challengeJSON!["number_challenge_participant"].stringValue) / \(challengeJSON!["participants"].stringValue)"
        
        userImage.sd_setImage(with: URL(string:challengeJSON!["myImageUrl"].stringValue), placeholderImage: UIImage(named: "icon_profile"))
        userNameLabel.text = challengeJSON!["myName"].stringValue
        userRankLabel.text = challengeJSON!["my_rank"].stringValue//ordinalFormatter.string(from: NSNumber(value: challengeJSON!["my_rank"].intValue))
        userCalLabel.text = challengeJSON!["my_cal"].stringValue
        //userCalLabel.text = challengeJSON!["my_cal"].stringValue.replacingOccurrences(of: " kcal", with: "", options: NSString.CompareOptions.literal, range: nil)
        
        rankingJSON = challengeJSON!["participant_rank"]
        myTableView.reloadData()
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ChallengeRank_2: UITableViewDataSource {
    
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
        return 40//self.myTableView.frame.height/6
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RankingCell", for: indexPath) as! RankingCell
        
        let cellArray = rankingJSON![indexPath.item]
        
//        if indexPath.row%2 == 0 {
//            cell.cellBackground.backgroundColor = .lightGray.withAlphaComponent(0.2)
//        }
//        else{
//            cell.cellBackground.backgroundColor = .white
//        }
        
        cell.cellImage.sd_setImage(with: URL(string:cellArray["pictureUrl"].stringValue), placeholderImage: UIImage(named: "icon_profile"))
        
        let ordinalStr = indexPath.item+1 //cellArray["ranking"].stringValue//ordinalFormatter.string(from: NSNumber(value: cellArray["ranking"].intValue))
        let name = cellArray["first_name"].stringValue
        cell.cellName.text = "\(ordinalStr). \(name)"
        cell.cellCalories.text = cellArray["sum"].stringValue
        //cell.cellCalories.text = cellArray["sum"].stringValue.replacingOccurrences(of: " kcal", with: "", options: NSString.CompareOptions.literal, range: nil)
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ChallengeRank_2: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}


