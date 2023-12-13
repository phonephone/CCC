//
//  WorkoutModel.swift
//  CCC
//
//  Created by Truk Karawawattana on 25/12/2564 BE.
//

import Foundation

struct MobileRunWorkoutInterval {
  var start: Date
  var end: Date
  
  init(start: Date, end: Date) {
    self.start = start
    self.end = end
  }
  
  var duration: TimeInterval {
    return end.timeIntervalSince(start)
  }
  
  var totalEnergyBurned: Double {
    let mobileRunCaloriesPerHour: Double = 450
    let hours: Double = duration/3600
    let totalCalories = mobileRunCaloriesPerHour * hours
    return totalCalories
  }
}

struct MobileRunWorkout {
  var start: Date
  var end: Date
  var intervals: [MobileRunWorkoutInterval]
  
  init(with intervals: [MobileRunWorkoutInterval]) {
    self.start = intervals.first!.start
    self.end = intervals.last!.end
    self.intervals = intervals
  }
  
  var totalEnergyBurned: Double {
    return intervals.reduce(0) { (result, interval) in
      result + interval.totalEnergyBurned
    }
  }
  
  var duration: TimeInterval {
    return intervals.reduce(0) { (result, interval) in
      result + interval.duration
    }
  }
}
