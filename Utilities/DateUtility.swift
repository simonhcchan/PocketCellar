//
//  DateUtility.swift
//  PocketCellar
//
//  Created by IE MacBook Pro 2014 on 23/04/24.
//

import Foundation

class DateUtility {
    static func getTimeDifference(from date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .weekOfYear, .day, .hour, .minute, .second], from: date, to: now)
        if let years = components.year, years > 0 {
            return "\(years) \(years == 1 ? "year".localized() : "years".localized()) \("ago".localized())"
        } else if let months = components.month, months > 0 {
            return "\(months) \(months == 1 ? "month".localized() : "months".localized()) \("ago".localized())"
        } else if let weeks = components.weekOfYear, weeks > 0 {
            return "\(weeks) \(weeks == 1 ? "week".localized() : "weeks".localized()) \("ago".localized())"
        } else if let days = components.day, days > 0 {
            return "\(days) \(days == 1 ? "day".localized() : "days".localized()) \("ago".localized())"
        } else if let hours = components.hour, hours > 0 {
            return "\(hours) \(hours == 1 ? "hour".localized() : "hours".localized()) \("ago".localized())"
        } else if let minutes = components.minute, minutes > 0 {
            return "\(minutes) \(minutes == 1 ? "minute".localized() : "minutes".localized()) \("ago".localized())"
        } else {
            return "\("Just now".localized())"
        }
    }
}
