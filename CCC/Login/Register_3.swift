//
//  Register_3.swift
//  CCC
//
//  Created by Truk Karawawattana on 24/10/2566 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD

class Register_3: UIViewController, UITextFieldDelegate {
    
    var selectedGenderID = ""
    var selectedWeight = ""
    var selectedHeight = ""
    var selectedWaist = ""
    
    var minWeight = 20
    var maxWeight = 120
    var defaultWeight = 50
    
    var minHeight = 50
    var maxHeight = 250
    var defaultHeight = 150
    
    var minWaist = 10
    var maxWaist = 100
    var defaultWaist = 25
    
    var maxAge = 100
    var defaultAge = 30
    
    @IBOutlet weak var maleBtn: UIButton!
    @IBOutlet weak var femaleBtn: UIButton!
    @IBOutlet weak var maleLabel: UILabel!
    @IBOutlet weak var femaleLabel: UILabel!
    
    @IBOutlet weak var weightField: UITextField!
    @IBOutlet weak var heightField: UITextField!
    @IBOutlet weak var waistField: UITextField!
    @IBOutlet weak var birthDayField: UITextField!
    
    @IBOutlet weak var submitBtn: UIButton!
    
    var weightPicker: UIPickerView! = UIPickerView()
    var heightPicker: UIPickerView! = UIPickerView()
    var waistPicker: UIPickerView! = UIPickerView()
    var birthDayPicker = MyMonthYearPicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("REGISTER_3")
        self.navigationController?.setStatusBar(backgroundColor: .themeColor)

        setupField(field: weightField)
        setupField(field: heightField)
        setupField(field: waistField)
        setupField(field: birthDayField)
        
        pickerSetup(picker: weightPicker)
        weightField.inputView = weightPicker
        
        pickerSetup(picker: heightPicker)
        heightField.inputView = heightPicker
        
        pickerSetup(picker: waistPicker)
        waistField.inputView = waistPicker
        
        birthDayPicker.dataSource = birthDayPicker
        birthDayPicker.delegate = birthDayPicker
        birthDayPicker.backgroundColor = .white
        birthDayPicker.pickerMode = .year
        birthDayPicker.buildYearCollection(previous: maxAge, next: 0)
        NotificationCenter.default.addObserver(self, selector: #selector(myYearChanged(notification:)), name:.yearChanged, object: nil)
        
        birthDayField.inputView = birthDayPicker
        
        submitBtn.disableBtn()
    }
    
    func pickerSetup(picker:UIPickerView) {
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = .white
        picker.setValue(UIColor.textDarkGray, forKeyPath: "textColor")
    }

    func setupField(field:UITextField) {
        field.delegate = self
        field.returnKeyType = .next
        field.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                                  for: .editingChanged)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == weightField && weightField.text == "" {
            let row = defaultWeight-minWeight
            weightPicker.selectRow(row, inComponent: 0, animated: true)
            selectPicker(weightPicker, didSelectRow: row)
        }
        else if textField == heightField && heightField.text == "" {
            let row = defaultHeight-minHeight
            heightPicker.selectRow(row, inComponent: 0, animated: true)
            selectPicker(heightPicker, didSelectRow: row)
        }
        else if textField == waistField && waistField.text == "" {
            let row = defaultWaist-minWaist
            waistPicker.selectRow(row, inComponent: 0, animated: true)
            selectPicker(waistPicker, didSelectRow: row)
        }
        else if textField == birthDayField && birthDayField.text == "" {
            let row = maxAge-defaultAge
            birthDayPicker.selectRow(row, inComponent: 0, animated: true)
            birthDayPicker.pickerView(birthDayPicker, didSelectRow:row, inComponent: 0)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == birthDayField {
            guard let textFieldText = textField.text,
                    let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                        return false
                }
                let substringToReplace = textFieldText[rangeOfTextToReplace]
                let count = textFieldText.count - substringToReplace.count + string.count
                return count <= 4
        }
        else{
            return true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        updateSubmitBtn()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == weightField {
            heightField.becomeFirstResponder()
            return true
        }
        else if textField == heightField {
            waistField.becomeFirstResponder()
            return true
        }
        else if textField == waistField {
            birthDayField.becomeFirstResponder()
            return true
        }
        else if textField == birthDayField {
            birthDayField.resignFirstResponder()
            return true
        }
        else {
            return false
        }
    }
    
    @objc func myYearChanged(notification:Notification){
        let userInfo = notification.userInfo
        birthDayField.text = (userInfo?["date"]) as? String
        updateSubmitBtn()
    }
    
    func updateSubmitBtn() {
        if selectedGenderID != "" &&
            weightField.text!.count >= 1 &&
            heightField.text!.count >= 1 &&
            birthDayField.text!.count == 4
        {
            submitBtn.enableBtn()
        }
        else{
            submitBtn.disableBtn()
        }
    }
    
    @IBAction func genderClick(_ sender: UIButton) {
        setBtnBorder(maleBtn, clear: true)
        //maleBtn.setImage(UIImage(named: "register_male_off"), for: .normal)
        maleLabel.textColor = .textGray
        
        setBtnBorder(femaleBtn, clear: true)
        //femaleBtn.setImage(UIImage(named: "register_female_off"), for: .normal)
        femaleLabel.textColor = .textGray
        
        if sender.tag == 1 {//MALE
            //maleBtn.setImage(UIImage(named: "register_male_on"), for: .normal)
            setBtnBorder(sender, clear: false)
            maleLabel.textColor = .textDarkGray
            selectedGenderID = "1"
        }
        else if sender.tag == 2 {//FEMALE
            //femaleBtn.setImage(UIImage(named: "register_female_on"), for: .normal)
            setBtnBorder(sender, clear: false)
            femaleLabel.textColor = .textDarkGray
            selectedGenderID = "2"
        }
        updateSubmitBtn()
    }
    
    func setBtnBorder(_ sender: UIButton, clear:Bool) {
        sender.backgroundColor = .clear
        sender.layer.cornerRadius = sender.frame.size.height/2
        sender.layer.borderWidth = 3
        if clear {
            sender.layer.borderColor = UIColor.clear.cgColor
        }
        else{
            sender.layer.borderColor = UIColor.textGray2.cgColor
        }
    }
    
    @IBAction func submitClick(_ sender: UIButton) {
        loadSubmit()
    }
    
    func loadSubmit() {
        
        let parameters:Parameters = ["user_id":SceneDelegate.GlobalVariables.userID,
                                     "weight":selectedWeight,
                                     "height":selectedHeight,
                                     "gender":selectedGenderID,
                                     "birthday_year":birthDayField.text!,
                                     "waistline":selectedWaist
        ]
        print(parameters)
        loadRequest_V2(method:.post, apiName:"update_profile/update_profile_data", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("REGISTER_3 SUBMIT\(json)")

                self.switchToHome()
            }
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
}


// MARK: - Picker Datasource
extension Register_3: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView == weightPicker{
            return maxWeight-minWeight+1
        }
        else if pickerView == heightPicker{
            return maxHeight-minHeight+1
        }
        else if pickerView == waistPicker{
            return maxWaist-minWaist+1
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
        
        if pickerView == weightPicker {
            pickerLabel?.text = "\(minWeight+row)"
        }
        else if pickerView == heightPicker {
            pickerLabel?.text = "\(minHeight+row)"
        }
        else if pickerView == waistPicker {
            pickerLabel?.text = "\(minWaist+row)"
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
extension Register_3: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        print("Select \(row)")
        selectPicker(pickerView, didSelectRow: row)
    }

    func selectPicker(_ pickerView: UIPickerView, didSelectRow row: Int) {
        
        if pickerView == weightPicker {
            selectedWeight = "\(minWeight+row)"
            weightField.text = "\(minWeight+row)"
        }
        else if pickerView == heightPicker {
            selectedHeight = "\(minHeight+row)"
            heightField.text = "\(minHeight+row)"
        }
        else if pickerView == waistPicker {
            selectedWaist = "\(minWaist+row)"
            waistField.text = "\(minWaist+row)"
        }
        
        updateSubmitBtn()
    }
}


