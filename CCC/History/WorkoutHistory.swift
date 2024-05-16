//
//  WorkoutHistory.swift
//  CCC
//
//  Created by Truk Karawawattana on 20/12/2564 BE.
//

import HealthKit
import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import SDWebImage
import SwiftAlertView

class WorkoutHistory: UIViewController, UITextFieldDelegate {
    
    var historyMode: HistoryMode?
    
    var syncedJSON : JSON?
    
    var typeJSON : JSON?
    var historyJSON : JSON?
    
    var typeID : String? = "0"
    
    var firstTime = true
    
    private var workouts: [HKWorkout]?
    private var walkRun: [HKQuantitySample]?
    
    @IBOutlet weak var myTableView: UITableView!
    
    @IBOutlet weak var typeField: UITextField!
    @IBOutlet weak var typeBtn: UIButton!
    
    @IBOutlet weak var monthYearField: UITextField!
    @IBOutlet weak var monthYearBtn: UIButton!
    
    var typePicker: UIPickerView! = UIPickerView()
    let myDatePicker = MyMonthYearPicker()
    let myDatePickerL = MyMonthYearPicker()
    let myDatePickerR = MyMonthYearPicker()
    var mySelectedDate = Date()
    let maxPreviousMonth = 12
    
    var serverwithTimeFormatter = DateFormatter.serverWihtTimeFormatter
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if firstTime {
            if historyMode == .appleformServer {
                syncHealth(startDateStr: SceneDelegate.GlobalVariables.userLastSynced)
            }
        }
        else{
            //loadHistory(monthYear: mySelectedDate)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("WORKOUT HISTORY")
        self.navigationController?.setStatusBar(backgroundColor: .themeColor)
        
        pickerSetup(picker: typePicker)
        typeField.inputView = typePicker
        
        myDatePicker.dataSource = myDatePicker
        myDatePicker.delegate = myDatePicker
        myDatePicker.backgroundColor = .white
        if historyMode == .appleformServer {
            myDatePicker.pickerMode = .month
            NotificationCenter.default.addObserver(self, selector: #selector(myMonthChanged(notification:)), name:.monthChanged, object: nil)
        }
        else {
            myDatePicker.pickerMode = .month2
            NotificationCenter.default.addObserver(self, selector: #selector(myMonthChanged(notification:)), name:.monthChanged2, object: nil)
        }
        myDatePicker.buildMonthCollection(previous: maxPreviousMonth, next: 0)
        myDatePicker.selectRow(maxPreviousMonth, inComponent: 0, animated: false)
        
        monthYearField.delegate = self
        monthYearField.inputView = myDatePicker
        
        myTableView.delegate = self
        myTableView.dataSource = self
        
        loadType()
    }
    
//    func loadHistory(showLoadingHUD:Bool) {
//        let parameters:Parameters = ["user_id":SceneDelegate.GlobalVariables.userID]
//        var urlStr:String
//        if historyMode == .appleformServer {
//            urlStr = "history/device"
//        }
//        else {
//            urlStr = "history"
//        }
//        loadRequest(method:.post, apiName:urlStr, authorization:true, showLoadingHUD:showLoadingHUD, dismissHUD:true, parameters: parameters){ result in
//            switch result {
//            case .failure(let error):
//                print(error)
//                ProgressHUD.dismiss()
//
//            case .success(let responseObject):
//                let json = JSON(responseObject)
//                print("SUCCESS HISTORY\(json)")
//                
//                self.historyJSON = json["data"]
//                self.myTableView.reloadData()
//            }
//        }
//    }
    
    func loadType() {
        let parameters:Parameters = ["user_id":SceneDelegate.GlobalVariables.userID]
        loadRequest_V2(method:.get, apiName:"history/filter", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                //print("SUCCESS HISTORY TYPE\(json)")
                
                self.typeJSON = json["data"]
                self.typePicker.reloadAllComponents()
                if self.typeJSON?.count != 0 {
                    self.typeField.text = self.typeJSON![0]["devices_text"].stringValue
                    self.typeID = self.typeJSON![0]["devices_var"].stringValue
                }
                self.loadHistory(monthYear: self.mySelectedDate)
            }
        }
    }
    
    func loadHistory(monthYear:Date) {
        historyJSON = []
        myTableView.reloadData()
        monthYearField.text = appStringFromDate(date: mySelectedDate, format: "MMMM yyyy")
        
        let monthYearStr = dateToServerString(date: monthYear)
        let dateArray = monthYearStr.split(separator: "-")
        let yearStr = String(dateArray[0])
        let monthStr = String(dateArray[1])
        
//        print(yearStr)
//        print(monthStr)
//        print(typeID!)
        
        var urlStr:String
        if historyMode == .appleformServer {
            urlStr = "history/device"
        }
        else {
            urlStr = "history"
        }
        
        let parameters:Parameters = ["user_id":SceneDelegate.GlobalVariables.userID,
                                     "year":yearStr,
                                     "month":monthStr,
                                     "filter":typeID!
        ]
        print("URL = \(urlStr)")
        print("Date = \(mySelectedDate)")
        print("Param = \(parameters)")
        loadRequest_V2(method:.post, apiName:urlStr, authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS HISTORY\(json)")
                
                self.historyJSON = json["data"]
                self.myTableView.reloadData()
                
                self.firstTime = false
            }
        }
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
    
}//end ViewController

// MARK: - Picker Datasource
extension WorkoutHistory: UIPickerViewDataSource {
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
            pickerLabel?.text = typeJSON![row]["devices_text"].stringValue
        }
        else{
            pickerLabel?.text = ""
        }
        
        pickerLabel?.textColor = .textDarkGray
        
        return pickerLabel!
    }
}

// MARK: - Picker Delegate
extension WorkoutHistory: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        selectPicker(pickerView, didSelectRow: row)
    }
    
    func selectPicker(_ pickerView: UIPickerView, didSelectRow row: Int) {
        if pickerView == typePicker {
            typeField.text = typeJSON![row]["devices_text"].stringValue
            typeID = typeJSON![row]["devices_var"].stringValue
            
            loadHistory(monthYear: mySelectedDate)
        }
    }
}

// MARK: - UITableViewDataSource

extension WorkoutHistory: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (historyJSON != nil) {
            return historyJSON!.count
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140//self.myTableView.frame.height/6
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkOutCell", for: indexPath) as! WorkOutCell
        
        let cellArray = historyJSON![indexPath.item]
        
        
        let actName = cellArray["act_name_th"].stringValue
        let actType = cellArray["activity_type"].stringValue
        let sourceName = cellArray["source_name"].stringValue
        
        if sourceName != "" {
            cell.cellName.text = "\(sourceName)"
            if actType != "" {
                cell.cellName.text = "\(sourceName) (\(actType))"
            }
        }
        else{
            cell.cellName.text = "\(actName)"
        }
        
        if let startDate = serverwithTimeFormatter.date(from: cellArray["startdate"].stringValue) {
            cell.cellDate.text = appStringFromDate(date: startDate, format:DateFormatter.formatDateWithTimeTH)
        }
        else{
            if let createDate = serverwithTimeFormatter.date(from: cellArray["cdate"].stringValue) {
                cell.cellDate.text = appStringFromDate(date: createDate, format:DateFormatter.formatDateWithTimeTH)
            }
            else{
                cell.cellDate.text = "-"
            }
        }
        
        let time = NSInteger(cellArray["activity_time"].stringValue)!
        //let ms = Int((self.truncatingRemainder(dividingBy: 1)) * 1000)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        cell.cellDuration.text = String(format: "ระยะเวลา: %0.2d:%0.2d:%0.2d",hours,minutes,seconds)
        
        if cellArray["distance"].stringValue == "" || cellArray["distance"].stringValue == "0" {
            cell.cellDistance.text = "ระยะทาง: -"
        }
        else{
            let distance = cellArray["distance"].doubleValue/1000
            cell.cellDistance.text = String(format:"ระยะทาง: %.2f km", distance)
        }
        
        let formattedCalories = String(format: "แคลอรี: %@ kCal", cellArray["summary_cal"].stringValue)
        cell.cellCalories.text = formattedCalories
        
        switch historyMode {
        case .appleformServer:
            if cellArray["send_status"].stringValue == "3" {
                cell.cellImportBtn.isHidden = false
                cell.cellImportBtn.setTitle("นำเข้าข้อมูล", for: .normal)
                cell.cellImportBtn.addTarget(self, action: #selector(importClick(_:)), for: .touchUpInside)
            }
            else{
                cell.cellImportBtn.isHidden = true
            }
            
        case .all:
            cell.cellImportBtn.isHidden = false
            cell.cellImportBtn.setTitle("แชร์", for: .normal)
            cell.cellImportBtn.addTarget(self, action: #selector(shareClick(_:)), for: .touchUpInside)
            
        default:
            cell.cellImportBtn.isHidden = true
        }
        
        cell.cellDeleteBtn.addTarget(self, action: #selector(deleteClick(_:)), for: .touchUpInside)
        
        let reasonStr = cellArray["send_status_text"].stringValue
        if reasonStr != "" {
            cell.cellReason.isHidden = false
            cell.cellReason.text = reasonStr
        }
        else{
            cell.cellReason.isHidden = true
        }
        
//            if historyMode == .appleformServer {
//                if cellArray["send_status"].stringValue == "3" {
//                    cell.cellImportBtn.isHidden = false
//                    cell.cellImportBtn.addTarget(self, action: #selector(importClick(_:)), for: .touchUpInside)
//                }
//                else{
//                    cell.cellImportBtn.isHidden = true
//                }
//            }
//            else if  {
//
//            }
//            else {
//                cell.cellImportBtn.isHidden = true
//            }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension WorkoutHistory: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard.runStoryBoard.instantiateViewController(withIdentifier: "RunSummary") as! RunSummary
        
        let cellArray = historyJSON![indexPath.item]
        vc.summaryMode = .fromHistory
        vc.totalDistance = cellArray["distance"].doubleValue/1000
        vc.totalDuration = cellArray["activity_time"].doubleValue
        vc.totalStep = cellArray["step"].intValue
        vc.totalCalories = cellArray["summary_cal"].doubleValue
        
        if let startDate = serverwithTimeFormatter.date(from: cellArray["startdate"].stringValue) {
            vc.startDate = startDate
        }
        else{
            if let createDate = serverwithTimeFormatter.date(from: cellArray["cdate"].stringValue) {
                vc.startDate = createDate
            }
            else{
                vc.startDate = Date()
            }
        }
        
        if let endDate = serverwithTimeFormatter.date(from: cellArray["enddate"].stringValue) {
            vc.endDate = endDate
        }
        else{
            if let createDate = serverwithTimeFormatter.date(from: cellArray["cdate"].stringValue) {
                vc.endDate = createDate
            }
            else{
                vc.endDate = Date()
            }
        }
        vc.lat = cellArray["latitude"].stringValue
        vc.long = cellArray["longitude"].stringValue
        
        self.navigationController!.pushViewController(vc, animated: true)
        
//        print(cellArray["distance"].doubleValue)
//        print(cellArray["activity_time"].doubleValue)
//        print(cellArray["step"].intValue)
//        print(cellArray["summary_cal"].doubleValue)
//        print(dateWithTimeFromServerString(dateStr: cellArray["startdate"].stringValue))
//        print(dateWithTimeFromServerString(dateStr: cellArray["enddate"].stringValue))
    }
    
    @IBAction func shareClick(_ sender: UIButton) {
        var superview = sender.superview
        while let view = superview, !(view is UITableViewCell) {
            superview = view.superview
        }
        guard let cell = superview as? UITableViewCell else {
            print("button is not contained in a table view cell")
            return
        }
        guard let indexPath = myTableView.indexPath(for: cell) else {
            print("failed to get index path for cell containing button")
            return
        }
        print("Share \(indexPath.section) - \(indexPath.item)")
        
        let cellArray = historyJSON![indexPath.item]
        
        let vc = UIStoryboard.runStoryBoard.instantiateViewController(withIdentifier: "Share") as! Share
        
        if cellArray["distance"].stringValue == "" || cellArray["distance"].stringValue == "0" {
            vc.totalDistance = 0
        }
        else{
            let distance = cellArray["distance"].doubleValue/1000
            vc.totalDistance = distance
        }
        
        vc.totalDuration = cellArray["activity_time"].doubleValue
        vc.totalStep = 0
        vc.totalCalories = cellArray["summary_cal"].doubleValue
        
        if let startDate = serverwithTimeFormatter.date(from: cellArray["startdate"].stringValue) {
            vc.startDate = startDate
        }
        else{
            if let createDate = serverwithTimeFormatter.date(from: cellArray["cdate"].stringValue) {
                vc.startDate = createDate
            }
        }
        //vc.endDate = endDate
        vc.lat = cellArray["latitude"].stringValue
        vc.long = cellArray["longitude"].stringValue
        
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction func importClick(_ sender: UIButton) {
        var superview = sender.superview
        while let view = superview, !(view is UITableViewCell) {
            superview = view.superview
        }
        guard let cell = superview as? UITableViewCell else {
            print("button is not contained in a table view cell")
            return
        }
        guard let indexPath = myTableView.indexPath(for: cell) else {
            print("failed to get index path for cell containing button")
            return
        }
        //print("Import \(indexPath.section) - \(indexPath.item)")
        
        if historyMode == .appleformServer{
            SwiftAlertView.show(title: "ยืนยันการนำเข้าข้อมูล",
                                message: "ข้อมูลการออกกำลังกาย ในช่วงเวลาเดียวกับรายการนี้ จากอุปกรณ์หรือแอปพลิเคชันอื่น จะถูกลบ",
                                buttonTitles: "ยกเลิก", "ยืนยัน") { alert in
                //alert.backgroundColor = .yellow
                alert.titleLabel.font = .Alert_Title
                alert.messageLabel.font = .Alert_Message
                alert.titleLabel.textColor = .themeColor
                
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
                                        self.loadImportFromServer(indexPath: indexPath)
                                    default:
                                        break
                                    }
                                }
            
        }
    }
    
    func loadImportFromHealth(indexPath: IndexPath) {
        print("Import \(indexPath.item)")
//        let cellArray = self.workouts![indexPath.row] as HKWorkout
//        let workoutID = cellArray.uuid.uuidString
//        let sourceName = String(describing:cellArray.sourceRevision.source.name)
//        let type: HKWorkoutActivityType = cellArray.workoutActivityType
//
//        let startDate = DateFormatter.serverWihtTimeFormatter.string(from: cellArray.startDate)
//        let endDate = DateFormatter.serverWihtTimeFormatter.string(from: cellArray.endDate)
//        let duration = String(format:"%.0f", cellArray.duration)
//        let caloriesBurned = String(format:"%.0f", cellArray.totalEnergyBurned!.doubleValue(for: .kilocalorie()))
//
//        var parameters:Parameters = ["id":SceneDelegate.GlobalVariables.userID ,
//                                     "id_fk_source":workoutID ,
//                                     "source_name":sourceName ,
//                                     "activity_type":type.name ,
//                                     "startdate":startDate ,
//                                     "enddate":endDate ,
//                                     "duration":duration ,
//                                     "calorie":caloriesBurned ,
//        ]
//        if let distance = cellArray.totalDistance?.doubleValue(for: .meter()) {
//            let kmDistance = "\((distance/1000).rounded(toPlaces: 2))"
//            parameters.updateValue(kmDistance, forKey: "distance")
//        }else{
//            parameters.updateValue("", forKey: "distance")
//        }
//        print(parameters)
//
//        loadRequest(method:.post, apiName:"history/single_synced", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
//            switch result {
//            case .failure(let error):
//                print(error)
//                ProgressHUD.dismiss()
//
//            case .success(let responseObject):
//                let json = JSON(responseObject)
//                print("SUCCESS WORKOUT SUBMIT\(json)")
//
//                ProgressHUD.showSucceed("นำเข้าข้อมูลเรียบร้อย")
//                self.loadSynced(showLoadingHUD: false)
//            }
//        }
    }
    
    func loadImportFromServer(indexPath: IndexPath) {
        print("Import From Server \(indexPath.item)")
        let cellArray = historyJSON![indexPath.item]
        let parameters:Parameters = ["cs_id":cellArray["cs_id"]]
        loadRequest(method:.post, apiName:"history/single_import", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS IMPORT\(json)")
                
                ProgressHUD.showSuccess("นำเข้าข้อมูลเรียบร้อย")
                self.historyJSON = nil
                self.myTableView.reloadData()
                //self.loadHistory(showLoadingHUD: false)
                self.loadHistory(monthYear: self.mySelectedDate)
            }
        }
    }
    
    @IBAction func deleteClick(_ sender: UIButton) {
        var superview = sender.superview
        while let view = superview, !(view is UITableViewCell) {
            superview = view.superview
        }
        guard let cell = superview as? UITableViewCell else {
            print("button is not contained in a table view cell")
            return
        }
        guard let indexPath = myTableView.indexPath(for: cell) else {
            print("failed to get index path for cell containing button")
            return
        }
        print("Delete \(indexPath.section) - \(indexPath.item)")
        
        let cellArray = historyJSON![indexPath.item]
        print(cellArray["cs_id"])
        
        SwiftAlertView.show(title: "ยืนยันการลบข้อมูลการออกกำลังกาย",
                            message: nil,
                            buttonTitles: "ยกเลิก", "ยืนยัน") { alert in
            //alert.backgroundColor = .yellow
            alert.titleLabel.font = .Alert_Title
            alert.messageLabel.font = .Alert_Message
            alert.titleLabel.textColor = .themeColor
            
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
                                    self.loadDelete(cs_id: cellArray["cs_id"].stringValue)
                                default:
                                    break
                                }
                            }
    }
    
    func loadDelete(cs_id: String) {
        print("Delete \(cs_id)")
        let parameters:Parameters = ["cs_id":cs_id]
        loadRequest(method:.post, apiName:"history/delete", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS DELETE\(json)")

                ProgressHUD.showSuccess("ลบข้อมูลเรียบร้อย")
                self.historyJSON = nil
                self.myTableView.reloadData()
                //self.loadHistory(showLoadingHUD: false)
                self.loadHistory(monthYear: self.mySelectedDate)
            }
        }
    }
}

//extension TimeInterval{
//    
//    func stringFromTimeInterval() -> String {
//        
//        let time = NSInteger(self)
//        
//        //let ms = Int((self.truncatingRemainder(dividingBy: 1)) * 1000)
//        let seconds = time % 60
//        let minutes = (time / 60) % 60
//        let hours = (time / 3600)
//        
//        //return String(format: "%0.2d:%0.2d:%0.2d.%0.3d",hours,minutes,seconds,ms)
//        return String(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds)
//    }
//}
//
//extension Measurement where UnitType == UnitLength {
//    private static let usFormatted: MeasurementFormatter = {
//       let formatter = MeasurementFormatter()
//        formatter.locale = Locale(identifier: "en_US")
//        formatter.unitOptions = .providedUnit
//        //formatter.numberFormatter.numberStyle = .decimal
//        formatter.numberFormatter.maximumFractionDigits = 2
//        //formatter.unitStyle = .short
//        return formatter
//    }()
//    var usFormatted: String { Measurement.usFormatted.string(from: self) }
//}
//
//extension Measurement where UnitType == UnitEnergy {
//    private static let usFormatted: MeasurementFormatter = {
//       let formatter = MeasurementFormatter()
//        formatter.locale = Locale(identifier: "en_US")
//        formatter.unitOptions = .providedUnit
//        //formatter.numberFormatter.numberStyle = .decimal
//        formatter.numberFormatter.maximumFractionDigits = 0
//        //formatter.unitStyle = .short
//        return formatter
//    }()
//    var usFormatted: String { Measurement.usFormatted.string(from: self) }
//}
//
//extension Double {
//    // Rounds the double to decimal places value
//    func rounded(toPlaces places:Int) -> Double {
//        let divisor = pow(10.0, Double(places))
//        return (self * divisor).rounded() / divisor
//    }
//}
