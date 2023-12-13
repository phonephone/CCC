//
//  ChallengeDetail.swift
//  CCC
//
//  Created by Truk Karawawattana on 11/1/2565 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import SwiftAlertView

class ChallengeDetail: UIViewController {
    
    var challengeID : String?
    var challengeJSON : JSON?
    
    var challengeMode: ChallengeMode?
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var myScrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ruleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var joinLabel: UILabel!
    @IBOutlet weak var agencyLabel: UILabel!
    @IBOutlet weak var submitBtn: UIButton!
    
    @IBOutlet weak var ruleView: UIView!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var passcodeView: UIView!
    @IBOutlet weak var passCodeField: UITextField!
    
    @IBOutlet weak var joinView: UIView!
    @IBOutlet weak var joinBtn: UIButton!
    @IBOutlet weak var leaveView: UIView!
    @IBOutlet weak var leaveBtn: UIButton!
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var editBtn: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadChallengeDetail(showLoadingHUD: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("CHALLENGE DETAIL")
        
        myScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        
        ruleView.isHidden = true
        joinView.isHidden = true
        leaveView.isHidden = true
        editView.isHidden = true
        passcodeView.isHidden = true
        submitBtn.disableBtn()
        
//        switch challengeMode {
//        case .all:
//            //joinView.isHidden = false
//
//        case .joined:
//            //leaveView.isHidden = false
//
//        case .create:
//            editView.isHidden = false
//            editBtn.setTitle("ยืนยันสร้างการแข่งขัน", for: .normal)
//
//        case .edit:
//            editView.isHidden = false
//            editBtn.setTitle("แก้ไขการแข่งขัน", for: .normal)
//
//        default:
//            break
//        }
    }
    
    func loadChallengeDetail(showLoadingHUD:Bool) {
        let parameters:Parameters = ["user_id":SceneDelegate.GlobalVariables.userID,
                                     "challenge_id":challengeID!
        ]
        
        loadRequest(method:.post, apiName:"challenges", authorization:true, showLoadingHUD:showLoadingHUD, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS CHALLENGE DETAIL\(json)")
                
                self.challengeJSON = json["data"][0]
                self.updateBtn()
            }
        }
    }
    
    func updateBtn() {
        submitBtn.enableBtn()
        coverImage.sd_setImage(with: URL(string:challengeJSON!["cover_img"].stringValue), placeholderImage: UIImage(named: "icon_1024"))
        titleLabel.text = challengeJSON!["competition_name"].stringValue
        dateLabel.text = "\(challengeJSON!["start_date"].stringValue) - \(challengeJSON!["end_date"].stringValue)"
        
        var limitPeople = challengeJSON!["participants"].stringValue
        if limitPeople == "" {
            limitPeople = "ไม่จำกัดคนเข้าร่วม"
        }
        joinLabel.text = "จำนวนผู้เข้าร่วม: \(challengeJSON!["number_challenge_participant"].stringValue) / \(limitPeople)"
        
        agencyLabel.text = "ผู้จัดการแข่งขัน: \(challengeJSON!["agency_name"].stringValue)"
        
        let ruleStr = challengeJSON!["rule"].stringValue
        //let ruleStr = "กติกา: ทดสอบ iOS"
        if ruleStr == "" {
            ruleView.isHidden = true
        }
        else{
            ruleView.isHidden = false
            ruleLabel.text = ruleStr
        }
        
        //descriptionLabel.text = challengeJSON!["description"].stringValue
        DispatchQueue.main.async {
            let attrStr = try! NSAttributedString(
                data: (self.challengeJSON!["description"].stringValue.data(using: String.Encoding.unicode, allowLossyConversion: true)!),
                        options: [.documentType : NSAttributedString.DocumentType.html],
                        documentAttributes: nil)
            self.descriptionLabel.attributedText = attrStr
            self.descriptionLabel.textAlignment = NSTextAlignment.justified
            self.descriptionLabel.contentMode = .scaleToFill
            self.descriptionLabel.font = UIFont.Prompt_Regular(ofSize: 14)
        }

        descriptionLabel.adjustsFontSizeToFitWidth = true
        descriptionLabel.sizeToFit()
        
        if challengeJSON!["status_public"].stringValue == "private"
        {
            passcodeView.isHidden = false
        }
        
//        if challengeJSON!["status_owner"].stringValue == "1"
//        {
//            challengeMode = .edit
//            submitBtn.setTitle("แก้ไขการแข่งขัน", for: .normal)
//        }
//        else{
            if challengeJSON!["status_join"].stringValue == "joined"
            {
                challengeMode = .joined
                submitBtn.setTitle("ออกจากการแข่งขัน", for: .normal)
                passcodeView.isHidden = true
            }
            else{
                challengeMode = .all
                submitBtn.setTitle("เข้าร่วมการแข่งขัน", for: .normal)
            }
//        }
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
//                else if passCodeField.text != challengeJSON!["challenge_code"].stringValue {
//                    ProgressHUD.showError("รหัสเข้าร่วมไม่ถูกต้อง")
//                }
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
                //            alert.buttonTitleColor = .themeColor
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
            
        case .edit:
            print("แก้ไข")
            let vc = UIStoryboard.challengeStoryBoard.instantiateViewController(withIdentifier: "ChallengeCreate") as! ChallengeCreate
            vc.challengeMode = challengeMode
            self.navigationController!.pushViewController(vc, animated: true)
            
        case .create:
            print("สร้าง")
            let vc = UIStoryboard.challengeStoryBoard.instantiateViewController(withIdentifier: "ChallengeJoin") as! ChallengeJoin
            vc.challengeMode = challengeMode
            self.navigationController!.pushViewController(vc, animated: true)
            
        default:
            break
        }
    }
    
    func loadJoin(join:Bool, withPasscode:Bool) {
        var parameters:Parameters = ["user_id":SceneDelegate.GlobalVariables.userID,
                                     "challenge_id":challengeID!,
                                     "join":join
        ]
        if withPasscode {
            parameters.updateValue(passCodeField.text!, forKey: "challenge_code")
        }
        
        loadRequest(method:.post, apiName:"challenges", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
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
                    let vc = UIStoryboard.challengeStoryBoard.instantiateViewController(withIdentifier: "ChallengeJoin") as! ChallengeJoin
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
    
    @IBAction func joinClick(_ sender: UIButton) {
//        let vc = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "ChallengeJoin") as! ChallengeJoin
//        vc.challengeMode = .joined
//        vc.challengeID = challengeID
//        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction func leaveClick(_ sender: UIButton) {
//        var alert = UIAlertController()
//
//        alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "ยกเลิก", style: .default, handler: { action in
//
//        }))
//        alert.actions.last?.titleTextColor = .buttonRed
//
//        alert.title = "ยืนยันออกจากการแข่งขัน"
//        //alert.message = "plaes make sure before..."
//
//        alert.addAction(UIAlertAction(title: "ยืนยัน", style: .default, handler: { action in
//            self.navigationController!.popToRootViewController(animated: true)
//        }))
//        alert.actions.last?.titleTextColor = .themeColor
//        alert.setColorAndFont()
//
//        self.present(alert, animated: true)
    }
    
    @IBAction func editClick(_ sender: UIButton) {
        
        if challengeMode == .create
        {
            let vc = UIStoryboard.challengeStoryBoard.instantiateViewController(withIdentifier: "ChallengeJoin") as! ChallengeJoin
            vc.challengeMode = challengeMode
            self.navigationController!.pushViewController(vc, animated: true)
        }
        else if challengeMode == .edit
        {
            let vc = UIStoryboard.challengeStoryBoard.instantiateViewController(withIdentifier: "ChallengeCreate") as! ChallengeCreate
            vc.challengeMode = challengeMode
            self.navigationController!.pushViewController(vc, animated: true)
        }
       
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
}
