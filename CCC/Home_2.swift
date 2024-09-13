//
//  Home_2.swift
//  CCC
//
//  Created by Truk Karawawattana on 14/12/2566 BE.
//

import HealthKit
import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import SDWebImage
import CoreLocation
import SwiftAlertView
import SkeletonView
import Parchment

class Home_2: UIViewController {
    
    var homeJSON: JSON?
    var challengeJSON: JSON?
    
    var popupRead = false
    var notShowAgain = false
    
    var circularProgress: CircularProgressView!
    
    var locationManager: CLLocationManager!
    
    private var workouts: [HKWorkout]?
    
    @IBOutlet weak var sideMenuBtn: UIButton!
    @IBOutlet weak var qrBtn: UIButton!
    
    @IBOutlet weak var nameView: UIView!
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var creditView: UIView!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var creditLabel: UILabel!
    
    @IBOutlet weak var medalTitle: UILabel!
    @IBOutlet weak var medalImage: UIImageView!
    @IBOutlet weak var medalLabelTH: UILabel!
    @IBOutlet weak var medalLabelEN: UILabel!
    @IBOutlet weak var remainLabel: UILabel!
    
    @IBOutlet weak var homeBg: UIImageView!
    @IBOutlet weak var calorieLabel: UILabel!
    
    @IBOutlet var popupView: UIView!
    @IBOutlet weak var popupPic: UIImageView!
    @IBOutlet weak var popupTitle: UILabel!
    @IBOutlet weak var popupDescription: UITextView!
    @IBOutlet weak var popupXBtn: UIButton!
    @IBOutlet weak var notShowAgainBtn: UIButton!
    
    var blurView : UIVisualEffectView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //print("3")
        if (homeJSON == nil) || SceneDelegate.GlobalVariables.reloadHome {
            loadHome()
            SceneDelegate.GlobalVariables.reloadHome = false
        }
        else {
            if !popupRead {
                checkConsent()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("HOME_2")
        
        print(self.tabBarController!.viewControllers![3])
        
        self.navigationController?.setStatusBar(backgroundColor: .themeColor)
        
        self.view.showAnimatedGradientSkeleton()
        
        circularProgress = CircularProgressView(frame: CGRect(x: 0, y: 0, width: 110, height: 110), lineWidth: 7, rounded: true)
        circularProgress.progressColor = .buttonGreen
        circularProgress.trackColor = .white
        //circularProgress.center = progressView.center
        //circularProgress.progress = 0.6
        progressView.addSubview(circularProgress)
        progressView.backgroundColor = .clear
        
        print(SceneDelegate.GlobalVariables.userID)
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 5.0 //minimun distance to update in meters
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        CheckUpdate.shared.showUpdate(withConfirmation: true)
        
        creditView.addTapGesture {
            self.tabBarController?.selectedIndex = 2
        }
        
        blurView = blurViewSetup()
        
        let popupWidth = self.view.bounds.width*0.9
        let popupHeight = self.view.bounds.height*0.8//popupWidth*1.5
        popupView.frame = CGRect(x: (self.view.bounds.width-popupWidth)/2, y: (self.view.bounds.height-popupHeight)/2, width: popupWidth, height: popupHeight)
    }
    
    func loadHome() {
        var parameters:Parameters = ["user_id":SceneDelegate.GlobalVariables.userID]
        let fcmToken = UserDefaults.standard.string(forKey:"fcm_token")
        if  fcmToken != nil {
            parameters.updateValue(fcmToken!, forKey: "token_notification")
        }
        //print(parameters)
        
        loadRequest_V2(method:.post, apiName:"get_home", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                //print("SUCCESS HOME\(json)")
                
                self.homeJSON = json["data"]
                //SceneDelegate.GlobalVariables.profileJSON = json["data"][0]
                
                SceneDelegate.GlobalVariables.userPicURL = self.homeJSON!["pictureUrl"].stringValue
                SceneDelegate.GlobalVariables.userHeight = self.homeJSON!["height"].floatValue
                
                let weight = self.homeJSON!["weight"].floatValue
                if weight == 0 {
                    //SceneDelegate.GlobalVariables.userWeight = 75
                }
                else{
                    SceneDelegate.GlobalVariables.userWeight = weight
                }
                
                SceneDelegate.GlobalVariables.profileURL = self.homeJSON!["profile_url"].stringValue
                
                SceneDelegate.GlobalVariables.userLastSynced = self.homeJSON!["last_sync"].stringValue
                
                if SceneDelegate.GlobalVariables.reSyncHealth {
                    self.syncHealth(startDateStr: SceneDelegate.GlobalVariables.userLastSynced)
                    self.syncSteps(startDateStr: SceneDelegate.GlobalVariables.userLastSynced)
                }
                
                self.popupRead = false
                self.checkConsent()
            }
        }
    }
    
    func checkConsent() {
        if homeJSON!["consent_status"] != "2" {
            SwiftAlertView.show(title: "มีการแก้ไขปรับปรุงเงื่อนไขการใช้งาน",
                                message: "ระบบจะทำการ Logout อัตโนมัติ\nกรุณาเข้าสู่ระบบใหม่อีกครั้ง",
                                buttonTitles: "กลับสู่หน้า Login") { alert in
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
                                    self.logOut()
                                }
        }
        else if homeJSON!["privacy_status"] != "1" {
            let vc = UIStoryboard.loginStoryBoard.instantiateViewController(withIdentifier: "Consent") as! Consent
            vc.consentMode = .fromHome
            vc.consentType = .privacy
            self.navigationController!.pushViewController(vc, animated: true)
        }
        else if homeJSON!["terms_status"] != "1" {
            let vc = UIStoryboard.loginStoryBoard.instantiateViewController(withIdentifier: "Consent") as! Consent
            vc.consentMode = .fromHome
            vc.consentType = .terms
            self.navigationController!.pushViewController(vc, animated: true)
        }
        else if homeJSON!["id_pop_ups"] != "" {
            self.showPopup()
        }
        self.updateDisplay()
    }
    
    func updateDisplay() {
        welcomeLabel.text = homeJSON!["welcome_message"].stringValue
        nameLabel.text = homeJSON!["first_name"].stringValue
        dateLabel.text = homeJSON!["date_text"].stringValue
        
        circularProgress.progress = homeJSON!["my_credit"].floatValue/homeJSON!["credit_next_level"].floatValue
        
        creditLabel.text = homeJSON!["my_credit"].stringValue
        
        medalTitle.text = homeJSON!["level_health_text"].stringValue
        medalImage.sd_setImage(with: URL(string:homeJSON!["credit_level_url_image"].stringValue), placeholderImage: nil)
        medalLabelTH.text = homeJSON!["credit_level_text_th"].stringValue
        medalLabelEN.text = homeJSON!["credit_level_text"].stringValue
        remainLabel.text = homeJSON!["credit_next_level_text"].stringValue
        
        homeBg.sd_setImage(with: URL(string:homeJSON!["image_home"].stringValue), placeholderImage: nil)
        calorieLabel.text = homeJSON!["kcal"].stringValue
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.00) {
            self.view.hideSkeleton()
        }
    }
    
    func showPopup() {
        self.popupPic.sd_setImage(with: URL(string:homeJSON!["pop_ups_img_url"].stringValue), placeholderImage: nil)
        
        self.popupTitle.text = homeJSON!["pop_ups_name"].stringValue
        
        //self.popupDescription.text = popupArray[0]["pop_ups_content"].stringValue.html2String
        self.popupDescription.attributedText = homeJSON!["pop_ups_content"].stringValue.convertToAttributedFromHTML()
        self.popupDescription.textColor = .textGray1
        self.popupDescription.font = .Prompt_Regular(ofSize: 14)
        self.popupDescription.textContainerInset = .zero
        
        self.popIn(popupView: self.blurView)
        self.popIn(popupView: self.popupView)
        
        self.popupPic.addTapGesture {
            switch self.homeJSON!["pop_ups_type"].stringValue {
            case "web":
                let urlStr = self.homeJSON!["pop_ups_link"].stringValue
                if urlStr.contains("http") {
                    let vc = UIStoryboard.mainStoryBoard_2.instantiateViewController(withIdentifier: "Web") as! Web
                    vc.titleString = ""
                    vc.webUrlString = urlStr
                    self.navigationController!.pushViewController(vc, animated: true)
                }
                else {
                    if let url = URL(string: urlStr) {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        }
                        else {
                            print("Can't open popup link")
                            //self.showErrorNoData()
                        }
                    }
                }
                
            case "challenge":
                self.checkJoinStatus(challengeID: self.homeJSON!["pop_ups_link"].stringValue)
                
            case "challenge_my":
                let vc = self.tabBarController!.viewControllers![3] as! Challenge_2
                vc.myMode = .official
                self.tabBarController?.selectedIndex = 3
                
            default:
                break
            }
            
            if self.notShowAgain {
                self.savePopupRead()
            }
            self.popOut(popupView: self.popupView)
            self.popOut(popupView: self.blurView)
        }
    }
    
    func checkJoinStatus(challengeID:String) {
        let parameters:Parameters = ["user_id":SceneDelegate.GlobalVariables.userID,
                                     "challenge_id":challengeID
        ]
        
        loadRequest_V2(method:.post, apiName:"challenges/info", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS JOIN CHECK\(json)")
                
                self.challengeJSON = json["data"][0]
                self.pushToChallenge(challengeID: challengeID, joinStatus: self.challengeJSON!["status_join"].stringValue)
            }
        }
    }
    
    func pushToChallenge(challengeID:String, joinStatus:String) {
        if joinStatus == "unjoin" {
            let vc = UIStoryboard.challengeStoryBoard.instantiateViewController(withIdentifier: "ChallengeDetail_2") as! ChallengeDetail_2
            vc.challengeMode = .all
            vc.challengeID = challengeID
            self.navigationController!.pushViewController(vc, animated: true)
        }
        else {
            let vc = UIStoryboard.challengeStoryBoard.instantiateViewController(withIdentifier: "ChallengeJoin_2") as! ChallengeJoin_2
            vc.challengeMode = .joined
            vc.challengeID = challengeID
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func leftMenuShow(_ sender: UIButton) {
        //        let sideMenu = self.sideMenuController?.menuViewController as! SideMenu_2
        //        sideMenu.loadSideMenu()
        
        self.sideMenuController!.revealMenu()
    }
    
    @IBAction func qrClick(_ sender: UIButton) {
        let vc = UIStoryboard.mainStoryBoard_2.instantiateViewController(withIdentifier: "QRScanner") as! QRScanner
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction func creditClick(_ sender: UIButton) {
        self.tabBarController?.selectedIndex = 2
    }
    
    @IBAction func notShowAgainClick(_ sender: UIButton) {
        if notShowAgain{
            notShowAgain = false
            notShowAgainBtn.setImage(UIImage(named: "form_checkbox_off"), for: .normal)
        }
        else{
            notShowAgain = true
            notShowAgainBtn.setImage(UIImage(named: "form_checkbox_on"), for: .normal)
        }
    }
    
    @IBAction func closePopupClick(_ sender: UIButton) {
        if notShowAgain {
            savePopupRead()
        }
        self.popOut(popupView: self.popupView)
        self.popOut(popupView: self.blurView)
    }
    
    func savePopupRead() {
        let parameters:Parameters = ["user_id":SceneDelegate.GlobalVariables.userID,
                                     "popups_id":homeJSON!["id_pop_ups"].stringValue
        ]
        //print(parameters)
        loadRequest_V2(method:.post, apiName:"popups/read", authorization:true, showLoadingHUD:false, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("POPUP READ\(json)")
                
                self.popupRead = true
            }
        }
    }
    
    @IBAction func startClick(_ sender: UIButton) {
        let vc = UIStoryboard.runStoryBoard.instantiateViewController(withIdentifier: "Run") as! Run
        self.navigationController!.pushViewController(vc, animated: true)
    }
}

// MARK: - CLLocation Delegate
extension Home_2: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        SceneDelegate.GlobalVariables.userLat = location.coordinate.latitude.description
        SceneDelegate.GlobalVariables.userLong = location.coordinate.longitude.description
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Handle authorization status
        
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            //myMap.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        @unknown default:
            fatalError()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}

