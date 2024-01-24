////
////  Login.swift
////  CCC
////
////  Created by Truk Karawawattana on 12/12/2564 BE.
////
//
//import UIKit
//import Alamofire
//import SwiftyJSON
//import ProgressHUD
//import Localize_Swift
//import LineSDK
//import AuthenticationServices
//
//enum LoginMode {
//    case login
//    case signup
//}
//
//class Login: UIViewController, UITextFieldDelegate, ASAuthorizationControllerDelegate {
//
//    var loginMode: LoginMode?
//
//    @IBOutlet weak var emailTitle: UILabel!
//    @IBOutlet weak var emailField: UITextField!
//    @IBOutlet weak var passTitle: UILabel!
//    @IBOutlet weak var passField: UITextField!
//    @IBOutlet weak var signInBtn: MyButton!
//    @IBOutlet weak var lineBtn: MyButton!
//    @IBOutlet weak var appleBtn: MyButton!
//    @IBOutlet weak var forgetBtn: UIButton!
//    @IBOutlet weak var noAccountLeft: UIButton!
//    @IBOutlet weak var noAccountRight: UIButton!
//    @IBOutlet weak var backBtn: UIButton!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        print("LOGIN")
//        self.navigationController?.setStatusBar(backgroundColor: .themeColor)
//
//        emailField.delegate = self
//        passField.delegate = self
//        emailField.returnKeyType = .next
//
//        emailField.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
//                                  for: .editingChanged)
//        passField.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
//                                  for: .editingChanged)
//
//        lineBtn.imageView?.contentMode = .scaleAspectFit
//        lineBtn.contentHorizontalAlignment = .fill
//        lineBtn.contentVerticalAlignment = .fill
//        lineBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0);
//        lineBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -50, bottom: 0, right: 0);
//        lineBtn.imageEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: -100);
//
//        appleBtn.imageView?.contentMode = .scaleAspectFit
//        appleBtn.contentHorizontalAlignment = .fill
//        appleBtn.contentVerticalAlignment = .fill
//        appleBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0);
//        appleBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -50, bottom: 0, right: 0);
//        appleBtn.imageEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: -100);
//
////        print(Localize.availableLanguages())
////        print(Localize.defaultLanguage())
////
////        Localize.setCurrentLanguage("en")
////        Localize.setCurrentLanguage("th")
////        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
////        Localize.resetCurrentLanguageToDefault()
////
////        emailTitle.text = "Email".localized()
////        emailField.placeholder = "Email".localized()
////        passTitle.text = "Password".localized()
////        passField.placeholder = "Password".localized()
////        signInBtn.setTitle("Login".localized(), for: .normal)
////        lineBtn.setTitle("Login with Line".localized(), for: .normal)
////        forgetBtn.setTitle("Forget your password?".localized(), for: .normal)
////        noAccountLeft.setTitle("Don't have an account?".localized(), for: .normal)
////        noAccountRight.setTitle("Sign up".localized(), for: .normal)
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        changeMode(mode: .login)
//    }
//
//    func changeMode(mode:LoginMode) {
//        loginMode = mode
//        switch mode {
//        case .login:
//            signInBtn.setTitle("เข้าสู่ระบบ", for: .normal)
//            lineBtn.setTitle("เข้าสู่ระบบด้วย LINE", for: .normal)
//            forgetBtn.isHidden = false
//            noAccountLeft.isHidden = false
//            noAccountRight.isHidden = true
//            backBtn.isHidden = true
//
//        case .signup:
//            signInBtn.setTitle("สมัครสมาชิก", for: .normal)
//            lineBtn.setTitle("สมัครสมาชิกด้วย LINE", for: .normal)
//            forgetBtn.isHidden = true
//            noAccountLeft.isHidden = true
//            noAccountRight.isHidden = true
//            backBtn.isHidden = false
//        }
//
//        emailField.text = ""
//        passField.text = ""
//
//        signInBtn.disableBtn()
//    }
//
//    @objc func textFieldDidChange(_ textField: UITextField) {
//        if isValidEmail(emailField.text!) && passField.text!.count >= 1 {
//            signInBtn.enableBtn()
//        }
//        else{
//            signInBtn.disableBtn()
//        }
//
//        if emailField.text == "888" {//Bypass Login
//            emailField.text = "jae4@edfthai.org"
//            passField.text = "1111"
//            signInBtn.enableBtn()
//        }
//    }
//
//    func isValidEmail(_ email: String) -> Bool {
//        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
//
//        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
//        return emailPred.evaluate(with: email)
//    }
//
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        if emailField.text! == "" {
//            return false
//        } else if textField == emailField {
//            emailField.resignFirstResponder()
//            passField.becomeFirstResponder()
//            return true
//        } else if textField == passField {
//            passField.resignFirstResponder()
//            return true
//        }else {
//            return false
//        }
//    }
//
//    @IBAction func secureClick(_ sender: UIButton) {
//        if passField.isSecureTextEntry == true {
//            passField.isSecureTextEntry = false
//            sender.setImage(UIImage(named: "login_password_hide.png"), for: .normal)
//        }
//        else {
//            passField.isSecureTextEntry = true
//            sender.setImage(UIImage(named: "login_password_hide.png"), for: .normal)
//        }
//    }
//
//    @IBAction func forgetClick(_ sender: UIButton) {
//        let vc = UIStoryboard.loginStoryBoard.instantiateViewController(withIdentifier: "ForgetPassword") as! ForgetPassword
//        self.navigationController!.pushViewController(vc, animated: true)
//    }
//
//    @IBAction func signUpClick(_ sender: UIButton) {
//        changeMode(mode: .signup)
//    }
//
//    @IBAction func backClick(_ sender: UIButton) {
//        changeMode(mode: .login)
//    }
//
//    @IBAction func signInClick(_ sender: UIButton) {
//        switch loginMode {
//        case .login:
//            loadLogin()
//
//        case .signup:
//            loadRegister()
//
//        default:
//            break
//        }
//    }
//
//    @IBAction func lineClick(_ sender: UIButton) {
//        lineAuthen()
//    }
//
//    @IBAction func appleClick(_ sender: UIButton) {
//        appleAuthen()
//    }
//
//    func loadLogin() {
//        let parameters:Parameters = ["email":emailField.text!, "password":passField.text!]
//        loadRequest(method:.post, apiName:"login", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
//            switch result {
//            case .failure(let error):
//                print(error)
//                //ProgressHUD.dismiss()
//                ProgressHUD.showError(error.localizedDescription)
//
//            case .success(let responseObject):
//                let json = JSON(responseObject)
//                print("SUCCESS LOGIN\(json)")
//
//                let userID = json["data"][0]["id"].stringValue
//                let status = json["data"][0]["status"].stringValue
//                self.saveAndPush(userID: userID, status: status, mode: .normal)
//            }
//        }
//    }
//
//    func loadRegister() {
//        let parameters:Parameters = ["email":emailField.text!, "password":passField.text!]
//        loadRequest(method:.post, apiName:"register_byemail", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
//            switch result {
//            case .failure(let error):
//                print(error)
//                ProgressHUD.dismiss()
//
//            case .success(let responseObject):
//                let json = JSON(responseObject)
//                print("SUCCESS REGISTER\(json)")
//
//                let userID = json["data"][0]["id"].stringValue
//                self.saveAndPush(userID: userID, status: "0", mode: .normal)
//            }
//        }
//    }
//
//    func saveAndPush(userID:String,status:String,mode:ConsentMode) {
//        print("USER ID = \(userID)\nSTATUS = \(status)")
//        UserDefaults.standard.set("\(userID)", forKey: "userID")
//        SceneDelegate.GlobalVariables.userID = userID
//
//        if status == "0" {//go to consent
//            let vc = UIStoryboard.loginStoryBoard.instantiateViewController(withIdentifier: "Consent") as! Consent
//            vc.consentMode = mode
//            self.navigationController!.pushViewController(vc, animated: true)
//        }
//        else if status == "1" {//go to register profile
//            let vc = UIStoryboard.loginStoryBoard.instantiateViewController(withIdentifier: "Profile") as! Profile
//            vc.profileMode = .register
//            self.navigationController!.pushViewController(vc, animated: true)
//        }
//        else if status == "2" {//go to home page
//            self.switchToHome()
//        }
//    }
//}//end ViewController
//
//
//// MARK: - 3rd Party login
//extension Login {
//    // MARK: - Line login
//    func lineAuthen() {
//        LoginManager.shared.login(permissions: [.profile], in: self) {
//            result in
//            switch result {
//            case .success(let loginResult):
//                //print(loginResult.accessToken.value)
//                if let profile = loginResult.userProfile {
//                    print("User ID: \(profile.userID)")
//                    print("User Display Name: \(profile.displayName)")
//                    print("User Icon: \(String(describing: profile.pictureURL))")
//                    self.loadLineLogin(lineUserID: profile.userID, displayName: profile.displayName, imgCover: String(describing: profile.pictureURL))
//                }
//            case .failure(let error):
//                print(error)
//            }
//        }
//    }
//
//    func loadLineLogin(lineUserID:String, displayName:String, imgCover:String) {
//        let parameters:Parameters = ["line_id":lineUserID,
//                                     "displayName":displayName,
//                                     "imgCover":imgCover
//        ]
//        loadRequest(method:.post, apiName:"login/byLine", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
//            switch result {
//            case .failure(let error):
//                print(error)
//                //ProgressHUD.dismiss()
//                ProgressHUD.showError(error.localizedDescription)
//
//            case .success(let responseObject):
//                let json = JSON(responseObject)
//                print("SUCCESS LINE LOGIN\(json)")
//
//                let userID = json["data"][0]["id"].stringValue
//                let status = json["data"][0]["status"].stringValue
//                self.saveAndPush(userID: userID, status: status, mode: .normal)
//            }
//        }
//    }
//
//    // MARK: - Apple login
//    @objc func appleAuthen() {
//        let appleIDProvider = ASAuthorizationAppleIDProvider()
//        let request = appleIDProvider.createRequest()
//        request.requestedScopes = []//[.fullName, .email]
//        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
//        authorizationController.delegate = self
//        authorizationController.performRequests()
//    }
//
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
//        if let appleIDCredential = authorization.credential as?  ASAuthorizationAppleIDCredential {
//            let userIdentifier = appleIDCredential.user
//            let fullName = appleIDCredential.fullName
//            let email = appleIDCredential.email
//            print("User id \(userIdentifier) \n FullName \(String(describing: fullName)) \n Email \(String(describing: email))")
//
//            loadAppleLogin(appleUserID: userIdentifier)
//        }
//    }
//
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
//        print(error)
//    }
//
//    func loadAppleLogin(appleUserID:String) {
//        let parameters:Parameters = ["apple_id":appleUserID]
//        print(parameters)
//
//        loadRequest(method:.post, apiName:"login/byApple", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
//            switch result {
//            case .failure(let error):
//                print(error)
//                //ProgressHUD.dismiss()
//                ProgressHUD.showError(error.localizedDescription)
//
//            case .success(let responseObject):
//                let json = JSON(responseObject)
//                print("SUCCESS APPLE LOGIN\(json)")
//
//                let userID = json["data"][0]["id"].stringValue
//                let status = json["data"][0]["status"].stringValue
//                self.saveAndPush(userID: userID, status: status, mode: .apple)
//            }
//        }
//    }
//}
