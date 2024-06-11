//
//  AttachmentHandler.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 17/11/2565 BE.
//

import Foundation
import UIKit
import MobileCoreServices
import AVFoundation
import Photos
import Localize_Swift

/*
 AttachmentHandler.shared.showAttachmentActionSheet(vc: self)
 
 AttachmentHandler.shared.imagePickedBlock = { (image) in
 /* get your image here */
 }
 
 AttachmentHandler.shared.videoPickedBlock = {(url) in
 /* get your compressed video url here */
 }
 
 AttachmentHandler.shared.filePickedBlock = {(filePath) in
 /* get your file path url here */
 }
 
 */

class AttachmentHandler: NSObject{
    static let shared = AttachmentHandler()
    fileprivate var currentVC: UIViewController?
    
    //MARK: - Internal Properties
    var imagePickedBlock: ((UIImage) -> Void)?
    var videoPickedBlock: ((NSURL) -> Void)?
    var filePickedBlock: ((URL) -> Void)?
    
    enum AttachmentType: String{
        case camera, video, photoLibrary
    }
    
    //MARK: - Constants
    struct Constants {
        static let actionFileTypeHeading = "Add a File"
        static let actionFileTypeDescription = "Choose a filetype to add..."
        static let camera = "Camera"
        static let phoneLibrary = "Photo Library"
        static let video = "Video"
        static let file = "File"
        
        
        static let alertForPhotoLibraryMessage = "App does not have access to your photos. To enable access, tap settings and turn on Photo Library Access."
        
        static let alertForCameraAccessMessage = "App does not have access to your camera. To enable access, tap settings and turn on Camera."
        
        static let alertForVideoLibraryMessage = "App does not have access to your video. To enable access, tap settings and turn on Video Library Access."
        
        
        static let settingsBtnTitle = "Settings"
        static let cancelBtnTitle = "Cancel"
    }
    
    //MARK: - showAttachmentActionSheet
    // This function is used to show the attachment sheet for image, video, photo and file.
    func showAttachmentActionSheet(vc: UIViewController, allowEdit: Bool) {
        currentVC = vc
        //let actionSheet = UIAlertController(title: Constants.actionFileTypeHeading, message: Constants.actionFileTypeDescription, preferredStyle: .actionSheet)
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera".localized(), style: .default, handler: { (action) -> Void in
            self.authorisationStatusCamera(attachmentTypeEnum: .camera, vc: self.currentVC!, allowEdit: allowEdit)
        }))
        actionSheet.actions.last?.titleTextColor = .themeColor
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library".localized(), style: .default, handler: { (action) -> Void in
            self.authorisationStatusPhotoLibrary(attachmentTypeEnum: .photoLibrary, vc: self.currentVC!, allowEdit: allowEdit)
        }))
        actionSheet.actions.last?.titleTextColor = .themeColor
        
        //        actionSheet.addAction(UIAlertAction(title: Constants.video, style: .default, handler: { (action) -> Void in
        //            self.authorisationStatus(attachmentTypeEnum: .video, vc: self.currentVC!)
        //
        //        }))
        //
        //        actionSheet.addAction(UIAlertAction(title: Constants.file, style: .default, handler: { (action) -> Void in
        //            self.documentPicker()
        //        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil))
        actionSheet.actions.last?.titleTextColor = .buttonRed
        
        vc.present(actionSheet, animated: true, completion: nil)
    }
    
    func showCameraOnly(vc: UIViewController, allowEdit: Bool) {
        currentVC = vc
        self.authorisationStatusCamera(attachmentTypeEnum: .camera, vc: self.currentVC!, allowEdit: allowEdit)
    }
    
    func showPhotoLibraryOnly(vc: UIViewController, allowEdit: Bool) {
        currentVC = vc
        self.authorisationStatusPhotoLibrary(attachmentTypeEnum: .photoLibrary, vc: self.currentVC!, allowEdit: allowEdit)
    }
    
    //MARK: - Authorisation Status
    // This is used to check the authorisation status whether user gives access to import the image, photo library, video.
    // if the user gives access, then we can import the data safely
    // if not show them alert to access from settings.
    
    func authorisationStatusCamera(attachmentTypeEnum: AttachmentType, vc: UIViewController, allowEdit: Bool){
        currentVC = vc
        
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        
        switch status {
        case .authorized:
            if attachmentTypeEnum == AttachmentType.camera{
                openCamera(allowEdit: allowEdit)
            }
        case .denied:
            print("permission denied")
            self.addAlertForSettings(attachmentTypeEnum)
        case .notDetermined:
            print("Permission Not Determined")
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
                DispatchQueue.main.sync {
                    if granted {
                        print("Camera access given")
                        if attachmentTypeEnum == AttachmentType.camera{
                            self.openCamera(allowEdit: allowEdit)
                        }
                    } else {
                        print("Camera restriced manually")
                        self.addAlertForSettings(attachmentTypeEnum)
                    }
                }
            }
        case .restricted:
            print("permission restricted")
            self.addAlertForSettings(attachmentTypeEnum)
        default:
            break
        }
    }
    
    func authorisationStatusPhotoLibrary(attachmentTypeEnum: AttachmentType, vc: UIViewController, allowEdit: Bool){
        currentVC = vc
        
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized:
            if attachmentTypeEnum == AttachmentType.photoLibrary{
                photoLibrary(allowEdit: allowEdit)
            }
            if attachmentTypeEnum == AttachmentType.video{
                videoLibrary()
            }
        case .denied:
            print("permission denied")
            self.addAlertForSettings(attachmentTypeEnum)
        case .notDetermined:
            print("Permission Not Determined")
            PHPhotoLibrary.requestAuthorization({ (status) in
                DispatchQueue.main.sync {
                    if status == PHAuthorizationStatus.authorized{
                        // photo library access given
                        print("Photo Library access given")
                        if attachmentTypeEnum == AttachmentType.photoLibrary{
                            self.photoLibrary(allowEdit: allowEdit)
                        }
                        if attachmentTypeEnum == AttachmentType.video{
                            self.videoLibrary()
                        }
                    }else{
                        print("Photo Library restriced manually")
                        self.addAlertForSettings(attachmentTypeEnum)
                    }
                }
            })
        case .restricted:
            print("permission restricted")
            self.addAlertForSettings(attachmentTypeEnum)
        default:
            break
        }
    }
    
    
    //MARK: - CAMERA PICKER
    //This function is used to open camera from the iphone and
    func openCamera(allowEdit: Bool){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self
            myPickerController.sourceType = .camera
            myPickerController.allowsEditing = allowEdit
            currentVC?.present(myPickerController, animated: true, completion: nil)
        }
    }
    
    
    //MARK: - PHOTO PICKER
    func photoLibrary(allowEdit: Bool){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self
            myPickerController.sourceType = .photoLibrary
            myPickerController.allowsEditing = allowEdit
            currentVC?.present(myPickerController, animated: true, completion: nil)
        }
    }
    
    //MARK: - VIDEO PICKER
    func videoLibrary(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self
            myPickerController.sourceType = .photoLibrary
            myPickerController.mediaTypes = [kUTTypeMovie as String, kUTTypeVideo as String]
            currentVC?.present(myPickerController, animated: true, completion: nil)
        }
    }
    
    //MARK: - FILE PICKER
    func documentPicker(){
        let importMenu = UIDocumentPickerViewController(documentTypes: [String(kUTTypePDF)], in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        currentVC?.present(importMenu, animated: true, completion: nil)
    }
    
    //MARK: - SETTINGS ALERT
    func addAlertForSettings(_ attachmentTypeEnum: AttachmentType){
        var alertTitle: String = ""
        if attachmentTypeEnum == AttachmentType.camera{
            alertTitle = "CAMERA_Allow".localized()//Constants.alertForCameraAccessMessage
        }
        if attachmentTypeEnum == AttachmentType.photoLibrary{
            alertTitle = "PHOTO_Allow".localized()//Constants.alertForPhotoLibraryMessage
        }
        if attachmentTypeEnum == AttachmentType.video{
            alertTitle = Constants.alertForVideoLibraryMessage
        }
        
        let cameraUnavailableAlertController = UIAlertController (title: alertTitle , message: nil, preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "GO_Setting".localized(), style: .destructive) { (_) -> Void in
            let settingsUrl = NSURL(string:UIApplication.openSettingsURLString)
            if let url = settingsUrl {
                UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .default, handler: nil)
        cameraUnavailableAlertController .addAction(cancelAction)
        cameraUnavailableAlertController .addAction(settingsAction)
        
        DispatchQueue.main.async {
            self.currentVC?.present(cameraUnavailableAlertController , animated: true, completion: nil)
        }
        
    }
}

//MARK: - IMAGE PICKER DELEGATE
// This is responsible for image picker interface to access image, video and then responsibel for canceling the picker
extension AttachmentHandler: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        currentVC?.dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage.rawValue] as? UIImage {
            self.imagePickedBlock?(image)
        }
        else if let image = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage {
            self.imagePickedBlock?(image)
        }
        else{
            print("Something went wrong in  image")
        }
        
        if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL.rawValue] as? NSURL{
            print("videourl: ", videoUrl)
            //trying compression of video
            let data = NSData(contentsOf: videoUrl as URL)!
            print("File size before compression: \(Double(data.length / 1048576)) mb")
            compressWithSessionStatusFunc(videoUrl)
        }
        else{
            print("Something went wrong in  video")
        }
        currentVC?.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Video Compressing technique
    fileprivate func compressWithSessionStatusFunc(_ videoUrl: NSURL) {
        let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".MOV")
        compressVideo(inputURL: videoUrl as URL, outputURL: compressedURL) { (exportSession) in
            guard let session = exportSession else {
                return
            }
            
            switch session.status {
            case .unknown:
                break
            case .waiting:
                break
            case .exporting:
                break
            case .completed:
                guard let compressedData = NSData(contentsOf: compressedURL) else {
                    return
                }
                print("File size after compression: \(Double(compressedData.length / 1048576)) mb")
                
                DispatchQueue.main.async {
                    self.videoPickedBlock?(compressedURL as NSURL)
                }
                
            case .failed:
                break
            case .cancelled:
                break
            @unknown default:
                fatalError()
            }
        }
    }
    
    // Now compression is happening with medium quality, we can change when ever it is needed
    func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPreset1280x720) else {
            handler(nil)
            
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mov
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously { () -> Void in
            handler(exportSession)
        }
    }
}

//MARK: - FILE IMPORT DELEGATE
extension AttachmentHandler: UIDocumentPickerDelegate{
    func documentMenu(_ documentMenu: UIDocumentPickerViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        currentVC?.present(documentPicker, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        print("url", url)
        self.filePickedBlock?(url)
    }
    
    //    Method to handle cancel action.
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        currentVC?.dismiss(animated: true, completion: nil)
    }
    
}
