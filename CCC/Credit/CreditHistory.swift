//
//  CreditHistory.swift
//  CCC
//
//  Created by Truk Karawawattana on 15/12/2566 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import AVFoundation
import ProgressHUD

class CreditHistory: UIViewController, UITextFieldDelegate {
    
    var typeID : String? = "0"
    
    var typeJSON : JSON?
    var historyJSON : JSON?
    var activityJSON : JSON?
    
    @IBOutlet weak var totalScoreTitle: UILabel!
    @IBOutlet weak var totalScoreLabel: UILabel!
    @IBOutlet weak var monthScoreTitle: UILabel!
    @IBOutlet weak var monthScoreLabel: UILabel!
    
    @IBOutlet weak var activityScoreTitle: UILabel!
    @IBOutlet weak var activityScoreLabel: UILabel!
    @IBOutlet weak var assessmentScoreTitle: UILabel!
    @IBOutlet weak var assessmentScoreLabel: UILabel!
    @IBOutlet weak var specialScoreTitle: UILabel!
    @IBOutlet weak var specialScoreLabel: UILabel!
    
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
        
        print("CREDIT_HISTORY")
        
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
        let parameters:Parameters = ["filter":"condition"]
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
                if self.typeJSON?.count != 0 {
                    self.typeField.text = self.typeJSON![0]["name_pointsCategory"].stringValue
                    self.typeID = self.typeJSON![0]["id_pointsCategory"].stringValue
                }
                self.loadHistory(monthYear: self.mySelectedDate)
            }
        }
    }
    
    func loadHistory(monthYear:Date) {
        let monthYearStr = dateToServerString(date: monthYear)
        let dateArray = monthYearStr.split(separator: "-")
        let yearStr = String(dateArray[0])
        let monthStr = String(dateArray[1])
        
//        print(yearStr)
//        print(monthStr)
//        print(typeID!)
        
        let parameters:Parameters = ["user_id":SceneDelegate.GlobalVariables.userID,
                                     "year":yearStr,
                                     "month":monthStr,
                                     "type":typeID!
        ]
        loadRequest_V2(method:.post, apiName:"credit/history", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS CREDIT HISTORY\(json)")
                
                self.historyJSON = json["data"]
                
                self.activityJSON = self.historyJSON?["this_month_history"]
                
                self.myTableView.reloadData()
                
                self.updateDisplay()
            }
        }
    }
    
    func updateDisplay() {
        
        if self.activityJSON?.count == 0 {
            showErrorNoData()
        }
        else {
            ProgressHUD.dismiss()
        }
        
        totalScoreTitle.text = historyJSON!["text_credit_all"].stringValue
        totalScoreLabel.text = historyJSON!["my_credit"].stringValue
        
        monthScoreTitle.text = historyJSON!["text_credit_this_month"].stringValue
        monthScoreLabel.text = historyJSON!["this_month_credit"].stringValue
        
        activityScoreTitle.text = historyJSON!["text_credit_activities"].stringValue
        activityScoreLabel.text = historyJSON!["credit_activities"].stringValue
        
        assessmentScoreTitle.text = historyJSON!["text_credit_online_assessment"].stringValue
        assessmentScoreLabel.text = historyJSON!["credit_online_assessment"].stringValue
        
        specialScoreTitle.text = historyJSON!["text_credit_special"].stringValue
        specialScoreLabel.text = historyJSON!["credit_special"].stringValue
        
        monthYearField.text = appStringFromDate(date: mySelectedDate, format: "MMMM yyyy")
    }
    
    @objc func myMonthChanged(notification:Notification){
        let userInfo = notification.userInfo
        mySelectedDate = appDateFromString(dateStr: (userInfo?["date"]) as! String, format: "MMMM yyyy")!
        monthYearField.text = appStringFromDate(date: mySelectedDate, format: "MMMM yyyy")
        loadHistory(monthYear: mySelectedDate)
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
extension CreditHistory: UIPickerViewDataSource {
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
extension CreditHistory: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        selectPicker(pickerView, didSelectRow: row)
    }
    
    func selectPicker(_ pickerView: UIPickerView, didSelectRow row: Int) {
        if pickerView == typePicker {
            typeField.text = typeJSON![row]["name_pointsCategory"].stringValue
            typeID = typeJSON![row]["id_pointsCategory"].stringValue
            
            loadHistory(monthYear: mySelectedDate)
        }
    }
}


// MARK: - UITableViewDataSource

extension CreditHistory: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (activityJSON != nil) {
            return activityJSON!.count
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreditHistoryCell", for: indexPath) as! CreditHistoryCell
        
        let cellArray = activityJSON![indexPath.item]

        cell.cellDate.text = cellArray["date_pointsData_text"].stringValue
        cell.cellTitle.text = cellArray["name_points_type"].stringValue
        cell.cellScore.text = cellArray["points_pointsData_text"].stringValue
        cell.cellRemark.text = cellArray["note"].stringValue
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CreditHistory: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

