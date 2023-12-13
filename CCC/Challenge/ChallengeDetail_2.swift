//
//  ChallengeDetail_2.swift
//  CCC
//
//  Created by Truk Karawawattana on 27/9/2566 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import SwiftAlertView

class ChallengeDetail_2: UIViewController {
    
    var challengeID : String?
    var challengeJSON : JSON?
    
    var challengeMode: ChallengeMode?
    
    var inviteID = ""
    
    @IBOutlet weak var myScrollView: UIScrollView!
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var coverImageHeight: NSLayoutConstraint!
    
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var joinLabel: UILabel!
    @IBOutlet weak var updateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var ruleView: UIView!
    @IBOutlet weak var typeStack: UIStackView!
    @IBOutlet weak var dailyCalLabel: UILabel!
    @IBOutlet weak var dailyDurationLabel: UILabel!
    @IBOutlet weak var dailyTimeLabel: UILabel!
    @IBOutlet weak var ruleLabel: UILabel!
    
    @IBOutlet weak var methodView: UIView!
    @IBOutlet weak var methodStack: UIStackView!
    
    @IBOutlet weak var inviteView: UIView!
    @IBOutlet weak var inviteCodeField: UITextField!
    
    @IBOutlet weak var passcodeView: UIView!
    @IBOutlet weak var passCodeField: UITextField!
    
    @IBOutlet weak var submitBtn: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadChallengeDetail(showLoadingHUD: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("CHALLENGE DETAIL 2")
        print(inviteID)
        
        myScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        descriptionView.isHidden = true
        ruleView.isHidden = true
        methodView.isHidden = true
        passcodeView.isHidden = true
        inviteView.isHidden = true
        submitBtn.disableBtn()
        
        inviteCodeField.text = inviteID
    }
    
    func loadChallengeDetail(showLoadingHUD:Bool) {
        let parameters:Parameters = ["user_id":SceneDelegate.GlobalVariables.userID,
                                     "challenge_id":challengeID!
        ]
        
        loadRequest_V2(method:.post, apiName:"challenges/info", authorization:true, showLoadingHUD:showLoadingHUD, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                //print("SUCCESS CHALLENGE DETAIL 2\(json)")
                
                self.challengeJSON = json["data"][0]
                self.updateBtn()
            }
        }
    }
    
    func updateBtn() {
        submitBtn.enableBtn()
        
        //DESCRIPTION VIEW
        //coverImage.sd_setImage(with: URL(string:challengeJSON!["cover_img"].stringValue), placeholderImage: UIImage(named: "icon_1024"))
        
        coverImage.sd_setImage(with: URL(string:challengeJSON!["cover_img"].stringValue),
                               placeholderImage: UIImage(named: "icon_1024"),
                               completed: { (image, error, cacheType, url) in
            guard image != nil else {
                return
            }
            let ratio = image!.size.width / image!.size.height
            let newHeight = self.coverImage.frame.width / ratio
            self.coverImageHeight.constant = newHeight
        })
        
        titleLabel.text = challengeJSON!["competition_name"].stringValue
        nameLabel.text = challengeJSON!["project_name"].stringValue
        dateLabel.text = challengeJSON!["date_string"].stringValue
        
        joinLabel.text = "\(challengeJSON!["number_challenge_participant"].stringValue) / \(challengeJSON!["participants"].stringValue)"
        
        updateLabel.text = challengeJSON!["update_time"].stringValue
        
        descriptionLabel.text = challengeJSON!["description"].stringValue.html2String
        descriptionView.isHidden = false
        
        //RULE VIEW
        let typeArray = challengeJSON!["type_activity"]
        for i in 0...typeArray.count {
            if typeArray[i]["act_type"] == "text" {
                let label = UILabel()
                label.text = typeArray[i]["act_name_th"].stringValue
                label.textColor = .textGray1
                label.font = .Prompt_SemiBold(ofSize: 13)
                typeStack.addArrangedSubview(label)
            }
            else {
                let imageView = UIImageView()
                imageView.contentMode = .scaleAspectFit
                //imageView.image = UIImage(named: "icon_run")
                imageView.sd_setImage(with: URL(string:typeArray[i]["act_icon_name"].stringValue))
                imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.0/1.0).isActive = true
                imageView.heightAnchor.constraint(equalToConstant: CGFloat(0)).isActive = false
                typeStack.addArrangedSubview(imageView)
            }
        }
        
        
        dailyCalLabel.text = challengeJSON!["cal_per_day"].stringValue
        dailyDurationLabel.text = challengeJSON!["time_limit"].stringValue
        dailyTimeLabel.text = challengeJSON!["times_per_day"].stringValue
        ruleLabel.text = challengeJSON!["other_text"].stringValue.html2String
        ruleView.isHidden = false
        
        //METHOD VIEW
        let methodArray = challengeJSON!["send_method"]
        for i in 0...methodArray.count {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            //imageView.image = UIImage(named: "icon_run")
            imageView.sd_setImage(with: URL(string:methodArray[i]["send_method_icon"].stringValue))
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.0/1.0).isActive = true
            methodStack.addArrangedSubview(imageView)
        }
        methodView.isHidden = false
        
        //PASSCODE VIEW
        if challengeJSON!["status_public"].stringValue == "private"
        {
            passcodeView.isHidden = false
        }
        
        //Check joined?
        if challengeJSON!["status_join"].stringValue == "joined"
        {
            challengeMode = .joined
            submitBtn.setTitle("ออกจากการแข่งขัน", for: .normal)
            passcodeView.isHidden = true
            inviteView.isHidden = true
        }
        else{
            challengeMode = .all
            submitBtn.setTitle("เข้าร่วมการแข่งขัน", for: .normal)
            inviteView.isHidden = false
        }
    }
    
    @IBAction func submitClick(_ sender: UIButton) {
        switch challengeMode {
        case .all:
            if challengeJSON!["status_public"].stringValue == "public"
            {
                print("เข้าร่วม")
                loadJoin(join: true, withPasscode: false)
            }
            else{
                print("ใส่รหัสเข้าร่วม")
                if passCodeField.text == "" {
                    ProgressHUD.showError("กรุณากรอกรหัสเข้าร่วม")
                }
                else{
                    loadJoin(join: true, withPasscode: true)
                }
            }
            
        case .joined:
            print("ออกจากการแข่ง")
            SwiftAlertView.show(title: "ยืนยันออกจากการแข่งขัน",
                                message: nil,
                                buttonTitles: "ยกเลิก", "ยืนยัน") { alert in
                //alert.backgroundColor = .yellow
                alert.titleLabel.font = .Alert_Title
                alert.messageLabel.font = .Alert_Message
                alert.cancelButtonIndex = 0
                alert.button(at: 0)?.titleLabel?.font = .Alert_Button
                alert.button(at: 0)?.setTitleColor(.buttonRed, for: .normal)
                
                alert.button(at: 1)?.titleLabel?.font = .Alert_Button
                alert.button(at: 1)?.setTitleColor(.themeColor, for: .normal)
                //alert.buttonTitleColor = .themeColor
            }
                                .onButtonClicked { _, buttonIndex in
                                    print("Button Clicked At Index \(buttonIndex)")
                                    switch buttonIndex{
                                    case 1:
                                        self.loadJoin(join: false, withPasscode: false)
                                    default:
                                        break
                                    }
                                }
            
        default:
            break
        }
    }
    
    func loadJoin(join:Bool, withPasscode:Bool) {
        var parameters:Parameters = ["user_id":SceneDelegate.GlobalVariables.userID,
                                     "challenge_id":challengeID!
        ]
        if withPasscode {
            parameters.updateValue(passCodeField.text!, forKey: "challenge_code")
        }
        
        var url:String = ""
        if join {
            url = "challenges/join"
            parameters.updateValue(inviteCodeField.text ?? "", forKey: "invite_code")
        }
        else{
            url = "challenges/unjoin"
        }
        
        loadRequest_V2(method:.post, apiName:url, authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS CHALLENGE JOIN\(json)")
                
                //self.loadChallengeDetail(showLoadingHUD: false)
                //self.submitSuccess()
                
                if join{
                    ProgressHUD.showSucceed("เข้าร่วมการแข่งขันแล้ว")
                    let vc = UIStoryboard.challengeStoryBoard.instantiateViewController(withIdentifier: "ChallengeJoin_2") as! ChallengeJoin_2
                    vc.challengeMode = .joined
                    vc.challengeID = self.challengeID
                    self.navigationController!.pushViewController(vc, animated: true)
                }
                else{
                    self.navigationController!.popToRootViewController(animated: true)
                }
            }
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.removeAnyViewControllers(ofKind: QRScanner.self)
        self.navigationController!.popViewController(animated: true)
    }
}

