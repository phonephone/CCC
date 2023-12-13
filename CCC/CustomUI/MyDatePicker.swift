//
//  MyDatePicker.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 8/2/2565 BE.
//

import UIKit

class MyDatePicker : UIPickerView{
//    var dateCollection = [Date]()
//    var monthCollection = [Date]()
    var yearCollection = [Date]()
    
//    func buildDateCollection()-> [Date]{
//        dateCollection.removeAll()
//        dateCollection.append(contentsOf: Date.previousYearDay())
//        dateCollection.append(contentsOf: Date.nextYearDay())
//        return dateCollection
//    }
    
//    func buildMonthCollection(previous:Int, next:Int){
//        monthCollection.removeAll()
//        monthCollection.append(contentsOf: Date.previousYearMonth(monthBackward:previous+1))
//        monthCollection.append(contentsOf: Date.nextYearMonth(monthForward: next))
//        //return monthCollection
//    }
    
    func buildYearCollection(previous:Int, next:Int){
        yearCollection.removeAll()
        yearCollection.append(contentsOf: Date.previousYearYear(yearBackward:previous+1))
        yearCollection.append(contentsOf: Date.nextYearYear(yearForward: next))
    }
    
    // MARK: - Get Today Index(row)
    //
    
//    func selectedDate()->Int{
//        var row = 0
//        for index in dateCollection.indices{
//            let today = Date()
//            if Calendar.current.compare(today, to: dateCollection[index], toGranularity: .day) == .orderedSame{
//                row = index
//            }
//        }
//        return row
//    }
    
//    func selectedMonth()->Int{
//        var row = 0
//        for index in monthCollection.indices{
//            let today = Date()
//            if Calendar.current.compare(today, to: monthCollection[index], toGranularity: .month) == .orderedSame{
//                row = index
//            }
//        }
//        return row
//    }
    
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
extension MyDatePicker : UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return yearCollection.count
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
            pickerLabel?.font = .Roboto_Regular(ofSize: 22)
            pickerLabel?.textAlignment = .center
        }
        
        pickerLabel?.text = formatDatePicker(date: yearCollection[row])
        pickerLabel?.textColor = .textDarkGray
        
        return pickerLabel!
    }
    
    func formatDatePicker(date: Date) -> String{
        let dateFormatter = DateFormatter.customFormatter
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: date)
    }
}

// MARK: - UIPickerViewDelegate
extension MyDatePicker : UIPickerViewDelegate{
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let date = formatDatePicker(date: self.yearCollection[row])
        NotificationCenter.default.post(name: .dateChanged, object: nil, userInfo:["date":date])
    }
}

// MARK: - Observer Notification Init
extension Notification.Name{
    static var dateChanged : Notification.Name{
        return .init("myDateChanged")
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

