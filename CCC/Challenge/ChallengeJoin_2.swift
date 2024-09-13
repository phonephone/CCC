//
//  ChallengeJoin_2.swift
//  CCC
//
//  Created by Truk Karawawattana on 27/9/2566 BE.
//

import HealthKit
import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import SDWebImage

class ChallengeJoin_2: UIViewController {
    var challengeID : String?
    var challengeJSON : JSON?
    
    var challengeMode: ChallengeMode?
    
    var newHeight:CGFloat?
    
    @IBOutlet weak var myScrollView: UIScrollView!
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var coverImageHeight: NSLayoutConstraint!
    
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var joinLabel: UILabel!
    @IBOutlet weak var qrBtn: UIButton!
    @IBOutlet weak var updateLabel: UILabel!
    
    @IBOutlet weak var rankingView: UIView!
    @IBOutlet weak var remainDayLabel: UILabel!
    @IBOutlet weak var rankingLabel: UILabel!
    @IBOutlet weak var joinDateLabel: UILabel!
    
    @IBOutlet weak var userCalTitle: UILabel!
    @IBOutlet weak var userCalLabel: UILabel!
    @IBOutlet weak var groupCalTitle: UILabel!
    @IBOutlet weak var groupCalLabel: UILabel!
    
    var blurView : UIVisualEffectView!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var qrPic: UIImageView!
    
    let refAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.Prompt_SemiBold(ofSize: 12),
        .foregroundColor: UIColor.themeColor,
        .underlineStyle: NSUnderlineStyle.single.rawValue
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("CHALLENGE JOIN 2")
        self.navigationController?.setStatusBar(backgroundColor: .themeColor)
        
        self.view.showAnimatedGradientSkeleton()
        
        myScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        coverImage.isHidden = true
        descriptionView.isHidden = true
        rankingView.isHidden = true
        userCalLabel.isHidden = true
        groupCalLabel.isHidden = true
        
        let attributeString = NSMutableAttributedString(
            string: qrBtn.titleLabel!.text!,
            attributes: refAttributes
        )
        qrBtn.setAttributedTitle(attributeString, for: .normal)
        
        blurView = blurViewSetup()
        
        let popupWidth = self.view.bounds.width*0.8
        let popupHeight = popupWidth*1.4
        popupView.frame = CGRect(x: (self.view.bounds.width-popupWidth)/2, y: (self.view.bounds.height-popupHeight)/2, width: popupWidth, height: popupHeight)
        
        loadChallengeSummary()
    }
    
    func loadChallengeSummary() {
        let parameters:Parameters = ["user_id":SceneDelegate.GlobalVariables.userID,
                                     "challenge_id":challengeID!
        ]
        
        loadRequest_V2(method:.post, apiName:"challenges/info", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
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
        coverImage.sd_setImage(with: URL(string:challengeJSON!["cover_img"].stringValue),
                               placeholderImage: UIImage(named: "icon_1024"),
                               completed: { (image, error, cacheType, url) in
            guard image != nil else {
                return
            }
            let ratio = image!.size.width / image!.size.height
            self.newHeight = self.coverImage.frame.width / ratio
            self.coverImageHeight.constant = self.newHeight!
            self.coverImage.isHidden = false
        })
        
        titleLabel.text = challengeJSON!["competition_name"].stringValue
        nameLabel.text = challengeJSON!["project_name"].stringValue
        dateLabel.text = challengeJSON!["date_string"].stringValue
        
        joinLabel.text = "\(challengeJSON!["number_challenge_participant"].stringValue) / \(challengeJSON!["participants"].stringValue)"
        
        updateLabel.text = challengeJSON!["update_time"].stringValue
        
        remainDayLabel.text = challengeJSON!["date_diff_txt"].stringValue
        rankingLabel.text = challengeJSON!["my_rank"].stringValue
        joinDateLabel.text = "วันที่เข้าร่วม : \(challengeJSON!["date_join"].stringValue)"
        
        userCalTitle.text = challengeJSON!["my_cal_title"].stringValue
        userCalLabel.text = challengeJSON!["my_cal"].stringValue
        groupCalTitle.text = challengeJSON!["sum_cal_group_title"].stringValue
        groupCalLabel.text = challengeJSON!["sum_cal_group"].stringValue
        
        descriptionView.isHidden = false
        rankingView.isHidden = false
        userCalLabel.isHidden = false
        groupCalLabel.isHidden = false
        
        //qrPic.image = generateQRCode(from: challengeJSON!["url_invite_code"].stringValue)
        //qrPic.image = generateQRCode(from: "\(SceneDelegate.GlobalVariables.userID)-\(challengeID!)")
        qrPic.image = generateQRCode(from: "ccc://challenge?\(challengeID!)")
        
        if challengeJSON!["show_status"].boolValue == false {
            qrBtn.isHidden = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.00) {
            self.view.hideSkeleton()
        }
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
    
    @IBAction func QRClick(_ sender: UIButton) {
        popIn(popupView: self.blurView)
        popIn(popupView: self.popupView)
    }
    
    @IBAction func QRClose(_ sender: UIButton) {
        popOut(popupView: self.popupView)
        popOut(popupView: self.blurView)
    }
    
    @IBAction func QRShare(_ sender: UIButton) {
        let qrImage = qrPic.image!.jpegData(compressionQuality: 1.0)
        //let qrImage = UIImage(named: "demo_home_bg")
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [qrImage!], applicationActivities: nil)
        
        // Anything you want to exclude
        activityViewController.excludedActivityTypes = [
            UIActivity.ActivityType.postToWeibo,
            //UIActivity.ActivityType.print,
            UIActivity.ActivityType.assignToContact,
            //UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.postToVimeo,
            UIActivity.ActivityType.postToTencentWeibo,
            //UIActivity.ActivityType.postToFacebook
        ]
        
        if let popoverController = activityViewController.popoverPresentationController {// iPad
            popoverController.sourceView = self.view
        }
        
        //activityViewController.isModalInPresentation = true
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func rankingClick(_ sender: UIButton) {
        let vc = UIStoryboard.challengeStoryBoard.instantiateViewController(withIdentifier: "ChallengeRank_2") as! ChallengeRank_2
        vc.challengeID = challengeID
        vc.challengeJSON = challengeJSON
        vc.newHeight = newHeight
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction func detailClick(_ sender: UIButton) {
        let vc = UIStoryboard.challengeStoryBoard.instantiateViewController(withIdentifier: "ChallengeDetail_2") as! ChallengeDetail_2
        vc.challengeMode = challengeMode
        vc.challengeID = challengeID
        vc.challengeJSON = challengeJSON
        self.navigationController!.pushViewController(vc, animated: true)
        
        print("XXX")
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.removeAnyViewControllers(ofKind: QRScanner.self)
        self.navigationController!.popToRootViewController(animated: true)
    }
}
