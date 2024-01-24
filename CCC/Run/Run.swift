//
//  Run.swift
//  CCC
//
//  Created by Truk Karawawattana on 25/12/2564 BE.
//

import HealthKit
import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import CoreMotion
import SwiftAlertView
import SideMenuSwift

enum Sex {
    case male
    case female
}

enum RunSession {
    case notStarted
    case active
    case pause
    case finished
}

enum Movement {
    case Stationary
    case Walking
    case Running
    case Automotive
}

class Run: UIViewController {
    
    var runJSON : JSON?
    
    var runCalPerMin:Float = 7.0
    var walkCalPerMin:Float = 4.0
    
    var timeArray = [Date]()
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var kmLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var calorieLabel: UILabel!
    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var startBtn: MyButton!
    @IBOutlet weak var pauseBtn: MyButton!
    @IBOutlet weak var stopBtn: MyButton!
    
    var state: RunSession = .notStarted
    var movementState: Movement = .Stationary
    
    var timer: Timer!
    var startDate: Date!
    var endDate: Date!
    var countDownTimer: Timer!
    var countDownNumber: Int!
    
    var workoutEvents: [HKWorkoutEvent] = []
    
    var durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = [.pad]
        return formatter
    }()
    
    var totalDistance: Double!
    var totalDuration: Double!
    var totalStep: Int!
    var totalCalories: Double!
    
    var previousDistance: Double!
    var previousStep: Int!
    
    var cacheDistance: Double = 0
    var cacheDuration: Double = 0
    var cacheStep: Int = 0
    
    //Default
    var userSex: Sex = .male
    
    // Provides to create an instance of the CMMotionActivityManager.
    private let activityManager = CMMotionActivityManager()
    // Provides to create an instance of the CMPedometer.
    private let pedometer = CMPedometer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("RUN")
        
        NotificationCenter.default.addObserver(self, selector: #selector(beforeTerminate), name: UIApplication.willTerminateNotification, object: nil)
        
//        cacheStep = 200
//        cacheDistance = 0.7
//        cacheDuration = 750
        
        clearWorkout()
    }
    
    @objc func beforeTerminate(notification:NSNotification) {
        // Save your data here
        print("Save running data...")
        writeToAppleHealth()
    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        NotificationCenter.default.removeObserver(self)
//    }
    
    func startPedometer() {
        activityManager.startActivityUpdates(to: OperationQueue.main) { (activity: CMMotionActivity?) in
            guard let activity = activity else { return }
            DispatchQueue.main.async {
                if activity.stationary {
                    print("Stationary")
                    self.movementState = .Stationary
                } else if activity.walking {
                    print("Walking")
                    self.movementState = .Walking
                } else if activity.running {
                    print("Running")
                    self.movementState = .Running
                } else if activity.automotive {
                    print("Automotive")
                    self.movementState = .Automotive
                }
            }
        }
        
        if CMPedometer.isStepCountingAvailable() {
            pedometer.startUpdates(from: Date()) { pedometerData, error in
                guard let pedometerData = pedometerData, error == nil else { return }
                
                DispatchQueue.main.async {
                    //print(pedometerData.numberOfSteps.intValue)
                    self.totalStep = self.previousStep + pedometerData.numberOfSteps.intValue
                    self.totalDistance = self.previousDistance + pedometerData.distance!.doubleValue/1000
                    
                    //print("Step per sec = \(pedometerData.currentCadence!.intValue)")
                    //print("Sec per meter = \(pedometerData.currentPace!.intValue)")
                }
            }
        }
    }
    
    func stopPedometer() {
        activityManager.stopActivityUpdates()
        pedometer.stopUpdates()
        
        previousDistance = totalDistance
        previousStep = totalStep
    }
    
    func updateActivity() {
//        print("TIME = \(timeArray)")
//        let elapsed = Date().timeIntervalSince(timeArray[0])
//        print("ELAPSE = \(elapsed) sec\n")
        var sumDuration = 0.0
        
        for i in 0..<timeArray.count{
            if i%2 == 0 {
                if i == timeArray.count-1{
                    let newSession = Double(Date().timeIntervalSince(timeArray.last!))
                    //print("New = \(newSession) sec")
                    sumDuration += newSession
                }
            }
            else{// >0
                let oldSession = Double(timeArray[i].timeIntervalSince(timeArray[i-1]))
                //print("Old Duration = \(oldSession) sec")
                sumDuration += oldSession
            }
        }
        //print("SUM = \(sumDuration) sec\n")
        totalDuration = round(sumDuration+cacheDuration)
        
        totalCalories = Double(totalStep/15)
        
        /*
        if state == .active{
            //totalDuration += 1
            
            switch movementState {
            case .Stationary:
                break
            case .Walking:
                let totalCalPerMin = (1/60) * walkCalPerMin * SceneDelegate.GlobalVariables.userWeight
                totalCalories += Double(totalCalPerMin)/60
//                switch userSex {
//                case .male:
//                    //let distancePerStepMeter = userHeightMeter * 0.415
//                    //let distanceMeter = Double(totalStep)*distancePerStepMeter
//                    //totalDistance = distanceMeter/1000
//                    totalCalories += 0.1
//
//                case .female:
//                    //let distancePerStepMeter = userHeightMeter * 0.413
//                    totalCalories += 0.1
//                }
            case .Running:
                let totalCalPerMin = (1/60) * runCalPerMin * SceneDelegate.GlobalVariables.userWeight
                totalCalories += Double(totalCalPerMin)/60
                
//                switch userSex {
//                case .male:
//                    totalCalories += 0.2
//
//                case .female:
//                    totalCalories += 0.2
//                }
            case .Automotive:
                ProgressHUD.showError("You're too fast")
            }
        }
        //        หญิง ความสูง x 0.413
        //        ชาย ความสูง x 0.415
        //
        //        สมมุติถ้าเป็นชายสูง 170 cm และเดินวันละ 10,000 ก้าวระยะทางเฉลี่ยที่ได้จะเท่ากับ
        //        170 cm x 0.415 = 70.55 cm/step
        //        เดิน 10,000 ก้าว x 70.55 cm = 705500 cm.
        //        705500 cm. = 7.06 ก.ม.ครับ
        */
        updateLabels()
    }
    
    func updateLabels() {
        kmLabel.text = String(format: "%.2f", totalDistance)
        
        timeLabel.text = durationFormatter.string(from: TimeInterval(totalDuration))!
        
        stepLabel.text = String(totalStep)
        calorieLabel.text = String(format: "%.0f", totalCalories)
        
        //        let duration = Date().timeIntervalSince(startDate)
        //        timeLabel.text = durationFormatter.string(from: duration)
        //
        //        let duration = session.endDate.timeIntervalSince(session.startDate)
        //        timeLabel.text = durationFormatter.string(from: duration)
        updateBtn()
    }
    
    func updateBtn() {
        startBtn.isHidden = true
        pauseBtn.isHidden = true
        stopBtn.isHidden = true
        
        switch state {
        case .notStarted:
            startBtn.isHidden = false
        case .active:
            pauseBtn.isHidden = false
        case .pause:
            startBtn.isHidden = false
            stopBtn.isHidden = false
        case .finished:
            stopBtn.isHidden = false
            break
        }
    }
    
    @IBAction func startClick(_ sender: UIButton) {
        if state == .notStarted {
            countDown()
        }
        else if state == .pause {
            continueWorkout()
        }
    }
    
    @IBAction func pauseClick(_ sender: UIButton) {
        pauseWorkout()
    }
    
    @IBAction func stopClick(_ sender: UIButton) {
        SwiftAlertView.show(title: "จบการออกกำลังกาย",
                            message: nil,
                            buttonTitles: "ยกเลิก", "ยืนยัน") { alert in
            //alert.backgroundColor = .yellow
            alert.titleLabel.font = .Alert_Title
            alert.messageLabel.font = .Alert_Message
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
                                    self.finishWorkout()
                                default:
                                    break
                                }
                            }
    }
    
    func countDown() {
        backBtn.isHidden = true
        countDownLabel.alpha = 1
        countDownLabel.text = String(countDownNumber)
        countDownLabel.transform = CGAffineTransform.identity
        
        UIView.animate(withDuration: 1.0, animations: {
            self.countDownLabel.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.countDownLabel.alpha = 0
        }, completion: { (finished: Bool) in
            if self.countDownNumber == 1 {
                self.beginWorkout()
            }
            else{
                self.countDownNumber -= 1
                self.countDown()
            }
        })
    }
    
    func beginWorkout() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.updateActivity()
        }
        timeArray.append(Date())
        
        //ProgressHUD.showSucceed("Start")
        state = .active
        startDate = Date().addingTimeInterval(TimeInterval(-cacheDuration))
        startPedometer()
    }
    
    func pauseWorkout() {
        timeArray.append(Date())
        
        workoutEvents.append(HKWorkoutEvent(type: .pause, dateInterval: DateInterval(start: Date(),duration: 0), metadata: [:]))
        
        //ProgressHUD.showError("Pause")
        state = .pause
        stopPedometer()
    }
    
    func continueWorkout() {
        timeArray.append(Date())
        
        workoutEvents.append(HKWorkoutEvent(type: .resume, dateInterval: DateInterval(start: Date(),duration: 0), metadata: [:]))
        
        //ProgressHUD.showSucceed("Continue")
        state = .active
        startPedometer()
    }
    
    func finishWorkout() {
        
        state = .finished
        endDate = Date()
        stopPedometer()
        
        writeToAppleHealth()//อย่าลืมอัพขึ้น apple health
        //loadSubmit()
    }
    
    func clearWorkout() {
        print("CLEAR WORKOUT")
        timeArray.removeAll()
        
        totalDistance = 0.0+cacheDistance
        totalDuration = 0+cacheDuration
        totalStep = 0+cacheStep
        totalCalories = 0.0+Double(totalStep/15)
        
        previousDistance = totalDistance
        previousStep = totalStep
        
//        kmLabel.text = "0.00"
//        timeLabel.text = "0:00:00"
//        stepLabel.text = "0"
//        calorieLabel.text = "0"
        
//        kmLabel.text = String(format: "%.2f", totalDistance)
//        timeLabel.text = durationFormatter.string(from: TimeInterval(totalDuration))!
//        stepLabel.text = String(totalStep)
//        calorieLabel.text = String(format: "%.0f", totalCalories)
        
        countDownLabel.alpha = 0
        countDownNumber = 3
        
        workoutEvents.removeAll()
        
        updateLabels()
    }
    
    func writeToAppleHealth() {
//        let finish = Date() // Now
//        let start = finish.addingTimeInterval(-3600) // 1 hour ago
        
//        workoutEvents = [
//            HKWorkoutEvent(type: .pause, dateInterval: DateInterval(start: start.addingTimeInterval(300),duration: 0), metadata: [:]),
//            HKWorkoutEvent(type: .resume, dateInterval: DateInterval(start: start.addingTimeInterval(600),duration: 0), metadata: [:]),
//        ]
        
        let totalEnergyBurned = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: totalCalories)

        let totalDistance = HKQuantity(unit: HKUnit.meterUnit(with: .kilo), doubleValue: totalDistance)
        
//        let metadata: [String: AnyObject] = [
//            HKMetadataKeyGroupFitness: true,
//            HKMetadataKeyIndoorWorkout: false,
//            HKMetadataKeyCoachedWorkout: true
//        ]
        
        let meta:[String:Any] = ["channel": "CCC Workout",
                                 "step":String(format: "%d", totalStep)
            ]
        
        let workout = HKWorkout(
            activityType: .running,
            start: startDate,
            end: endDate,
            workoutEvents: workoutEvents,
            totalEnergyBurned: totalEnergyBurned,
            totalDistance: totalDistance,
            device: nil,
            metadata: meta
        )
        
        let healthStore = HKHealthStore()
        healthStore.save(workout) { success, error in
            if (error != nil) {
                print("Error: \(String(describing: error?.localizedDescription))")
                self.loadSubmit()
            }
            if success {
                print("Saved: \(success)")
                self.syncHealth(startDateStr: SceneDelegate.GlobalVariables.userLastSynced)
                
                DispatchQueue.main.async {
                    self.pushToSummary()
                }
            }
        }
    }
    
    func loadSubmit() {
        //print(totalDuration!)
        let duration = (totalDuration/60).rounded(.up)
        
        let parameters:Parameters = ["user_id":SceneDelegate.GlobalVariables.userID ,
                                     "activity_time":String(format: "%.0f", duration) ,
                                     "weight":String(format: "%.1f", SceneDelegate.GlobalVariables.userWeight) ,
                                     "step":String(format: "%d", totalStep) ,
                                     "distance":String(format: "%.0f", totalDistance) ,
                                     "summary_cal":String(format: "%.0f", totalCalories),
                                     "latitude":SceneDelegate.GlobalVariables.userLat,
                                     "longitude":SceneDelegate.GlobalVariables.userLong,
                                     
                                     "start_datetime":dateWithTimeToServerString(date: startDate),
                                     "end_datetime":dateWithTimeToServerString(date: endDate),
                                     "channel":"CCC Workout",
                                     "os_system":"iOS",
                                     "os_version":UIDevice.current.systemVersion,
                                     "app_version":Bundle.main.appVersionLong,
                                     "mac_address":UIDevice.current.identifierForVendor?.uuidString ?? ""
        ]
        print(parameters)
        
        loadRequest_V2(method:.post, apiName:"send_activity_kcal", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS RUN SUBMIT\(json)")

                self.pushToSummary()
            }
        }
    }
    
    func pushToSummary() {
        let vc = UIStoryboard.runStoryBoard.instantiateViewController(withIdentifier: "RunSummary") as! RunSummary
        vc.summaryMode = .fromRun
        vc.totalDistance = totalDistance
        vc.totalDuration = totalDuration
        vc.totalStep = totalStep
        vc.totalCalories = totalCalories
        vc.startDate = startDate
        vc.endDate = endDate
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
}
