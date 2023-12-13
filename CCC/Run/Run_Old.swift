//
//  Run_Old.swift
//  CCC
//
//  Created by Truk Karawawattana on 9/1/2565 BE.
//

//import HealthKit
//import UIKit
//import Alamofire
//import SwiftyJSON
//import ProgressHUD
//
//class Run_Old: UIViewController {
//
//    var runJSON : JSON?
//
//    @IBOutlet weak var kmLabel: UILabel!
//    @IBOutlet weak var timeLabel: UILabel!
//    @IBOutlet weak var stepLabel: UILabel!
//    @IBOutlet weak var calorieLabel: UILabel!
//    @IBOutlet weak var startBtn: MyButton!
//
//    var timer: Timer!
//
//    var session = WorkoutSession()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
//            self.updateLabels()
//        }
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        session.clear()
//        updateDoneButtonStatus()
//    }
//
//    var startTimeFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "HH:mm:ss"
//        return formatter
//    }()
//
//    var durationFormatter: DateComponentsFormatter = {
//        let formatter = DateComponentsFormatter()
//        formatter.unitsStyle = .positional
//        formatter.allowedUnits = [.minute, .second]
//        formatter.zeroFormattingBehavior = [.pad]
//        return formatter
//    }()
//
//    func updateLabels() {
//        switch session.state {
//        case .active, .pause:
//            //startTimeLabel.text = startTimeFormatter.string(from: session.startDate)
//            let duration = Date().timeIntervalSince(session.startDate)
//            timeLabel.text = durationFormatter.string(from: duration)
//
//            let totalCalories = session.intervals.reduce(0) { (result, interval) in
//                result + interval.totalEnergyBurned }
//            calorieLabel.text = "\(totalCalories)"
//        case .finished:
//            //startTimeLabel.text = startTimeFormatter.string(from: session.startDate)
//            let duration = session.endDate.timeIntervalSince(session.startDate)
//            timeLabel.text = durationFormatter.string(from: duration)
//
//            let totalCalories = session.intervals.reduce(0) { (result, interval) in
//                result + interval.totalEnergyBurned }
//            calorieLabel.text = "\(totalCalories)"
//        default:
//            timeLabel.text = "0:00:00"
//            stepLabel.text = "0"
//            calorieLabel.text = "0"
//        }
//    }
//
//    @IBAction func startClick(_ sender: UIButton) {
//        switch session.state {
//        case .notStarted, .finished:
//            ProgressHUD.showSucceed("Start")
//            beginWorkout()
//        case .pause:
//            ProgressHUD.showError("Pause")
//        case .active:
//            finishWorkout()
//        }
//    }
//
//    func beginWorkout() {
//        session.start()
//        updateLabels()
//        updateDoneButtonStatus()
//    }
//
//    func finishWorkout() {
//        session.end()
//        updateLabels()
//        updateDoneButtonStatus()
//    }
//
//    func pauseWorkout() {
//        session.pause()
//        updateLabels()
//        updateDoneButtonStatus()
//    }
//
//    func updateDoneButtonStatus() {
//        var isEnabled = false
//
//        switch session.state {
//        case .notStarted, .active:
//            isEnabled = false
//        case .pause, .finished:
//            isEnabled = true
//        }
//        //navigationItem.rightBarButtonItem?.isEnabled = isEnabled
//    }
//}
