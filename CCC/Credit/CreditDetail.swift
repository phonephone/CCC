//
//  CreditDetail.swift
//  CCC
//
//  Created by Truk Karawawattana on 15/12/2566 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import SkeletonView

class CreditDetail: UIViewController {
    
    var creditID : String?
    var detailJSON: JSON?
    
    @IBOutlet weak var headTitle: UILabel!
    @IBOutlet weak var coverImage: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var typeImage: UIImageView!
    @IBOutlet weak var typeTitle: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    @IBOutlet weak var coinImage: UIImageView!
    @IBOutlet weak var coinTitle: UILabel!
    @IBOutlet weak var coinLabel: UILabel!
    
    @IBOutlet weak var timeImage: UIImageView!
    @IBOutlet weak var timeTitle: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var durationImage: UIImageView!
    @IBOutlet weak var durationTitle: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var termsLabel: UILabel!
    
    @IBOutlet weak var myScrollView: UIScrollView!
    @IBOutlet weak var myStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.showAnimatedGradientSkeleton()
        
        print("CREDIT DETAIL")
        self.navigationController?.setStatusBar(backgroundColor: .themeColor)
        
        myScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        
        acceptBtn.isHidden = true
        termsLabel.isHidden = true
        
        loadDetail()
    }
    
    func loadDetail() {
        let parameters:Parameters = ["id":creditID!]
        loadRequest_V2(method:.post, apiName:"credit/activity_info", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS HOME\(json)")
                
                self.detailJSON = json["data"]
                
                self.updateDisplay()
            }
        }
    }
    
    func updateDisplay() {
        //headTitle.text = detailJSON!["type_name"].stringValue
        coverImage.sd_setImage(with: URL(string:detailJSON!["image_cover"].stringValue), placeholderImage: nil)
        
        titleLabel.text = detailJSON!["title"].stringValue
        
        switch detailJSON!["type_id"].stringValue {
        case "1"://Assessment
            typeImage.image = UIImage(named: "credit_clipboard")
            acceptBtn.isHidden = false
            //termsLabel.isHidden = true
            
        case "2"://Activity
            typeImage.image = UIImage(named: "credit_activity")
            acceptBtn.isHidden = true
            //termsLabel.isHidden = false
            
        case "3"://Special
            typeImage.image = UIImage(named: "credit_special")
            acceptBtn.isHidden = true
            //termsLabel.isHidden = false
            
        default:
            break
        }
        
        typeTitle.text = detailJSON!["type_text"].stringValue
        typeLabel.text = detailJSON!["type_name"].stringValue
        
        coinTitle.text = detailJSON!["get_text"].stringValue
        coinLabel.text = detailJSON!["point"].stringValue
        
        timeTitle.text = detailJSON!["condition_1_text"].stringValue
        timeLabel.text = detailJSON!["condition_1"].stringValue
        
        durationTitle.text = detailJSON!["condition_2_text"].stringValue
        durationLabel.text = detailJSON!["condition_2"].stringValue
        
        //descriptionLabel.text = detailJSON!["detail"].stringValue.html2String
        //descriptionTextView.text = detailJSON!["detail"].stringValue.html2String
        descriptionTextView.attributedText = detailJSON!["detail"].stringValue.convertToAttributedFromHTML()
        descriptionTextView.textColor = .textGray1
        descriptionTextView.font = .Prompt_Regular(ofSize: 14)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.00) {
            self.view.hideSkeleton()
        }
    }
    
    @IBAction func acceptClicked(_ sender: UIButton) {
        let vc = UIStoryboard.mainStoryBoard_2.instantiateViewController(withIdentifier: "Web") as! Web
        vc.titleString = detailJSON!["type_name"].stringValue
        vc.webUrlString = detailJSON!["url"].stringValue
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
}
