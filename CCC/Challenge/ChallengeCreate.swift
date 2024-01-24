//
//  ChallengeCreate.swift
//  CCC
//
//  Created by Truk Karawawattana on 24/1/2565 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import AVFoundation
import Photos

class ChallengeCreate: UIViewController, UITextFieldDelegate {
    
    var challengeMode: ChallengeMode?
    
    @IBOutlet weak var myScrollView: UIScrollView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var coverPic: UIImageView!
    @IBOutlet weak var coverBtn: UIButton!
    @IBOutlet weak var coverTitle: UILabel!
    @IBOutlet weak var submitBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("CHALLENGE CREATE")
        self.navigationController?.setStatusBar(backgroundColor: .themeColor)
        
        myScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        
        if challengeMode == .create {
            headerView.isHidden = true
            submitBtn.setTitle("สร้าง", for: .normal)
        }
        else if challengeMode == .edit {
            headerView.isHidden = false
            submitBtn.setTitle("แก้ไข", for: .normal)
        }
        
        coverDisplay(isCoverDisplay: false)
    }
    
    func coverDisplay(isCoverDisplay:Bool) {
        if isCoverDisplay {
            coverBtn.isHidden = true
            coverTitle.isHidden = true
        }
        else{
            coverBtn.isHidden = false
            coverTitle.isHidden = false
        }
    }
    
    func chooseImageSource()
    {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.checkPermission(camera: true)
        }))
        alert.actions.last?.titleTextColor = .themeColor
        
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
            imagePicker.allowsEditing = true
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
                imagePicker.allowsEditing = true
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
    
    @IBAction func cameraClick(_ sender: UIButton) {
        chooseImageSource()
    }
    
    @IBAction func submitClick(_ sender: UIButton) {
        let vc = UIStoryboard.challengeStoryBoard.instantiateViewController(withIdentifier: "ChallengeDetail") as! ChallengeDetail
        vc.challengeMode = .create
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate

extension ChallengeCreate: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[.editedImage] as? UIImage {
            // imageViewPic.contentMode = .scaleToFill
            coverPic.image = pickedImage
            //self.uploadToServer(image: pickedImage)
            coverDisplay(isCoverDisplay: true)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func uploadToServer(image:UIImage)
    {
        //        let base64Image = image.convertImageToBase64String()
        //        //print(base64Image)
        //
        //        let parameters:Parameters = ["image":base64Image]
        //        loadRequest(method:.post, apiName:"auth/setprofilepic", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
        //            switch result {
        //            case .failure(let error):
        //                print(error)
        //                ProgressHUD.dismiss()
        //
        //            case .success(let responseObject):
        //                let json = JSON(responseObject)
        //                print("SUCCESS UPLOAD\(json)")
        //
        //                self.loadProfile()
        //                //self.userPic.image = image
        //                //self.submitSuccess()
        //            }
        //        }
        
    }
}

