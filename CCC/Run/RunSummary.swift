//
//  RunSummary.swift
//  CCC
//
//  Created by Truk Karawawattana on 10/1/2565 BE.
//

import HealthKit
import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import SideMenuSwift

enum SummaryMode {
    case fromRun
    case fromHistory
}

class RunSummary: UIViewController {
    
    var summaryJSON : JSON?
    
    var summaryMode: SummaryMode?
    
    var totalDistance: Double!
    var totalDuration: Double!
    var totalStep: Int!
    var totalCalories: Double!
    
    var startDate: Date!
    var endDate: Date!
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var kmLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var calorieLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var submitBtn: UIButton!
    
    var durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = [.pad]
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("RUN SUMMARY")
        
        kmLabel.text = String(format: "%.2f", totalDistance)
        timeLabel.text = durationFormatter.string(from: TimeInterval(totalDuration))!
        stepLabel.text = String(totalStep)
        calorieLabel.text = String(format: "%.0f", totalCalories)
        dateLabel.text = appStringFromDate(date: endDate, format: "d MMMM yyyy")
    }
    
    @IBAction func submitClick(_ sender: UIButton) {
        if summaryMode == .fromRun {
            popToAnotherTabBar()
        }
        else if summaryMode == .fromHistory {
            self.navigationController!.popViewController(animated: true)
        }
    }
    
    func popToAnotherTabBar() {
        if let viewControllers = self.navigationController?.children {
               for vc in viewControllers {
                    if vc.isKind(of: SideMenuController.classForCoder()) {
                         print("It is in stack")
                        let sideMenuController = vc as? SideMenuController
                        let tabBar = sideMenuController?.contentViewController as? TabBar
                        tabBar?.selectedIndex = 1
                        tabBar?.tabBar(tabBar!.tabBar, didSelect: (tabBar?.tabBar.items![1])!)
                        self.navigationController!.popToRootViewController(animated: true)
                    }
               }
         }
//        let tabBar = self.navigationController?.children.first?.children.first as? TabBar
//        tabBar?.selectedIndex = 1
    }
    
    @IBAction func shareClick(_ sender: UIButton) {
        let vc = UIStoryboard.runStoryBoard.instantiateViewController(withIdentifier: "Share") as! Share
        vc.totalDistance = totalDistance
        vc.totalDuration = totalDuration
        vc.totalStep = totalStep
        vc.totalCalories = totalCalories
        vc.startDate = startDate
        vc.endDate = endDate
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    @objc func switchToDataTabCont(){
        //self.navigationController!.popToRootViewController(animated: true)
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.removeAnyViewControllers(ofKind: Run.self)
        self.navigationController!.popViewController(animated: true)
    }
}
