//
//  QRScanner.swift
//  CCC
//
//  Created by Truk Karawawattana on 7/12/2566 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import AVFoundation
import ProgressHUD

class QRScanner: UIViewController {
    
    var challengeJSON : JSON?
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrcodeFrameView: UIView?
    
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      AVMetadataObject.ObjectType.qr]
    
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var backBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setStatusBar(backgroundColor: .themeBgColor)
        
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            captureSession.addInput(input)
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            //captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds//view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            view.bringSubviewToFront(topBar)
            
            //Start video capture
            captureSession.startRunning()
            
            //Innitialize QR Code Frame to highlight the QR Code
            qrcodeFrameView = UIView()
            
            if let qrcodeFrameView = qrcodeFrameView {
                qrcodeFrameView.layer.borderColor = UIColor.red.cgColor
                qrcodeFrameView.layer.borderWidth = 2
                view.addSubview(qrcodeFrameView)
                view.bringSubviewToFront(qrcodeFrameView)
            }
            
        } catch {
            // IF any error occurs, simply print it out and don't continue anymore
            print(error)
            return
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
}

extension QRScanner: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        //Check if the metadataObjects array is not nil
        if metadataObjects.count == 0 {
            qrcodeFrameView?.frame = CGRect.zero
            return
        }
        
        //Get the metadata object
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            let barcodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrcodeFrameView?.frame = barcodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                let QRString = metadataObj.stringValue!
                print(QRString)
                
                let strArray = QRString.split(separator: "-")
                if strArray.count == 2 {
                    let inviteID = String(strArray[0])
                    let challengeID = String(strArray[1])
                    
                    captureSession.stopRunning()
                    checkJoinStatus(inviteID: inviteID, challengeID: challengeID)
                }
            }
        }
    }
    
    func checkJoinStatus(inviteID:String, challengeID:String) {
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
                self.pushToChallenge(inviteID: inviteID, challengeID: challengeID, joinStatus: self.challengeJSON!["status_join"].stringValue)
            }
        }
    }
    
    func pushToChallenge(inviteID:String, challengeID:String, joinStatus:String) {
        print("\(inviteID) invite you to join challenge \(challengeID)\n Your status = \(joinStatus)")
        
        if joinStatus == "unjoin" {
            let vc = UIStoryboard.challengeStoryBoard.instantiateViewController(withIdentifier: "ChallengeDetail_2") as! ChallengeDetail_2
            vc.challengeMode = .all
            vc.challengeID = challengeID
            vc.inviteID = inviteID
            self.navigationController!.pushViewController(vc, animated: true)
        }
        else {
            let vc = UIStoryboard.challengeStoryBoard.instantiateViewController(withIdentifier: "ChallengeJoin_2") as! ChallengeJoin_2
            vc.challengeMode = .joined
            vc.challengeID = challengeID
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }
}
