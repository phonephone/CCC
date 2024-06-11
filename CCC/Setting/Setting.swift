//
//  Setting.swift
//  CCC
//
//  Created by Truk Karawawattana on 30/3/2565 BE.
//

import UIKit
import HealthKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import NotificationCenter
import OAuthSwift
import AuthenticationServices
import SwiftAlertView

//enum thirdParty {
//    case all
//    case none
//    case apple
//    case garmin
//    case strava
//    case coros
//    case fitbit
//    case parkrun
//}

class Setting: UIViewController {
    
    var settingJSON : JSON?
    var garminJSON : JSON?
    var stravaJSON : JSON?
    
    //var thirdParty:thirdParty = .all
    
    private let urlScheme: String = "ccc"
    
    var garminOauthSwift: OAuth1Swift?
    private let garminConsumerKey: String = PlistParser.getKeysValue()!["garminConsumerKey"]!
    private let garminConsumerSecret: String = PlistParser.getKeysValue()!["garminConsumerSecret"]!
    
    private var authSession: ASWebAuthenticationSession?
    private let stravaClientId: String = PlistParser.getKeysValue()!["stravaClientId"]!
    private let stravaFallbackUrl: String = "stravacallback"
    private let stravaClientSecret: String = PlistParser.getKeysValue()!["stravaClientSecret"]!
    
    private let corosClientId: String = PlistParser.getKeysValue()!["corosClientId"]!
    private let corosState: String = PlistParser.getKeysValue()!["corosState"]!
    
    var suuntoOauthSwift: OAuth2Swift?
    
    @IBOutlet weak var myScrollView: UIScrollView!
    @IBOutlet weak var appleHealthSwitch: UISwitch!
    @IBOutlet weak var garminSwitch: UISwitch!
    @IBOutlet weak var stravaSwitch: UISwitch!
    @IBOutlet weak var corosSwitch: UISwitch!
    @IBOutlet weak var fitbitSwitch: UISwitch!
    @IBOutlet weak var parkrunSwitch: UISwitch!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadPartnerStatus()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("SETTING")
        myScrollView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 50, right: 0)
        
        //Mark:- application move to bckground
        NotificationCenter.default.addObserver(self, selector:#selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        //Mark:- application move to foreground
        NotificationCenter.default.addObserver(self, selector:#selector(appMovedToForeground),name: UIApplication.didBecomeActiveNotification, object: nil)
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
        if (HKHealthStore().authorizationStatus(for: HKObjectType.workoutType()) == .sharingAuthorized) {
            print("Health ON")
            appleHealthSwitch.isOn = true
        } else {
            print("Health OFF")
            appleHealthSwitch.isOn = false
        }
        if settingJSON != nil {
            garminSwitch.isOn = settingJSON!["garminstatus"].boolValue
            stravaSwitch.isOn = settingJSON!["stravastatus"].boolValue
            corosSwitch.isOn = settingJSON!["corosstatus"].boolValue
            fitbitSwitch.isOn = settingJSON!["fitbitstatus"].boolValue
            parkrunSwitch.isOn = settingJSON!["parkrunstatus"].boolValue
        }
        //stravaSwitch.isOn = settingJSON!["stravastatus"].boolValue
        
        //        if SceneDelegate.GlobalVariables.stravaAccessToken == ""{
        //            stravaSwitch.isOn = false
        //        }
        //        else{
        //            stravaSwitch.isOn = true
        //        }
        //
        //        if SceneDelegate.GlobalVariables.garminAccessToken == ""{
        //            garminSwitch.isOn = false
        //        }
        //        else{
        //            garminSwitch.isOn = true
        //        }
    }
    
    // MARK: - APPLE HEALTH
    @IBAction func appleHealth_Click(_ sender: UISwitch) {
        if sender.isOn{//เปิด
            if (HKHealthStore().authorizationStatus(for: HKObjectType.workoutType()) == .sharingAuthorized) {
                sender.setOn(true, animated: true)
                //sender.isOn = true
                
                ProgressHUD.showSuccess("เชื่อมต่อ Apple Health")
            } else {
                sender.setOn(false, animated: true)
                //sender.isOn = false
                
                SwiftAlertView.show(title: "ไม่ได้รับอนุญาตให้เข้าถึง Apple Health",
                                    message: "เข้าแอป Settings (ตั้งค่า) -> \nPrivacy (ความเป็นส่วนตัว) -> \nHealth (สุขภาพ) -> \nCCC -> Turn On All (เปิดใช้ทั้งหมด)",
                                    buttonTitles: "OK") { alert in
                    //alert.backgroundColor = .yellow
                    alert.titleLabel.font = .Alert_Title
                    alert.messageLabel.font = .Alert_Message
                    alert.titleLabel.textColor = .themeColor
                    
                    alert.cancelButtonIndex = 0
                    alert.button(at: 0)?.titleLabel?.font = .Alert_Button
                    alert.button(at: 0)?.setTitleColor(.themeColor, for: .normal)
                }
                                    .onButtonClicked { _, buttonIndex in
                                        print("Button Clicked At Index \(buttonIndex)")
                                    }
            }
        }
        else{//ปิด
            if (HKHealthStore().authorizationStatus(for: HKObjectType.workoutType()) == .sharingAuthorized) {
                sender.setOn(true, animated: true)
                
                SwiftAlertView.show(title: "หากต้องการปิดการเข้าถึง Apple Health",
                                    message: "เข้าแอป Settings (ตั้งค่า) -> \nPrivacy (ความเป็นส่วนตัว) -> \nHealth (สุขภาพ) -> \nCCC -> Turn Off All (ปิดใช้ทั้งหมด)",
                                    buttonTitles: "OK") { alert in
                    //alert.backgroundColor = .yellow
                    alert.titleLabel.font = .Alert_Title
                    alert.messageLabel.font = .Alert_Message
                    alert.titleLabel.textColor = .themeColor
                    alert.cancelButtonIndex = 0
                    alert.button(at: 0)?.titleLabel?.font = .Alert_Button
                    alert.button(at: 0)?.setTitleColor(.themeColor, for: .normal)
                }
                                    .onButtonClicked { _, buttonIndex in
                                        print("Button Clicked At Index \(buttonIndex)")
                                    }
            } else {
                sender.setOn(false, animated: true)
                ProgressHUD.showSuccess("ยกเลิกการเชื่อมต่อ Apple Health")
            }
            
        }
    }
    
    // MARK: - GARMIN
    @IBAction func garmin_Click(_ sender: UISwitch) {
        if sender.isOn{//กดเปิด
//            sender.setOn(false, animated: true)
            authorizeGarmin()
        }
        else{//กดปิด
//            sender.setOn(true, animated: true)
            deAuthorizeGarminFromCCC()
        }
    }
    
    func authorizeGarmin() {
        // create an instance of oAuth and retain it
        garminOauthSwift =  OAuth1Swift(
            consumerKey:    garminConsumerKey,
            consumerSecret: garminConsumerSecret,
            requestTokenUrl: "https://connectapi.garmin.com/oauth-service/oauth/request_token",
            authorizeUrl: "https://connect.garmin.com/oauthConfirm",
            accessTokenUrl: "https://connectapi.garmin.com/oauth-service/oauth/access_token"
        )
        
        if let oauth = garminOauthSwift {
            // add safari as authorized URL Handler
            oauth.authorizeURLHandler = SafariURLHandler(viewController: self, oauthSwift: oauth)
            
            // set redirection URL
            guard let redirectURL = URL(string: "\(urlScheme)://garmin-callback") else { return }
            
            // add callback url to authorized url
            oauth.addCallbackURLToAuthorizeURL = true
            oauth.authorize(withCallbackURL: redirectURL)  { result in
                switch result {
                case .success(let (req, response, res)):
                    print("response=", response ?? "no")
                    print("req=", req )
                    print("res=", res )
                    //                    print("dataString=",response?.dataString())
                    
                    var accessToken = ""
                    var accessTokenSecret = ""
                    if let token = res["oauth_token"] as? String{
                        //                        SceneDelegate.GlobalVariables.garminAccessToken = token
                        accessToken = token
                        print("ACCESS TOKEN = \(token)")
                    }
                    if let secret = res["oauth_token_secret"] as? String{
                        //                        SceneDelegate.GlobalVariables.garminAccessTokenSecret = secret
                        accessTokenSecret = secret
                        print("ACCESS TOKEN SECRET = \(secret)")
                    }
                    self.authorizeGarminToCCC(token: accessToken, tokenSecret: accessTokenSecret)
                    
                case .failure(let error):
                    print("ERROR \(error.description)")
                }
            }
        }
    }
    
    func authorizeGarminToCCC(token: String, tokenSecret: String) {
        let parameters:Parameters = ["id":SceneDelegate.GlobalVariables.userID,
                                     "oauth_token_user":token,
                                     "oauth_token_secret_user":tokenSecret,
        ]
        
        loadRequest(method:.post, apiName:"connect/garmin/auth/connect", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS GARMIN CCC\(json)")
                
                self.loadPartnerStatus()
            }
        }
    }
    
    func deAuthorizeGarminFromCCC() {
        let parameters:Parameters = [:]
        
        loadRequest(method:.delete, apiName:"connect/garmin/user/delete/\(SceneDelegate.GlobalVariables.userID)", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS GARMIN DELETE\(json)")
                
                self.loadPartnerStatus()
            }
        }
    }
    
    
    // MARK: - STRAVA
    @IBAction func strava_Click(_ sender: UISwitch) {
        if sender.isOn{//เปิด
            sender.setOn(false, animated: true)
            
            //let appOAuthUrlStravaScheme = URL(string: "strava://oauth/mobile/authorize?client_id=\(stravaClientId)&redirect_uri=\(urlScheme)%3A%2F%2F\(stravaFallbackUrl)&response_type=code&approval_prompt=force&scope=activity:read_all")!
            
            let appOAuthUrlStravaScheme = URL(string: "strava://oauth/mobile/authorize?client_id=\(stravaClientId)&redirect_uri=\(HTTPHeaders.websiteURL)connect-auth/strava/\(SceneDelegate.GlobalVariables.userID)&response_type=code&approval_prompt=auto&scope=read_all,activity:read,activity:read_all,activity:write,profile:read_all")!
            
            if UIApplication.shared.canOpenURL(appOAuthUrlStravaScheme) {
                UIApplication.shared.open(appOAuthUrlStravaScheme, options: [:])
                //thirdParty = .strava
            }
            else {
                authorizeStrava()
            }
        }
        else{//ปิด
            sender.setOn(true, animated: true)
            //deAuthorizeStrava()
            deAuthorizeStravaFromCCC()
        }
    }
    
    func authorizeStrava() {
        //let url: String = "https://www.strava.com/oauth/mobile/authorize?client_id=\(stravaClientId)&redirect_uri=\(urlScheme)%3A%2F%2F\(stravaFallbackUrl)&response_type=code&approval_prompt=force&scope=activity:read_all"
        
        let url: String = "https://www.strava.com/oauth/mobile/authorize?client_id=\(stravaClientId)&redirect_uri=\(HTTPHeaders.websiteURL)connect-auth/strava/\(SceneDelegate.GlobalVariables.userID)&response_type=code&approval_prompt=auto&scope=read_all,activity:read,activity:read_all,activity:write,profile:read_all"
        
        guard let authenticationUrl = URL(string: url) else { return }
        
        authSession = ASWebAuthenticationSession(url: authenticationUrl, callbackURLScheme: "\(urlScheme)") { [weak self] url, error in
            if let error = error {
                print(error)
            } else {
                if let code = self?.getCode(from: url) {
                    print("CODE \(code)")
                    //self?.requestStravaTokens(with: code)
                }
                self?.loadPartnerStatus()
            }
        }
        
        authSession?.presentationContextProvider = self
        authSession?.start()
    }
    
    func getCode(from url: URL?) -> String? {
        guard let url = url?.absoluteString else { return nil }
        
        let urlComponents: URLComponents? = URLComponents(string: url)
        let code: String? = urlComponents?.queryItems?.filter { $0.name == "code" }.first?.value
        
        return code
    }
    
    func requestStravaTokens(with code: String) {
        let parameters: [String: Any] = ["client_id": stravaClientId, "client_secret": stravaClientSecret, "code": code, "grant_type": "authorization_code"]
        
        AF.request("https://www.strava.com/oauth/token",
                   method: .post,
                   parameters: parameters
        ).responseJSON { response in
            
            switch response.result {
            case .success(let data as AnyObject):
                
                let json = JSON(data)
                print("STRAVA = \(json)")
                let token = json["access_token"].stringValue
                print("ACCESS TOKEN = \(token)")
                let secret = json["refresh_token"].stringValue
                print("REFRESH TOKEN = \(secret)")
                
                self.stravaSwitch.setOn(true, animated: true)
                SceneDelegate.GlobalVariables.stravaAccessToken = token
                self.fetchStrava()
                
            case .failure(let error):
                print("ERROR \(error)")
                
            default:
                fatalError("received non-dictionary JSON response")
            }
        }
    }
    
    func fetchStrava() {//ให้หลังบ้านทำ
        let headerWithAuthorize = ["Authorization": "Bearer \(SceneDelegate.GlobalVariables.stravaAccessToken)",
                                   //"Accept": "application/json"
        ] as HTTPHeaders
        
        let parameters:Parameters = [:]
        print("HEADER \(headerWithAuthorize)")
        AF.request("https://www.strava.com/api/v3/athlete/activities",
                   method: .get,
                   parameters: parameters,
                   //encoding: JSONEncoding.default,
                   headers: headerWithAuthorize).responseJSON { response in
            
            //debugPrint(response)
            
            switch response.result {
            case .success(let data as AnyObject):
                let json = JSON(data)
                print("FETCH STRAVA \(json)")
                
            case .failure(let error):
                print("ERROR \(error)")
                
            default:
                fatalError("received non-dictionary JSON response")
            }
        }
    }
    
    func deAuthorizeStrava() {
        let parameters:Parameters = ["access_token":SceneDelegate.GlobalVariables.stravaAccessToken]
        AF.request("https://www.strava.com/oauth/deauthorize",
                   method: .post,
                   parameters: parameters,
                   //encoding: JSONEncoding.default,
                   headers: HTTPHeaders.header).responseJSON { response in
            
            //debugPrint(response)
            
            switch response.result {
            case .success(let data as AnyObject):
                let json = JSON(data)
                print("DEAUTHORIZE STRAVA \(json)")
                self.stravaSwitch.setOn(false, animated: true)
                SceneDelegate.GlobalVariables.stravaAccessToken = ""
                
            case .failure(let error):
                print("ERROR \(error)")
                
            default:
                fatalError("received non-dictionary JSON response")
            }
        }
    }
    
    func deAuthorizeStravaFromCCC() {
        let parameters:Parameters = ["id":SceneDelegate.GlobalVariables.userID]
        
        loadRequest(method:.post, apiName:"connect/strava/user/disconnect", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS STRAVA DELETE\(json)")
                
                self.loadPartnerStatus()
            }
        }
    }
    
    
    // MARK: - COROS
    @IBAction func coros_Click(_ sender: UISwitch) {
        if sender.isOn{//เปิด
            sender.setOn(false, animated: true)
            
            let appOAuthUrlCorosScheme = URL(string: "http://open.coros.com/oauth2/authorize?client_id=\(corosClientId)&state=\(corosState)&response_type=code&redirect_uri=\(HTTPHeaders.websiteURL)connect-auth/coros/\(SceneDelegate.GlobalVariables.userID)")!
            
            if UIApplication.shared.canOpenURL(appOAuthUrlCorosScheme) {
                UIApplication.shared.open(appOAuthUrlCorosScheme, options: [:])
            }
            else {
                //authorizeCoros()
            }
        }
        else{//ปิด
            sender.setOn(true, animated: true)
            deAuthorizeCorosFromCCC()
        }
    }
    
    func deAuthorizeCorosFromCCC() {
        let parameters:Parameters = ["id":SceneDelegate.GlobalVariables.userID]
        
        loadRequest(method:.post, apiName:"connect/coros/user/disconnect", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS COROS DELETE\(json)")
                
                self.loadPartnerStatus()
            }
        }
    }
    
    
    // MARK: - FITBIT
    @IBAction func fitbit_Click(_ sender: UISwitch) {
        if sender.isOn{//เปิด
            sender.setOn(false, animated: true)
            requestFitbitURL()
        }
        else{//ปิด
            sender.setOn(true, animated: true)
            deAuthorizeFitbitFromCCC()
        }
    }
    
    func requestFitbitURL() {
        let parameters:Parameters = [:]
        
        loadRequest(method:.get, apiName:"connect/fitbit/user/auth_url/\(SceneDelegate.GlobalVariables.userID)", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS FITBIT URL\(json)")
                
                let authenticationUrl = URL(string:json["data"]["link_authorization"].stringValue)

                if UIApplication.shared.canOpenURL(authenticationUrl!) {
                    UIApplication.shared.open(authenticationUrl!, options: [:])
                }
                else {
                    //authorizeFitbit()
                }
            }
        }
    }
    
    func deAuthorizeFitbitFromCCC() {
        let parameters:Parameters = ["user_id":SceneDelegate.GlobalVariables.userID]
        
        loadRequest(method:.post, apiName:"connect/fitbit/user/disconnect", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS FITBIT DELETE\(json)")
                
                self.loadPartnerStatus()
            }
        }
    }
    
    
    // MARK: - SUUNTO
    @IBAction func suunto_Click(_ sender: UISwitch) {
        // create an instance of oAuth and retain it
        suuntoOauthSwift = OAuth2Swift(
            consumerKey:    "********",
            consumerSecret: "",
            authorizeUrl:   "https://cloudapi-oauth.suunto.com/oauth/authorize",
            responseType:   "code"//"token"
        )
        let handle = suuntoOauthSwift!.authorize(
            withCallbackURL: "ccc://oauth-callback/instagram",
            scope: "likes+comments", state:"INSTAGRAM") { result in
                switch result {
                case .success(let (credential, response, parameters)):
                    print(credential.oauthToken)
                    // Do your request
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        
        //        if let oauth = suuntoOauthSwift {
        //            // add safari as authorized URL Handler
        //            oauth.authorizeURLHandler = SafariURLHandler(viewController: self, oauthSwift: oauth)
        //
        //            // set redirection URL
        //            guard let redirectURL = URL(string: "\(urlScheme)://garmin-callback") else { return }
        //
        //            // add callback url to authorized url
        //            oauth.addCallbackURLToAuthorizeURL = true
        //            oauth.authorize(withCallbackURL: redirectURL)  { result in
        //                switch result {
        //                case .success(let (req, response, res)):
        //                    print("response=", response ?? "no")
        //                    print("req=", req )
        //                    print("res=", res )
        //                    //                    print("dataString=",response?.dataString())
        //
        //                    if let token = res["oauth_token"] as? String{
        //                        //self.garminAccessToken = token
        //                        print("ACCESS TOKEN = \(token)")
        //                    }
        //                    if let secret = res["oauth_token_secret"] as? String{
        //                        //self.garminAccessTokenSecret = secret
        //                        print("ACCESS TOKEN SECRET = \(secret)")
        //                    }
        //
        //                case .failure(let error):
        //                    print("ERROR \(error.description)")
        //                }
        //            }
        //        }
    }
    
    // MARK: - PARKRUN
    @IBAction func parkrun_Click(_ sender: UISwitch) {
        if sender.isOn{//กดเปิด
//            sender.setOn(false, animated: true)
            let vc = UIStoryboard.mainStoryBoard_2.instantiateViewController(withIdentifier: "Web") as! Web
            vc.titleString = "เชื่อมต่อ Park Run THAILAND"
            vc.webUrlString = "\(HTTPHeaders.websiteURL)connect-auth/parkrun/\(SceneDelegate.GlobalVariables.userID)"
            self.navigationController!.pushViewController(vc, animated: true)
        }
        else{//กดปิด
//            sender.setOn(true, animated: true)
            deAuthorizeParkrun()
        }
    }
    
    func deAuthorizeParkrun() {
        let parameters:Parameters = ["id":SceneDelegate.GlobalVariables.userID]
        
        loadRequest(method:.post, apiName:"connect/parkrun/user/disconnect", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS PARKRUN DELETE\(json)")
                
                ProgressHUD.showSuccess(json["data"]["message"].stringValue)
                self.loadPartnerStatus()
            }
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
}


// MARK: - UIViewController
extension Setting: ASWebAuthenticationPresentationContextProviding {
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.windows[0]
    }
    
}
