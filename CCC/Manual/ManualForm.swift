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
    var iamgeProcessJSON : JSON?
    
    var manualActivity:ManualActivity?
    
    var durationMinute:Float = 0
    var distanceMeter:Float = 0
    var distanceKiloMeter:Float = 0
    var calPerMinute:Float = 0
    var summaryCal:Float = 0
    
    var minuteArray:[Int] = []
    
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
    
    var minutePicker: UIPickerView! = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("MANUAL FORM")
        
        print(SceneDelegate.GlobalVariables.userHeight)
        print(SceneDelegate.GlobalVariables.userWeight)
        
        manualPic.sd_setImage(with: URL(string:manualJSON!["icon"].stringValue), placeholderImage: UIImage(named: "icon_1024"))
        manualName.text = manualJSON!["act_name_th"].stringValue
        
        for i in 1...60{
            minuteArray.append(i)
        }
        
        timeField.delegate = self
        pickerSetup(picker: minutePicker)
        timeField.inputView = minutePicker
//        timeField.addTarget(self, action: #selector(self.textFieldDidChange(_:)),for: .editingChanged)
//        
//        distancefield.delegate = self
//        distancefield.addTarget(self, action: #selector(self.textFieldDidChange(_:)),for: .editingChanged)
        
        tiredLabel.isHidden = true
        
        switch manualJSON!["act_id"].stringValue {
        case "4"://วิ่ง
            manualActivity = .run
            distanceStack.isHidden = true
            
        case "11"://เดิน
            manualActivity = .walk
            distanceStack.isHidden = true
            
        case "12"://ปั่น
            manualActivity = .cycling
            distanceStack.isHidden = true
            
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
    
    func pickerSetup(picker:UIPickerView) {
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = .white
        picker.setValue(UIColor.textDarkGray, forKeyPath: "textColor")
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == timeField && timeField.text == "" {
            selectPicker(minutePicker, didSelectRow: 0)
        }
        
        if textField == timeField {
            //timeField.text = String(format: "%.0f", durationMinute)
        }
        else if textField == distancefield {
            //distancefield.text = String(format: "%.2f", distanceKiloMeter)
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        clearBtn()
        
        if textField == timeField {
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
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        //        if manualActivity == .other {
        //            if timeField.text == "" {
        //                durationMinute = 0
        //                calLabel.text = "0"
        //            }
        //            else{
        //                let minute:Float? = Float(timeField.text!)
        //                durationMinute = minute!
        //                //timeField.text = String(format: "%.0f นาที", durationMinute)
        //                calculateSummaryCal()
        //            }
        //            updateBtn()
        //        }
        //        else {//เดิน,วิ่ง,ปั่น
        //            if textField == timeField {
        //                if timeField.text == "" {
        //                    durationMinute = 0
        //                    tiredLabel.isHidden = true
        //                }
        //                else {
        //                    let minute:Float? = Float(timeField.text!)
        //                    durationMinute = minute!
        //                    //timeField.text = String(format: "%.0f นาที", durationMinute)
        //                }
        //            }
        //            else if textField == distancefield {
        //                if distancefield.text == "" {
        //                    distanceKiloMeter = 0.00
        //                    distanceMeter = 0
        //                    tiredLabel.isHidden = true
        //                }
        //                else {
        //                    let meter:Float? = Float(distancefield.text!)
        //                    distanceKiloMeter = meter!
        //                    distanceMeter = distanceKiloMeter*1000
        //                    //distancefield.text = String(format: "%.2f กิโลเมตร", distanceKiloMeter)
        //                }
        //            }
        //
        //            if timeField.text == "" || distancefield.text == "" {
        //                calLabel.text = "0"
        //            }
        //            else{
        //                calculateSummaryCal()
        //            }
        //            updateBtn()
        //        }
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
                //                if averageDistance >= 5.2 {
                //                    calPerMinute = 4.30
                //                    tiredLabel.text = tiredLevelHigh
                //                }
                //                else if averageDistance > 3.0 {
                //                    calPerMinute = 3.50
                //                    tiredLabel.text = tiredLevelMedium
                //                }
                //                else if averageDistance <= 3.0 {
                //                    calPerMinute = 2.50
                //                    tiredLabel.text = tiredLevelLow
                //                }
                calPerMinute = 3.50
                tiredLabel.text = tiredLevelMedium
                
            case .run:
                //                if averageDistance >= 9.7 {
                //                    calPerMinute = 9.80
                //                    tiredLabel.text = tiredLevelHigh
                //                }
                //                else if averageDistance > 6.7 {
                //                    calPerMinute = 8.30
                //                    tiredLabel.text = tiredLevelMedium
                //                }
                //                else if averageDistance <= 6.7 {
                //                    calPerMinute = 7.00
                //                    tiredLabel.text = tiredLevelLow
                //                }
                calPerMinute = 8.30
                tiredLabel.text = tiredLevelMedium
                
            case .cycling:
                //                if averageDistance >= 19.3 {
                //                    calPerMinute = 8.00
                //                    tiredLabel.text = tiredLevelHigh
                //                }
                //                else if averageDistance > 8.9 {
                //                    calPerMinute = 5.80
                //                    tiredLabel.text = tiredLevelMedium
                //                }
                //                else if averageDistance <= 8.9 {
                //                    calPerMinute = 3.50
                //                    tiredLabel.text = tiredLevelLow
                //                }
                calPerMinute = 5.80
                tiredLabel.text = tiredLevelMedium
                
            default:
                break
            }
            //tiredLabel.isHidden = false
        }
        summaryCal = Float((durationMinute/60)*calPerMinute*weight)
        calLabel.text = String(format: "%.0f", summaryCal)
    }
    
    func updateBtn() {
        if timeField.text != "" && selectedImage != nil {
            submitBtn.enableBtn()
        }
        else{
            submitBtn.disableBtn()
        }
        
        //        if manualActivity == .other {
        //            if timeField.text != "" && selectedImage != nil {
        //                submitBtn.enableBtn()
        //            }
        //            else{
        //                submitBtn.disableBtn()
        //            }
        //        }
        //        else {//เดิน,วิ่ง,ปั่น
        //            if timeField.text != "" && distancefield.text != "" && selectedImage != nil {
        //                submitBtn.enableBtn()
        //            }
        //            else{
        //                submitBtn.disableBtn()
        //            }
        //        }
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
                            message: nil,//"1. จำนวนแคลอรีของแต่ละกิจกรรมใช้ตัวเลขเฉลี่ย เพื่อให้จดจำง่าย ซึ่งใกล้เคียงกับตัวเลขจริง\n2. แนบรูปหลักฐานการออกกำลังกายด้วยทุกครั้ง",
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
                
                SceneDelegate.GlobalVariables.reloadHome = true
                SceneDelegate.GlobalVariables.reloadMyCalory = true
                SceneDelegate.GlobalVariables.reloadCredit = true
                
                let vc = UIStoryboard.manualStoryBoard.instantiateViewController(withIdentifier: "ManualComplete") as! ManualComplete
                self.navigationController!.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
}

// MARK: - Picker Datasource
extension ManualForm: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return minuteArray.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(minuteArray[row])
    }
}

// MARK: - Picker Delegate
extension ManualForm: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        print("Select \(row)")
        selectPicker(pickerView, didSelectRow: row)
    }

    func selectPicker(_ pickerView: UIPickerView, didSelectRow row: Int) {
        if pickerView == minutePicker {
            timeField.text = String(minuteArray[row])
            
            durationMinute = Float(minuteArray[row])
            calculateSummaryCal()
            updateBtn()
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension ManualForm: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func chooseImageSource()
    {
        DispatchQueue.main.async {
            AttachmentHandler.shared.showAttachmentActionSheet(vc: self, allowEdit: true)
            AttachmentHandler.shared.imagePickedBlock = { (image) in
                self.selectedImage = image
                self.sharePic.image = image
                self.sharePic.isHidden = false
                
                self.updateBtn()
                
                let imageProcessUrl = self.manualJSON!["url"].stringValue
                if imageProcessUrl != "" {
                    self.loadImageProcess(apiPath:imageProcessUrl, withImage: image)
                }
            }
        }
    }
    
    func loadImageProcess(apiPath:String, withImage:UIImage?) {
        
        loadingHUD()
        
        var parameters:Parameters = [:]
        if withImage != nil {
            let base64Image = selectedImage!.convertImageToBase64String()
            parameters.updateValue(base64Image, forKey: "base64str")
        }
        
        AF.request(apiPath,
                   method: .post,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   headers: HTTPHeaders.header,
                   requestModifier: { $0.timeoutInterval = 60 }
        ).responseJSON { response in
            
            //debugPrint(response)
            
            switch response.result {
            case .success(let data as AnyObject):
                
                let json = JSON(data)
                print("IMAGE PROCESS\(json)")
                
                if json["message"] == "success" {
                    
                    let durationFromImage = json["data"]["tm"].stringValue
                    if durationFromImage != "" {
                        self.autofillAsk(duration: durationFromImage)
                    }
                    ProgressHUD.dismiss()
                }
                else{
                    //ProgressHUD.showError(json["message"].stringValue)
                    ProgressHUD.dismiss()
                }
                
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            default:
                fatalError("received non-dictionary JSON response")
            }
        }
    }
    
    func autofillAsk(duration:String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let date = dateFormatter.date(from: duration)
        print(date ?? "")
        
        let calendar = Calendar.current
        let comp = calendar.dateComponents([.hour, .minute], from: date!)
        let hour = comp.hour ?? 0
        let minute = comp.minute ?? 0
        print(hour)
        let finalMinute:Int = (hour * 60) + minute
        print(finalMinute)
        
        self.durationMinute = Float(finalMinute)
        self.timeField.text = String(finalMinute)
        self.calculateSummaryCal()
        self.updateBtn()
        
//        SwiftAlertView.show(title: "เปลี่ยนเวลาออกกำลังกาย",
//                            message: "เป็น \(finalMinute) นาที",
//                            buttonTitles: "ยกเลิก", "ยืนยัน") { alert in
//            //alert.backgroundColor = .yellow
//            alert.titleLabel.font = .Alert_Title
//            alert.messageLabel.font = .Alert_Message
//            alert.messageLabel.textAlignment = .left
//            alert.cancelButtonIndex = 0
//            alert.button(at: 0)?.titleLabel?.font = .Alert_Button
//            alert.button(at: 0)?.setTitleColor(.buttonRed, for: .normal)
//            
//            alert.button(at: 1)?.titleLabel?.font = .Alert_Button
//            alert.button(at: 1)?.setTitleColor(.themeColor, for: .normal)
//            //            alert.buttonTitleColor = .themeColor
//        }
//                            .onButtonClicked { _, buttonIndex in
//                                print("Button Clicked At Index \(buttonIndex)")
//                                switch buttonIndex{
//                                case 1:
//                                    self.durationMinute = Float(finalMinute)
//                                    self.timeField.text = String(finalMinute)
//                                    
//                                default:
//                                    break
//                                }
//                                
//                                self.calculateSummaryCal()
//                                self.updateBtn()
//                            }
    }
}
