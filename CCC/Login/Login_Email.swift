//
//  Login_Email.swift
//  CCC
//
//  Created by Truk Karawawattana on 6/3/2567 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD

class Login_Email: UIViewController, UITextFieldDelegate {
    
    var loginMode: LoginMode?
    var emailFormLogin: String? = ""
    
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var emailTitle: UILabel!
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passField: UITextField!
    
    @IBOutlet weak var rePassView: UIView!
    @IBOutlet weak var rePassField: UITextField!
    
    @IBOutlet weak var forgetBtn: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var signUpStack: UIStackView!
    
    @IBOutlet weak var submitBtn: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        changeMode(mode: .login)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("LOGIN EMAIL")
        self.navigationController?.setStatusBar(backgroundColor: .themeColor)

        setupField(field: emailField)
        setupField(field: passField)
        setupField(field: rePassField)
        
        submitBtn.disableBtn()
    }
    
    func changeMode(mode:LoginMode) {
        loginMode = mode
        switch mode {
        case .login:
            //headerTitle.text = "สมัครสมาชิก"
            emailTitle.text = "เข้าสู่ระบบ"
            passField.placeholder = "กรุณากรอก รหัสผ่าน *"
            rePassView.isHidden = true
            forgetBtn.isHidden = false
            signUpStack.isHidden = false
            submitBtn.setTitle("เข้าสู่ระบบ", for: .normal)
            
        case .signup:
            emailTitle.text = "สมัครสมาชิก"
            passField.placeholder = "กรุณากำหนด รหัสผ่าน *"
            rePassView.isHidden = false
            forgetBtn.isHidden = true
            signUpStack.isHidden = true
            submitBtn.setTitle("สมัครสมาชิก", for: .normal)
        }
        
        emailField.text = ""
        passField.text = ""
        
        submitBtn.disableBtn()
    }
    
    func setupField(field:UITextField) {
        field.delegate = self
        field.returnKeyType = .next
        field.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                                  for: .editingChanged)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        switch loginMode {
        case .login:
            if isValidEmail(emailField.text!) && passField.text!.count >= 1 {
                submitBtn.enableBtn()
            }
            else{
                submitBtn.disableBtn()
            }
            
        case .signup:
            if isValidEmail(emailField.text!) && passField.text!.count >= 1 && rePassField.text!.count >= 1 && passField.text! == rePassField.text! {
                submitBtn.enableBtn()
            }
            else{
                submitBtn.disableBtn()
            }
            
        default :
            break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        if textField == emailField {
//            passField.becomeFirstResponder()
//            return true
//        }
//        else if textField == passField {
//            passField.resignFirstResponder()
//            return true
//        }
//        else {
//            return false
//        }
        return false
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    @IBAction func secureClick(_ sender: UIButton) {
        if sender.tag == 1 {//pass field
            if passField.isSecureTextEntry == true {
                passField.isSecureTextEntry = false
                sender.setImage(UIImage(named: "login_password_hide.png"), for: .normal)
            }
            else {
                passField.isSecureTextEntry = true
                sender.setImage(UIImage(named: "login_password_hide.png"), for: .normal)
            }
        }
        else if sender.tag == 2 {
            if rePassField.isSecureTextEntry == true {
                rePassField.isSecureTextEntry = false
                sender.setImage(UIImage(named: "login_password_hide.png"), for: .normal)
            }
            else {
                rePassField.isSecureTextEntry = true
                sender.setImage(UIImage(named: "login_password_hide.png"), for: .normal)
            }
        }
        
    }
    
    @IBAction func forgetClick(_ sender: UIButton) {
        let vc = UIStoryboard.loginStoryBoard.instantiateViewController(withIdentifier: "ForgetPassword") as! ForgetPassword
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction func signUpClick(_ sender: UIButton) {
        changeMode(mode: .signup)
    }
    
    @IBAction func submitClick(_ sender: UIButton) {
        switch loginMode {
        case .login:
            loadLogin()

        case .signup:
            loadRegister()
            
        default:
            break
        }
    }
    
    func loadLogin() {
        let parameters:Parameters = ["email":emailField.text!, "password":passField.text!]
        loadRequest(method:.post, apiName:"login", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                //ProgressHUD.dismiss()
                ProgressHUD.showError(error.localizedDescription)

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS LOGIN\(json)")
                
                let userID = json["data"][0]["id"].stringValue
                let status = json["data"][0]["status"].stringValue
                self.emailFormLogin = self.emailField.text
                self.saveAndPush(userID: userID, status: status, mode: .normal)
            }
        }
    }
    
    func loadRegister() {
        let parameters:Parameters = ["email":emailField.text!, "password":passField.text!]
        loadRequest(method:.post, apiName:"register_byemail", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS REGISTER\(json)")
                
                let userID = json["data"][0]["id"].stringValue
                self.emailFormLogin = self.emailField.text
                self.saveAndPush(userID: userID, status: "0", mode: .normal)
            }
        }
    }
    
    func saveAndPush(userID:String,status:String,mode:ConsentMode) {
        print("USER ID = \(userID)\nSTATUS = \(status)")
        UserDefaults.standard.set("\(userID)", forKey: "userID")
        SceneDelegate.GlobalVariables.userID = userID

        if status == "0" {//go to consent
            let vc = UIStoryboard.loginStoryBoard.instantiateViewController(withIdentifier: "Consent") as! Consent
            vc.consentMode = mode
            vc.consentType = .privacy
            vc.emailFormLogin = emailFormLogin
            self.navigationController!.pushViewController(vc, animated: true)
        }
        else if status == "1" {//go to register profile
            //let vc = UIStoryboard.loginStoryBoard.instantiateViewController(withIdentifier: "Register_1") as! Register_1
            //vc.emailFormLogin = emailFormLogin
            
            //let vc = UIStoryboard.loginStoryBoard.instantiateViewController(withIdentifier: "Register_2") as! Register_2
            //self.navigationController!.pushViewController(vc, animated: true)
            
            let vc = UIStoryboard.loginStoryBoard.instantiateViewController(withIdentifier: "LocationRequest") as! LocationRequest
            self.navigationController!.pushViewController(vc, animated: true)
        }
        else if status == "2" {//go to home page
            self.switchToHome()
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        if loginMode == .signup {
            changeMode(mode: .login)
        }
        else {
            self.navigationController!.popViewController(animated: true)
        }
    }
}


