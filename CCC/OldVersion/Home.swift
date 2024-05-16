//
//  Home.swift
//  CCC
//
//  Created by Truk Karawawattana on 12/12/2564 BE.
//

import HealthKit
import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import SDWebImage
import CoreLocation
import SwiftAlertView

class Home: UIViewController {
    
    var profileJSON : JSON?
    
    var firstTime = true
    
    @IBOutlet weak var sideMenuBtn: UIButton!
    @IBOutlet weak var userPic: UIButton!
    @IBOutlet weak var userPoint: UILabel!
    @IBOutlet weak var pointView: UIView!
    @IBOutlet weak var manualPic: UIImageView!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var appleHealthBtn: UIButton!
    
    var locationManager: CLLocationManager!
    
    private var workouts: [HKWorkout]?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadHome()
        firstTime = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("HOME")
        self.navigationController?.setStatusBar(backgroundColor: .themeColor)
        
        print(SceneDelegate.GlobalVariables.userID)
        
        pointView.layer.shadowColor = UIColor.gray.cgColor
        pointView.layer.shadowOpacity = 0.5
        pointView.layer.shadowOffset = .zero
        pointView.layer.shadowRadius = 2
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        manualPic.addGestureRecognizer(tapGestureRecognizer)
        manualPic.isUserInteractionEnabled = true
        
        versionLabel.text = ""//"Version (\(Bundle.main.appVersionLong))"//(\(Bundle.main.appBuild))"
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 5.0 //minimun distance to update in meters
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        CheckUpdate.shared.showUpdate(withConfirmation: true)
        
        loadSteps() //Test Function
    }
    
    //    override var preferredStatusBarStyle : UIStatusBarStyle {
    //        return .lightContent //.default for black style
    //    }
    
    func loadHome() {
        let parameters:Parameters = ["id":SceneDelegate.GlobalVariables.userID]
        loadRequest(method:.post, apiName:"get_profile", authorization:true, showLoadingHUD:firstTime, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS HOME\(json)")
                
                self.profileJSON = json["data"][0]
                SceneDelegate.GlobalVariables.profileJSON = json["data"][0]
                
                if json["data"][0]["consent_status"] != "2" {
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
                else if json["data"][0]["privacy_status"] != "1" {
                    let vc = UIStoryboard.loginStoryBoard.instantiateViewController(withIdentifier: "Consent") as! Consent
                    vc.consentMode = .fromHome
                    vc.consentType = .privacy
                    self.navigationController!.pushViewController(vc, animated: true)
                }
                else if json["data"][0]["terms_status"] != "1" {
                    let vc = UIStoryboard.loginStoryBoard.instantiateViewController(withIdentifier: "Consent") as! Consent
                    vc.consentMode = .fromHome
                    vc.consentType = .terms
                    self.navigationController!.pushViewController(vc, animated: true)
                }
                else{
                    SceneDelegate.GlobalVariables.userPicURL = self.profileJSON!["pictureUrl"].stringValue
                    self.userPic.sd_setImage(with: URL(string:self.profileJSON!["pictureUrl"].stringValue), for: .normal, placeholderImage: UIImage(named: "icon_profile"))
                    self.userPoint.text = "\(self.profileJSON!["kcal"].stringValue) kCal"
                    SceneDelegate.GlobalVariables.userHeight = self.profileJSON!["height"].floatValue
                    
                    let weight = self.profileJSON!["weight"].floatValue
                    if weight == 0 {
                        //SceneDelegate.GlobalVariables.userWeight = 75
                    }
                    else{
                        SceneDelegate.GlobalVariables.userWeight = weight
                    }
                    
                    SceneDelegate.GlobalVariables.userLastSynced = self.profileJSON!["last_sync"].stringValue
                    self.syncHealth(startDateStr: SceneDelegate.GlobalVariables.userLastSynced)
                    
                }
            }
        }
    }
    
    func loadSteps() {
        
        //Specific Date
        getStepsCount(forSpecificDate: Date()) { (steps) in
                        if steps == 0.0 {
                            print("steps :: \(steps)")
                        }
                        else {
                            DispatchQueue.main.async {
                                print("steps :: \(steps)")
                            }
                        }
                    }
        
        //Steps History
        let startDate = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        getStepsHistory(fromSpecificDate: startDate) { (steps) in
            print("Steps Array : \(steps)")
        }
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        manualClick(UIButton())
    }
    
    @IBAction func leftMenuShow(_ sender: UIButton) {
        exit(-1)
        //self.sideMenuController!.revealMenu()
    }
    
    @IBAction func qrClick(_ sender: UIButton) {
        let vc = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "QRScanner") as! QRScanner
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction func profileClick(_ sender: UIButton) {
        let vc = UIStoryboard.loginStoryBoard.instantiateViewController(withIdentifier: "Profile") as! Profile
        vc.profileMode = .edit
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction func startClick(_ sender: UIButton) {
        let vc = UIStoryboard.runStoryBoard.instantiateViewController(withIdentifier: "Run") as! Run
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction func manualClick(_ sender: UIButton) {
//        let vc = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "ManualList") as! ManualList
//        self.navigationController!.pushViewController(vc, animated: true)
        
        let vc = UIStoryboard.mainStoryBoard_2.instantiateViewController(withIdentifier: "Web") as! Web
        vc.titleString = "ข้อเสนอแนะ (Feedback)"
        vc.webUrlString = "\(HTTPHeaders.websiteURL)feedback"
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
//    @IBAction func appleHealthClick(_ sender: UIButton) {
//
//        // ** IMPORTANT
//        // Check for access to your HealthKit Type(s).
//        if (HKHealthStore().authorizationStatus(for: HKObjectType.workoutType()) == .sharingAuthorized) {
//            print("Permission Granted to Access Workout")
//
//            let vc = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "WorkoutHistory") as! WorkoutHistory
//            //vc.mode = .Me
//            //vc.userID = self.profileJSON!["user_id"].stringValue
//            self.navigationController!.pushViewController(vc, animated: true)
//
//        } else {
//            print("Permission Denied to Access Energy Burned")
//            //ProgressHUD.showFailed("Access to Workout Denied")
//            goToSetting()
//        }
//    }
//
//    func goToSetting()
//    {
//        let alert = UIAlertController(title: "Access to Healthkit data was denied", message: "Please allow access to use this feature", preferredStyle: .alert)
//
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
//
//        }))
//        alert.actions.last?.titleTextColor = .buttonRed
//
//        alert.addAction(UIAlertAction(title: "Go to Setting", style: .default, handler: { action in
//
//            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
//        }))
//        alert.actions.last?.titleTextColor = .themeColor
//
//        self.present(alert, animated: true)
//    }
}

// MARK: - CLLocation Delegate
extension Home: CLLocationManagerDelegate {
    
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
    
    // Check accuracy authorization
    
//    let accuracy = manager.accuracyAuthorization
//    switch accuracy {
//    case .fullAccuracy:
//    print("Location accuracy is precise.")
//    case .reducedAccuracy:
//    print("Location accuracy is not precise.")
//    @unknown default:
//    fatalError()
//    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}
