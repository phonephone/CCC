//
//  Register_1.swift
//  CCC
//
//  Created by Truk Karawawattana on 24/10/2566 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD

class Register_1: UIViewController, UITextFieldDelegate {
    
    var emailFormLogin: String?
    
    @IBOutlet weak var fullNameField: UITextField!
    @IBOutlet weak var idNoField: UITextField!
    @IBOutlet weak var telField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var inviteField: UITextField!
    
    @IBOutlet weak var submitBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("REGISTER_1")
        self.navigationController?.setStatusBar(backgroundColor: .themeBgColor)

        setupField(field: fullNameField)
        setupField(field: idNoField)
        setupField(field: telField)
        setupField(field: emailField)
        setupField(field: inviteField)
        
        emailField.text = emailFormLogin
        
        submitBtn.disableBtn()
    }
    
    func setupField(field:UITextField) {
        field.delegate = self
        field.returnKeyType = .next
        field.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                                  for: .editingChanged)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == idNoField {
            guard let textFieldText = textField.text,
                    let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                        return false
                }
                let substringToReplace = textFieldText[rangeOfTextToReplace]
                let count = textFieldText.count - substringToReplace.count + string.count
                return count <= 13
        }
        else if textField == telField {
            guard let textFieldText = textField.text,
                    let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                        return false
                }
                let substringToReplace = textFieldText[rangeOfTextToReplace]
                let count = textFieldText.count - substringToReplace.count + string.count
                return count <= 10
        }
        else{
            return true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        updateSubmitBtn()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == fullNameField {
            idNoField.becomeFirstResponder()
            return true
        }
        else if textField == idNoField {
            telField.becomeFirstResponder()
            return true
        }
        else if textField == telField {
            emailField.becomeFirstResponder()
            return true
        }
        else if textField == emailField {
            inviteField.becomeFirstResponder()
            return true
        }
        else if textField == inviteField {
            inviteField.resignFirstResponder()
            return true
        }
        else {
            return false
        }
    }
    
    func updateSubmitBtn() {
        if  fullNameField.text!.count >= 3 &&
            idNoField.text!.count == 13 &&
            telField.text!.count == 10
        {
            submitBtn.enableBtn()
        }
        else{
            submitBtn.disableBtn()
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    @IBAction func submitClick(_ sender: UIButton) {
        loadSubmit()
    }
    
    func loadSubmit() {
        let parameters:Parameters = ["user_id":SceneDelegate.GlobalVariables.userID,
                                     "name":fullNameField.text!,
                                     "identity_number":idNoField.text!,
                                     "phone_no":telField.text!,
                                     "email":emailField.text ?? "",
                                     "invite_code":inviteField.text ?? "",
        ]
        print(parameters)
        loadRequest_V2(method:.post, apiName:"update_profile/update_personal_data", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("REGISTER_1 SUBMIT\(json)")

                let vc = UIStoryboard.loginStoryBoard.instantiateViewController(withIdentifier: "Register_2") as! Register_2
                self.navigationController!.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
}

