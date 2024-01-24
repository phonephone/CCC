//
//  ManualForm.swift
//  CCC
//
//  Created by Truk Karawawattana on 21/1/2565 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import AVFoundation
import Photos
import SwiftAlertView

enum ManualActivity {
    case run
    case walk
    case cycling
    case other
}

class ManualForm: UIViewController, UITextFieldDelegate {
    
    var manualJSON : JSON?
    
    var manualActivity:ManualActivity?
    
    var durationMinute:Float = 0
    var distanceMeter:Float = 0
    var distanceKiloMeter:Float = 0
    var calPerMinute:Float = 0
    var summaryCal:Float = 0
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var manualPic: UIImageView!
    @IBOutlet weak var manualName: UILabel!
    @IBOutlet weak var time15Btn: UIButton!
    @IBOutlet weak var time30Btn: UIButton!
    @IBOutlet weak var time60Btn: UIButton!
    @IBOutlet weak var time90Btn: UIButton!
    @IBOutlet weak var timeField: UITextField!
    
    @IBOutlet weak var distanceStack: UIStackView!
    @IBOutlet weak var distancefield: UITextField!
    @IBOutlet weak var tiredLabel: UILabel!
    
    let tiredLevelLow = "เหนื่อยน้อย"
    let tiredLevelMedium = "เหนื่อยปานกลาง"
    let tiredLevelHigh = "เหนื่อยมาก"
    
    @IBOutlet weak var calLabel: UILabel!
    
    var selectedImage: UIImage?
    @IBOutlet weak var sharePic: UIImageView!
    
    @IBOutlet weak var submitBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("MANUAL FORM")
        
        print(SceneDelegate.GlobalVariables.userHeight)
        print(SceneDelegate.GlobalVariables.userWeight)
        
        manualPic.sd_setImage(with: URL(string:manualJSON!["icon"].stringValue), placeholderImage: UIImage(named: "icon_1024"))
        manualName.text = manualJSON!["act_name_th"].stringValue
        
        timeField.delegate = self
        timeField.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                                  for: .editingChanged)
        
        distancefield.delegate = self
        distancefield.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                                  for: .editingChanged)
        
        tiredLabel.isHidden = true
        
        switch manualJSON!["act_id"].stringValue {
        case "4"://วิ่ง
            manualActivity = .run
            distanceStack.isHidden = false
            
        case "11"://เดิน
            manualActivity = .walk
            distanceStack.isHidden = false
            
        case "12"://ปั่น
            manualActivity = .cycling
            distanceStack.isHidden = false
            
        default:
            manualActivity = .other
            distanceStack.isHidden = true
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        sharePic.addGestureRecognizer(tapGestureRecognizer)
        sharePic.isUserInteractionEnabled = true
        sharePic.isHidden = true
        submitBtn.disableBtn()
        clearBtn()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == timeField {
            //timeField.text = String(format: "%.0f", durationMinute)
        }
        else if textField == distancefield {
            //distancefield.text = String(format: "%.2f", distanceKiloMeter)
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        clearBtn()
        calLabel.text = "0"
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if manualActivity == .other {
            if timeField.text == "" {
                durationMinute = 0
                calLabel.text = "0"
            }
            else{
                let minute:Float? = Float(timeField.text!)
                durationMinute = minute!
                //timeField.text = String(format: "%.0f นาที", durationMinute)
                calculateSummaryCal()
            }
            updateBtn()
        }
        else {//เดิน,วิ่ง,ปั่น
            if textField == timeField {
                if timeField.text == "" {
                    durationMinute = 0
                    tiredLabel.isHidden = true
                }
                else {
                    let minute:Float? = Float(timeField.text!)
                    durationMinute = minute!
                    //timeField.text = String(format: "%.0f นาที", durationMinute)
                }
            }
            else if textField == distancefield {
                if distancefield.text == "" {
                    distanceKiloMeter = 0.00
                    distanceMeter = 0
                    tiredLabel.isHidden = true
                }
                else {
                    let meter:Float? = Float(distancefield.text!)
                    distanceKiloMeter = meter!
                    distanceMeter = distanceKiloMeter*1000
                    //distancefield.text = String(format: "%.2f กิโลเมตร", distanceKiloMeter)
                }
            }
            
            if timeField.text == "" || distancefield.text == "" {
                calLabel.text = "0"
            }
            else{
                calculateSummaryCal()
            }
            updateBtn()
        }
    }
    
    func clearBtn() {
        time15Btn.setTitleColor(UIColor.textDarkGray, for: .normal)
        time30Btn.setTitleColor(UIColor.textDarkGray, for: .normal)
        time60Btn.setTitleColor(UIColor.textDarkGray, for: .normal)
        time90Btn.setTitleColor(UIColor.textDarkGray, for: .normal)
        
        time15Btn.backgroundColor = .white
        time30Btn.backgroundColor = .white
        time60Btn.backgroundColor = .white
        time90Btn.backgroundColor = .white
    }
    
    func calculateSummaryCal() {
        calPerMinute = manualJSON!["act_cal_per_min"].floatValue
        let weight = SceneDelegate.GlobalVariables.userWeight
        
        if manualActivity != .other {
            let averageDistance = (distanceMeter/(durationMinute*60)) * 3600/1000
            switch manualActivity {
            case .walk:
                if averageDistance >= 5.2 {
                    calPerMinute = 4.30
                    tiredLabel.text = tiredLevelHigh
                }
                else if averageDistance > 3.0 {
                    calPerMinute = 3.50
                    tiredLabel.text = tiredLevelMedium
                }
                else if averageDistance <= 3.0 {
                    calPerMinute = 2.50
                    tiredLabel.text = tiredLevelLow
                }
                
            case .run:
                if averageDistance >= 9.7 {
                    calPerMinute = 9.80
                    tiredLabel.text = tiredLevelHigh
                }
                else if averageDistance > 6.7 {
                    calPerMinute = 8.30
                    tiredLabel.text = tiredLevelMedium
                }
                else if averageDistance <= 6.7 {
                    calPerMinute = 7.00
                    tiredLabel.text = tiredLevelLow
                }
                
            case .cycling:
                if averageDistance >= 19.3 {
                    calPerMinute = 8.00
                    tiredLabel.text = tiredLevelHigh
                }
                else if averageDistance > 8.9 {
                    calPerMinute = 5.80
                    tiredLabel.text = tiredLevelMedium
                }
                else if averageDistance <= 8.9 {
                    calPerMinute = 3.50
                    tiredLabel.text = tiredLevelLow
                }
                
            default:
                break
            }
            tiredLabel.isHidden = false
        }
        summaryCal = Float((durationMinute/60)*calPerMinute*weight)
        calLabel.text = String(format: "%.0f", summaryCal)
    }
    
    func updateBtn() {
        if manualActivity == .other {
            if timeField.text != "" && selectedImage != nil {
                submitBtn.enableBtn()
            }
            else{
                submitBtn.disableBtn()
            }
        }
        else {//เดิน,วิ่ง,ปั่น
            if timeField.text != "" && distancefield.text != "" && selectedImage != nil {
                submitBtn.enableBtn()
            }
            else{
                submitBtn.disableBtn()
            }
        }
    }
    
    @IBAction func timeCick(_ sender: UIButton) {
        clearBtn()
        
        sender.setTitleColor(UIColor.white, for: .normal)
        sender.backgroundColor = .themeColor
        
        switch sender {
        case time15Btn:
            timeField.text = "15"
            durationMinute = 15
        case time30Btn:
            timeField.text = "30"
            durationMinute = 30
        case time60Btn:
            timeField.text = "60"
            durationMinute = 60
        case time90Btn:
            timeField.text = "90"
            durationMinute = 90
            
        default:
            break
        }
        calculateSummaryCal()
        updateBtn()
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        chooseImageSource()
    }
    
    @IBAction func cameraClick(_ sender: UIButton) {
        chooseImageSource()
    }
    
    @IBAction func submitClick(_ sender: UIButton) {
        confirmAsk()
    }
    
    func confirmAsk() {
        SwiftAlertView.show(title: "ยืนยันการส่งผลแบบกรอกเอง",
                            message: "1. จำนวนแคลอรีของแต่ละกิจกรรมใช้ตัวเลขเฉลี่ย เพื่อให้จดจำง่าย ซึ่งใกล้เคียงกับตัวเลขจริง\n2. แนบรูปหลักฐานการออกกำลังกายด้วยทุกครั้ง",
                            buttonTitles: "ยกเลิก", "ยืนยัน") { alert in
            //alert.backgroundColor = .yellow
            alert.titleLabel.font = .Alert_Title
            alert.messageLabel.font = .Alert_Message
            alert.messageLabel.textAlignment = .left
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
                                    self.loadSubmit()
                                default:
                                    break
                                }
                            }
    }
    
    func loadSubmit() {
        
        var parameters:Parameters = ["act_id":manualJSON!["act_id"].stringValue,
                                     "user_id":SceneDelegate.GlobalVariables.userID,
                                     "activity_time":String(format: "%.0f", durationMinute),
                                     "act_cal_per_min":String(format: "%.0f", calPerMinute),
                                     "distance":String(format: "%.0f", distanceMeter),
                                     "weight":String(format: "%.1f", SceneDelegate.GlobalVariables.userWeight) ,
                                     "summary_cal":String(format: "%.0f", summaryCal),
                                     "latitude":SceneDelegate.GlobalVariables.userLat,
                                     "longitude":SceneDelegate.GlobalVariables.userLong,
                                     
                                     "start_datetime":dateWithTimeToServerString(date: Date()),
                                     "end_datetime":dateWithTimeToServerString(date: Date()) ,
                                     "channel":"CCC Virtual",
                                     "os_system":"iOS",
                                     "os_version":UIDevice.current.systemVersion,
                                     "app_version":Bundle.main.appVersionLong,
                                     "mac_address":UIDevice.current.identifierForVendor?.uuidString ?? ""
        ]
        if selectedImage != nil {
            let base64Image = selectedImage!.convertImageToBase64String()
            parameters.updateValue(base64Image, forKey: "pic")
        }
        
        print(parameters)
        loadRequest_V2(method:.post, apiName:"send_activity_kcal", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS MANUAL SUBMIT\(json)")
                
                let vc = UIStoryboard.manualStoryBoard.instantiateViewController(withIdentifier: "ManualComplete") as! ManualComplete
                self.navigationController!.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate

extension ManualForm: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[.editedImage] as? UIImage {
            // imageViewPic.contentMode = .scaleToFill
            selectedImage = pickedImage
            sharePic.image = selectedImage
            sharePic.isHidden = false
            
            updateBtn()
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
