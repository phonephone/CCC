//
//  Profile_2.swift
//  CCC
//
//  Created by Truk Karawawattana on 15/12/2566 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import AVFoundation
import Photos
import SkeletonView

enum ProfileMode {
    case register
    case edit
}

class Profile_2: UIViewController, UITextFieldDelegate {
    
    var profileMode: ProfileMode? = .edit
    
    var profileJSON:JSON?
    var occupationJSON:JSON?
    var genderJSON:JSON?
    var provinceJSON:JSON?
    var amphurJSON:JSON?
    var tumbonJSON:JSON?
    var informationJSON:JSON?
    var shirtJSON:JSON?
    
    var verifiedEmail = false
    
    var selectedOccupationID = ""
    var selectedGenderID = ""
    var selectedProvinceID = ""
    var selectedAmphurID = ""
    var selectedTumbonID = ""
    var selectedInformationID = ""
    var selectedShirtID = ""
    
    var maxAge = 100
    var defaultAge = 30
    
    var minHeight = 50
    var maxHeight = 250
    var defaultHeight = 150
    
    var minWeight = 20
    var maxWeight = 120
    var defaultWeight = 50
    
    var minWaist = 10
    var maxWaist = 100
    var defaultWaist = 25
    
    var selectedImage: UIImage?
    
    var firstTime = true
    
    @IBOutlet weak var myScrollView: UIScrollView!
    @IBOutlet weak var myStackView: UIStackView!
    
    @IBOutlet weak var userPic: UIImageView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var emailBtn: UIButton!
    @IBOutlet weak var telField: UITextField!
    @IBOutlet weak var fullNameField: UITextField!
    @IBOutlet weak var idNoField: UITextField!
    @IBOutlet weak var occupationField: UITextField!
    @IBOutlet weak var birthDayField: UITextField!
    @IBOutlet weak var genderField: UITextField!
    @IBOutlet weak var provinceField: UITextField!
    @IBOutlet weak var amphurField: UITextField!
    @IBOutlet weak var tumbonField: UITextField!
    @IBOutlet weak var heightField: UITextField!
    @IBOutlet weak var weightField: UITextField!
    @IBOutlet weak var waistField: UITextField!
    @IBOutlet weak var informationField: UITextField!
    @IBOutlet weak var sourceField: UITextField!
    @IBOutlet weak var shirtField: UITextField!
    @IBOutlet weak var submitBtn: UIButton!
    
    var blurView : UIVisualEffectView!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var popupImage: UIImageView!
    
    var occupationPicker: UIPickerView! = UIPickerView()
    var birthDayPicker = MyMonthYearPicker()
    var genderPicker: UIPickerView! = UIPickerView()
    var provincePicker: UIPickerView! = UIPickerView()
    var amphurPicker: UIPickerView! = UIPickerView()
    var tumbonPicker: UIPickerView! = UIPickerView()
    var heightPicker: UIPickerView! = UIPickerView()
    var weightPicker: UIPickerView! = UIPickerView()
    var waistPicker: UIPickerView! = UIPickerView()
    var informationPicker: UIPickerView! = UIPickerView()
    var shirtPicker: UIPickerView! = UIPickerView()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadProfile()
        
        firstTime = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("PROFILE_2")
        
        self.view.showAnimatedGradientSkeleton()
        
        self.navigationController?.setStatusBar(backgroundColor: .themeColor)
        
        myScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        
        setupField(field: emailField)
        setupField(field: telField)
        setupField(field: fullNameField)
        setupField(field: idNoField)
        setupField(field: occupationField)
        setupField(field: birthDayField)
        setupField(field: genderField)
        setupField(field: provinceField)
        setupField(field: amphurField)
        setupField(field: tumbonField)
        setupField(field: heightField)
        setupField(field: weightField)
        setupField(field: waistField)
        setupField(field: informationField)
        setupField(field: sourceField)
        setupField(field: shirtField)
        
        pickerSetup(picker: occupationPicker)
        occupationField.inputView = occupationPicker
        
        birthDayPicker.dataSource = birthDayPicker
        birthDayPicker.delegate = birthDayPicker
        birthDayPicker.backgroundColor = .white
        birthDayPicker.pickerMode = .year
        birthDayPicker.buildYearCollection(previous: maxAge, next: 0)
        NotificationCenter.default.addObserver(self, selector: #selector(myYearChanged(notification:)), name:.yearChanged, object: nil)
        
        birthDayField.inputView = birthDayPicker
        
        pickerSetup(picker: genderPicker)
        genderField.inputView = genderPicker
        
        pickerSetup(picker: provincePicker)
        provinceField.inputView = provincePicker
        
        pickerSetup(picker: amphurPicker)
        amphurField.inputView = amphurPicker
        amphurField.isUserInteractionEnabled = false
        
        pickerSetup(picker: tumbonPicker)
        tumbonField.inputView = tumbonPicker
        tumbonField.isUserInteractionEnabled = false
        
        pickerSetup(picker: heightPicker)
        heightField.inputView = heightPicker
        
        pickerSetup(picker: weightPicker)
        weightField.inputView = weightPicker
        
        pickerSetup(picker: waistPicker)
        waistField.inputView = waistPicker
        
        pickerSetup(picker: informationPicker)
        informationField.inputView = informationPicker
        
        pickerSetup(picker: shirtPicker)
        shirtField.inputView = shirtPicker
        
        sourceField.isHidden = true
        
        if profileMode == .register {
            submitBtn.setTitle("ลงทะเบียน", for: .normal)
        }
        else if profileMode == .edit {
            submitBtn.setTitle("ปรับปรุงข้อมูล", for: .normal)
        }
        emailBtn.isHidden = true
        emailField.isUserInteractionEnabled = true
        submitBtn.disableBtn()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        userPic.addGestureRecognizer(tapGestureRecognizer)
        userPic.isUserInteractionEnabled = true
        
        blurView = blurViewSetup()
        
        let popupWidth = self.view.bounds.width*0.9
        let popupHeight = self.view.bounds.height*0.8//popupWidth*1.5
        popupView.frame = CGRect(x: (self.view.bounds.width-popupWidth)/2, y: (self.view.bounds.height-popupHeight)/2, width: popupWidth, height: popupHeight)
    }
    
    func pickerSetup(picker:UIPickerView) {
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = .white
        picker.setValue(UIColor.textDarkGray, forKeyPath: "textColor")
    }
    
    func loadProfile() {
        
        let parameters:Parameters = ["id":SceneDelegate.GlobalVariables.userID]
        print(parameters)
        loadRequest(method:.post, apiName:"get_profile", authorization:true, showLoadingHUD:firstTime, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS PROFILE\(json)")
                
                self.profileJSON = json["data"][0]
                self.loadDropdown()
            }
        }
    }
    
    func loadDropdown() {
        let parameters:Parameters = ["id":SceneDelegate.GlobalVariables.userID]
        print(parameters)
        loadRequest(method:.get, apiName:"masterdata", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS DROPDOWN\(json)")
                
                let jsonArray = json["data"][0]
                self.occupationJSON = jsonArray["occupation"]
                self.genderJSON = jsonArray["gender"]
                self.provinceJSON = jsonArray["province"]
                self.informationJSON = jsonArray["information"]
                self.shirtJSON = jsonArray["sizeinformation"]
                
                self.popupImage.sd_setImage(with: URL(string:jsonArray["sizeimages"][0]["url"].stringValue), placeholderImage: UIImage(named: "icon_profile"))
                
                self.updateDisplay()
            }
        }
    }
    
    func updateDisplay() {
        userPic.sd_setImage(with: URL(string:profileJSON!["pictureUrl"].stringValue), placeholderImage: UIImage(named: "icon_profile"))
        
        emailField.text = profileJSON!["email"].stringValue
        if profileMode == .register {
            if emailField.text == "" {
                emailBtn.isHidden = false
                emailBtn.disableBtn()
            }
            else{
                emailField.isUserInteractionEnabled = false
                emailField.textColor = .gray
                verifiedEmail = true
            }
        }
        else if profileMode == .edit {
            submitBtn.setTitle("ปรับปรุงข้อมูล", for: .normal)
        }
        
        telField.text = profileJSON!["mobile"].stringValue
        fullNameField.text = profileJSON!["first_name"].stringValue
        idNoField.text = profileJSON!["identity_number"].stringValue
        
        selectedOccupationID = profileJSON!["occupation_id"].stringValue
        if selectedOccupationID == ""
        {
            occupationPicker.selectRow(0, inComponent: 0, animated: false)
        }
        else{
            for i in 0..<occupationJSON!.count{
                if occupationJSON![i]["occupation_id"].stringValue == selectedOccupationID {
                    occupationField.text = occupationJSON![i]["occupation_name_th"].stringValue
                    occupationPicker.selectRow(i, inComponent: 0, animated: false)
                }
            }
        }
        
        birthDayField.text = profileJSON!["birthday_year"].stringValue
        if birthDayField.text == ""
        {
            birthDayPicker.selectRow(maxAge-defaultAge, inComponent: 0, animated: false)
        }
        else{
            let todayYear = appStringFromDate(date: Date(), format: "yyyy")
            print(todayYear)
            let loadedAge = Int(todayYear)!-(Int(birthDayField.text!)!)
            birthDayPicker.selectRow(maxAge-loadedAge, inComponent: 0, animated: false)
            birthDayPicker.pickerView(birthDayPicker, didSelectRow: birthDayPicker.selectedRow(inComponent: 0), inComponent: 0)
        }
        
        selectedGenderID = profileJSON!["gender"].stringValue
        if selectedGenderID == ""
        {
            genderPicker.selectRow(0, inComponent: 0, animated: false)
        }
        else{
            for i in 0..<genderJSON!.count{
                if genderJSON![i]["gender_id"].stringValue == selectedGenderID {
                    genderField.text = genderJSON![i]["gender_text"].stringValue
                    genderPicker.selectRow(i, inComponent: 0, animated: false)
                }
            }
        }
        
        selectedProvinceID = profileJSON!["province"].stringValue
        selectedAmphurID = profileJSON!["district"].stringValue
        selectedTumbonID = profileJSON!["sub_district"].stringValue
        if selectedProvinceID == ""
        {
            provincePicker.selectRow(0, inComponent: 0, animated: false)
        }
        else{
            for i in 0..<provinceJSON!.count{
                if provinceJSON![i]["id_provinces"].stringValue == selectedProvinceID {
                    provinceField.text = provinceJSON![i]["name_th_provinces"].stringValue
                    provincePicker.selectRow(i, inComponent: 0, animated: false)
                    
                    loadAmphur(inProvinceID: selectedProvinceID)
                }
            }
        }
        
        let userHeight = profileJSON!["height"].stringValue
        if userHeight == "" || userHeight == "0"
        {
            heightField.text = ""
            heightPicker.selectRow(defaultHeight-minHeight, inComponent: 0, animated: false)
        }
        else{
            let loadedHeight = (Int(userHeight)!)-minHeight
            selectPicker(heightPicker, didSelectRow: loadedHeight)
            heightPicker.selectRow(loadedHeight, inComponent: 0, animated: false)
        }
        
        let userWeight = profileJSON!["weight"].stringValue
        if userWeight == "" || userWeight == "0"
        {
            weightField.text = ""
            weightPicker.selectRow(defaultWeight-minWeight, inComponent: 0, animated: false)
        }
        else{
            let loadedWeight = (Int(userWeight)!)-minWeight
            selectPicker(weightPicker, didSelectRow: loadedWeight)
            weightPicker.selectRow(loadedWeight, inComponent: 0, animated: false)
        }
        
        let userWaist = profileJSON!["waistline"].stringValue
        if userWaist == "" || userWaist == "0"
        {
            waistField.text = ""
            waistPicker.selectRow(defaultWaist-minWaist, inComponent: 0, animated: false)
        }
        else{
            let loadedWaist = (Int(userWaist)!)-minWaist
            selectPicker(waistPicker, didSelectRow: loadedWaist)
            waistPicker.selectRow(loadedWaist, inComponent: 0, animated: false)
        }
        
        selectedInformationID = profileJSON!["information"].stringValue
        if selectedInformationID == ""
        {
            informationPicker.selectRow(0, inComponent: 0, animated: false)
        }
        else{
            for i in 0..<informationJSON!.count{
                if informationJSON![i]["information_id"].stringValue == selectedInformationID {
                    informationField.text = informationJSON![i]["information_name"].stringValue
                    informationPicker.selectRow(i, inComponent: 0, animated: false)
                    
                    if i == informationJSON!.count-1{
                        sourceField.isHidden = false
                        sourceField.text = profileJSON!["source"].stringValue
                    }
                }
            }
        }
        
        selectedShirtID = profileJSON!["my_size"].stringValue
        if selectedShirtID == ""
        {
            shirtPicker.selectRow(0, inComponent: 0, animated: false)
        }
        else{
            for i in 0..<shirtJSON!.count{
                if shirtJSON![i]["size_information_id"].stringValue == selectedShirtID {
                    shirtField.text = shirtJSON![i]["size_name"].stringValue
                    shirtPicker.selectRow(i, inComponent: 0, animated: false)
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.00) {
            self.view.hideSkeleton()
        }
        
        updateSubmitBtn()
    }
    
    func loadAmphur(inProvinceID:String) {
        amphurField.isUserInteractionEnabled = false
        tumbonField.isUserInteractionEnabled = false
        
        let parameters:Parameters = ["id_provinces":inProvinceID]
        print(parameters)
        loadRequest(method:.post, apiName:"amphures", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                //print("SUCCESS AMPHUR\(json)")
                
                self.amphurJSON = json["data"]
                self.amphurPicker.reloadAllComponents()
                self.amphurField.isUserInteractionEnabled = true
                
                if self.selectedAmphurID != "" {
                    for i in 0..<self.amphurJSON!.count{
                        if self.amphurJSON![i]["id_amphures"].stringValue == self.selectedAmphurID {
                            self.amphurField.text = self.amphurJSON![i]["name_th_amphures"].stringValue
                            self.amphurPicker.selectRow(i, inComponent: 0, animated: false)
                            self.updateSubmitBtn()
                            
                            self.loadTumbon(inAumphurID: self.selectedAmphurID)
                        }
                    }
                }
                
            }
        }
    }
    
    func loadTumbon(inAumphurID:String) {
        tumbonField.isUserInteractionEnabled = false
        
        let parameters:Parameters = ["id_amphures":inAumphurID]
        print(parameters)
        loadRequest(method:.post, apiName:"districts", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                //print("SUCCESS TUMBON\(json)")
                
                self.tumbonJSON = json["data"]
                self.tumbonPicker.reloadAllComponents()
                self.tumbonField.isUserInteractionEnabled = true
                
                if self.selectedTumbonID != "" {
                    for i in 0..<self.tumbonJSON!.count{
                        if self.tumbonJSON![i]["id_districts"].stringValue == self.selectedTumbonID {
                            self.tumbonField.text = self.tumbonJSON![i]["name_th_districts"].stringValue
                            self.tumbonPicker.selectRow(i, inComponent: 0, animated: false)
                            self.updateSubmitBtn()
                        }
                    }
                }
                
            }
        }
    }
    
    // MARK: - textField
    func setupField(field:UITextField) {
        field.delegate = self
        field.returnKeyType = .next
        field.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                                  for: .editingChanged)
    }
    
    @objc func myYearChanged(notification:Notification){
        let userInfo = notification.userInfo
        birthDayField.text = (userInfo?["date"]) as? String
        updateSubmitBtn()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == occupationField && occupationField.text == "" {
            selectPicker(occupationPicker, didSelectRow: 0)
        }
        else if textField == birthDayField && birthDayField.text == "" {
            //birthDayPicker.selectRow(birthDayPicker.selectedYear(), inComponent: 0, animated: true)
            birthDayPicker.pickerView(birthDayPicker, didSelectRow: birthDayPicker.selectedRow(inComponent: 0), inComponent: 0)
        }
        else if textField == genderField && genderField.text == "" {
            selectPicker(genderPicker, didSelectRow: 0)
        }
        else if textField == provinceField && provinceField.text == "" {
            selectPicker(provincePicker, didSelectRow: 0)
        }
        else if textField == amphurField && amphurField.text == "" {
            selectPicker(amphurPicker, didSelectRow: 0)
            amphurPicker.selectRow(0, inComponent: 0, animated: false)
        }
        else if textField == tumbonField && tumbonField.text == "" {
            selectPicker(tumbonPicker, didSelectRow: 0)
            tumbonPicker.selectRow(0, inComponent: 0, animated: false)
        }
        else if textField == heightField && heightField.text == "" {
            selectPicker(heightPicker, didSelectRow: heightPicker.selectedRow(inComponent: 0))
        }
        else if textField == weightField && weightField.text == "" {
            selectPicker(weightPicker, didSelectRow: weightPicker.selectedRow(inComponent: 0))
        }
        else if textField == waistField && waistField.text == "" {
            selectPicker(waistPicker, didSelectRow: waistPicker.selectedRow(inComponent: 0))
        }
        else if textField == informationField && informationField.text == "" {
            selectPicker(informationPicker, didSelectRow: 0)
        }
        else if textField == shirtField && shirtField.text == "" {
            selectPicker(shirtPicker, didSelectRow: 0)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == telField {
            guard let textFieldText = textField.text,
                    let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                        return false
                }
                let substringToReplace = textFieldText[rangeOfTextToReplace]
                let count = textFieldText.count - substringToReplace.count + string.count
                return count <= 10
        }
        if textField == idNoField {
            guard let textFieldText = textField.text,
                    let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                        return false
                }
                let substringToReplace = textFieldText[rangeOfTextToReplace]
                let count = textFieldText.count - substringToReplace.count + string.count
                return count <= 13
        }
        else{
            return true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField == emailField {
            verifiedEmail = false
        }
        
        if emailField.text == "888" {//Bypass Login
            fullNameField.text = "นรุตม์ศรณ์ พรหมศิริ"
            idNoField.text = "0123456789012"
            occupationField.text = "Programmer"//not in api
            birthDayField.text = "1985-04-02"
            genderField.text = "male"
            emailField.text = "jae2@edfthai.org"
            telField.text = "0957109509"
            provinceField.text = "3"
            heightField.text = "165"
            weightField.text = "95"
            waistField.text = "34"
            informationField.text = "Website"
            submitBtn.enableBtn()
        }
        updateSubmitBtn()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            telField.becomeFirstResponder()
            return true
        }
        else if textField == telField {
            fullNameField.becomeFirstResponder()
            return true
        }
        else if textField == fullNameField {
            idNoField.becomeFirstResponder()
            return true
        }
        else if textField == idNoField {
            occupationField.becomeFirstResponder()
            return true
        }
        else if textField == occupationField {
            birthDayField.becomeFirstResponder()
            return true
        }
        else if textField == birthDayField {
            genderField.becomeFirstResponder()
            return true
        }
        else if textField == genderField {
            provinceField.becomeFirstResponder()
            return true
        }
        else if textField == provinceField {
            amphurField.becomeFirstResponder()
            return true
        }
        else if textField == amphurField {
            tumbonField.becomeFirstResponder()
            return true
        }
        else if textField == tumbonField {
            heightField.becomeFirstResponder()
            return true
        }
        else if textField == heightField {
            weightField.becomeFirstResponder()
            return true
        }
        else if textField == weightField {
            waistField.becomeFirstResponder()
            return true
        }
        else if textField == waistField {
            shirtField.becomeFirstResponder()
            return true
        }
        else if textField == shirtField {
            informationField.becomeFirstResponder()
            return true
        }
        else if textField == informationField {
            sourceField.becomeFirstResponder()
            return true
        }
        else {
            return false
        }
    }
    
    func updateSubmitBtn() {
        if isValidEmail(emailField.text!) {
            emailBtn.enableBtn()
            if verifiedEmail {
                emailBtn.backgroundColor = .buttonGreen
            }else{
                emailBtn.backgroundColor = .buttonRed
            }
        }
        else{
            emailBtn.disableBtn()
        }
        
        if //isValidEmail(emailField.text!) &&
            //telField.text!.count >= 9 &&
            fullNameField.text!.count >= 1 &&
            idNoField.text!.count == 13 &&
            //occupationField.text!.count >= 1 &&
            birthDayField.text!.count >= 1 &&
            genderField.text!.count >= 1 &&
            //provinceField.text!.count >= 1 &&
            //amphurField.text!.count >= 1 &&
            //tumbonField.text!.count >= 1 &&
            heightField.text!.count >= 1 &&
            weightField.text!.count >= 1
            //waistField.text!.count >= 1 &&
        {
            submitBtn.enableBtn()
        }
        else{
            submitBtn.disableBtn()
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        chooseImageSource()
    }
    
    @IBAction func cameraClick(_ sender: UIButton) {
        chooseImageSource()
    }
    
    @IBAction func verifyEmailClick(_ sender: UIButton) {
        verifiedEmail = false
        loadVerifyEmail()
    }
    
    func loadVerifyEmail() {
        let parameters:Parameters = ["id":SceneDelegate.GlobalVariables.userID,
                                     "email":emailField.text!,
        ]
        print(parameters)
        loadRequest(method:.post, apiName:"CheckEmailExist/mergeAccount", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS VERIFY EMAIL\(json)")

                if json["status_found"].stringValue == "1" {
                    ProgressHUD.showSuccess(json["status_found_message"].stringValue)
                    self.verifiedEmail = true
                    self.updateSubmitBtn()
                }
                else{
                    if json["status_send"].stringValue == "1" {
                        ProgressHUD.dismiss()
                        let alert = UIAlertController(title: json["status_found_message"].stringValue, message: json["status_send_message"].stringValue, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "กลับสู่หน้า Login", style: .cancel, handler: { _ in
                            self.logOut()
                        }))
                        alert.actions.last?.titleTextColor = .themeColor
                        self.present(alert, animated: true, completion: nil)
                    }
                    else{
                        ProgressHUD.showError(json["status_send_message"].stringValue)
                    }
                    
                }
            }
        }
    }
    
    @IBAction func sizeGuideClick(_ sender: UIButton) {
        popIn(popupView: self.blurView)
        popIn(popupView: self.popupView)
    }
    
    @IBAction func sizeGuideClose(_ sender: UIButton) {
        popOut(popupView: self.popupView)
        popOut(popupView: self.blurView)
    }
    
    @IBAction func submitClick(_ sender: UIButton) {
        
//        if profileMode == .register && verifiedEmail == false {
//            let alert = UIAlertController(title: "กรุณากดปุ่มตรวจสอบอีเมล", message: nil, preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
//
//            }))
//            alert.actions.last?.titleTextColor = .themeColor
//            self.present(alert, animated: true, completion: nil)
//        }
//        else{
//            loadSubmit()
//        }
        
        loadSubmit()
    }
    
    func loadSubmit() {
        var parameters:Parameters = ["id":SceneDelegate.GlobalVariables.userID,
                                     "email":emailField.text!,
                                     "mobile":telField.text!,
                                     "first_name":fullNameField.text!,
                                     "identity_number":idNoField.text!,
                                     "occupation":selectedOccupationID,
                                     "birthday_year":birthDayField.text!,
                                     "gender":selectedGenderID, //genderField.text!,
                                     "province":selectedProvinceID, //provinceField.text!,
                                     "district":selectedAmphurID,
                                     "sub_district":selectedTumbonID,
                                     "height":heightField.text!,
                                     "weight":weightField.text!,
                                     "waistline":waistField.text!,
                                     "information":selectedInformationID,
                                     "source":sourceField.text!,
                                     "my_size":selectedShirtID,
        ]
        if selectedImage != nil {
            let base64Image = selectedImage!.convertImageToBase64String()
            parameters.updateValue(base64Image, forKey: "pic")
        }
        
        print(parameters)
        loadRequest_V2(method:.post, apiName:"update_profile", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("UPDATE PROFILE\(json)")

                self.submitSuccess()

                if self.profileMode == .register {
                    self.switchToHome()
                }
            }
        }
    }
    
    @IBAction func leftMenuShow(_ sender: UIButton) {
        self.sideMenuController!.revealMenu()
    }
}

// MARK: - Picker Datasource
extension Profile_2: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView == occupationPicker && occupationJSON != nil {
            return occupationJSON!.count
        }
        else if pickerView == genderPicker && genderJSON != nil  {
            return genderJSON!.count
        }
        else if pickerView == provincePicker && provinceJSON != nil {
            return provinceJSON!.count
        }
        else if pickerView == amphurPicker && amphurJSON != nil {
            return amphurJSON!.count
        }
        else if pickerView == tumbonPicker && tumbonJSON != nil {
            return tumbonJSON!.count
        }
        else if pickerView == heightPicker{
            return maxHeight-minHeight+1
        }
        else if pickerView == weightPicker{
            return maxWeight-minWeight+1
        }
        else if pickerView == waistPicker{
            return maxWaist-minWaist+1
        }
        else if pickerView == informationPicker && informationJSON != nil {
            return informationJSON!.count
        }
        else if pickerView == shirtPicker && shirtJSON != nil  {
            return shirtJSON!.count
        }
        else{
            return 0
        }
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = .Prompt_Regular(ofSize: 20)
            pickerLabel?.textAlignment = .center
        }
        
        if pickerView == occupationPicker && occupationJSON != nil {
            pickerLabel?.text = occupationJSON![row]["occupation_name_th"].stringValue
        }
        else if pickerView == genderPicker && genderJSON != nil {
            pickerLabel?.text = genderJSON![row]["gender_text"].stringValue
        }
        else if pickerView == provincePicker && provinceJSON != nil {
            pickerLabel?.text = provinceJSON![row]["name_th_provinces"].stringValue
        }
        else if pickerView == amphurPicker && amphurJSON != nil {
            pickerLabel?.text = amphurJSON![row]["name_th_amphures"].stringValue
        }
        else if pickerView == tumbonPicker && tumbonJSON != nil {
            pickerLabel?.text = tumbonJSON![row]["name_th_districts"].stringValue
        }
        else if pickerView == heightPicker {
            pickerLabel?.text = "\(minHeight+row)"
        }
        else if pickerView == weightPicker {
            pickerLabel?.text = "\(minWeight+row)"
        }
        else if pickerView == waistPicker {
            pickerLabel?.text = "\(minWaist+row)"
        }
        else if pickerView == informationPicker && informationJSON != nil {
            pickerLabel?.text = informationJSON![row]["information_name"].stringValue
        }
        else if pickerView == shirtPicker && shirtJSON != nil {
            pickerLabel?.text = shirtJSON![row]["size_name"].stringValue
        }
        else{
            pickerLabel?.text = ""
        }

        pickerLabel?.textColor = .textDarkGray

        return pickerLabel!
    }

    /*
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == typePicker && leaveJSON!.count > 0{
            return leaveJSON![row]["category_name_en"].stringValue
        }
        else if pickerView == headPicker && headJSON!.count > 0{
            return "\(headJSON![row]["first_name"].stringValue) \(headJSON![row]["last_name"].stringValue)"
        }
        else{
            return ""
        }
    }
 */
}

// MARK: - Picker Delegate
extension Profile_2: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        print("Select \(row)")
        selectPicker(pickerView, didSelectRow: row)
    }

    func selectPicker(_ pickerView: UIPickerView, didSelectRow row: Int) {
        
        if pickerView == occupationPicker {
            occupationField.text = occupationJSON![row]["occupation_name_th"].stringValue
            selectedOccupationID = occupationJSON![row]["occupation_id"].stringValue
        }
        else if pickerView == genderPicker {
            genderField.text = genderJSON![row]["gender_text"].stringValue
            selectedGenderID = genderJSON![row]["gender_id"].stringValue
        }
        else if pickerView == provincePicker {
            provinceField.text = provinceJSON![row]["name_th_provinces"].stringValue
            selectedProvinceID = provinceJSON![row]["id_provinces"].stringValue
            
            selectedAmphurID = ""
            amphurField.text = ""
            
            
            selectedTumbonID = ""
            tumbonField.text = ""
            tumbonJSON = nil
            tumbonPicker.reloadAllComponents()
            
            loadAmphur(inProvinceID: selectedProvinceID)
        }
        else if pickerView == amphurPicker {
            amphurField.text = amphurJSON![row]["name_th_amphures"].stringValue
            selectedAmphurID = amphurJSON![row]["id_amphures"].stringValue
            
            selectedTumbonID = ""
            tumbonField.text = ""
            tumbonJSON = nil
            tumbonPicker.reloadAllComponents()
            
            loadTumbon(inAumphurID: selectedAmphurID)
        }
        else if pickerView == tumbonPicker {
            tumbonField.text = tumbonJSON![row]["name_th_districts"].stringValue
            selectedTumbonID = tumbonJSON![row]["id_districts"].stringValue
        }
        else if pickerView == heightPicker {
            heightField.text = "\(minHeight+row)"
        }
        else if pickerView == weightPicker {
            weightField.text = "\(minWeight+row)"
        }
        else if pickerView == waistPicker {
            waistField.text = "\(minWaist+row)"
        }
        else if pickerView == informationPicker {
            informationField.text = informationJSON![row]["information_name"].stringValue
            selectedInformationID = informationJSON![row]["information_id"].stringValue
            
            if row == informationJSON!.count-1{
                sourceField.isHidden = false
            }
            else{
                sourceField.isHidden = true
                sourceField.text = ""
            }
        }
        else if pickerView == shirtPicker {
            shirtField.text = shirtJSON![row]["size_name"].stringValue
            selectedShirtID = shirtJSON![row]["size_information_id"].stringValue
        }
        
        updateSubmitBtn()
    }
}


// MARK: - UIImagePickerControllerDelegate

extension Profile_2: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
            userPic.image = selectedImage
            //self.uploadToServer(image: pickedImage)
            updateSubmitBtn()
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

