//
//  ChallengeJoin.swift
//  CCC
//
//  Created by Truk Karawawattana on 14/1/2565 BE.
//

import HealthKit
import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD

class ChallengeJoin: UIViewController {
    
    var challengeID : String?
    var challengeJSON : JSON?
    
    var challengeMode: ChallengeMode?
    
    @IBOutlet weak var myScrollView: UIScrollView!
    
    @IBOutlet weak var challengeImageView: UIImageView!
    @IBOutlet weak var challengeName: UILabel!
    @IBOutlet weak var challengeDay: UILabel!
    
    @IBOutlet weak var challengeRank: UILabel!
    @IBOutlet weak var challengeDate: UILabel!
    
    @IBOutlet weak var challengeRight1: UILabel!
    @IBOutlet weak var challengeRight2: UILabel!
    @IBOutlet weak var challengeRight3: UILabel!
    
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var detailBtn: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadChallengeSummary()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        
        shareBtn.imageView?.contentMode = .scaleAspectFit
        shareBtn.contentHorizontalAlignment = .fill
        shareBtn.contentVerticalAlignment = .fill
        shareBtn.imageEdgeInsets = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 0);
        shareBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10);
        
        detailBtn.imageView?.contentMode = .scaleAspectFit
        detailBtn.contentHorizontalAlignment = .fill
        detailBtn.contentVerticalAlignment = .fill
        detailBtn.imageEdgeInsets = UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 0);
        detailBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10);
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        //totalCaloriesLabel.text = formatter.string(from: 5700200)
    }
    
    func loadChallengeSummary() {
        let parameters:Parameters = ["user_id":SceneDelegate.GlobalVariables.userID,
                                     "challenge_id":challengeID!
        ]
        
        loadRequest(method:.post, apiName:"challenges/summary_challenges", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS CHALLENGE SUMMARY\(json)")
                
                self.challengeJSON = json["data"][0]
                self.updateBtn()
            }
        }
    }
    
    func updateBtn() {
        challengeImageView.sd_setImage(with: URL(string:challengeJSON!["cover_img"].stringValue), placeholderImage: UIImage(named: "icon_1024"))
        challengeName.text = challengeJSON!["competition_name"].stringValue
        challengeDay.text = challengeJSON!["date_diff_txt"].stringValue
        challengeRank.text = challengeJSON!["my_rank"].stringValue
        challengeDate.text = challengeJSON!["today"].stringValue
        challengeRight1.text = "\(challengeJSON!["number_challenge_participant"].stringValue) / \(challengeJSON!["participants"].stringValue)"
        challengeRight2.text = challengeJSON!["my_cal"].stringValue
        challengeRight3.text = challengeJSON!["sum_cal_group"].stringValue
    }
    
    @IBAction func shareClick(_ sender: UIButton) {
        
    }
    
    @IBAction func rankingClick(_ sender: UIButton) {
        let vc = UIStoryboard.challengeStoryBoard.instantiateViewController(withIdentifier: "ChallengeRank") as! ChallengeRank
        vc.challengeJSON = challengeJSON
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction func detailClick(_ sender: UIButton) {
        let vc = UIStoryboard.challengeStoryBoard.instantiateViewController(withIdentifier: "ChallengeDetail") as! ChallengeDetail
        vc.challengeMode = challengeMode
        vc.challengeID = challengeID
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popToRootViewController(animated: true)
    }
}
