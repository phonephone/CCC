//
//  ForgetPassword.swift
//  CCC
//
//  Created by Truk Karawawattana on 24/1/2565 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD

class ForgetPassword: UIViewController, UITextFieldDelegate {
    
    var profileMode: ProfileMode?
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var submitBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("FORGET PASSWORD")
        self.navigationController?.setStatusBar(backgroundColor: .themeColor)
        
        emailField.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                                  for: .editingChanged)
        
        submitBtn.disableBtn()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if isValidEmail(emailField.text!) {
            submitBtn.enableBtn()
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    @IBAction func submitClick(_ sender: UIButton) {
        loadForget()
    }
    
    func loadForget() {
        let parameters:Parameters = ["email":emailField.text!]
        loadRequest(method:.post, apiName:"ForgetPassword/byEmail", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS FORGET\(json)")
                
                ProgressHUD.showSuccess(json["data"][0]["message"].stringValue)
            }
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
}

