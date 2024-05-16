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
import Photos
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
    @IBOutlet weak var uploadPicBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setStatusBar(backgroundColor: .themeColor)
        
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
            view.bringSubviewToFront(uploadPicBtn)
            
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
    
    @IBAction func uploadPicClick(_ sender: UIButton) {
        chooseImageSource()
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
                
                verifyQRCode(qrStr: QRString)
            }
        }
    }
    
    func verifyQRCode(qrStr:String) {
        if qrStr.contains("challenge") {
            let component = qrStr.split(separator: "?")
            if component.count > 1, let challengeID = component.last {
                //let inviteID = String(component[0])
                //let challengeID = String(component[1])
                
                captureSession.stopRunning()
                checkJoinStatus(inviteID: "", challengeID: String(challengeID))
            }
            else{
                ProgressHUD.showError("ข้อมูล QR ไม่ถูกต้อง กรุณาตรวจสอบและทำรายการใหม่อีกครั้ง")
            }
        }
        else {
            ProgressHUD.showError("ข้อมูล QR ไม่ถูกต้อง กรุณาตรวจสอบและทำรายการใหม่อีกครั้ง")
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

// MARK: - UIImagePickerControllerDelegate

extension QRScanner: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func chooseImageSource()
    {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        //        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
        //            self.checkPermission(camera: true)
        //        }))
        //        alert.actions.last?.titleTextColor = .themeColor
        
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
            self.checkPermission(camera: false)
        }))
        alert.actions.last?.titleTextColor = .themeColor
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        alert.actions.last?.titleTextColor = .buttonRed
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func checkPermission(camera:Bool)
    {
        if camera == true {
            //Camera Permission
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { success in
                if success {
                    //Camera access granted
                    DispatchQueue.main.async {
                        self.openCamera()
                    }
                } else {
                    //No Camera access
                    DispatchQueue.main.async {
                        self.askPermission(camera: true)
                    }
                }
            }
        }
        else{
            //Photos Permission
            let status = PHPhotoLibrary.authorizationStatus()
            switch status {
            case .authorized:
                self.openGallery()
                
            case .denied, .restricted :
                askPermission(camera: false)
                
            case .notDetermined:
                // ask for permissions
                PHPhotoLibrary.requestAuthorization { status in
                    switch status {
                    case .authorized:
                        self.openGallery()
                    case .denied, .restricted:
                        self.askPermission(camera: false)
                    case .notDetermined: // won't happen but still
                        break
                    case .limited:
                        break
                    @unknown default:
                        break
                    }
                }
                
            case .limited:
                break
            @unknown default:
                break
            }
        }
    }
    
    func askPermission(camera:Bool)
    {
        if camera == true {//Camera
            let alert = UIAlertController(title: "Your Camera Access Denied", message: "Please allow camera access to upload profile photo", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                
            }))
            alert.actions.last?.titleTextColor = .buttonRed
            
            alert.addAction(UIAlertAction(title: "Go to Setting", style: .default, handler: { action in
                
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            }))
            alert.actions.last?.titleTextColor = .themeColor
            
            self.present(alert, animated: true)
        }
        else{//Photo Library
            let alert = UIAlertController(title: "Your Photo Library Access Denied", message: "Please allow photo library access to upload profile photo", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                
            }))
            alert.actions.last?.titleTextColor = .buttonRed
            
            alert.addAction(UIAlertAction(title: "Go to Setting", style: .default, handler: { action in
                
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            }))
            alert.actions.last?.titleTextColor = .themeColor
            
            self.present(alert, animated: true)
        }
    }
    
    func openCamera()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallery()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            DispatchQueue.main.async {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.allowsEditing = false
                imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have permission to access gallery.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[.originalImage] as? UIImage {
            let QRString = pickedImage.parseQR().first ?? ""
            print(QRString)
            
            verifyQRCode(qrStr: QRString)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
