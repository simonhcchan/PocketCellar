//
//  IAP.swift
//  PocketCellar
//
//  Created by IE MacBook Pro 2014 on 11/04/24.
//

import Foundation
import UIKit
import StoreKit

protocol GetProductsPrice {
    func didReceivedProducts(products: [SKProduct])
}

private let purchaseIdentifierYearly = "com.pocketcellar.yearly"

class IAPHelper: NSObject {
    
    static let shared = IAPHelper()
    var products = [SKProduct]()
    let paymentQueue = SKPaymentQueue.default()
    var purchasedProductName: String?
    var hasReceiptData: Bool {
        return loadReceipt() != nil
    }
     var delegate: GetProductsPrice?
    
    let PurchaseSuccess = Notification.Name("PurchaseSuccess")
    let PurchaseFailed = Notification.Name("PurchaseFailed")
    let PurchaseRestored = Notification.Name("PurchaseRestored")
    let NoPurchasesToRestore = Notification.Name("NoPurchasesToRestore")
    
    
    private override init() { }
    
    func getProducts() {

        let products: Set = [purchaseIdentifierYearly]
        let request = SKProductsRequest(productIdentifiers: products)
        request.delegate = self
        request.start()
        paymentQueue.add(self)
    }
    
    func purchase(product: String) {
        print(product)
        print(products)
        print(products.first?.productIdentifier)
        let ptp = products.filter({ $0.productIdentifier == product })
        print(ptp.first?.productIdentifier)
        guard let productToPurchase = products.filter({ $0.productIdentifier == product }).first else
        { return }
        let payment = SKPayment(product: productToPurchase)
        paymentQueue.add(payment)
    }
    
    func restorePurchase() {
        print(" Restoring ")
        paymentQueue.restoreCompletedTransactions()
    }
}

extension IAPHelper {
    
    
    func returnReceipt(completion: ((_ responseData: [String: Any]?, _ success: Bool) -> Void)? = nil) {
        if let receiptData = loadReceipt() {
            IAPServices.shared.upload(receipt: receiptData) { (result) in
                switch result {
                case .success(let result):
                        print("Pending Status: \(result.responseData)")
                        completion?(result.responseData, true)
                case .failure(let error):
                    print(" Return Receipt Failed: \(error)")
                    completion?(nil, false)
                }
            }
        }
    }


    func uploadReceipt(completion: ((_ success: Bool) -> Void)? = nil) {
        if let receiptData = loadReceipt() {
            IAPServices.shared.upload(receipt: receiptData) { (result) in
                switch result {
                case .success(let result):
                    if result.status == 0 {
                        print("Pending Status:\(result.responseData)")
                        completion?(true)
                    } else {
                        completion?(false)
                    }
                case .failure(let error):
                    print("🚫 Receipt Upload Failed: \(error.localizedDescription)")
                    completion?(false)
                }
            }
        }
    }
    
    private func loadReceipt() -> Data? {
        guard let url = Bundle.main.appStoreReceiptURL else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            return data
        } catch {
            print("Error loading receipt data: \(error.localizedDescription)")
            return nil
        }
    }
}

extension IAPHelper : SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
            // Check if any products were returned
            guard !response.products.isEmpty else {
                print("No products found")
                return
            }
        self.products = response.products
        self.delegate?.didReceivedProducts(products: response.products)
            // Process each product
            for product in response.products {
                print("Product identifier: \(product.productIdentifier)")
                print("Product title: \(product.localizedTitle)")
                print("Product price: \(product.price)")
                // You can store the product information or update your UI here
              
            }
        }
        
        func request(_ request: SKRequest, didFailWithError error: Error) {
            print("Failed to retrieve products: \(error.localizedDescription)")
            // Handle the error, such as informing the user or retrying later
        }
    
    
    
//    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
//        print(response.products)
//        self.products = response.products
//        
//
//    }
}

extension IAPHelper : SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
         for transaction in transactions {
            
            print(transaction.transactionState.status())
            print(transaction.payment.productIdentifier)
            print(transaction.transactionDate as Any)
            print(transaction.transactionIdentifier as Any)
            print(transaction.original?.transactionIdentifier as Any)
         
            switch transaction.transactionState {
                
            case .purchasing:
                print("purchasing Queue")
                break
            case .purchased:
                handlePurchasedState(for: transaction, in: queue, isRestored: false)
                NotificationCenter.default.post(name: PurchaseSuccess, object: nil)
                
                break
            case .failed:
                NotificationCenter.default.post(name: PurchaseFailed, object: transaction.error)
                
                break
            case .restored:
                handlePurchasedState(for: transaction, in: queue, isRestored: true)
                NotificationCenter.default.post(name: PurchaseRestored, object: nil)
                break
            case .deferred:
                handlePurchasedState(for: transaction, in: queue, isRestored: false)
               NotificationCenter.default.post(name: PurchaseFailed, object: nil)
                break
            default:
                queue.finishTransaction(transaction)
            }
        }
    }
    
    func handlePurchasedState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue, isRestored: Bool) {
        
        print("User purchased product id: \(transaction.payment.productIdentifier)")
        print("transactionIdentifier: \(String(describing: transaction.transactionIdentifier))")
        print("original transactionIdentifier: \(String(describing: transaction.original?.transactionIdentifier))")
        
        let productDict = ["product": transaction] as [String : Any]
        
        let productIds = [purchaseIdentifierYearly]
        if productIds.contains(transaction.payment.productIdentifier) || transaction.transactionState == .deferred {
            uploadReceipt { (success) in
                DispatchQueue.main.async {
                    if success {
                        if let expireDate = IAPServices.shared.expireDate {
                            print(" Monthly Expiry Date - \(expireDate)")
                            UserDefaults.standard.set(expireDate, forKey: UserDefaultsKeys.expiryDate)
                            queue.finishTransaction(transaction)
                            NotificationCenter.default.post(name: self.PurchaseSuccess, object: nil, userInfo: productDict)
                        } else {
                            NotificationCenter.default.post(name: self.PurchaseFailed, object: nil)
                        }
                    } else {
                        NotificationCenter.default.post(name: self.PurchaseFailed, object: nil)
                    }
                }
            }
        }
        else {
            queue.finishTransaction(transaction)
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
            if queue.transactions.isEmpty {
                NotificationCenter.default.post(name: NoPurchasesToRestore, object: nil)
            } else {
                NotificationCenter.default.post(name: PurchaseRestored, object: nil)
            }
        }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print(" Restore Failed")
        NotificationCenter.default.post(name: PurchaseFailed, object: nil)
    }
}

extension SKPaymentTransactionState {
    
    func status() -> String {
        switch self {
        case .deferred: return("deferred")
        case .failed: return("failed")
        case .purchased: return("purchased")
        case .purchasing: return("purchasing")
        case .restored: return("restored")
        default: return("default")
        }
    }
}




import Foundation

private let iapAccountSecret = "0bf5b2c649fe40e9b61c841c04f5b0bf"

import Foundation

 enum Resultt<T> {
    case failure(SelfieServiceError)
    case success(T)
}

 typealias UploadReceiptCompletion = (_ result: Resultt<(responseData: [String: Any], status: Int)>) -> Void

 enum SelfieServiceError: Error {
    case missingAccountSecret
    case invalidSession
    case noActiveSubscription
    case other(Error)
}

 class IAPServices {
    
    public static let shared = IAPServices()
    let simulatedStartDate: Date
    public var expireDate: Date?
    public var purchaseDate: Date?
    public var productId: String?
    public var transactionId: String?
    
    
    init() {
        let persistedDateKey = "SubscriptionStartDate"
        if let persistedDate = UserDefaults.standard.object(forKey: persistedDateKey) as? Date {
            simulatedStartDate = persistedDate
        } else {
            let date = Date().addingTimeInterval(-30) // 30 second difference to account for server/client drift.
            UserDefaults.standard.set(date, forKey: "SubscriptionStartDate")
            
            simulatedStartDate = date
        }
    }
    
    // getting receipt for apple id user
    public func upload(receipt data: Data, completion: @escaping UploadReceiptCompletion) {
        let constant = IAPConstant.self
        let body = [constant.kReceiptData: data.base64EncodedString(),
                    constant.kReceiptPassword: iapAccountSecret,
                    constant.kExcludeOldTransactions: true] as [String : Any]
        
        PurchaseAPIService.verifyInAppReceipt(requestBody: body) { (responseData, error) in
            if let error = error {
                completion(.failure(.other(error)))
            } else if let responseData = responseData {
                print(responseData)
                do {
                    let jsonData = try JSONSerialization.jsonObject(with: responseData, options: JSONSerialization.ReadingOptions.mutableLeaves)
                    print("Receipt Data: \(jsonData)")
                    if let dictionary = jsonData as? [String: Any],
                       let pendingRenewalInfo = dictionary[constant.kPendingRenewalInfo] as? NSArray,
                       let pendingRenewal = pendingRenewalInfo.firstObject as? [String: Any] {
                        
                        if let autoRenewStatus = pendingRenewal[constant.kAutoRenewStatus] as? String, let originalTransactionId = pendingRenewal[constant.kOriginalTransactionId] as? String  {
                            
                            print(" * OriginalTransactionId - \(originalTransactionId)")
                            
                            UserDefaultsUtil.originalTransactionId = originalTransactionId
                            expirationDateFromResponse(jsonResponse: dictionary)
                            
                            
                            if autoRenewStatus == "1" {
                                UserDefaultsUtil.isSubscriptionActive = true

                                if let receiptStatus = dictionary[constant.kReceiptStatus] as? Int {
                                    let result = (responseData: pendingRenewal, status: receiptStatus)
                                    completion(.success(result))
                                }
                            } else {
                                // Check if the subscription is active, then don't treat it as an error
                                if UserDefaultsUtil.isSubscriptionActive ?? false {
                                    // Subscription is still active, so treat it as a success
                                    let result = (responseData: pendingRenewal, status: 0) // Assuming status 0 indicates success
                                    completion(.success(result))
                                } else {
                                    // Handle the case where auto-renew subscription is not active (e.g., expired or canceled)
                                    UserDefaultsUtil.isSubscriptionActive = false
                                    let error = NSError(domain: "Auto-renew subscription is not active.", code: 0, userInfo: nil)
                                    completion(.failure(.other(error)))
                                }
                            }
                            
                            
                            
                            
                            
                          //  if autoRenewStatus == "1" {
//                                UserDefaultsUtil.isSubscriptionActive = true
//                                
//                                if let receiptStatus = dictionary[constant.kReceiptStatus] as? Int {
//                                    let result = (responseData: pendingRenewal, status: receiptStatus)
//                                    //                                let result = (responseData: pendingRenewal, status: jsonData[constant.kReceiptStatus].intValue)
//                                    completion(.success(result))
//                                }
                                
//                            } else {
//                                UserDefaultsUtil.isSubscriptionActive = false
//                                let error = NSError(domain: "Auto renew subscription has been expired.", code: 0, userInfo: nil)
//                                completion(.failure(.other(error)))
//                            }
                        }
                    }
                } catch {
                    print(error)
                }
            }
        }
        
        func expirationDateFromResponse(jsonResponse: [String: Any]) {
            let constant = IAPConstant.self
            
            print(jsonResponse)
            
            var arraySubscriptionInfo: [[String:Any]] = []
            
            if let arrayReceiptInfo = jsonResponse[constant.kLatestReceiptInfo] as? NSArray {
                print(arrayReceiptInfo)
                IAPManager.shared.saveLatestReceiptInfo(latestReceiptInfo: arrayReceiptInfo)
                
                for receiptInfo in arrayReceiptInfo {
                    var dictionarySubscriptionInfo: [String: Any] = [:]
                    
                    if let dictionary = receiptInfo as? [String:Any] {
                        
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
                        
                        if let expireDateStr = dictionary[constant.kExpiresDate] as? String,
                           let expireDate = formatter.date(from: expireDateStr) as Date?,
                           let purchaseDateStr = dictionary[constant.kPurchaseDate] as? String,
                           let purchaseDate = formatter.date(from: purchaseDateStr) as Date?,
                           let productId = dictionary[constant.kProductId] as? String,
                           let transactionId = dictionary[constant.kTransactionId] as? String {
                            self.productId = productId
                            self.expireDate = expireDate
                            self.purchaseDate = purchaseDate
                            self.transactionId = transactionId
                            UserDefaultsUtil.subscriptionExpireDate = self.expireDate
                            UserDefaultsUtil.subscriptionPurchaseDate = self.purchaseDate
                            UserDefaultsUtil.subscriptionProductId = self.productId
                            UserDefaultsUtil.transactionId = self.transactionId
                            
//                            let isSubscribed = !DateUtil.checkIfExpiresDateIsSmallerThenCurrentDate(expiresDate: expireDate)
//                            print(isSubscribed)
                            
                            //if isSubscribed {
                                
                                if let productId = dictionary[constant.kProductId] as? String {
                                    print(productId)
                                    dictionarySubscriptionInfo["ProductId"] = productId
                                    dictionarySubscriptionInfo["PurchaseDate"] = purchaseDate
                                    dictionarySubscriptionInfo["ExpiresDate"] = expireDate
                                    arraySubscriptionInfo.append(dictionarySubscriptionInfo)
                                }
                          //  }
                            print("** Expire Date: - \(expireDate) ** Purchase Date - \(purchaseDate)")
                        }
                    }
                }
                UserDefaultsUtil.userSubscriptionInfo = arraySubscriptionInfo
            }
        }
    }
}
    
