//
//  WorkoutSession.swift
//  CCC
//
//  Created by Truk Karawawattana on 25/12/2564 BE.
//

import Foundation

enum WorkoutSessionState {
    case notStarted
    case active
    case pause
    case finished
}

class WorkoutSession {
    private (set) var startDate: Date!
    private (set) var endDate: Date!
    
    var intervals: [MobileRunWorkoutInterval] = []
    var state: WorkoutSessionState = .notStarted
    
    func start() {
        startDate = Date()
        state = .active
    }
    
    func end() {
        endDate = Date()
        addNewInterval()
        state = .finished
    }
    
    func pause() {
        //endDate = Date()
        //addNewInterval()
        state = .pause
    }
    
    func clear() {
        startDate = nil
        endDate = nil
        state = .notStarted
        intervals.removeAll()
    }
    
    private func addNewInterval() {
        let interval = MobileRunWorkoutInterval(start: startDate,
                                                  end: endDate)
        intervals.append(interval)
    }
    
    var completeWorkout: MobileRunWorkout? {
        guard state == .finished, intervals.count > 0 else {
            return nil
        }
        
        return MobileRunWorkout(with: intervals)
    }
}
