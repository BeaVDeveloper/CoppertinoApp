//
//  DateExtension.swift
//  CoppertinoApp
//
//  Created by Yura Velko on 9/6/19.
//  Copyright © 2019 Yura Velko. All rights reserved.
//

import Foundation

let formatter = DateFormatter()

extension Date {
    //Convert data from search request data to actual day
    func toHistoryString() -> String {
        var historyString = ""
        
        let historyWeekday = Calendar.current.component(.weekday, from: self)
        let todayWeekday = Calendar.current.component(.weekday, from: Date())
        
        if historyWeekday == todayWeekday {
            historyString += "Today - "
        } else if historyWeekday + 1 == todayWeekday {
            historyString += "Yesterday - "
        }
        formatter.dateFormat = "MMMM dd, yyyy"
        
        historyString += formatter.string(from: self)
        return historyString
    }
    
    /*
     getDateInfo() date extension
     
     Get the actual day, number of month and year date to further properly sorting by each day
     Used in sortByDays() method in DatabaseManager
     */
    func getDateInfo() -> (day: Int, month: Int, year: Int) {
        formatter.dateFormat = "MM dd yyyy"
        let dateStr = formatter.string(from: self)
        let dateStrArray = dateStr.components(separatedBy: " ") // count = 3
        
        let day = Int(dateStrArray[1])
        let month = Int(dateStrArray.first!)
        let year = Int(dateStrArray.last!)
        
        return (day!, month!, year!)
    }
}
