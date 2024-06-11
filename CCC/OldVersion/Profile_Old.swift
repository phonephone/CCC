////
////  Profile.swift
////  CCC
////
////  Created by Truk Karawawattana on 9/1/2565 BE.
////
//
//import UIKit
//import Alamofire
//import SwiftyJSON
//import ProgressHUD
//import AVFoundation
//import Photos
//
//enum ProfileMode {
//    case register
//    case edit
//}
//
//class Profile: UIViewController, UITextFieldDelegate, UITextViewDelegate {
//
//    var profileMode: ProfileMode?
//
//    var provinceJSON:JSON?
//    var amphurJSON:JSON?
//    var tumbonJSON:JSON?
//    var selectedGender = "male"
//    var selectedProvinceID = ""
//    var selectedAmphureID = ""
//    var selectedTumbonID = ""
//
//    var selectedImage: UIImage?
//
//    @IBOutlet weak var userPic: UIImageView!
//    @IBOutlet weak var fullNameField: UITextField!
//    @IBOutlet weak var idNoField: UITextField!
//    @IBOutlet weak var occupationField: UITextField!
//    @IBOutlet weak var workNameField: UITextField!
//    @IBOutlet weak var birthDayField: UITextField!
//    @IBOutlet weak var genderField: UITextField!
//    @IBOutlet weak var emailField: UITextField!
//    @IBOutlet weak var telField: UITextField!
//    @IBOutlet weak var provinceField: UITextField!
//    @IBOutlet weak var amphurField: UITextField!
//    @IBOutlet weak var tumbonField: UITextField!
//    @IBOutlet weak var heightField: UITextField!
//    @IBOutlet weak var weightField: UITextField!
//    @IBOutlet weak var sourceField: UITextView!
//    @IBOutlet weak var submitBtn: UIButton!
//
//    var birthDayPicker: UIDatePicker! = UIDatePicker()
//    var genderPicker: UIPickerView! = UIPickerView()
//    var provincePicker: UIPickerView! = UIPickerView()
//    var amphurPicker: UIPickerView! = UIPickerView()
//    var tumbonPicker: UIPickerView! = UIPickerView()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        print("PROFILE")
//        self.navigationController?.setStatusBar(backgroundColor: .themeColor)
//
//        setupField(field: fullNameField)
//        setupField(field: idNoField)
//        setupField(field: occupationField)
//        setupField(field: workNameField)
//        setupField(field: birthDayField)
//        setupField(field: genderField)
//        setupField(field: emailField)
//        setupField(field: telField)
//        setupField(field: provinceField)
//        setupField(field: amphurField)
//        setupField(field: tumbonField)
//        setupField(field: heightField)
//        setupField(field: weightField)
//
//        sourceField.delegate = self
//        sourceField.textContainerInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
//
//        datePickerSetup(picker: birthDayPicker)
//        birthDayField.inputView = birthDayPicker
//
//        pickerSetup(picker: genderPicker)
//        genderField.inputView = genderPicker
//
//        pickerSetup(picker: provincePicker)
//        provinceField.inputView = provincePicker
//
//        pickerSetup(picker: amphurPicker)
//        amphurField.inputView = amphurPicker
//
//        pickerSetup(picker: tumbonPicker)
//        tumbonField.inputView = tumbonPicker
//
//        if profileMode == .register {
//            submitBtn.setTitle("ลงทะเบียน", for: .normal)
//        }
//        else if profileMode == .edit {
//            submitBtn.setTitle("ปรับปรุงข้อมูล", for: .normal)
//        }
//
//        submitBtn.disableBtn()
//        loadProfile()
//
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
//        userPic.addGestureRecognizer(tapGestureRecognizer)
//        userPic.isUserInteractionEnabled = true
//    }
//
//    func pickerSetup(picker:UIPickerView) {
//        picker.delegate = self
//        picker.dataSource = self
//        picker.backgroundColor = .white
//        picker.setValue(UIColor.textDarkGray, forKeyPath: "textColor")
//    }
//
//    func datePickerSetup(picker:UIDatePicker) {
//        if #available(iOS 13.4, *) {
//            picker.preferredDatePickerStyle = .wheels
//        } else {
//            // Fallback on earlier versions
//        }
//
//        picker.datePickerMode = .date
//        picker.maximumDate = Date()
//        picker.calendar = Calendar(identifier: .buddhist)
//        picker.date = Date()
//        picker.locale = Locale(identifier: "th")
//        picker.addTarget(self, action: #selector(datePickerChanged(picker:)), for: .valueChanged)
//
//        picker.setValue(false, forKey: "highlightsToday")
//        picker.setValue(UIColor.white, forKeyPath: "backgroundColor")
//        picker.setValue(UIColor.textDarkGray, forKeyPath: "textColor")
//    }
//
//    @objc func datePickerChanged(picker: UIDatePicker) {
//        let selectDate = appStringFromDate(date: picker.date, format: "d MMMM yyyy")
//
//        if picker == birthDayPicker {
//            birthDayField.text = selectDate
//        }
//    }
//
//    func loadProfile() {
//
//        let parameters:Parameters = ["id":SceneDelegate.GlobalVariables.userID]
//        print(parameters)
//        loadRequest(method:.post, apiName:"get_profile", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
//            switch result {
//            case .failure(let error):
//                print(error)
//                ProgressHUD.dismiss()
//
//            case .success(let responseObject):
//                let json = JSON(responseObject)
//                print("SUCCESS PROFILE\(json)")
//
//                let profileArray = json["data"][0]
//
//                self.userPic.sd_setImage(with: URL(string:profileArray["pictureUrl"].stringValue), placeholderImage: UIImage(named: "icon_profile"))
//
//                self.fullNameField.text = profileArray["first_name"].stringValue
//                self.idNoField.text = profileArray["identity_number"].stringValue
//                //self.occupationField.text = profileArray["occupation"].stringValue
//                self.workNameField.text = profileArray["works_name"].stringValue
//
//                if let birthDate = self.dateFromServerString(dateStr: profileArray["birthday"].stringValue) {
//
//                    self.birthDayPicker.date = birthDate
//                    self.datePickerChanged(picker: self.birthDayPicker)
//                    //self.birthDayField.text = self.appStringFromDate(date: birthDate!, format: "d MMMM yyyy")
//                }
//
//                if profileArray["gender"].stringValue == "female"
//                {
//                    self.selectPicker(self.genderPicker, didSelectRow: 1)
//                    self.genderPicker.selectRow(1, inComponent: 0, animated: false)
//                }
//                else{
//                    self.selectPicker(self.genderPicker, didSelectRow: 0)
//                    self.genderPicker.selectRow(0, inComponent: 0, animated: false)
//                }
//
//                self.emailField.text = profileArray["email"].stringValue
//                self.telField.text = profileArray["mobile"].stringValue
//
//                self.selectedProvinceID = profileArray["province"].stringValue
//                self.selectedAmphureID = profileArray["district"].stringValue
//                self.selectedTumbonID = profileArray["sub_district"].stringValue
//                self.loadProvince(indexMatch: true)
//
//                self.heightField.text = profileArray["height"].stringValue
//                self.weightField.text = profileArray["weight"].stringValue
//                self.sourceField.text = profileArray["source"].stringValue
//            }
//        }
//    }
//
//    func loadProvince(indexMatch:Bool) {
//        provinceField.isUserInteractionEnabled = false
//        amphurField.isUserInteractionEnabled = false
//        tumbonField.isUserInteractionEnabled = false
//
//        let parameters:Parameters = [:]
//        print(parameters)
//        loadRequest(method:.post, apiName:"provinces", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
//            switch result {
//            case .failure(let error):
//                print(error)
//                ProgressHUD.dismiss()
//
//            case .success(let responseObject):
//                let json = JSON(responseObject)
//                //print("SUCCESS PROVINCE\(json)")
//
//                self.provinceJSON = json["data"]
//                self.provincePicker.reloadAllComponents()
//                self.provinceField.isUserInteractionEnabled = true
//
//                if indexMatch {
//                    for i in 0..<self.provinceJSON!.count{
//                        if self.provinceJSON![i]["id_provinces"].stringValue == self.selectedProvinceID {
//                            self.provinceField.text = self.provinceJSON![i]["name_th_provinces"].stringValue
//                            self.provincePicker.selectRow(i, inComponent: 0, animated: false)
//                            self.loadAmphur(indexMatch: true)
//                        }
//                    }
//                }
//
//            }
//        }
//    }
//
//    func loadAmphur(indexMatch:Bool) {
//        let parameters:Parameters = ["id_provinces":selectedProvinceID]
//        print(parameters)
//        loadRequest(method:.post, apiName:"amphures", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
//            switch result {
//            case .failure(let error):
//                print(error)
//                ProgressHUD.dismiss()
//
//            case .success(let responseObject):
//                let json = JSON(responseObject)
//                //print("SUCCESS AMPHUR\(json)")
//
//                self.amphurJSON = json["data"]
//                self.amphurPicker.reloadAllComponents()
//                self.amphurPicker.selectRow(0, inComponent: 0, animated: false)
//                self.amphurField.isUserInteractionEnabled = true
//
//                if indexMatch {
//                    for i in 0..<self.amphurJSON!.count{
//                        if self.amphurJSON![i]["id_amphures"].stringValue == self.selectedAmphureID {
//                            self.amphurField.text = self.amphurJSON![i]["name_th_amphures"].stringValue
//                            self.amphurPicker.selectRow(i, inComponent: 0, animated: false)
//                            self.loadTumbon(indexMatch: true)
//                        }
//                    }
//                }
//
//            }
//        }
//    }
//
//    func loadTumbon(indexMatch:Bool) {
//        let parameters:Parameters = ["id_amphures":selectedAmphureID]
//        print(parameters)
//        loadRequest(method:.post, apiName:"districts", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
//            switch result {
//            case .failure(let error):
//                print(error)
//                ProgressHUD.dismiss()
//
//            case .success(let responseObject):
//                let json = JSON(responseObject)
//                //print("SUCCESS TUMBON\(json)")
//
//                self.tumbonJSON = json["data"]
//                self.tumbonPicker.reloadAllComponents()
//                self.tumbonPicker.selectRow(0, inComponent: 0, animated: false)
//                self.tumbonField.isUserInteractionEnabled = true
//
//                if indexMatch {
//                    for i in 0..<self.tumbonJSON!.count{
//                        if self.tumbonJSON![i]["id_districts"].stringValue == self.selectedTumbonID {
//                            self.tumbonField.text = self.tumbonJSON![i]["name_th_districts"].stringValue
//                            self.tumbonPicker.selectRow(i, inComponent: 0, animated: false)
//                            self.updateSubmitBtn()
//                        }
//                    }
//                }
//
//            }
//        }
//    }
//
//    // MARK: - textField
//    func setupField(field:UITextField) {
//        field.delegate = self
//        field.returnKeyType = .next
//        field.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
//                                  for: .editingChanged)
//    }
//
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        if textField == birthDayField && birthDayField.text == "" {
//            datePickerChanged(picker: birthDayPicker)
//        }
//        else if textField == genderField && genderField.text == "" {
//            selectPicker(genderPicker, didSelectRow: 0)
//        }
//        else if textField == provinceField && provinceField.text == "" {
//            selectPicker(provincePicker, didSelectRow: 0)
//        }
//        else if textField == amphurField && amphurField.text == "" {
//            selectPicker(amphurPicker, didSelectRow: 0)
//        }
//        else if textField == tumbonField && tumbonField.text == "" {
//            selectPicker(tumbonPicker, didSelectRow: 0)
//        }
//    }
//
//    func textFieldDidEndEditing(_ textField: UITextField) {
//
//    }
//
//    @objc func textFieldDidChange(_ textField: UITextField) {
//        updateSubmitBtn()
//
//        if fullNameField.text == "888" {//Bypass Login
//            fullNameField.text = "นรุตม์ศรณ์ พรหมศิริ"
//            idNoField.text = "1160100057958"
//            occupationField.text = "Programmer"//not in api
//            workNameField.text = "TMA"
//            birthDayField.text = "1985-04-02"
//            genderField.text = "male"
//            emailField.text = "jae2@edfthai.org"
//            telField.text = "0957109509"
//            provinceField.text = "3"
//            amphurField.text = "58"
//            tumbonField.text = "120109"
//            heightField.text = "165"
//            weightField.text = "95"
//            sourceField.text = "Website"
//            submitBtn.enableBtn()
//        }
//    }
//
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        if textField == fullNameField {
//            idNoField.becomeFirstResponder()
//            return true
//        }
//        else if textField == idNoField {
//            occupationField.becomeFirstResponder()
//            return true
//        }
//        else if textField == occupationField {
//            workNameField.becomeFirstResponder()
//            return true
//        }
//        else if textField == workNameField {
//            birthDayField.becomeFirstResponder()
//            return true
//        }
//        else if textField == birthDayField {
//            genderField.becomeFirstResponder()
//            return true
//        }
//        else if textField == genderField {
//            emailField.becomeFirstResponder()
//            return true
//        }
//        else if textField == emailField {
//            telField.becomeFirstResponder()
//            return true
//        }
//        else if textField == telField {
//            provinceField.becomeFirstResponder()
//            return true
//        }
//        else if textField == provinceField {
//            amphurField.becomeFirstResponder()
//            return true
//        }
//        else if textField == amphurField {
//            tumbonField.becomeFirstResponder()
//            return true
//        }
//        else if textField == tumbonField {
//            heightField.becomeFirstResponder()
//            return true
//        }
//        else if textField == heightField {
//            weightField.becomeFirstResponder()
//            return true
//        }
//        else if textField == weightField {
//            sourceField.becomeFirstResponder()
//            return true
//        }
//        else {
//            return false
//        }
//    }
//
//    func updateSubmitBtn() {
//        if fullNameField.text!.count >= 1 && idNoField.text!.count >= 13 && birthDayField.text!.count >= 1 && genderField.text!.count >= 1 && isValidEmail(emailField.text!) && telField.text!.count >= 9 && provinceField.text!.count >= 1 && amphurField.text!.count >= 1 && tumbonField.text!.count >= 1 && heightField.text!.count >= 1 && weightField.text!.count >= 1 {
//            submitBtn.enableBtn()
//        }
//        else{
//            submitBtn.disableBtn()
//        }
//    }
//
//    func isValidEmail(_ email: String) -> Bool {
//        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
//
//        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
//        return emailPred.evaluate(with: email)
//    }
//
//    // MARK: - textView
//    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
//        return true
//    }
//
//    func textViewDidChange(_ textView: UITextView) {
//    }
//
//    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
//        return true
//    }
//
//    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
//    {
//        chooseImageSource()
//    }
//
//    func chooseImageSource()
//    {
//        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
//            self.checkPermission(camera: true)
//        }))
//        alert.actions.last?.titleTextColor = .themeColor
//
//        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
//            self.checkPermission(camera: false)
//        }))
//        alert.actions.last?.titleTextColor = .themeColor
//
//        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
//        alert.actions.last?.titleTextColor = .buttonRed
//
//        self.present(alert, animated: true, completion: nil)
//    }
//
//    func checkPermission(camera:Bool)
//    {
//        if camera == true {
//            //Camera Permission
//            AVCaptureDevice.requestAccess(for: AVMediaType.video) { success in
//                if success {
//                    //Camera access granted
//                    DispatchQueue.main.async {
//                        self.openCamera()
//                    }
//                } else {
//                    //No Camera access
//                    DispatchQueue.main.async {
//                        self.askPermission(camera: true)
//                    }
//                }
//            }
//        }
//        else{
//            //Photos Permission
//            let status = PHPhotoLibrary.authorizationStatus()
//            switch status {
//            case .authorized:
//                self.openGallery()
//
//            case .denied, .restricted :
//                askPermission(camera: false)
//
//            case .notDetermined:
//                // ask for permissions
//                PHPhotoLibrary.requestAuthorization { status in
//                    switch status {
//                    case .authorized:
//                        self.openGallery()
//                    case .denied, .restricted:
//                        self.askPermission(camera: false)
//                    case .notDetermined: // won't happen but still
//                        break
//                    case .limited:
//                        break
//                    @unknown default:
//                        break
//                    }
//                }
//
//            case .limited:
//                break
//            @unknown default:
//                break
//            }
//        }
//    }
//
//    func askPermission(camera:Bool)
//    {
//        if camera == true {//Camera
//            let alert = UIAlertController(title: "Your Camera Access Denied", message: "Please allow camera access to upload profile photo", preferredStyle: .alert)
//
//            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
//
//            }))
//            alert.actions.last?.titleTextColor = .buttonRed
//
//            alert.addAction(UIAlertAction(title: "Go to Setting", style: .default, handler: { action in
//
//                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
//            }))
//            alert.actions.last?.titleTextColor = .themeColor
//
//            self.present(alert, animated: true)
//        }
//        else{//Photo Library
//            let alert = UIAlertController(title: "Your Photo Library Access Denied", message: "Please allow photo library access to upload profile photo", preferredStyle: .alert)
//
//            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
//
//            }))
//            alert.actions.last?.titleTextColor = .buttonRed
//
//            alert.addAction(UIAlertAction(title: "Go to Setting", style: .default, handler: { action in
//
//                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
//            }))
//            alert.actions.last?.titleTextColor = .themeColor
//
//            self.present(alert, animated: true)
//        }
//    }
//
//    func openCamera()
//    {
//        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
//            let imagePicker = UIImagePickerController()
//            imagePicker.delegate = self
//            imagePicker.sourceType = UIImagePickerController.SourceType.camera
//            imagePicker.allowsEditing = true
//            self.present(imagePicker, animated: true, completion: nil)
//        }
//        else
//        {
//            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//        }
//    }
//
//    func openGallery()
//    {
//        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
//            DispatchQueue.main.async {
//                let imagePicker = UIImagePickerController()
//                imagePicker.delegate = self
//                imagePicker.allowsEditing = true
//                imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
//                self.present(imagePicker, animated: true, completion: nil)
//            }
//        }
//        else
//        {
//            let alert  = UIAlertController(title: "Warning", message: "You don't have permission to access gallery.", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//        }
//    }
//
//    @IBAction func cameraClick(_ sender: UIButton) {
//        chooseImageSource()
//    }
//
//    @IBAction func submitClick(_ sender: UIButton) {
//        loadSubmit()
//    }
//
//    func loadTestUpload() {
////        let parameters:Parameters = ["id":SceneDelegate.GlobalVariables.userID,
////                                     "username":userNameField.text!,
////                                     "first_name":fullNameField.text!,
////                                     "identity_number":idNoField.text!,
////                                     //"occupation":occupationField.text!,
////                                     "works_name":workNameField.text!,
////                                     "birthday":birthDayField.text!,
////                                     "gender":genderField.text!,
////                                     "email":emailField.text!,
////                                     "mobile":telField.text!,
////                                     "province":provinceField.text!,
////                                     "district":amphurField.text!,
////                                     "sub_district":tumbonField.text!,
////                                     "height":heightField.text!,
////                                     "weight":weightField.text!,
////                                     "source":sourceField.text!,
////        ]
//
////        let data = selectedImage!.jpegData(compressionQuality: 0.5)
////        // You can change your image name here, i use NSURL image and convert into string
////        //let imageURL = info[UIImagePickerControllerReferenceURL] as! NSURL
////        //let fileName = imageURL.absouluteString
////
////        AF.upload(multipartFormData: { multipartFormData in
////            for (key,value) in parameters {
////                multipartFormData.append((value as! String).data(using: .utf8)!, withName: key)
////            }
////            multipartFormData.append(data, withName: "pic", fileName: "profile_pic.jpg",mimeType: "image/jpeg")
////        },
////                  usingTreshold: UInt64.init(),
////                  to: "xxx",
////                  method: .post,
////                  encodingCompletion: { encodingResult in
////            switch encodingResult {
////            case .success(let upload, _, _):
////                upload.responJSON { response in
////                    debugPrint(response)
////                }
////            case .failure(let encodingError):
////                print(encodingError)
////            }
////        })
//
//
//
//        //if selectedImage != nil {
//        //            let imageData = UIImageJPEGRepresentation(selectedImage, 0.5)
//        //        }
//        //
//        //        AF.upload(multipartFormData: { multipartFormData in
//        //            multipartFormData.append(imageData,
//        //                                     withName: "imagefile",
//        //                                     fileName: "image.jpg",
//        //                                     mimeType: "image/jpeg")
//        //          },
//        //                           to: "http://api.imagga.com/v1/content",
//        //                           headers: ["Authorization": "Basic xxx"],
//        //                           encodingCompletion: { encodingResult in
//        //            switch encodingResult {
//        //            case .success(let upload, _, _):
//        //              upload.uploadProgress { progress in
//        //                progressCompletion(Float(progress.fractionCompleted))
//        //              }
//        //              upload.validate()
//        //              upload.responseJSON { response in
//        //                  // 1
//        //                  guard response.result.isSuccess,
//        //                    let value = response.result.value else {
//        //                      print("Error while uploading file: \(String(describing: response.result.error))")
//        //                      completion(nil, nil)
//        //                      return
//        //                  }
//        //
//        //                  // 2
//        //                  let firstFileID = JSON(value)["uploaded"][0]["id"].stringValue
//        //                  print("Content uploaded with ID: \(firstFileID)")
//        //
//        //                  //3
//        //                  completion(nil, nil)
//        //              }
//        //            case .failure(let encodingError):
//        //              print(encodingError)
//        //            }
//        //          })
//
//    }
//
//    func loadSubmit() {
//
//
//
//        var parameters:Parameters = ["id":SceneDelegate.GlobalVariables.userID,
//                                     "first_name":fullNameField.text!,
//                                     "identity_number":idNoField.text!,
//                                     "occupation":occupationField.text!,
//                                     "works_name":workNameField.text!,
//                                     "birthday":dateToServerString(date: birthDayPicker.date), //birthDayField.text!,
//                                     "gender":selectedGender, //genderField.text!,
//                                     "email":emailField.text!,
//                                     "mobile":telField.text!,
//                                     "province":selectedProvinceID, //provinceField.text!,
//                                     "district":selectedAmphureID, //amphurField.text!,
//                                     "sub_district":selectedTumbonID, //tumbonField.text!,
//                                     "height":heightField.text!,
//                                     "weight":weightField.text!,
//                                     "source":sourceField.text!,
//        ]
//        if selectedImage != nil {
//            let base64Image = selectedImage!.convertImageToBase64String()
//            parameters.updateValue(base64Image, forKey: "pic")
//        }
//
//        print(parameters)
//        loadRequest(method:.post, apiName:"update_profile", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
//            switch result {
//            case .failure(let error):
//                print(error)
//                ProgressHUD.dismiss()
//
//            case .success(let responseObject):
//                let json = JSON(responseObject)
//                print("UPDATE PROFILE\(json)")
//
//                self.submitSuccess()
//
//                if self.profileMode == .register {
//                    UserDefaults.standard.set(true, forKey: "loginStatus")
//                    self.switchToHome()
//                }
//            }
//        }
//    }
//
//    @IBAction func back(_ sender: UIButton) {
//        self.navigationController!.popViewController(animated: true)
//    }
//}
//
//// MARK: - UIImagePickerControllerDelegate
//
//extension Profile: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//
//        if let pickedImage = info[.editedImage] as? UIImage {
//            // imageViewPic.contentMode = .scaleToFill
//            selectedImage = pickedImage
//            userPic.image = selectedImage
//            //self.uploadToServer(image: pickedImage)
//            updateSubmitBtn()
//        }
//        picker.dismiss(animated: true, completion: nil)
//    }
//
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        picker.dismiss(animated: true, completion: nil)
//    }
//
//    func uploadToServer(image:UIImage)
//    {
//        //        let base64Image = image.convertImageToBase64String()
//        //        //print(base64Image)
//        //
//        //        let parameters:Parameters = ["image":base64Image]
//        //        loadRequest(method:.post, apiName:"auth/setprofilepic", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
//        //            switch result {
//        //            case .failure(let error):
//        //                print(error)
//        //                ProgressHUD.dismiss()
//        //
//        //            case .success(let responseObject):
//        //                let json = JSON(responseObject)
//        //                print("SUCCESS UPLOAD\(json)")
//        //
//        //                self.loadProfile()
//        //                //self.userPic.image = image
//        //                //self.submitSuccess()
//        //            }
//        //        }
//
//    }
//}
//
//
//// MARK: - Picker Datasource
//extension Profile: UIPickerViewDataSource {
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//
//        if pickerView == genderPicker {
//            return 2
//        }
//        else if pickerView == provincePicker && provinceJSON != nil {
//            return provinceJSON!.count
//        }
//        else if pickerView == amphurPicker && amphurJSON != nil{
//            return amphurJSON!.count
//        }
//        else if pickerView == tumbonPicker && tumbonJSON != nil{
//            return tumbonJSON!.count
//        }
//        else{
//            return 0
//        }
//    }
//
//    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
//        var pickerLabel: UILabel? = (view as? UILabel)
//        if pickerLabel == nil {
//            pickerLabel = UILabel()
//            pickerLabel?.font = .Prompt_Regular(ofSize: 20)
//            pickerLabel?.textAlignment = .center
//        }
//
//        if pickerView == genderPicker {
//            if row == 0 {
//                pickerLabel?.text = "ชาย"
//            }
//            else{
//                pickerLabel?.text = "หญิง"
//            }
//        }
//        else if pickerView == provincePicker && provinceJSON!.count > 0{
//            pickerLabel?.text = provinceJSON![row]["name_th_provinces"].stringValue
//        }
//        else if pickerView == amphurPicker && amphurJSON!.count > 0{
//            pickerLabel?.text = amphurJSON![row]["name_th_amphures"].stringValue
//        }
//        else if pickerView == tumbonPicker && tumbonJSON!.count > 0{
//            pickerLabel?.text = tumbonJSON![row]["name_th_districts"].stringValue
//        }
//        else{
//            pickerLabel?.text = ""
//        }
//
//        pickerLabel?.textColor = .textDarkGray
//
//        return pickerLabel!
//    }
//
//    /*
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        if pickerView == typePicker && leaveJSON!.count > 0{
//            return leaveJSON![row]["category_name_en"].stringValue
//        }
//        else if pickerView == headPicker && headJSON!.count > 0{
//            return "\(headJSON![row]["first_name"].stringValue) \(headJSON![row]["last_name"].stringValue)"
//        }
//        else{
//            return ""
//        }
//    }
// */
//}
//
//// MARK: - Picker Delegate
//extension Profile: UIPickerViewDelegate {
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
//    {
//        print("Select \(row)")
//        selectPicker(pickerView, didSelectRow: row)
//    }
//
//    func selectPicker(_ pickerView: UIPickerView, didSelectRow row: Int) {
//        if pickerView == genderPicker {
//            if row == 0 {
//                genderField.text = "ชาย"
//                selectedGender = "male"
//            }
//            else{
//                genderField.text = "หญิง"
//                selectedGender = "female"
//            }
//        }
//        else if pickerView == provincePicker {
//            provinceField.text = provinceJSON![row]["name_th_provinces"].stringValue
//            selectedProvinceID = provinceJSON![row]["id_provinces"].stringValue
//
//            self.amphurField.isUserInteractionEnabled = false
//            amphurField.text = ""
//            selectedAmphureID = ""
//            loadAmphur(indexMatch: false)
//
//            self.tumbonField.isUserInteractionEnabled = false
//            tumbonField.text = ""
//            selectedTumbonID = ""
//            tumbonJSON = nil
//        }
//        else if pickerView == amphurPicker {
//            amphurField.text = amphurJSON![row]["name_th_amphures"].stringValue
//            selectedAmphureID = amphurJSON![row]["id_amphures"].stringValue
//
//            self.tumbonField.isUserInteractionEnabled = false
//            tumbonField.text = ""
//            selectedTumbonID = ""
//            loadTumbon(indexMatch: false)
//        }
//        else if pickerView == tumbonPicker {
//            tumbonField.text = tumbonJSON![row]["name_th_districts"].stringValue
//            selectedTumbonID = tumbonJSON![row]["id_districts"].stringValue
//        }
//
//        updateSubmitBtn()
//    }
//}
//
