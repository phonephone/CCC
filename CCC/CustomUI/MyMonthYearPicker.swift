//
//  MyMonthYearPicker.swift
//  CCC
//
//  Created by Truk Karawawattana on 19/12/2566 BE.
//

import UIKit

enum myPickerMode {
    case month
    case month2
    case year
}

class MyMonthYearPicker : UIPickerView{
    var pickerMode:myPickerMode?
    var monthCollection = [Date]()
    var yearCollection = [Date]()
    
    func buildMonthCollection(previous:Int, next:Int){
        monthCollection.removeAll()
        monthCollection.append(contentsOf: Date.previousYearMonth(monthBackward:previous+1))
        monthCollection.append(contentsOf: Date.nextYearMonth(monthForward: next))
    }
    
    func buildYearCollection(previous:Int, next:Int){
        yearCollection.removeAll()
        yearCollection.append(contentsOf: Date.previousYearYear(yearBackward:previous+1))
        yearCollection.append(contentsOf: Date.nextYearYear(yearForward: next))
    }
    
    func selectedMonth()->Int{
        var row = 0
        for index in monthCollection.indices{
            let today = Date()
            if Calendar.current.compare(today, to: monthCollection[index], toGranularity: .month) == .orderedSame{
                row = index
            }
        }
        return row
    }
    
    func selectedYear()->Int{
        var row = 0
        for index in yearCollection.indices{
            let today = Date()
            if Calendar.current.compare(today, to: yearCollection[index], toGranularity: .year) == .orderedSame{
                row = index
            }
        }
        return row
    }
}

// MARK: - UIPickerViewDataSource
extension MyMonthYearPicker : UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerMode {
        case .month:
            return monthCollection.count
            
        case .month2:
            return monthCollection.count
            
        case .year:
            return yearCollection.count
            
        default :
            return 0
        }
    }
    
    //    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    //        if component == 0 {
    //            let label = formatMonthPicker(date: monthCollection[row])
    //            return label
    //        }
    //        else{
    //            let label = formatYearPicker(date: yearCollection[row])
    //            return label
    //        }
    //    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = .Prompt_Regular(ofSize: 22)
            pickerLabel?.textAlignment = .center
        }
        
        switch pickerMode {
        case .month:
            pickerLabel?.text = formatMonthPicker(date: monthCollection[row])
            
        case .month2:
            pickerLabel?.text = formatMonthPicker(date: monthCollection[row])
            
        case .year:
            pickerLabel?.text = formatYearPicker(date: yearCollection[row])
            
        default :
            pickerLabel?.text = ""
        }
        
        pickerLabel?.textColor = .textDarkGray
        
        return pickerLabel!
    }
    
    func formatMonthPicker(date: Date) -> String{
        let dateFormatter = DateFormatter.customFormatter
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: date)
    }
    
    func formatYearPicker(date: Date) -> String{
        let dateFormatter = DateFormatter.customFormatter
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: date)
    }
}

// MARK: - UIPickerViewDelegate
extension MyMonthYearPicker : UIPickerViewDelegate{
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerMode {
        case .month:
            let date = formatMonthPicker(date: self.monthCollection[row])
            NotificationCenter.default.post(name: .monthChanged, object: nil, userInfo:["date":date])
            
        case .month2:
            let date = formatMonthPicker(date: self.monthCollection[row])
            NotificationCenter.default.post(name: .monthChanged2, object: nil, userInfo:["date":date])
            
        case .year:
            let date = formatYearPicker(date: self.yearCollection[row])
            NotificationCenter.default.post(name: .yearChanged, object: nil, userInfo:["date":date])
            
        default :
            break
        }
    }
}

// MARK: - Observer Notification Init
extension Notification.Name{
    static var monthChanged : Notification.Name{
        return .init("myMonthChanged")
    }
    
    static var monthChanged2 : Notification.Name{
        return .init("myMonthChanged2")
    }
    
    static var yearChanged : Notification.Name{
        return .init("myYearChanged")
    }
}

// MARK: - Date extension
extension Date {
    //    static func nextYearDay() -> [Date]{
    //        return Date.nextDay(numberOfDays: 365, from: Date())
    //    }
    //
    //    static func previousYearDay()-> [Date]{
    //        return Date.nextDay(numberOfDays: 365, from: Calendar.current.date(byAdding: .year, value: -1, to: Date())!)
    //    }
    //
    //    static func nextDay(numberOfDays: Int, from startDate: Date) -> [Date]{
    //        var dates = [Date]()
    //        for i in 0..<numberOfDays {
    //            if let date = Calendar.current.date(byAdding: .day, value: i, to: startDate) {
    //                dates.append(date)
    //            }
    //        }
    //        return dates
    //    }
    
    static func nextYearMonth(monthForward:Int) -> [Date]{
        //return Date.nextMonth(numberOfMonth: monthForward, from: Date())
        return Date.nextMonth(numberOfMonth: monthForward, from: Calendar.current.date(byAdding: .month, value: +1, to: Date())!)
    }
    
    static func previousYearMonth(monthBackward:Int)-> [Date]{
        return Date.previousMonth(numberOfMonth: monthBackward, from: Date())
    }
    
    static func nextMonth(numberOfMonth: Int, from startDate: Date) -> [Date]{
        var dates = [Date]()
        for i in 0..<numberOfMonth {
            if let date = Calendar.current.date(byAdding: .month, value: i, to: startDate) {
                dates.append(date)
            }
        }
        return dates
    }
    
    static func previousMonth(numberOfMonth: Int, from startDate: Date) -> [Date]{
        var dates = [Date]()
        for i in 0..<numberOfMonth {
            if let date = Calendar.current.date(byAdding: .month, value: -i, to: startDate) {
                dates.insert(date, at: 0)
            }
        }
        return dates
    }
    
    
    static func nextYearYear(yearForward:Int) -> [Date]{
        return Date.nextYear(numberOfYear: yearForward, from: Calendar.current.date(byAdding: .year, value: +1, to: Date())!)
    }
    
    static func previousYearYear(yearBackward:Int)-> [Date]{
        return Date.previousYear(numberOfYear: yearBackward, from: Date())
    }
    
    static func nextYear(numberOfYear: Int, from startDate: Date) -> [Date]{
        var dates = [Date]()
        for i in 0..<numberOfYear {
            if let date = Calendar.current.date(byAdding: .year, value: i, to: startDate) {
                dates.append(date)
            }
        }
        return dates
    }
    
    static func previousYear(numberOfYear: Int, from startDate: Date) -> [Date]{
        var dates = [Date]()
        for i in 0..<numberOfYear {
            if let date = Calendar.current.date(byAdding: .year, value: -i, to: startDate) {
                dates.insert(date, at: 0)
            }
        }
        return dates
    }
}


