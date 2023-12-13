//
//  CheckUpdate.swift
//  CCC
//
//  Created by Truk Karawawattana on 16/4/2565 BE.
//

import Foundation
import UIKit
import SwiftAlertView

enum VersionError: Error {
    case invalidBundleInfo, invalidResponse
}

class LookupResult: Decodable {
    var results: [AppInfo]
}

class AppInfo: Decodable {
    var version: String
    var trackViewUrl: String
}

class CheckUpdate: NSObject {
    
    static let shared = CheckUpdate()
    
    
    func showUpdate(withConfirmation: Bool) {
        DispatchQueue.global().async {
            self.checkVersion(force : !withConfirmation)
        }
    }
    
    
    private  func checkVersion(force: Bool) {
        if let currentVersion = self.getBundle(key: "CFBundleShortVersionString") {
            _ = getAppInfo { (info, error) in
                if let appStoreAppVersion = info?.version {
                    if let error = error {
                        print("error getting app store version: ", error)
                    } else if appStoreAppVersion <= currentVersion {
                        print("Already on the last app version: ",currentVersion)
                    } else {
                        print("Needs update: AppStore Version: \(appStoreAppVersion) > Current version: ",currentVersion)
                        DispatchQueue.main.async {
                            let topController: UIViewController = (UIApplication.shared.windows.first?.rootViewController)!
                            topController.showAppUpdateAlert(Version: (info?.version)!, Force: force, AppURL: (info?.trackViewUrl)!)
                        }
                    }
                }
            }
        }
    }
    
    private func getAppInfo(completion: @escaping (AppInfo?, Error?) -> Void) -> URLSessionDataTask? {
        
        // You should pay attention on the country that your app is located, in my case I put Brazil */br/*
        // Você deve prestar atenção em que país o app está disponível, no meu caso eu coloquei Brasil */br/*
        
        guard let identifier = self.getBundle(key: "CFBundleIdentifier"),
              let url = URL(string: "http://itunes.apple.com/th/lookup?bundleId=\(identifier)") else {
                  DispatchQueue.main.async {
                      completion(nil, VersionError.invalidBundleInfo)
                  }
                  return nil
              }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            
            do {
                if let error = error { throw error }
                guard let data = data else { throw VersionError.invalidResponse }
                
                let result = try JSONDecoder().decode(LookupResult.self, from: data)
                print(result.results)
                guard let info = result.results.first else {
                    throw VersionError.invalidResponse
                }
                
                completion(info, nil)
            } catch {
                completion(nil, error)
            }
        }
        
        task.resume()
        return task
        
    }
    
    func getBundle(key: String) -> String? {
        
        guard let filePath = Bundle.main.path(forResource: "Info", ofType: "plist") else {
            fatalError("Couldn't find file 'Info.plist'.")
        }
        // 2 - Add the file to a dictionary
        let plist = NSDictionary(contentsOfFile: filePath)
        // Check if the variable on plist exists
        guard let value = plist?.object(forKey: key) as? String else {
            fatalError("Couldn't find key '\(key)' in 'Info.plist'.")
        }
        return value
    }
}

extension UIViewController {
    @objc fileprivate func showAppUpdateAlert( Version : String, Force: Bool, AppURL: String) {
        guard let appName = CheckUpdate.shared.getBundle(key: "CFBundleName") else { return } //Bundle.appName()
        let alertTitle = "อัปเดตใหม่ของแอปฯ \(appName) พร้อมให้ดาวน์โหลดแล้ว"
        //let alertMessage = "อัปเดตใหม่ของแอปฯ \(appName) พร้อมให้ดาวน์โหลดแล้ว"
        
        //        let alertController = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)
        //
        //        if !Force {
        //            let notNowButton = UIAlertAction(title: "ไม่ใช่ตอนนี้", style: .default)
        //            alertController.addAction(notNowButton)
        //            alertController.actions.last?.titleTextColor = .buttonRed
        //        }
        //
        //        let updateButton = UIAlertAction(title: "อัปเดต", style: .default) { (action:UIAlertAction) in
        //            guard let url = URL(string: AppURL) else {
        //                return
        //            }
        //            if #available(iOS 10.0, *) {
        //                print(url)
        //                UIApplication.shared.open(url, options: [:], completionHandler: nil)
        //            } else {
        //                UIApplication.shared.openURL(url)
        //            }
        //        }
        //
        //        alertController.addAction(updateButton)
        //        alertController.actions.last?.titleTextColor = .themeColor
        //
        //        //alertController.setColorAndFont()
        //        self.present(alertController, animated: true, completion: nil)
        
        SwiftAlertView.show(title: alertTitle,
                            message: nil,
                            buttonTitles: "ไม่ใช่ตอนนี้", "อัปเดต") { alert in
            //alert.backgroundColor = .yellow
            alert.titleLabel.font = .Alert_Title
            alert.messageLabel.font = .Alert_Message
            alert.cancelButtonIndex = 0
            alert.button(at: 0)?.titleLabel?.font = .Alert_Button
            alert.button(at: 0)?.setTitleColor(.buttonRed, for: .normal)
            
            alert.button(at: 1)?.titleLabel?.font = .Alert_Button
            alert.button(at: 1)?.setTitleColor(.themeColor, for: .normal)
            //            alert.buttonTitleColor = .themeColor
        }
                            .onButtonClicked { _, buttonIndex in
                                print("Button Clicked At Index \(buttonIndex)")
                                switch buttonIndex{
                                case 1:
                                    guard let url = URL(string: AppURL) else {
                                        return
                                    }
                                    if #available(iOS 10.0, *) {
                                        print(url)
                                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                    } else {
                                        UIApplication.shared.openURL(url)
                                    }
                                default:
                                    break
                                }
                            }
    }
}

