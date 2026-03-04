//
//  DateUtil.swift
//  PocketCellar
//
//  Created by IE MacBook Pro 2014 on 12/04/24.
//

import Foundation

struct DateUtil {
    static func checkIfPurchaseAndExpiryDatesAreSame(purchaseDate: Date, expiresDate: Date) -> Bool {
        if purchaseDate.compare(expiresDate) == .orderedSame {
            print("Both dates are same")
            return true
        } else {
            return false
        }
    }
    
    static func checkIfExpiresDateIsSmallerThenCurrentDate(expiresDate: Date) -> Bool {
        print(Date())
        print(expiresDate)
        if expiresDate.compare(Date()) == .orderedDescending {
            print("Expires Date is behind current date. Subscription expired")
            return false
        } else {
            return true
        }
    }
    
    static let customDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
        return formatter
    }()
}
