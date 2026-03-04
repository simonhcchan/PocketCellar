//
//  PurchaseConfiguration.swift
//  PocketCellar
//
//  Created by IE MacBook Pro 2014 on 12/04/24.
//

import Foundation

struct IAPConstant {
    //ReceiptURL
    static let kReceiptVerifyURL = "https://sandbox.itunes.apple.com/verifyReceipt"
    static let kReceiptProductionVerifyURL = "https://buy.itunes.apple.com/verifyReceipt"
    //UpdateUserMinute
    static let kAvailableMinutes                            = "AvailableMinutes"
    static let kIsExpired                                   = "IsExpired"
    //Receipt Data
    static let kReceiptData                                 = "receipt-data"
    static let kReceiptPassword                             = "password"
    static let kExcludeOldTransactions                      = "exclude-old-transactions"
    static let kReceiptStatus                               = "status"
    static let kReceipt                                     = "receipt"
    static let kLatestReceipt                               = "latest_receipt"
    static let kLatestReceiptInfo                           = "latest_receipt_info"
    static let kLatestExpiredReceiptInfo                    = "latest_expired_receipt_info"
    static let kPendingRenewalInfo                          = "pending_renewal_info"
    static let kProductId                                   = "product_id"
    static let kInApp                                       = "in_app"
    static let kExpiresDate                                 = "expires_date"
    static let kPurchaseDate                                = "purchase_date"
    static let kAutoRenewStatus                             = "auto_renew_status"
    static let kCancellationReason                          = "cancellation_reason"
    static let kCancellationDate                            = "cancellation_date"
    static let kIsSubscriptionActive                        = "subscription_active"
    static let kOriginalTransactionId                       = "original_transaction_id"
    static let kTransactionId                               = "transaction_id"
    static let kExpiresDateMS                               = "expires_date_ms"
    static let kLifeTimeTransactionId                       = "LifeTimeTransactionId"
    static let kReStoreTransactionId                        = "ReStoreTransactionId"
    static let kUserSubscriptionInfo                        = "UserSubscriptionInfo"
}

struct UserDefaultsKeys {
    
    static let launchApplication   =  "launch"
    static let isAlreadyLaunched   =  "isAppAlreadyLaunchedOnce"
    static let expiryDate          =  "ExpireDate"
    static let userId              =  "userid"
    static let userName            =  "userName"
    static let expiryStatus        =  "expiryStatus"
    static let currentSubscription =  "currentSubscription"
    static let originalUserId      =  "originalUserId"
    static let mobile              =  "mobile"
    static let email               =  "email"
    static let emailRemember       =  "emailRemember"
    static let RememberCheck       =  "RememberCheck"
}

