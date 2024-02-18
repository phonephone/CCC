//
//  InterfaceController.swift
//  Watch WatchKit Extension
//
//  Created by Truk Karawawattana on 17/11/2565 BE.
//

import WatchKit
import Foundation
import WatchConnectivity
import HealthKit
import CoreMotion

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

class InterfaceController: WKInterfaceController {
    
    var runCalPerMin:Float = 7.0
    var walkCalPerMin:Float = 4.0
    
    var timeArray = [Date]()
    
    @IBOutlet weak var kmLabel: WKInterfaceLabel!
    @IBOutlet weak var timeLabel: WKInterfaceLabel!
    @IBOutlet weak var stepLabel: WKInterfaceLabel!
    @IBOutlet weak var calorieLabel: WKInterfaceLabel!
    @IBOutlet weak var countDownLabel: WKInterfaceLabel!
    @IBOutlet weak var startBtn: WKInterfaceButton!
    @IBOutlet weak var pauseBtn: WKInterfaceButton!
    @IBOutlet weak var playBtn: WKInterfaceButton!
    @IBOutlet weak var stopBtn: WKInterfaceButton!
    
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
    
    @IBOutlet weak var mainLabel: WKInterfaceLabel!
    @IBOutlet weak var userLabel: WKInterfaceLabel!
    @IBOutlet weak var sendBtn: WKInterfaceButton!
    
    var session = WCSession.default
    var i = 0
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        print("WATCH")
        
        // Configure interface objects here.
        session.delegate = self
        session.activate()
        
        clearWorkout()
    }
    
    override func didAppear () {
        super.didAppear()
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }
    
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
        
        updateLabels()
    }
    
    func updateLabels() {
        kmLabel.setText(String(format: "%.2f", totalDistance))
        
        timeLabel.setText(durationFormatter.string(from: TimeInterval(totalDuration))!)
        
        stepLabel.setText(String(totalStep))
        calorieLabel.setText(String(format: "%.0f kcal", totalCalories))
        
        //        let duration = Date().timeIntervalSince(startDate)
        //        timeLabel.text = durationFormatter.string(from: duration)
        //
        //        let duration = session.endDate.timeIntervalSince(session.startDate)
        //        timeLabel.text = durationFormatter.string(from: duration)
        updateBtn()
    }
    
    func updateBtn() {
        startBtn.setHidden(true)
        pauseBtn.setHidden(true)
        playBtn.setHidden(true)
        stopBtn.setHidden(true)
        
        switch state {
        case .notStarted:
            startBtn.setHidden(false)
        case .active:
            pauseBtn.setHidden(false)
        case .pause:
            playBtn.setHidden(false)
            stopBtn.setHidden(false)
        case .finished:
            stopBtn.setHidden(false)
            break
        }
    }
    
    @IBAction func startClick() {
        if state == .notStarted {
            countDown()
        }
        else if state == .pause {
            continueWorkout()
        }
    }
    
    @IBAction func pauseClick() {
        pauseWorkout()
    }
    
    @IBAction func stopClick() {
        let action1 = WKAlertAction.init(title: "ยกเลิก", style:.cancel) {
            print("cancel action")
        }
        
        let action2 = WKAlertAction.init(title: "ยืนยัน", style:.default) {
            print("default action")
            self.finishWorkout()
        }
        
        presentAlert(withTitle: "จบการออกกำลังกาย", message: nil, preferredStyle:.actionSheet, actions: [action1,action2])
    }
    
    func countDown() {
        //backBtn.isHidden = true
        //countDownLabel.setAlpha(1)
        countDownLabel.setText(String(countDownNumber))
        
        self.beginWorkout()
        
//        self.animate(withDuration: 1.0, animations: {
//            //self.countDownLabel.setAlpha(0)
//        }, completion: {
//            if self.countDownNumber == 1 {
//                self.beginWorkout()
//            }
//            else{
//                self.countDownNumber -= 1
//                self.countDown()
//            }
//        })
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
        
        //writeToAppleHealth()//อย่าลืมอัพขึ้น apple health
        clearWorkout()//loadSubmit()
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
        
        countDownLabel.setAlpha(0)
        countDownNumber = 3
        
        workoutEvents.removeAll()
        
        state = .notStarted
        updateLabels()
    }
    
    //    func writeToAppleHealth() {
    //
    //        let totalEnergyBurned = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: totalCalories)
    //
    //        let totalDistance = HKQuantity(unit: HKUnit.meterUnit(with: .kilo), doubleValue: totalDistance)
    //
    //        let workout = HKWorkout(
    //            activityType: .running,
    //            start: startDate,
    //            end: endDate,
    //            workoutEvents: workoutEvents,
    //            totalEnergyBurned: totalEnergyBurned,
    //            totalDistance: totalDistance,
    //            device: nil,
    //            metadata: nil
    //        )
    //
    //        let healthStore = HKHealthStore()
    //        healthStore.save(workout) { success, error in
    //            if (error != nil) {
    //                print("Error: \(String(describing: error?.localizedDescription))")
    //                self.loadSubmit()
    //            }
    //            if success {
    //                print("Saved: \(success)")
    //                self.syncHealth(startDateStr: SceneDelegate.GlobalVariables.userLastSynced)
    //
    //                DispatchQueue.main.async {
    //                    self.pushToSummary()
    //                }
    //            }
    //        }
    //    }
    //
    //    func loadSubmit() {
    //        //print(totalDuration!)
    //        let duration = (totalDuration/60).rounded(.up)
    //
    //        let parameters:Parameters = ["id":SceneDelegate.GlobalVariables.userID ,
    //                                     "activity_time":String(format: "%.0f", duration) ,
    //                                     "weight":String(format: "%.1f", SceneDelegate.GlobalVariables.userWeight) ,
    //                                     "step":String(format: "%d", totalStep) ,
    //                                     "distance":String(format: "%.0f", totalDistance) ,
    //                                     "summary_cal":String(format: "%.0f", totalCalories),
    //                                     "latitude":SceneDelegate.GlobalVariables.userLat,
    //                                     "longitude":SceneDelegate.GlobalVariables.userLong
    //        ]
    //        print(parameters)
    //
    //        loadRequest(method:.post, apiName:"send_app_run_activity_kcal", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
    //            switch result {
    //            case .failure(let error):
    //                print(error)
    //                ProgressHUD.dismiss()
    //
    //            case .success(let responseObject):
    //                let json = JSON(responseObject)
    //                print("SUCCESS RUN SUBMIT\(json)")
    //
    //                self.pushToSummary()
    //            }
    //        }
    //    }
    //
    //    func pushToSummary() {
    //        let vc = UIStoryboard.runStoryBoard.instantiateViewController(withIdentifier: "RunSummary") as! RunSummary
    //        vc.totalDistance = totalDistance
    //        vc.totalDuration = totalDuration
    //        vc.totalStep = totalStep
    //        vc.totalCalories = totalCalories
    //        vc.startDate = startDate
    //        vc.endDate = endDate
    //        self.navigationController!.pushViewController(vc, animated: true)
    //    }
    //
    //    @IBAction func back(_ sender: UIButton) {
    //        self.navigationController!.popViewController(animated: true)
    //    }
    
    @IBAction func sendClicked() {
        print("SEND FROM WATCH")
        i += 1
        let data: [String: Any] = ["watch": "Message from watch \(i)" as Any]
        session.sendMessage(data, replyHandler: nil, errorHandler: nil)
        session.transferUserInfo(data)
    }
}

extension InterfaceController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("recieved iPhone message: \(message)")
        DispatchQueue.main.async {
            if let value = message["iPhone"] as? String {
                self.mainLabel.setText(value)
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        print("recieved iPhone user: \(userInfo)")
        DispatchQueue.main.async {
            if let value = userInfo["iPhone"] as? String {
                self.userLabel.setText(value)
            }
        }
    }
    
    func animate(withDuration duration: TimeInterval,
                 animations: @escaping () -> Swift.Void,
                 completion: @escaping () -> Swift.Void) {
        
        let queue = DispatchGroup()
        queue.enter()
        
        let action = {
            animations()
            queue.leave()
        }
        
        self.animate(withDuration: duration, animations: action)
        
        queue.notify(queue: .main, execute: completion)
    }
}
