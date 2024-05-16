//
//  Register_2.swift
//  CCC
//
//  Created by Truk Karawawattana on 24/10/2566 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD

class Register_2: UIViewController, UITextFieldDelegate {
    
    var provinceJSON:JSON?
    var amphurJSON:JSON?
    var tumbonJSON:JSON?
    
    var selectedProvinceID = ""
    var selectedAmphurID = ""
    var selectedTumbonID = ""
    
    @IBOutlet weak var provinceField: UITextField!
    @IBOutlet weak var amphurField: UITextField!
    @IBOutlet weak var tumbonField: UITextField!
    
    @IBOutlet weak var submitBtn: UIButton!
    
    var provincePicker: UIPickerView! = UIPickerView()
    var amphurPicker: UIPickerView! = UIPickerView()
    var tumbonPicker: UIPickerView! = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("REGISTER_2")
        self.navigationController?.setStatusBar(backgroundColor: .themeColor)

        setupField(field: provinceField)
        setupField(field: amphurField)
        setupField(field: tumbonField)
        
        pickerSetup(picker: provincePicker)
        provinceField.inputView = provincePicker
        provinceField.isUserInteractionEnabled = false
        
        pickerSetup(picker: amphurPicker)
        amphurField.inputView = amphurPicker
        amphurField.isUserInteractionEnabled = false
        
        pickerSetup(picker: tumbonPicker)
        tumbonField.inputView = tumbonPicker
        tumbonField.isUserInteractionEnabled = false
        
        submitBtn.disableBtn()
        
        loadDropdown()
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
                self.provinceJSON = jsonArray["province"]
                self.provincePicker.reloadAllComponents()
                self.provinceField.isUserInteractionEnabled = true
            }
        }
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
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == provinceField && provinceField.text == "" {
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
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        updateSubmitBtn()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == provinceField {
            amphurField.becomeFirstResponder()
            return true
        }
        else if textField == amphurField {
            tumbonField.becomeFirstResponder()
            return true
        }
        else if textField == tumbonField {
            tumbonField.resignFirstResponder()
            return true
        }
        else {
            return false
        }
    }
    
    func updateSubmitBtn() {
        if provinceField.text!.count >= 1 &&
            amphurField.text!.count >= 1 &&
            tumbonField.text!.count >= 1
        {
            submitBtn.enableBtn()
        }
        else{
            submitBtn.disableBtn()
        }
    }
    
    @IBAction func submitClick(_ sender: UIButton) {
        loadSubmit()
    }
    
    func loadSubmit() {
        let parameters:Parameters = ["user_id":SceneDelegate.GlobalVariables.userID,
                                     "province":selectedProvinceID,
                                     "district":selectedAmphurID,
                                     "sub_district":selectedTumbonID
        ]
        print(parameters)
        loadRequest_V2(method:.post, apiName:"update_profile/update_address_data", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("REGISTER_2 SUBMIT\(json)")

//                let vc = UIStoryboard.loginStoryBoard.instantiateViewController(withIdentifier: "Register_3") as! Register_3
//                self.navigationController!.pushViewController(vc, animated: true)
                self.switchToHome()
            }
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
}


// MARK: - Picker Datasource
extension Register_2: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView == provincePicker && provinceJSON != nil {
            return provinceJSON!.count
        }
        else if pickerView == amphurPicker && amphurJSON != nil {
            return amphurJSON!.count
        }
        else if pickerView == tumbonPicker && tumbonJSON != nil {
            return tumbonJSON!.count
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
        
        if pickerView == provincePicker && provinceJSON != nil {
            pickerLabel?.text = provinceJSON![row]["name_th_provinces"].stringValue
        }
        else if pickerView == amphurPicker && amphurJSON != nil {
            pickerLabel?.text = amphurJSON![row]["name_th_amphures"].stringValue
        }
        else if pickerView == tumbonPicker && tumbonJSON != nil {
            pickerLabel?.text = tumbonJSON![row]["name_th_districts"].stringValue
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
extension Register_2: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        print("Select \(row)")
        selectPicker(pickerView, didSelectRow: row)
    }

    func selectPicker(_ pickerView: UIPickerView, didSelectRow row: Int) {
        
        if pickerView == provincePicker {
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
            
            loadTumbon(inAumphurID: selectedAmphurID)
        }
        else if pickerView == tumbonPicker {
            tumbonField.text = tumbonJSON![row]["name_th_districts"].stringValue
            selectedTumbonID = tumbonJSON![row]["id_districts"].stringValue
        }
        
        updateSubmitBtn()
    }
}

