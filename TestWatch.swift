//
//  TestWatch.swift
//  CCC
//
//  Created by Truk Karawawattana on 8/12/2565 BE.
//

import UIKit
import ProgressHUD
import WatchConnectivity

class TestWatch: UIViewController {
    
    var titleString:String?
    
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var reachableLabel: UILabel!
    @IBOutlet weak var recieveLabel: UILabel!
    @IBOutlet weak var recieveUserLabel: UILabel!
    
    var session: WCSession?
    var i = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureWatchKitSession()
    }
    
    func configureWatchKitSession() {
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    @IBAction func sendClicked() {
        print("SEND FROM iPhone")
        
        if let validSession = self.session, validSession.isReachable {
            i += 1
            let data: [String: Any] = ["iPhone": "Data from iPhone \(i)" as Any]
            validSession.sendMessage(data, replyHandler: nil, errorHandler: nil)
            validSession.transferUserInfo(data)
        }
    }
}

extension TestWatch: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WC Session activation failed with error: \(error.localizedDescription)")
            return
        }
        
        if WCSession.default.isReachable {
            print("Reachable")
        } else {
            print("Not Reachable")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("recieved watch message: \(message)")
        DispatchQueue.main.async {
            if let value = message["watch"] as? String {
                self.recieveLabel.text = value
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        print("recieved watch user: \(userInfo)")
        DispatchQueue.main.async {
            if let value = userInfo["watch"] as? String {
                self.recieveUserLabel.text = value
            }
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        print("Reachable \(session.isReachable)")
        var  isReachable = false
        if WCSession.default.activationState == .activated {
            isReachable = WCSession.default.isReachable
        }
        
        DispatchQueue.main.async {
            self.reachableLabel.textColor = isReachable ? .green : .red
        }
    }
}
