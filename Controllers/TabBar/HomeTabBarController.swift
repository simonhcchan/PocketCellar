//
//  HomeTabBarController.swift
//  PocketCellar
//
//  Created by IE15 on 14/03/24.
//

import UIKit
import Firebase
import AdSupport
import AppTrackingTransparency
import FirebaseMessaging

class HomeTabBarController: UITabBarController {
    var purchaseDate: String = ""
    var expireDate: String = ""
    var productId: String = ""
    var transactionId: String = ""
    var originalTransactionId: String = ""
    var fbPurchaseDate: String = ""
    var fbExpireDate: String = ""
    var fbProductId: String = ""
    var fboriginalTransactionId: String = ""
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        requestPermission()
        guard let userId = UserDefaultsManager.getUserEmail() else { return }
        getUserDetails(userID: userId)
        setTabBarTitles()
        let idfa = ASIdentifierManager.shared().advertisingIdentifier
        print("IDFA: \(idfa.uuidString)")
        if UserDefaultsManager.getFcmToken() != nil {
            Messaging.messaging().subscribe(toTopic: "newPost") { error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("Subscribed to weather topic")
                }
            }
        }
        returnReceiptInfo()
        
        
    }
    
    func requestPermission() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    print("Authorized")
                    print(ASIdentifierManager.shared().advertisingIdentifier)
                case .denied:
                    print("Denied")
                case .notDetermined:
                    print("Not Determined")
                case .restricted:
                    print("Restricted")
                @unknown default:
                    print("Unknown")
                }
            }
        }
    }
    func returnReceiptInfo() {
        IAPHelper.shared.returnReceipt { responseData, success in
            if success {
                if let responseData = responseData {
                    print("Received Data: \(responseData)")
                    self.manageSubscriptionInfo()
                } else {
                    print("Received Data is nil")
                }
            } else {
                // manageSubscriptionInfo()
                print("Receipt info not found")
            }
        }
    }
    
    func setTabBarTitles() {
        
        let titles: [String] = ["Home","Cellar World","My Cellar","Settings"]
        
        guard titles.count <= tabBar.items?.count ?? 0 else {
            print("Error: Number of titles exceeds the number of tab bar items.")
            return
        }
        for (index, title) in titles.enumerated() {
            tabBar.items?[index].title = title.localized()
        }
    }
    
    func getUserDetails(userID: String) {
        let userRef = Firestore.firestore().collection("users").document(userID)
        
        userRef.getDocument { (document, error) in
            if let error = error {
                print("Error fetching document: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                if let data = document.data(), let firstName = data["userFirstName"] as? String, let lastName = data["userLastName"] as? String {
                    // Retrieve first name and last name from the document data
                    let userName = firstName + " \(lastName)"
                    UserDefaultsManager.setUserName(name: userName)
                } else {
                    print("Document data is invalid")
                }
            } else {
                // Document does not exist
            }
        }
    }
}

extension HomeTabBarController {
    
    func manageSubscriptionInfo() {
        DispatchQueue.main.async {
            self.getLatestSubscriptionDetails()
            guard let email = UserDefaults.standard.string(forKey: UserDefaultsKeys.userId)else { return }
            UserDefaults.standard.setValue(email, forKey: UserDefaultsKeys.originalUserId)
            self.checkOriginalTransactionIDForAllUsers(originalTransactionID: self.originalTransactionId) { matchingUserIDs, error in
                if let error = error {
                    // Handle the error
                    print("Error: \(error)")
                    return
                }
                if matchingUserIDs.isEmpty {
                    print("No users found with the original transaction ID.")
                    // UserDefaults.standard.setValue(email, forKey: "originalUserId")
                    // original id exist false
                    //originalTIdExist = false
                    UserDefaults.standard.set(false, forKey: "isUserSubscribed")
                } else {
                    print("Users found with the original transaction ID:")
                    for userID in matchingUserIDs {
                        print(userID)
                        // originalTIdExist = true
                        if email == userID {
                            //  userIsSame = true
                            print("email reterived \(email)")
                            // add tokens to account logged in with
                            self.addTheUpdatedSubscriptionDetails()
                        } else {
                            // add tokens to the returned user id
                            UserDefaults.standard.setValue(userID, forKey: UserDefaultsKeys.originalUserId)
                            self.addTheUpdatedSubscriptionDetails()
                        }
                    }
                }
            }
            // check for original transaction id
            // if user have original transaction id update token
            // else tokens transfer to id associated with it
        }
    }
    
    func getLatestSubscriptionDetails() {
        
        if let purchaseDate = UserDefaultsUtil.subscriptionPurchaseDate {
            print("purchaseDate:\(purchaseDate)")
            self.purchaseDate = "\(purchaseDate)"
        } else {
            print("No user subscription info saved.")
        }
        if let expireDate = UserDefaultsUtil.subscriptionExpireDate {
            print("expireDate:\(expireDate)")
            self.expireDate = "\(expireDate)"
        } else {
            print("No user subscription info saved.")
        }
        if let productId = UserDefaultsUtil.subscriptionProductId {
            print("productId:\(productId)")
            self.productId = productId
        } else {
            print("No user subscription info saved.")
        }
        if let transactionId = UserDefaultsUtil.transactionId {
            print("productId:\(transactionId)")
            self.transactionId = transactionId
        } else {
            print("No user subscription info saved.")
        }
        if let originalTransactionId = UserDefaultsUtil.originalTransactionId {
            print("productId:\(originalTransactionId)")
            self.originalTransactionId = originalTransactionId
        } else {
            print("No user subscription info saved.")
        }
    }
    
    
    func addTheUpdatedSubscriptionDetails() {
        getLastSubscriptionDetailsFromFirebase() { success in
            if success {
                if self.fbProductId == self.productId {
                    print(self.fbExpireDate)
                    print(self.expireDate)
                    self.compareDates(firstDateString: self.fbExpireDate, secondDateString: self.expireDate)
                } else {
                    let productID = self.productId
                    //handleProduct(withID: productID)
                    print("Product id not same")
                }
            } else {
                UserDefaults.standard.set(false, forKey: "isUserSubscribed")
                print("No subscription detail found")
                
            }
        }
    }
    
    func compareDates(firstDateString: String, secondDateString: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss +0000"
        if let firstDate = dateFormatter.date(from: firstDateString),
           let secondDate = dateFormatter.date(from: secondDateString) {
            let comparisonResult = firstDate.compare(secondDate)
            if comparisonResult == .orderedSame {
                print("The dates are the same.")
                UserDefaults.standard.set(true, forKey: "isUserSubscribed")
            } else if comparisonResult == .orderedAscending {
                print("The first date is smaller than the second date.")
                UserDefaults.standard.set(true, forKey: "isUserSubscribed")
                saveSubscriptionDetailsToFirebase(productId: productId, transactionId: transactionId, transactionDate: purchaseDate, status: "purchased", expiryDate: expireDate, originalTransactionId: originalTransactionId ) { success in
                    if success {
                        print("Success")
                        // handleProduct(withID: productId)
                    }
                }
            } else if comparisonResult == .orderedDescending {
                print("The first date is bigger than the second date.")
                UserDefaults.standard.set(false, forKey: "isUserSubscribed")
            }
        } else {
            print("Invalid date format.")
        }
    }
    
    
    func saveSubscriptionDetailsToFirebase(productId: String, transactionId: String, transactionDate: String, status: String,expiryDate: String,originalTransactionId: String, completion: @escaping (Bool) -> Void) {
        saveSubscriptionDetails(productId: productId, transactionId: transactionId, transactionDate: transactionDate, status: status, expiryDate: expiryDate, originalTransactionId: originalTransactionId) { success in
            if success {
                print("saved Successfully")
                completion(true)
            }else {
                print("ErrorWhile saving")
                completion(false)
            }
        }
    }
    func getLastSubscriptionDetailsFromFirebase(completion: @escaping (Bool) -> Void) {
        getSubscriptionDetailsFromFirebase { success, expiry, purchaseDate, productId, originalTransactionId in
            if success {
                if let expiry = expiry, let purchaseDate = purchaseDate, let productId = productId , let originalTransactionId = originalTransactionId  {
                    // Handle the subscription details
                    print("fbExpiry Date: \(expiry)")
                    print("fbPurchase Date: \(purchaseDate)")
                    print("fbProduct ID: \(productId)")
                    self.fboriginalTransactionId = "\(originalTransactionId)"
                    self.fbExpireDate = "\(expiry)"
                    self.fbPurchaseDate = "\(purchaseDate)"
                    self.fbProductId = "\(productId)"
                    completion(true)
                } else {
                    print("Subscription details not available")
                    completion(false)
                }
            } else {
                print("Failed to retrieve subscription details")
                completion(false)
            }
        }
    }
    
    func checkOriginalTransactionIDForAllUsers(originalTransactionID: String, completion: @escaping ([String], Error?) -> Void) {
        let db = Firestore.firestore()
        let userDetailsCollection = db.collection("users")
        userDetailsCollection.getDocuments { snapshot, error in
            if let error = error {
                completion([], error)
                return
            }
            var matchingUserIDs: [String] = []
            if let documents = snapshot?.documents {
                for document in documents {
                    let userID = document.documentID
                    let subscriptionDetailsCollection = userDetailsCollection
                        .document(userID)
                        .collection("subscriptionDetail")
                        .document("currentSubscription")
                    subscriptionDetailsCollection.getDocument { snapshot, error in
                        if let error = error {
                            completion([], error)
                            return
                        }
                        if let document = snapshot, document.exists {
                            let data = document.data()
                            let originalID = data?["originalTransactionId"] as? String
                            if originalID == originalTransactionID {
                                matchingUserIDs.append(userID)
                                completion(matchingUserIDs, nil)
                            }
                        }
                    }
                }
            } else {
                completion([], nil)
            }
        }
    }
    func getSubscriptionDetailsFromFirebase(completion: @escaping (Bool, String?, String?, String?, String?) -> Void) {
        guard let userid = UserDefaults.standard.string(forKey: UserDefaultsKeys.originalUserId)else { return }
        let documentRef = Firestore.firestore().collection("usersDetail")
            .document(userid).collection("subscriptionDetail").document("currentSubscription")
        documentRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let expiry = document.data()?["ExpiryDate"] as? String ,let purchaseDate = document.data()?["Transaction Date"],let productId = document.data()?["productId"],
                   let originalTransactionId = document.data()?["originalTransactionId"] {
                    print("fbExpiry\(expiry)")
                    print("fbpurchase\(purchaseDate)")
                    print("fbproductId\(productId)")
                    print("fboriginalTransactionId\(originalTransactionId)")
                    completion(true, expiry, (purchaseDate as! String), (productId as! String), originalTransactionId as! String)
                } else {
                    print(" subscription Data not found")
                    completion(false, nil, nil, nil, nil)
                }
            } else {
                print("getSubscription Document Doesnot exist")
                completion(false, nil, nil, nil, nil)
            }
        }
    }
    
    func saveSubscriptionDetails(productId: String, transactionId: String, transactionDate: String, status: String, expiryDate: String, originalTransactionId: String, completion: @escaping (Bool) -> Void  ) {
        guard let userid = UserDefaultsManager.getUserEmail() else { return }
        DispatchQueue.main.async {
            let documentRef = Firestore.firestore().collection("users")
                .document(userid).collection("subscriptionDetail").document("currentSubscription")
            documentRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    if let expiry = document.data()?["ExpiryDate"] as? String {
                        let expiry = self.convertToDate(dateString: expiry, format: "yyyy-MM-dd HH:mm:ss +0000")
                        if self.checkIfExpired(expiryDate: expiry) {
                            documentRef.updateData(["productId": productId,
                                                    "transactionId": transactionId,
                                                    "originalTransactionId": originalTransactionId,
                                                    "Transaction Date": transactionDate,
                                                    "status": status,
                                                    "ExpiryDate": expiryDate ]) { error in
                                if let error = error {
                                    completion(false)
                                    print("Error updating document: \(error)")
                                } else {
                                    print("Document updated successfully.")
                                    completion(true)
                                }
                            }
                        } else {
                            completion(false)
                            print("subscription is not expired yet")
                            return
                        }
                    } else {
                        completion(false)
                        print("error while fetchinh expiry date")
                    }
                } else {
                    Firestore.firestore().collection("users").document(userid).collection("subscriptionDetail").document("currentSubscription").setData([
                        "productId": productId,
                        "transactionId": transactionId,
                        "Transaction Date": transactionDate,
                        "originalTransactionId": originalTransactionId,
                        "status": status,
                        "ExpiryDate": expiryDate
                    ]) { err in
                        if let err = err {
                            completion(false)
                            print("Error writing document: \(err)")
                        } else {
                            completion(true)
                            print("Document successfully written!")
                        }
                    }
                }
            }
        }
    }
    
    func convertToDate(dateString: String, format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: dateString)
    }
    func checkIfExpired(expiryDate: Date?) -> Bool {
        if let expiryDate = expiryDate {
            let currentDateAsString = getTodayDateString() // Get today's date as a String
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss +0000"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            if let currentDate = dateFormatter.date(from: currentDateAsString) {
                return expiryDate < currentDate // Compare two Date objects
            }
        }
        return false // Return false if not expired or if expiryDate is nil
    }
    
    func getTodayDateString() -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss +0000"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        return dateFormatter.string(from: currentDate)
    }
    
}







