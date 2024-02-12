//
//  SceneDelegate.swift
//  CCC
//
//  Created by Truk Karawawattana on 12/12/2564 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import SideMenuSwift
import LineSDK
import SwiftUI
import OAuthSwift
import FacebookCore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    struct GlobalVariables {
        static var userID = ""
        static var userLastSynced = "2024-01-01"
        static var userHeight:Float = 170
        static var userWeight:Float = 75
        static var userLat = ""
        static var userLong = ""
        static var userPicURL = ""
        
        static var profileJSON:JSON? = nil
        
        static var stravaAccessToken = ""
        //static var stravaRefreshToken = ""
        static var garminAccessToken = ""
        static var garminAccessTokenSecret = ""
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        //UserDefaults.standard.removeObject(forKey:"userID")//อย่าลืมเอาออก
        
        var userID = UserDefaults.standard.string(forKey:"userID")
        
        //userID = "17479" //พี่แจ้0
        //userID = "17480" //พี่แจ้1*
        //userID = "17481" //พี่แจ้2
        //userID = "17358" //ป้อม test parkrun
        //userID = "17364" //ป้อม
        //userID = "17517" //โฟน line (U6ab18b49434959efb295ca19164df5c5)
        //userID = "17530" //ป้อม Line
        //userID = "2238" //พี่เม
        //userID = "17617" //โฟน Apple*
        //userID = "17619" //เทส Challenge
        //userID = "41475" //ป้อม pk2:test
        //userID = "17497" //โฟน Google
        //userID = "19413"//ป้อม 2023
        //userID = "999"//พี่เม 2024 parkrun
        
        checkConsent(userID:userID, scene:scene)
    }
    
    func checkConsent(userID:String?, scene:UIScene) {
        if userID != nil {
            GlobalVariables.userID = userID!
            
            let fullURL = HTTPHeaders.baseURL+"get_profile"
            let headers = HTTPHeaders.headerWithAuthorize
            let parameters:Parameters = ["id":userID!]
            //AF.sessionConfiguration.timeoutIntervalForRequest = 60
            AF.request(fullURL,
                       method: .post,
                       parameters: parameters,
                       encoding: JSONEncoding.default,
                       headers: headers,
                       requestModifier: { $0.timeoutInterval = 60 }
            ).responseJSON { response in
                
                //debugPrint(response)
                switch response.result {
                case .success(let data as AnyObject):
                    let json = JSON(data)
                    //print("SUCCESS DELEGATE \(json)")
                    
                    SceneDelegate.GlobalVariables.profileJSON = json["data"][0]
                    
                    if json["message"] == "success" {
                        self.setFirstPage(consentStatus: json["data"][0]["consent_status"].stringValue, scene:scene, isApple: json["data"][0]["is_apple_chanel"].boolValue)
                    }
                    else{
                        self.setFirstPage(consentStatus: "0", scene:scene)
                    }
                    
                case .failure(let error):
                    print("error \(error)")
                    self.setFirstPage(consentStatus: "99", scene:scene)
                    
                default:
                    //fatalError("received non-dictionary JSON response")
                    self.setFirstPage(consentStatus: "99", scene:scene)
                }
            }
        }
        else{
            setFirstPage(consentStatus: "0", scene:scene)
        }
    }
    
    func setFirstPage(consentStatus:String, scene:UIScene, isApple:Bool? = false) {
        var navigationController : UINavigationController
        switch consentStatus {
        case "1":
            let vc = UIStoryboard.loginStoryBoard.instantiateViewController(withIdentifier: "Consent") as! Consent
            switch isApple {
            case true:
                vc.consentMode = .apple
            default:
                vc.consentMode = .normal
            }
            vc.consentType = .privacy
            navigationController = UINavigationController.init(rootViewController: vc)
            
        case "2":
            let menuViewController = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "SideMenu")
            let contentViewController = UIStoryboard.mainStoryBoard_2.instantiateViewController(withIdentifier: "TabBar_2")
            let screenSize: CGRect = UIScreen.main.bounds
            SideMenuController.preferences.basic.menuWidth = screenSize.width*0.8
            SideMenuController.preferences.basic.position = .above
            SideMenuController.preferences.basic.direction = .left
            SideMenuController.preferences.basic.enablePanGesture = true
            SideMenuController.preferences.basic.supportedOrientations = .portrait
            SideMenuController.preferences.basic.shouldRespectLanguageDirection = true
            
            let vc = SideMenuController(contentViewController: contentViewController, menuViewController: menuViewController)
            navigationController = UINavigationController.init(rootViewController: vc)
            
        case "99":
            let vc = UIStoryboard.loginStoryBoard.instantiateViewController(withIdentifier: "ServerError")
            navigationController = UINavigationController.init(rootViewController: vc)
            
        default:
            print("1ST time")
            let vc = UIStoryboard.loginStoryBoard.instantiateViewController(withIdentifier: "Login") as! Login
            navigationController = UINavigationController.init(rootViewController: vc)
        }
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            
            //let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            
//            let statusBar = UIView(frame: window.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero)
//            statusBar.backgroundColor = .red
//            window.addSubview(statusBar)
            
            //***อย่าลืม
            //let vc = UIStoryboard.loginStoryBoard.instantiateViewController(withIdentifier: "Login") as! Login
            
//            let vc = UIStoryboard.loginStoryBoard.instantiateViewController(withIdentifier: "Consent") as! Consent
//            //vc.consentMode = .fromHome
//            vc.consentType = .privacy
            
            //let vc = UIStoryboard.loginStoryBoard.instantiateViewController(withIdentifier: "Register_1") as! Register_1
            
            //let vc = UIStoryboard.loginStoryBoard.instantiateViewController(withIdentifier: "Register_2") as! Register_2
            
            //let vc = UIStoryboard.loginStoryBoard.instantiateViewController(withIdentifier: "Register_3") as! Register_3
            
//            let vc = UIStoryboard.loginStoryBoard.instantiateViewController(withIdentifier: "Profile") as! Profile
//            //vc.profileMode = .register
//            vc.profileMode = .edit
            
//            let vc = UIStoryboard.mainStoryBoard_2.instantiateViewController(withIdentifier: "TabBar_2") as! TabBar_2
//            vc.selectedIndex = 2
            
            //let vc = UIStoryboard.runStoryBoard.instantiateViewController(withIdentifier: "Run") as! Run
            
            //let vc = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "RunSummary") as! RunSummary
            
            //let vc = UIStoryboard.manualStoryBoard.instantiateViewController(withIdentifier: "ManualList") as! ManualList
            
            //let vc = UIStoryboard.manualStoryBoard.instantiateViewController(withIdentifier: "ManualComplete") as! ManualComplete
            
            //let vc = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "MyCalorie_2") as! MyCalorie_2
            
            //let vc = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "Ranking") as! Ranking
            
            //let vc = UIStoryboard.mainStoryBoard_2.instantiateViewController(withIdentifier: "Challenge_2") as! Challenge_2
            
//            let vc = UIStoryboard.challengeStoryBoard.instantiateViewController(withIdentifier: "ChallengeDetail_2") as! ChallengeDetail_2
//            vc.challengeID = "2590"//"2581"//"2511"//"40"
            
//            let vc = UIStoryboard.challengeStoryBoard.instantiateViewController(withIdentifier: "ChallengeJoin_2") as! ChallengeJoin_2
//            vc.challengeID = "2599"//"2581"//"2511"
            
            //let vc = UIStoryboard.mainStoryBoard_2.instantiateViewController(withIdentifier: "QRScanner") as! QRScanner
            
            //let vc = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "Knowledge") as! Knowledge
            
            //let vc = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "Web") as! Web
            
            //let vc = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "Setting") as! Setting
            
            //let vc = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "Share") as! Share
            
            //let vc = UIStoryboard.loginStoryBoard.instantiateViewController(withIdentifier: "ServerError") as! ServerError
            
            //let vc = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "TestWatch") as! TestWatch
            
            //let vc = UIStoryboard.creditStoryBoard.instantiateViewController(withIdentifier: "CreditHistory") as! CreditHistory
            
            //let vc = UIStoryboard.creditStoryBoard.instantiateViewController(withIdentifier: "CreditList") as! CreditList
            
            //let vc = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "Home") as! Home
            
            //let vc = UIStoryboard.historyStoryBoard.instantiateViewController(withIdentifier: "History") as! History
            
            //let vc = UIStoryboard.historyStoryBoard.instantiateViewController(withIdentifier: "Parkrun") as! Parkrun
            
            //navigationController = UINavigationController.init(rootViewController: vc)
            //***อย่าลืม
            
            navigationController.setNavigationBarHidden(true, animated:false)
            window.rootViewController = navigationController// Your RootViewController in here
            window.makeKeyAndVisible()
            self.window = window
        }
        //guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        
        //LINE
        _ = LoginManager.shared.application(.shared, open: URLContexts.first?.url)
        
        guard let url = URLContexts.first?.url else {
            return
        }
        //GARMIN
        if url.host == "garmin-callback" {
            OAuthSwift.handle(url: url)
        }
        
        //FACEBOOK
        ApplicationDelegate.shared.application(
            UIApplication.shared,
            open: url,
            sourceApplication: nil,
            annotation: [UIApplication.OpenURLOptionsKey.annotation]
        )
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}

