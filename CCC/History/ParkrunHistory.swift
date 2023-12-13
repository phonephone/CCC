//
//  ParkrunHistory.swift
//  CCC
//
//  Created by Truk Karawawattana on 14/9/2565 BE.
//

import HealthKit
import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import SDWebImage
import SwiftAlertView

enum parkrunMode {
    case history
    case added
}

class ParkrunHistory: UIViewController {
    
    var parkrunMode: parkrunMode?
    
    var historyJSON : JSON?
    
    @IBOutlet weak var myTableView: UITableView!
    
    var serverwithTimeFormatter = DateFormatter.serverWihtTimeFormatter
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadHistory(showLoadingHUD: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("WORKOUT HISTORY")
        self.navigationController?.setStatusBar(backgroundColor: .themeBgColor)
        
        myTableView.delegate = self
        myTableView.dataSource = self
    }
    
    func loadHistory(showLoadingHUD:Bool) {
        let parameters:Parameters = ["user_id":SceneDelegate.GlobalVariables.userID]
        var urlStr:String
        if parkrunMode == .history {
            urlStr = "connect/parkrun/user/history"
        }
        else {
            urlStr = "connect/parkrun/user/history_sended"
        }
        loadRequest(method:.post, apiName:urlStr, authorization:true, showLoadingHUD:showLoadingHUD, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                //print("SUCCESS HISTORY\(json)")
                
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

extension ParkrunHistory: UITableViewDataSource {
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
            cell.cellName.text = "\(sourceName) (\(actType))"
        }
        else{
            cell.cellName.text = "\(actName)"
        }
        
//            let serverFormatter = DateFormatter()
//            serverFormatter.locale = Locale(identifier: "en_US")
//            serverFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let startDate = serverwithTimeFormatter.date(from: cellArray["startdate"].stringValue) {
            cell.cellDate.text = appStringFromDate(date: startDate, format: DateFormatter.formatDateWithTimeTH)
        }
        else{
            if let createDate = serverwithTimeFormatter.date(from: cellArray["cdate"].stringValue) {
                cell.cellDate.text = appStringFromDate(date: createDate, format: DateFormatter.formatDateWithTimeTH)
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
        
        switch parkrunMode {
        case .history:
            cell.cellImportBtn.isHidden = false
            cell.cellImportBtn.setTitle("ส่งผลการแข่งขัน", for: .normal)
            cell.cellImportBtn.addTarget(self, action: #selector(importClick(_:)), for: .touchUpInside)
            
        case .added:
            cell.cellImportBtn.isHidden = false
            cell.cellImportBtn.setTitle("แชร์", for: .normal)
            cell.cellImportBtn.addTarget(self, action: #selector(shareClick(_:)), for: .touchUpInside)
            
        default:
            cell.cellImportBtn.isHidden = true
        }
        
        cell.cellDeleteBtn.isHidden = true
        cell.cellDeleteBtn.addTarget(self, action: #selector(deleteClick(_:)), for: .touchUpInside)
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ParkrunHistory: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
        
       if parkrunMode == .history{
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
                                        self.sendActivity(indexPath: indexPath)
                                    default:
                                        break
                                    }
                                }
            
        }
    }
    
    func sendActivity(indexPath: IndexPath) {
        print("Send Activity \(indexPath.item)")
        
        let cellArray = historyJSON![indexPath.item]
        let parameters:Parameters = ["user_id":SceneDelegate.GlobalVariables.userID,
                                     "cs_id":cellArray["cs_id"]]
        loadRequest(method:.post, apiName:"connect/parkrun/user/send_activity", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS IMPORT\(json)")
                
                ProgressHUD.showSuccess("ส่งผลการแข่งขันเรียบร้อย")
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
