//
//  CreditList.swift
//  CCC
//
//  Created by Truk Karawawattana on 15/12/2566 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import AVFoundation
import ProgressHUD

enum CreditMode {
    case assessment
    case activity
    case special
    case other
}

class CreditList: UIViewController, UITextFieldDelegate {
    
    var creditMode: CreditMode? = .other
    
    var typeID : String? = "0"
    
    var typeJSON : JSON?
    var listJSON : JSON?
    
    @IBOutlet weak var typeField: UITextField!
    @IBOutlet weak var typeBtn: UIButton!
    
    @IBOutlet weak var monthYearField: UITextField!
    @IBOutlet weak var monthYearBtn: UIButton!
    
    @IBOutlet weak var myTableView: UITableView!
    
    var typePicker: UIPickerView! = UIPickerView()
    let myDatePicker = MyMonthYearPicker()
    var mySelectedDate = Date()
    let maxPreviousMonth = 12
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setStatusBar(backgroundColor: .themeColor)
        
        pickerSetup(picker: typePicker)
        typeField.inputView = typePicker
        
        myDatePicker.dataSource = myDatePicker
        myDatePicker.delegate = myDatePicker
        myDatePicker.backgroundColor = .white
        myDatePicker.pickerMode = .month
        myDatePicker.buildMonthCollection(previous: maxPreviousMonth, next: 0)
        myDatePicker.selectRow(maxPreviousMonth, inComponent: 0, animated: false)
        NotificationCenter.default.addObserver(self, selector: #selector(myMonthChanged(notification:)), name:.monthChanged, object: nil)
        
        monthYearField.delegate = self
        monthYearField.inputView = myDatePicker
        
        // TableView
        self.myTableView.delegate = self
        self.myTableView.dataSource = self
        self.myTableView.backgroundColor = .clear
        //self.myTableView.tableFooterView = UIView(frame: .zero)
        self.myTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.myTableView.frame.size.width, height: 1))
        
        loadType()
    }
    
    func loadType() {
        let parameters:Parameters = [:]
        loadRequest_V2(method:.get, apiName:"credit/category", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS CREDIT TYPE\(json)")
                
                self.typeJSON = json["data"]
                self.typePicker.reloadAllComponents()
                self.loadList(monthYear: self.mySelectedDate)
            }
        }
    }
    
    func loadList(monthYear:Date) {
//        let monthYearStr = dateToServerString(date: monthYear)
//        let dateArray = monthYearStr.split(separator: "-")
//        let yearStr = String(dateArray[0])
//        let monthStr = String(dateArray[1])
        
//        print(yearStr)
//        print(monthStr)
//        print(typeID!)
        
        let parameters:Parameters = [
//            "user_id":SceneDelegate.GlobalVariables.userID,
//            "year":yearStr,
//            "month":monthStr,
            "type":typeID!
        ]
        loadRequest_V2(method:.post, apiName:"credit/activities", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS CREDIT LIST\(json)")
                
                self.listJSON = json["data"]
                
                self.myTableView.reloadData()
                
                self.updateDisplay()
            }
        }
    }
    
    func updateDisplay() {
        if self.listJSON?.count == 0 {
            showErrorNoData()
        }
        else {
            ProgressHUD.dismiss()
        }
        
        for i in 0..<typeJSON!.count{
            if typeJSON![i]["id_pointsCategory"].stringValue == typeID {
                typeField.text = typeJSON![i]["name_pointsCategory"].stringValue
                typePicker.selectRow(i, inComponent: 0, animated: false)
            }
        }
        //monthYearField.text = appStringFromDate(date: mySelectedDate, format: "MMMM yyyy")
    }
    
    @objc func myMonthChanged(notification:Notification){
        let userInfo = notification.userInfo
        mySelectedDate = appDateFromString(dateStr: (userInfo?["date"]) as! String, format: "MMMM yyyy")!
        monthYearField.text = appStringFromDate(date: mySelectedDate, format: "MMMM yyyy")
        loadList(monthYear: mySelectedDate)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == typeField && typeField.text == "" {
            selectPicker(typePicker, didSelectRow: 0)
        }
        else if textField == monthYearField && monthYearField.text == "" {
            myDatePicker.selectRow(myDatePicker.selectedMonth(), inComponent: 0, animated: true)
            myDatePicker.pickerView(myDatePicker, didSelectRow: myDatePicker.selectedRow(inComponent: 0), inComponent: 0)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func pickerSetup(picker:UIPickerView) {
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = .white
        picker.setValue(UIColor.textDarkGray, forKeyPath: "textColor")
    }
    
    @IBAction func dropdownClick(_ sender: UIButton) {
        switch sender.tag {
        case 1://type
            typeField.becomeFirstResponder()
            
        case 2://head
            monthYearField.becomeFirstResponder()
            
        default:
            break
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
}

// MARK: - Picker Datasource
extension CreditList: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == typePicker && typeJSON!.count > 0{
            return typeJSON!.count
        }
        else{
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = .Prompt_Regular(ofSize: 22)
            pickerLabel?.textAlignment = .center
        }
        
        if pickerView == typePicker && typeJSON!.count > 0{
            pickerLabel?.text = typeJSON![row]["name_pointsCategory"].stringValue
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
extension CreditList: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        selectPicker(pickerView, didSelectRow: row)
    }
    
    func selectPicker(_ pickerView: UIPickerView, didSelectRow row: Int) {
        if pickerView == typePicker {
            typeField.text = typeJSON![row]["name_pointsCategory"].stringValue
            typeID = typeJSON![row]["id_pointsCategory"].stringValue
            
            loadList(monthYear: mySelectedDate)
        }
    }
}


// MARK: - UITableViewDataSource

extension CreditList: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (listJSON != nil) {
            return listJSON!.count
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 152
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreditListCell", for: indexPath) as! CreditListCell
        
        let cellArray = listJSON![indexPath.item]

        cell.cellImage.sd_setImage(with: URL(string:cellArray["image_cover"].stringValue), placeholderImage: nil)
        cell.cellTitle.text = cellArray["title"].stringValue

        switch cellArray["type_id"] {
        case "1"://Assessment
            cell.cellImage2.image = UIImage(named: "credit_clipboard")
            
        case "2"://Activity
            cell.cellImage2.image = UIImage(named: "credit_activity")
            
        case "3"://Special
            cell.cellImage2.image = UIImage(named: "credit_special")
            
        default:
            break
        }
        
        cell.cellTitle2.text = cellArray["type_text"].stringValue
        cell.cellDesc2.text = cellArray["type_name"].stringValue

        cell.cellTitle3.text = cellArray["point_text"].stringValue
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CreditList: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellArray = self.listJSON![indexPath.item]
        
        let vc = UIStoryboard.creditStoryBoard.instantiateViewController(withIdentifier: "CreditDetail") as! CreditDetail
        vc.creditID = cellArray["id"].stringValue
        self.navigationController!.pushViewController(vc, animated: true)
    }
}


