//
//  WorkoutDataStore.swift
//  CCC
//
//  Created by Truk Karawawattana on 20/12/2564 BE.
//

import HealthKit
import Alamofire
import SwiftyJSON
import ProgressHUD

class WorkoutDataStore {
    
    class func loadWorkouts(startDate:Date,
                            completion:@escaping ([HKWorkout]?, Error?) -> Void) {
        //1. Get all workouts with the "Other" activity type.
        //let runningPredicate = HKQuery.predicateForWorkouts(with: .running)
        //let walkingPredicate = HKQuery.predicateForWorkouts(with: .walking)
        //let otherPredicate = HKQuery.predicateForWorkouts(with: .other)
        
        //2. Get all workouts that only came from this app.
        //let sourcePredicate = HKQuery.predicateForObjects(from: .default())
        let notUserPredicate = HKQuery.predicateForObjects(withMetadataKey:  HKMetadataKeyWasUserEntered, operatorType: .notEqualTo, value: true)
        
        //DATE FILTER
        //let startDate = Calendar.current.date(byAdding: .day, value: -30, to: Date())
        let endDate = Date()
        //let startDate = DateFormatter.serverFormatter.date(from: "2022-01-01")//"yyyy-MM-dd"
        //let endDate = DateFormatter.serverFormatter.date(from: "2023-01-01")//"yyyy-MM-dd"
        
        let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options:[.strictStartDate,.strictEndDate])
        
        //3. Combine the predicates into a single predicate.
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates:
                                                        [notUserPredicate,datePredicate])//, sourcePredicate])
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate,
                                              ascending: false)
        
        let query = HKSampleQuery(
            sampleType: .workoutType(),
            predicate: compoundPredicate,
            limit: 0,
            sortDescriptors: [sortDescriptor]) { (query, samples, error) in
                DispatchQueue.main.async {
                    guard
                        let samples = samples as? [HKWorkout],
                        error == nil
                    else {
                        completion(nil, error)
                        return
                    }
                    
                    completion(samples, nil)
                }
            }
        HKHealthStore().execute(query)
    }
    
    class func syncWorkouts(startDate:Date,
                            completion:@escaping (Bool) -> Void) {
        
        HealthKitSetupAssistant.authorizeHealthKit { (authorized, error) in
            guard authorized else {
                if let error = error {
                    print("HealthKit Authorization Failed : \(error.localizedDescription)")
                }
                return
            }
            
            print("HealthKit Successfully Authorized.")
            print("Lat = \(SceneDelegate.GlobalVariables.userLat)\nLong = \(SceneDelegate.GlobalVariables.userLong)")
            WorkoutDataStore.loadWorkouts(startDate: startDate, completion: { (workouts, error) in
                if workouts!.count > 0
                {
                    var parameters: [String: Any] = ["id":SceneDelegate.GlobalVariables.userID]
                    var data = [Any]()
                    
                    let myGroup = DispatchGroup()
                    
                    for i in 0..<workouts!.count{
                        myGroup.enter()
                        let cellArray = workouts![i] as HKWorkout
                        let workoutID = cellArray.uuid.uuidString
                        let sourceName = String(describing:cellArray.sourceRevision.source.name)
                        let type: HKWorkoutActivityType = cellArray.workoutActivityType
                        
                        let startDate = DateFormatter.serverWihtTimeFormatter.string(from: cellArray.startDate)
                        let endDate = DateFormatter.serverWihtTimeFormatter.string(from: cellArray.endDate)
                        let duration = String(format:"%.0f", cellArray.duration)
                        
                        var workOutArray: [String: String] = [:]
                        workOutArray["os_system"] = "iOS"
                        workOutArray["os_version"] = UIDevice.current.systemVersion
                        workOutArray["app_version"] = Bundle.main.appVersionLong
                        workOutArray["mac_address"] = UIDevice.current.identifierForVendor?.uuidString
                        
                        let meta:[String:Any]? = cellArray.metadata
                        let channel = meta?["channel"]
                        if channel != nil {
                            workOutArray["channel"] = String(describing: channel!)
                        } else {
                            workOutArray["channel"] = "CCC Sync"
                        }
                        
                        let step = meta?["step"]
                        if step != nil {
                            workOutArray["step"] = String(describing: step!)
                        } else {
                            workOutArray["step"] = ""
                        }
                        
                        workOutArray["id"] = workoutID
                        workOutArray["source_name"] = sourceName
                        workOutArray["activity_type"] = type.name
                        workOutArray["startdate"] = startDate
                        workOutArray["enddate"] = endDate
                        workOutArray["duration"] = duration
                        
                        if let caloriesBurned = cellArray.totalEnergyBurned?.doubleValue(for: .kilocalorie()) {
                            let kCalBurn = String(format:"%.0f",caloriesBurned)
                            workOutArray["calorie"] = kCalBurn
                        }else{
                            workOutArray["calorie"] = ""
                        }
                        
                        if let distance = cellArray.totalDistance?.doubleValue(for: .meter()) {
                            let kmDistance = distance/1000
                            let roundedDistance = String(format:"%.2f", kmDistance)//"\((distance/1000).rounded(toPlaces: 2))"
                            workOutArray["distance"] = roundedDistance
                        }else{
                            workOutArray["distance"] = ""
                        }
                        workOutArray["latitude"] = SceneDelegate.GlobalVariables.userLat
                        workOutArray["longitude"] = SceneDelegate.GlobalVariables.userLong
                        
                        let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
                        let predicate = HKQuery.predicateForSamples(withStart: cellArray.startDate, end: cellArray.endDate, options: .strictEndDate)
                        
                        let query = HKStatisticsQuery.init(quantityType: hrType,
                                                           quantitySamplePredicate: predicate,
                                                           options: HKStatisticsOptions.discreteAverage) { (query, results, error) in
                            let beats = results?.averageQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
                            
                            if beats != nil {
                                workOutArray["heart_rate"] = String(Int(beats!))
                            }
                            else{
                                workOutArray["heart_rate"] = ""
                            }
                            
                            //print("BPM = \(String(Int(beats!)))")
                            //print(JSON(workOutArray))
                            data.append(workOutArray)
                            myGroup.leave()
                        }
                        HKHealthStore().execute(query)
                    }// end for loop
                    
                    myGroup.notify(queue: .main) {
                        //print("Finished all query.")
                        
                        parameters["data"] = data
                        print(JSON(parameters))
                        
                        let fullURL = HTTPHeaders.baseURL+"history/sync"
                        let headers = HTTPHeaders.headerWithAuthorize
                        AF.request(fullURL,
                                   method: .post,
                                   parameters: parameters,
                                   encoding: JSONEncoding.default,
                                   headers: headers,
                                   requestModifier: { $0.timeoutInterval = 60 }
                        ).responseJSON { response in
                            
                            //debugPrint(response)
                            switch response.result {
                            case .success(let data as AnyObject):
                                let json = JSON(data)
                                print("SUCCESS SYNC \(json)")
                                
                                if json["message"] == "success" {
                                    print(json["data"][0]["message"].stringValue)
                                    //ProgressHUD.showSucceed(json["data"][0]["message"].stringValue)
                                    
                                    SceneDelegate.GlobalVariables.reSyncHealth = false
                                    
                                    SceneDelegate.GlobalVariables.reloadHome = true
                                    SceneDelegate.GlobalVariables.reloadMyCalory = true
                                    SceneDelegate.GlobalVariables.reloadCredit = true
                                }
                                else{
                                    print(json["message"].stringValue)
                                    //ProgressHUD.showError(json["message"].stringValue)
                                }
                                completion(true)
                                
                            case .failure(let error):
                                print(error.localizedDescription)
                                //ProgressHUD.showError(error.localizedDescription)
                                completion(false)
                                
                            default:
                                fatalError("received non-dictionary JSON response")
                            }
                        }
                    }
                }
                else{
                    print("ไม่พบข้อมูลหรือไม่ได้รับอนุญาตให้เข้าถึงข้อมูลจาก Apple Health")
                    //ProgressHUD.showError("ไม่พบข้อมูลหรือไม่ได้รับอนุญาตให้เข้าถึงข้อมูลจาก Apple Health")
                }
            })// end loadWorkout
        }//end authorizeHealthKit
    }
    
    //    class func loadWalkRunning(completion:
    //                                       @escaping ([HKQuantitySample]?, Error?) -> Void) {
    //        //1. Get all workouts with the "Other" activity type.
    //        //let runningPredicate = HKQuery.predicateForWorkouts(with: .running)
    //        //let walkingPredicate = HKQuery.predicateForWorkouts(with: .walking)
    //
    //        //2. Get all workouts that only came from this app.
    //        //let sourcePredicate = HKQuery.predicateForObjects(from: .default())
    //        let notUserPredicate = HKQuery.predicateForObjects(withMetadataKey:  HKMetadataKeyWasUserEntered, operatorType: .notEqualTo, value: true)
    //
    //        //3. Combine the predicates into a single predicate.
    //        let compound = NSCompoundPredicate(orPredicateWithSubpredicates:
    //                                            [notUserPredicate])//, sourcePredicate])
    //
    //        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate,
    //                                              ascending: false)
    //
    //        let distanceType =  HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!
    //
    //        let query = HKSampleQuery(
    //          sampleType: distanceType,
    //          predicate: compound,
    //          limit: 0,
    //          sortDescriptors: [sortDescriptor]) { (query, samples, error) in
    //            DispatchQueue.main.async {
    //              guard
    //                let samples = samples as? [HKQuantitySample],
    //                error == nil
    //                else {
    //                  completion(nil, error)
    //                  return
    //              }
    //
    //              completion(samples, nil)
    //            }
    //          }
    //        HKHealthStore().execute(query)
    //    }
    
    
    class func save(mobileRunWorkout: MobileRunWorkout,
                    completion: @escaping ((Bool, Error?) -> Swift.Void)) {
        
        let healthStore = HKHealthStore()
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .other
        let builder = HKWorkoutBuilder(healthStore: healthStore,
                                       configuration: workoutConfiguration,
                                       device: .local())
        
        builder.beginCollection(withStart: mobileRunWorkout.start) { (success, error) in
            guard success else {
                completion(false, error)
                return
            }
        }
        
        let samples = self.samples(for: mobileRunWorkout)
        
        builder.add(samples) { (success, error) in
            guard success else {
                completion(false, error)
                return
            }
            
            builder.endCollection(withEnd: mobileRunWorkout.end) { (success, error) in
                guard success else {
                    completion(false, error)
                    return
                }
                
                builder.finishWorkout { (workout, error) in
                    let success = error == nil
                    completion(success, error)
                }
            }
        }
    }
    
    
    private class func samples(for workout: MobileRunWorkout) -> [HKSample] {
        //1. Verify that the energy quantity type is still available to HealthKit.
        guard let energyQuantityType = HKSampleType.quantityType(
            forIdentifier: .activeEnergyBurned) else {
            fatalError("*** Energy Burned Type Not Available ***")
        }
        
        //2. Create a sample for each MobileRunWorkout
        let samples: [HKSample] = workout.intervals.map { interval in
            let calorieQuantity = HKQuantity(unit: .kilocalorie(),
                                             doubleValue: interval.totalEnergyBurned)
            
            return HKCumulativeQuantitySample(type: energyQuantityType,
                                              quantity: calorieQuantity,
                                              start: interval.start,
                                              end: interval.end)
        }
        
        return samples
    }
    
    // MARK: - STEP
    class func loadSteps(startDate:Date, completion: @escaping (Any) -> Void) {
        let now = Date()
        
        var interval = DateComponents()
        interval.day = 1
        
        var anchorComponents = Calendar.current.dateComponents([.day, .month, .year], from: now)
        anchorComponents.hour = 0
        let anchorDate = Calendar.current.date(from: anchorComponents)!
        
        let query = HKStatisticsCollectionQuery(
            quantityType: HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            quantitySamplePredicate: nil,
            options: [.cumulativeSum],
            anchorDate: anchorDate,
            intervalComponents: interval
        )
        
        var stepsArr = [Any]()
        var stepAndDate:[String: String] = [:]
        query.initialResultsHandler = { _, results, error in
            guard let results = results else {
                print("Error returned form resultHandler = \(String(describing: error?.localizedDescription))")
                return
            }
            
            results.enumerateStatistics(from: startDate, to: now) { statistics, _ in
                if let sum = statistics.sumQuantity() {
                    let steps = Int(sum.doubleValue(for: HKUnit.count()))
                    let date = DateFormatter.serverWihtTimeFormatter.string(from: statistics.startDate)
                    
                    //print("Amount of steps: \(steps), date: \(statistics.startDate)")
                    stepAndDate["step"] = "\(steps)"
                    stepAndDate["date"] = "\(date)"
                    stepsArr.append(stepAndDate)
                }
            }
            //print(stepsArr)
            completion(stepsArr)
        }
        
        let healthStore = HKHealthStore()
        healthStore.execute(query)
    }
    
    class func syncSteps(startDate:Date,
                         completion:@escaping (Bool) -> Void) {
        
        HealthKitSetupAssistant.authorizeHealthKit { (authorized, error) in
            guard authorized else {
                if let error = error {
                    print("HealthKit Authorization Failed : \(error.localizedDescription)")
                }
                return
            }
            
            print("HealthKit Successfully Authorized. (STEP)")
            
            WorkoutDataStore.loadSteps(startDate: startDate, completion: { (steps) in
                if (steps as AnyObject).count > 0
                {
                    var parameters: [String: Any] = ["id":SceneDelegate.GlobalVariables.userID]
                    parameters["data"] = steps
                    print(JSON(parameters))
                    
                    let fullURL = HTTPHeaders.baseURL_V2+"step_daily/sync"
                    let headers = HTTPHeaders.headerWithAuthorize
                    AF.request(fullURL,
                               method: .post,
                               parameters: parameters,
                               encoding: JSONEncoding.default,
                               headers: headers,
                               requestModifier: { $0.timeoutInterval = 60 }
                    ).responseJSON { response in
                        
                        //debugPrint(response)
                        switch response.result {
                        case .success(let data as AnyObject):
                            let json = JSON(data)
                            print("SUCCESS SYNC STEP \(json)")
                            
                            if json["message"] == "success" {
                                print(json["data"][0]["message"].stringValue)
                                //ProgressHUD.showSucceed(json["data"][0]["message"].stringValue)
                            }
                            else{
                                print(json["message"].stringValue)
                                //ProgressHUD.showError(json["message"].stringValue)
                            }
                            completion(true)
                            
                        case .failure(let error):
                            print(error.localizedDescription)
                            //ProgressHUD.showError(error.localizedDescription)
                            completion(false)
                            
                        default:
                            fatalError("received non-dictionary JSON response")
                        }
                    }
                }
                else{
                    print("ไม่พบข้อมูลหรือไม่ได้รับอนุญาตให้เข้าถึงข้อมูลจาก Apple Health (STEP)")
                    //ProgressHUD.showError("ไม่พบข้อมูลหรือไม่ได้รับอนุญาตให้เข้าถึงข้อมูลจาก Apple Health")
                }
            })// end loadSteps
        }//end authorizeHealthKit
    }
    
}//end Class

// MARK: - UIViewController
extension UIViewController {
    func syncHealth(startDateStr:String) {
        let startDate = self.dateFromServerString(dateStr:startDateStr)// "2022-01-01")
        WorkoutDataStore.syncWorkouts(startDate: startDate!, completion: { (success) in
            if success {}
        })
    }
    
    func syncSteps(startDateStr:String) {
        let startDate = self.dateFromServerString(dateStr:startDateStr)// "2022-01-01")
        WorkoutDataStore.syncSteps(startDate: startDate!, completion: { (success) in
            if success {}
        })
    }
    
    func getStepsCount(forSpecificDate:Date, completion: @escaping (Double) -> Void) {
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        let now = Date()
        let startOfDay = forSpecificDate//Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(
            quantityType: stepsQuantityType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0)
                return
            }
            completion(sum.doubleValue(for: HKUnit.count()))
        }
        
        let healthStore = HKHealthStore()
        healthStore.execute(query)
    }
    
    func getStepsHistory(fromSpecificDate:Date, completion: @escaping (Any) -> Void) {
        let now = Date()
        let startDate = fromSpecificDate//Calendar.current.date(byAdding: .day, value: -30, to: now)!
        
        var interval = DateComponents()
        interval.day = 1
        
        var anchorComponents = Calendar.current.dateComponents([.day, .month, .year], from: now)
        anchorComponents.hour = 0
        let anchorDate = Calendar.current.date(from: anchorComponents)!
        
        let query = HKStatisticsCollectionQuery(
            quantityType: HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            quantitySamplePredicate: nil,
            options: [.cumulativeSum],
            anchorDate: anchorDate,
            intervalComponents: interval
        )
        
        var stepsArr = [Any]()
        var stepAndDate:[String: String] = [:]
        query.initialResultsHandler = { _, results, error in
            guard let results = results else {
                print("Error returned form resultHandler = \(String(describing: error?.localizedDescription))")
                return
            }
            
            
            results.enumerateStatistics(from: startDate, to: now) { statistics, _ in
                if let sum = statistics.sumQuantity() {
                    let steps = Int(sum.doubleValue(for: HKUnit.count()))
                    let date = DateFormatter.serverWihtTimeFormatter.string(from: statistics.startDate)
                    
                    print("Amount of steps: \(steps), date: \(statistics.startDate)")
                    stepAndDate["step"] = "\(steps)"
                    stepAndDate["date"] = "\(date)"
                    stepsArr.append(stepAndDate)
                }
            }
            //print(stepsArr)
            completion(stepsArr)
        }
        
        let healthStore = HKHealthStore()
        healthStore.execute(query)
    }
}
