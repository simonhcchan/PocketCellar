//
//  IAPManager.swift
//  PocketCellar
//
//  Created by IE MacBook Pro 2014 on 12/04/24.
//

import Foundation

import Foundation

struct SubscriptionDetails {
    var subscriptionGroup: String
    var productId: String
    var purchaseDate: Date
    var expiresDate: Date
    var isSubscribed: Bool
}

class IAPManager: NSObject {
    
    static let shared = IAPManager()
    private override init() { }
    
    var arraySubscriptionInfo: [[String:Any]] = [[:]]
    var arraySubscriptionDetails: [SubscriptionDetails] = []
    
    func saveLatestReceiptInfo(latestReceiptInfo: NSArray) {
        print(latestReceiptInfo)
        
        for receiptInfo in latestReceiptInfo {
            let constant = IAPConstant.self
            
            var dictionarySubscriptionInfo: [String: Any] = [:]
            
            if let dictionary = receiptInfo as? [String:Any] {
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
                
                if let expireDateStr = dictionary[constant.kExpiresDate] as? String,
                   let expireDate = formatter.date(from: expireDateStr) as Date?,
                   let purchaseDateStr = dictionary[constant.kPurchaseDate] as? String,
                   let purchaseDate = formatter.date(from: purchaseDateStr) as Date? {
                    
//                    let isSubscribed = DateUtil.checkIfExpiresDateIsSmallerThenCurrentDate(expiresDate: expireDate)
//                    print(isSubscribed)
                    var subscribedGroup : String = ""
                   // if isSubscribed {
                        if let productId = dictionary[constant.kProductId] as? String {
                            print(productId)
                         
                            dictionarySubscriptionInfo["ProductId"] = productId
                            dictionarySubscriptionInfo["PurchaseDate"] = purchaseDate
                            dictionarySubscriptionInfo["ExpiresDate"] = expireDate
                            
                            let subscriptionDetails = SubscriptionDetails(subscriptionGroup: subscribedGroup, productId: productId, purchaseDate: purchaseDate, expiresDate: expireDate, isSubscribed: true)
                            arraySubscriptionDetails.append(subscriptionDetails)
                            arraySubscriptionInfo.append(dictionarySubscriptionInfo)
                        }
//                    }
//                    print("** Expire Date: - \(expireDate) ** Purchase Date - \(purchaseDate)")
//                    UserDefaults.standard.set(expireDate, forKey: UserDefaultsKeys.expiryDate)
                }
            }
        }
    }
    
    func fetchLatestReceiptInfo(subscriptionGroupName: String) {
        
        let dictionarySubscriptionInfo = arraySubscriptionDetails.filter {
            $0.subscriptionGroup == subscriptionGroupName
        }
        
        print(dictionarySubscriptionInfo.first)
    }
    
}



