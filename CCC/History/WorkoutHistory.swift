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

enum HistoryMode {
    case apple
    case appleformServer
    case all
}

class WorkoutHistory: UIViewController {
    
    var historyMode: HistoryMode?
    
    var syncedJSON : JSON?
    var historyJSON : JSON?
    
    private var workouts: [HKWorkout]?
    private var walkRun: [HKQuantitySample]?
    
    @IBOutlet weak var myTableView: UITableView!
    
    var serverwithTimeFormatter = DateFormatter.serverWihtTimeFormatter
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if historyMode == .apple {
            syncHealth(startDateStr: SceneDelegate.GlobalVariables.userLastSynced)
            reloadWorkouts()
        }
        else if historyMode == .appleformServer {
            syncHealth(startDateStr: SceneDelegate.GlobalVariables.userLastSynced)
            loadHistory(showLoadingHUD: true)
        }
        else {
            loadHistory(showLoadingHUD: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("WORKOUT HISTORY")
        self.navigationController?.setStatusBar(backgroundColor: .themeBgColor)
        
        myTableView.delegate = self
        myTableView.dataSource = self
    }
    
    //    override var preferredStatusBarStyle : UIStatusBarStyle {
    //        return .lightContent //.default for black style
    //    }
    
    func reloadWorkouts() {
        HealthKitSetupAssistant.authorizeHealthKit { (authorized, error) in
            guard authorized else {
                print("HealthKit Authorization Failed.")
                ProgressHUD.showError("ไม่ได้รับอนุญาตให้เข้าถึงข้อมูลจาก Apple Health")
                return
            }
            
            print("HealthKit Successfully Authorized.")
            let startDate = self.dateFromServerString(dateStr: "2021-01-01")
            WorkoutDataStore.loadWorkouts(startDate: startDate!, completion: { (workouts, error) in
                if workouts!.count > 0
                {
                    self.workouts = workouts
                    //print(workouts!)
                    self.myTableView.reloadData()
                    self.loadSynced(showLoadingHUD: true)
                }
                else{
                    ProgressHUD.showError("ไม่พบข้อมูลหรือไม่ได้รับอนุญาตให้เข้าถึงข้อมูลจาก Apple Health")
                }
            })
            
//            WorkoutDataStore.loadWorkouts { (workouts, error) in
//            }
        }
    }
    
    func loadSynced(showLoadingHUD:Bool) {
        let parameters:Parameters = ["id":SceneDelegate.GlobalVariables.userID]
        loadRequest(method:.post, apiName:"history/synced", authorization:true, showLoadingHUD:showLoadingHUD, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                //print("SUCCESS SYNCED\(json)")
                
                self.syncedJSON = json["data"]
                self.myTableView.reloadData()
            }
        }
    }
    
    func loadHistory(showLoadingHUD:Bool) {
        let parameters:Parameters = ["user_id":SceneDelegate.GlobalVariables.userID]
        var urlStr:String
        if historyMode == .appleformServer {
            urlStr = "history/device"
        }
        else {
            urlStr = "history"
        }
        loadRequest(method:.post, apiName:urlStr, authorization:true, showLoadingHUD:showLoadingHUD, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS HISTORY\(json)")
                
                self.historyJSON = json["data"]
                self.myTableView.reloadData()
            }
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
    
}//end ViewController

// MARK: - UITableViewDataSource

extension WorkoutHistory: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if historyMode == .apple {
            if (workouts != nil) {
                return workouts!.count
            }
            else{
                return 0
            }
        }
        else {
            if (historyJSON != nil) {
                return historyJSON!.count
            }
            else{
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140//self.myTableView.frame.height/6
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkOutCell", for: indexPath) as! WorkOutCell
        
        if historyMode == .apple {
            let cellArray = self.workouts![indexPath.row] as HKWorkout
            //print(cellArray.uuid)
            
            let sourceName = String(describing:cellArray.sourceRevision.source.name)
            //let deviceName = String(describing:cellArray.sourceRevision.productType)
            let type: HKWorkoutActivityType = cellArray.workoutActivityType

            cell.cellName.text = "\(sourceName)"+" (\(type.name))"
            
            if cellArray.device != nil
            {
                //cell.cellName.text = "\(sourceName) \(String(describing: cellArray.device!.name))"
            }
            
            let startDate = appStringFromDate(date: cellArray.startDate, format: "dd MMM yyyy HH:mm:ss")//dateFormatter.string(from:cellArray.startDate)
            //let endDate = dateFormatter.string(from:cellArray.endDate)
            
            cell.cellDate.text = "\(startDate)"// - \(endDate)"
            
            let formattedDuration = String(format: "ระยะเวลา: %@", cellArray.duration.stringFromTimeInterval())
            cell.cellDuration.text = formattedDuration
            
            if let distance = cellArray.totalDistance?.doubleValue(for: .meter()) {
                let meters: Measurement<UnitLength> = .init(value: distance, unit: .meters)
                let kmDistance = meters.converted(to: .kilometers)
                let formattedDistance = String(format: "ระยะทาง: %@", kmDistance.usFormatted)
                cell.cellDistance.text = formattedDistance
            }
            else{
                cell.cellDistance.text = "ระยะทาง: -"
            }
            
            let caloriesBurned = cellArray.totalEnergyBurned?.doubleValue(for: .kilocalorie())
            let kiloCalories: Measurement<UnitEnergy> = .init(value: caloriesBurned!, unit: .kilocalories)
            //let kiloCalories = calories.converted(to: .kilocalories)
            let formattedCalories = String(format: "แคลอรี่: %@", kiloCalories.usFormatted)
            cell.cellCalories.text = formattedCalories
            
            cell.cellImportBtn.isHidden = true
            if let items = syncedJSON?.array {
                cell.cellImportBtn.isHidden = false
                for item in items {
                    if item.stringValue == cellArray.uuid.uuidString {
                        cell.cellImportBtn.isHidden = true
                    }
                }
            }
            cell.cellImportBtn.addTarget(self, action: #selector(importClick(_:)), for: .touchUpInside)
            
            cell.cellReason.isHidden = true
        }
        else {
            let cellArray = historyJSON![indexPath.item]
            
            
            let actName = cellArray["act_name_th"].stringValue
            let actType = cellArray["activity_type"].stringValue
            let sourceName = cellArray["source_name"].stringValue
            if sourceName != "" {
                cell.cellName.text = "\(sourceName) (\(actType))"
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
            
            let formattedCalories = String(format: "แคลอรี่: %@ kCal", cellArray["summary_cal"].stringValue)
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
            
        }
        
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
        
        if historyMode == .apple {
            loadImportFromHealth(indexPath: indexPath)
        }
        else if historyMode == .appleformServer{
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
                self.loadHistory(showLoadingHUD: false)
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
                self.loadHistory(showLoadingHUD: false)
            }
        }
    }
}

extension TimeInterval{
    
    func stringFromTimeInterval() -> String {
        
        let time = NSInteger(self)
        
        //let ms = Int((self.truncatingRemainder(dividingBy: 1)) * 1000)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        
        //return String(format: "%0.2d:%0.2d:%0.2d.%0.3d",hours,minutes,seconds,ms)
        return String(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds)
    }
}

extension Measurement where UnitType == UnitLength {
    private static let usFormatted: MeasurementFormatter = {
       let formatter = MeasurementFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.unitOptions = .providedUnit
        //formatter.numberFormatter.numberStyle = .decimal
        formatter.numberFormatter.maximumFractionDigits = 2
        //formatter.unitStyle = .short
        return formatter
    }()
    var usFormatted: String { Measurement.usFormatted.string(from: self) }
}

extension Measurement where UnitType == UnitEnergy {
    private static let usFormatted: MeasurementFormatter = {
       let formatter = MeasurementFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.unitOptions = .providedUnit
        //formatter.numberFormatter.numberStyle = .decimal
        formatter.numberFormatter.maximumFractionDigits = 0
        //formatter.unitStyle = .short
        return formatter
    }()
    var usFormatted: String { Measurement.usFormatted.string(from: self) }
}

extension Double {
    // Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
