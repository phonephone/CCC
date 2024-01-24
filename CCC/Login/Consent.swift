//
//  Consent.swift
//  CCC
//
//  Created by Truk Karawawattana on 9/2/2565 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import SwiftAlertView

enum ConsentMode {
    case normal
    case apple
    case fromHome
}

enum ConsentType {
    case privacy
    case terms
}

class Consent: UIViewController, UITextViewDelegate {
    
    var consentMode: ConsentMode?
    var consentType: ConsentType?
    var emailFormLogin: String?
    
    var acceptConsent = false
    var reachBottom = false
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var consentTitle: UILabel!
    @IBOutlet weak var consentTextView: UITextView!
    @IBOutlet weak var acceptStack: UIStackView!
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var acceptTitle: UILabel!
    @IBOutlet weak var submitBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("CONSENT")
        self.navigationController?.setStatusBar(backgroundColor: .themeColor)
        
        //print(SceneDelegate.GlobalVariables.userID)
        
        consentTextView.delegate = self
        consentTextView.textContainerInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        //consentTextView.contentInset = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
        
        //acceptStack.isHidden = true
        enableAccept(enable: false)
        submitBtn.disableBtn()
        
        if consentMode == .fromHome {
            backBtn.isHidden = true
        }
        
        loadConsent()
    }
    
    func loadConsent() {
        let parameters:Parameters = [:]
        var url:String = ""
        if consentType == .privacy {
            url = "content/privacy"
        }
        else if consentType == .terms {
            url = "content/terms"
        }
        
        loadRequest_V2(method:.get, apiName:url, authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                //print("SUCCESS CONSENT\(json)")
                
                self.consentTitle.text = json["data"][0]["title"].stringValue
                self.consentTextView.text = json["data"][0]["content"].stringValue.html2String
                
//                let htmlString = json["data"][0]["content"].stringValue
//                let htmlData = NSString(string: htmlString).data(using: String.Encoding.unicode.rawValue)
//
//                let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
//
//                let attributedString = try! NSAttributedString(data: htmlData!, options: options, documentAttributes: nil)
//
//                self.consentTextView.attributedText = attributedString
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height)
        {
            reachBottom = true
            enableAccept(enable: true)
            //acceptStack.isHidden = false
            //submitBtn.enableBtn()
        }
    }
    
    func enableAccept(enable: Bool) {
        if enable {
            acceptBtn.isEnabled = true
            acceptTitle.textColor = .textDarkGray
        }
        else {
            acceptBtn.isEnabled = false
            acceptTitle.textColor = .buttonDisable
        }
    }
    
    @IBAction func acceptClick(_ sender: UIButton) {
        if acceptConsent{
            acceptConsent = false
            acceptBtn.setImage(UIImage(named: "form_checkbox_off"), for: .normal)
            submitBtn.disableBtn()
        }
        else{
            acceptConsent = true
            acceptBtn.setImage(UIImage(named: "form_checkbox_on"), for: .normal)
            submitBtn.enableBtn()
        }
    }
    
    @IBAction func submitClick(_ sender: UIButton) {
        loadSubmit()
//        if acceptConsent {
//            loadSubmit()
//        }
//        else {
//            SwiftAlertView.show(title: "ทดสอบ Alert",
//                                message: "กรุณากดเข้าใจในข้อกำหนดและเงื่อนไขการใช้บริการ",
//                                buttonTitles: "ตกลง") { alert in
//                //alert.backgroundColor = .yellow
//                alert.titleLabel.font = .Alert_Title
//                alert.messageLabel.font = .Alert_Message
//                alert.titleLabel.textColor = .themeColor
//
//                alert.cancelButtonIndex = 0
//                alert.button(at: 0)?.titleLabel?.font = .Alert_Button
//                alert.button(at: 0)?.setTitleColor(.themeColor, for: .normal)
//            }
//                                .onButtonClicked { _, buttonIndex in
//                                    print("Button Clicked At Index \(buttonIndex)")
//
//                                }
//        }
    }
    
    func loadSubmit() {
        let parameters:Parameters = ["user_id":SceneDelegate.GlobalVariables.userID]
        print(parameters)
        
        var url:String = ""
        if consentType == .privacy {
            url = "consent_accept/privacy"
        }
        else if consentType == .terms {
            url = "consent_accept/terms"
        }
        
        loadRequest_V2(method:.post, apiName:url, authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("CONSENT ACCEPT\(json)")
                
                if self.consentMode == .fromHome {
                    self.navigationController!.popViewController(animated: true)
                }
//                else if self.consentMode == .apple {
//                    self.switchToHome()
//                }
                else{
                    let vc = UIStoryboard.loginStoryBoard.instantiateViewController(withIdentifier: "Register_1") as! Register_1
                    vc.emailFormLogin = self.emailFormLogin
                    self.navigationController!.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        logOut()
        //self.navigationController!.popViewController(animated: true)
    }
}
