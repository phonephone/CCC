//
//  Setting_Account.swift
//  CCC
//
//  Created by Truk Karawawattana on 5/3/2567 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import SwiftAlertView
import NotificationCenter

class Setting_Account: UIViewController {
    
    var settingJSON : JSON?
    
    @IBOutlet weak var myScrollView: UIScrollView!
    @IBOutlet weak var thaiIDSwitch: UISwitch!
    
    @IBOutlet weak var cccAdminView: UIView!
    @IBOutlet weak var cccAdminLabel: UILabel!
    @IBOutlet weak var cccAdminSwitch: UISwitch!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadPartnerStatus()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("SETTING_ACCOUNT")
        myScrollView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 50, right: 0)
        
        //Mark:- application move to bckground
        NotificationCenter.default.addObserver(self, selector:#selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        //Mark:- application move to foreground
        NotificationCenter.default.addObserver(self, selector:#selector(appMovedToForeground),name: UIApplication.didBecomeActiveNotification, object: nil)
        
        cccAdminView.isHidden = true
        
        thaiIDSwitch.isUserInteractionEnabled = false
    }
    
    // MARK: - background method implementation
    @objc func appMovedToBackground() {
        print("App moved to background!")
    }
    
    // MARK: - foreground method implementation
    @objc func appMovedToForeground() {
        print("App moved to foreground!")
        //loadAllStatus()
        loadPartnerStatus()
    }
    
    func loadPartnerStatus() {
        let parameters:Parameters = ["user_id":SceneDelegate.GlobalVariables.userID]
        
        loadRequest_V2(method:.get, apiName:"status_connect", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS PARTNER STATUS\(json)")
                
                self.settingJSON = json["data"]
                self.updateSwitch()
            }
        }
    }
    
    func updateSwitch() {
        cccAdminView.isHidden = true
        if settingJSON != nil {
            thaiIDSwitch.isOn = settingJSON!["thaiidstatus"].boolValue
            thaiIDSwitch.isUserInteractionEnabled = true
            
            cccAdminLabel.text = settingJSON!["adminstatus_text"].stringValue
            switch settingJSON!["adminstatus"].stringValue
            {
            case "0":
                cccAdminSwitch.isOn = false
                cccAdminSwitch.isUserInteractionEnabled = true
                
            case "1":
                cccAdminSwitch.isOn = true
                cccAdminSwitch.isUserInteractionEnabled = true
                
            case "2":
                cccAdminSwitch.isOn = true
                cccAdminSwitch.isUserInteractionEnabled = false
                
            default:
                break
            }
            
            if settingJSON!["adminstatus_show"].boolValue {
                cccAdminView.isHidden = false
            }
            else {
                cccAdminView.isHidden = true
            }
        }
    }
    
    // MARK: - THAIID
    @IBAction func thaiID_Click(_ sender: UISwitch) {
        if sender.isOn{//เปิด
            sender.setOn(false, animated: true)
            
            //let appOAuthUrlThaiIDScheme = URL(string: "https://ccc.mots.go.th/Thaiid/sqrcode")!
            let appOAuthUrlThaiIDScheme = URL(string: settingJSON!["url_connect_thaid"].stringValue)!
            
            if UIApplication.shared.canOpenURL(appOAuthUrlThaiIDScheme) {
                UIApplication.shared.open(appOAuthUrlThaiIDScheme, options: [:])
            }
            else {
                //authorizeThaiID()
            }
        }
        else{//ปิด
            sender.setOn(true, animated: true)
//            deAuthorizeThaiIDFromCCC()
        }
    }
    
    func deAuthorizeThaiIDFromCCC() {
        let parameters:Parameters = ["user_id":SceneDelegate.GlobalVariables.userID]
        
        loadRequest_V2(method:.post, apiName:"ThaiID/disconnect", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS THAIID DELETE\(json)")
                
                self.loadPartnerStatus()
            }
        }
    }
    
    // MARK: - CCC ADMIN
    @IBAction func CCCAdmin_Click(_ sender: UISwitch) {
        if sender.isOn{//เปิด
            //sender.setOn(false, animated: true)
            authorizeAdminFromCCC()
        }
        else{//ปิด
            //sender.setOn(true, animated: true)
            deAuthorizeAdminFromCCC()
        }
    }
    
    func authorizeAdminFromCCC() {
        let parameters:Parameters = ["user_id":SceneDelegate.GlobalVariables.userID]
        
        loadRequest_V2(method:.post, apiName:"admin/request", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS CONNECT ADMIN\(json)")
                
                self.loadPartnerStatus()
            }
        }
    }
    
    func deAuthorizeAdminFromCCC() {
        let parameters:Parameters = ["user_id":SceneDelegate.GlobalVariables.userID]
        
        loadRequest_V2(method:.post, apiName:"admin/revoke", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS DISCONNECT ADMIN\(json)")
                
                self.loadPartnerStatus()
            }
        }
    }
    
    
    // MARK: - DELETE ACCOUNT
    @IBAction func deleteAccount(_ sender: UIButton) {
        SwiftAlertView.show(title: "ยืนยันการลบบัญชีผู้ใช้งาน",
                            message: "บัญชีผู้ใช้งานของคุณจะถูกลบอย่างถาวร\n\nกรุณาพิมพ์คำว่า \"ยืนยันเพื่อที่จะลบ\" เพื่อยืนยันการลบบัญชี",
                            buttonTitles: "ยกเลิก", "ยืนยัน") { alert in
            //alert.backgroundColor = .yellow
            alert.titleLabel.font = .Alert_Title
            alert.messageLabel.font = .Alert_Message
            alert.titleLabel.textColor = .buttonRed
            
            alert.addTextField { textField in
                textField.placeholder = ""
                textField.font = .Alert_Message
            }
            alert.isEnabledValidationLabel = true
            alert.isDismissOnActionButtonClicked = false
            alert.validationLabel.font = .Alert_Message
            
            alert.cancelButtonIndex = 0
            alert.button(at: 0)?.titleLabel?.font = .Alert_Button
            alert.button(at: 0)?.setTitleColor(.themeColor, for: .normal)
            
            alert.button(at: 1)?.titleLabel?.font = .Alert_Button
            alert.button(at: 1)?.setTitleColor(.buttonRed, for: .normal)
            //            alert.buttonTitleColor = .themeColor
        }
                            .onButtonClicked { alert, buttonIndex in
                                print("Button Clicked At Index \(buttonIndex)")
                                
                                switch buttonIndex{
                                case 1:
                                    let confirmStr = alert.textField(at: 0)?.text ?? ""
                                    if confirmStr == "ยืนยันเพื่อที่จะลบ" {
                                        self.loadDeleteAccount()
                                        alert.dismiss()
                                    } else {
                                        alert.validationLabel.text = "คำยืนยันไม่ถูกต้อง"
                                    }
                                default:
                                    break
                                }
                            }
                            .onTextChanged { alert , text, textFieldIndex in
                                if textFieldIndex == 0 {
                                    print("Confirm text changed: ", text ?? "")
                                    alert.validationLabel.text = ""
                                }
                            }
    }
    
    func loadDeleteAccount() {
        let parameters:Parameters = ["user_id":SceneDelegate.GlobalVariables.userID]
        
        loadRequest(method:.post, apiName:"account/delete", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS DELETE ACCOUNT\(json)")
                
                self.logOut()
            }
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        SceneDelegate.GlobalVariables.reloadSideMenu = true
        self.navigationController!.popViewController(animated: true)
    }
}
