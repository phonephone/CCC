//
//  ChallengeRank.swift
//  CCC
//
//  Created by Truk Karawawattana on 14/1/2565 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD

class ChallengeRank: UIViewController {
    
    var challengeJSON : JSON?
    var rankingJSON : JSON?
    
    @IBOutlet weak var challengeImageView: UIImageView!
    @IBOutlet weak var challengeName: UILabel!
    
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
        
        // TableView
        self.myTableView.delegate = self
        self.myTableView.dataSource = self
        self.myTableView.backgroundColor = .clear
        //self.myTableView.tableFooterView = UIView(frame: .zero)
        self.myTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.myTableView.frame.size.width, height: 1))
        
        challengeImageView.sd_setImage(with: URL(string:challengeJSON!["cover_img"].stringValue), placeholderImage: UIImage(named: "icon_1024"))
        challengeName.text = challengeJSON!["competition_name"].stringValue
        
        myImageView.sd_setImage(with: URL(string:challengeJSON!["myImageUrl"].stringValue), placeholderImage: UIImage(named: "icon_profile"))
        
        let ordinalStr = ordinalFormatter.string(from: NSNumber(value: challengeJSON!["my_rank"].intValue))
        let name = challengeJSON!["myName"].stringValue
        //cell.cellName.text = "\(ordinalStr!) \(name)"
        
        let attString:NSMutableAttributedString = NSMutableAttributedString(string: "\(ordinalStr!) \(name)", attributes: [.font:UIFont.Prompt_Bold(ofSize: 17)])
        attString.setAttributes([.font:UIFont.Prompt_Bold(ofSize: 14),.baselineOffset:5], range: NSRange(location:ordinalStr!.count-2,length:2))
        myName.attributedText = attString
        //myName.text = self.myRankJSON!["name"].stringValue
        myCalories.text = challengeJSON!["my_cal"].stringValue
        
        rankingJSON = challengeJSON!["participant_rank"]
        myTableView.reloadData()
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ChallengeRank: UITableViewDataSource {
    
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
        
        if indexPath.row%2 == 0 {
            cell.cellBackground.backgroundColor = .lightGray.withAlphaComponent(0.2)
        }
        else{
            cell.cellBackground.backgroundColor = .white
        }
        
        let nameFont = UIFont.Prompt_Regular(ofSize: 14)
        let ordinalFont = UIFont.Prompt_Regular(ofSize: 12)
        cell.cellCalories.font = UIFont.Prompt_Bold(ofSize: 18)
        
        cell.cellName.textColor = .textDarkGray
        cell.cellCalories.textColor = .textDarkGray
        cell.cellKCal.textColor = .textDarkGray
        
        cell.cellImage.sd_setImage(with: URL(string:cellArray["pictureUrl"].stringValue), placeholderImage: UIImage(named: "icon_profile"))
        
        let ordinalStr = ordinalFormatter.string(from: NSNumber(value: cellArray["ranking"].intValue))
        let name = cellArray["first_name"].stringValue
        //cell.cellName.text = "\(ordinalStr!) \(name)"
        
        let attString:NSMutableAttributedString = NSMutableAttributedString(string: "\(ordinalStr!) \(name)", attributes: [.font:nameFont])
        attString.setAttributes([.font:ordinalFont,.baselineOffset:5], range: NSRange(location:ordinalStr!.count-2,length:2))
        cell.cellName.attributedText = attString
        
        cell.cellCalories.text = cellArray["sum"].stringValue
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ChallengeRank: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

