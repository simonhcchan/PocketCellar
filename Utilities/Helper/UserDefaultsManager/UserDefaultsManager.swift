//
//  UserDefaultsManager.swift
//  PocketCellar
//
//  Created by IE MacBook Pro 2014 on 29/03/24.
//

import Foundation

class UserDefaultsManager {
    
    // UserDefaults keys
    private static let userEmailKey = "UserEmail"
    private static let userNameKey = "UserName"
    private static let isUserLoggedIn = "UserLoggedIn"
    private static let fcmToken = "FcmToken"
    private static let isShowingAds = "showingAds"
    private static let rememberMe = "rememberMe"
    private static let userPassword = "userPassword"
    private static let notification = "notification"
    private static let applyLanguages = "ApplyLanguages"
    private static let googleIDTokenKey = "googleIDToken"
    private static let facebookAccessTokenKey = "facebookAccessToken"
    private static let appleIDTokenKey = "appleIDToken"
    private static let appleNonceKey = "appleNonce"
    private static let googleAccessTokenKey = "googleAccessToken"

      static func setGoogleIDToken(idToken: String) {
           UserDefaults.standard.set(idToken, forKey: googleIDTokenKey)
       }
       
       static func getGoogleIDToken() -> String? {
           return UserDefaults.standard.string(forKey: googleIDTokenKey)
       }
    
      static func setGoogleAccessToken(accessToken: String) {
           UserDefaults.standard.set(accessToken, forKey: googleAccessTokenKey)
       }
       
       static func getGoogleAccessToken() -> String? {
           return UserDefaults.standard.string(forKey: googleAccessTokenKey)
       }
       static func setFacebookAccessToken(accessToken: String) {
           UserDefaults.standard.set(accessToken, forKey: facebookAccessTokenKey)
       }
       
       static func getFacebookAccessToken() -> String? {
           return UserDefaults.standard.string(forKey: facebookAccessTokenKey)
       }
    
       static func setAppleNonce(nonce: String) {
            UserDefaults.standard.set(nonce, forKey: appleNonceKey)
        }
        
        static func getAppleNonce() -> String? {
            return UserDefaults.standard.string(forKey: appleNonceKey)
        }
       static func setAppleIDToken(idToken: String) {
           UserDefaults.standard.set(idToken, forKey: appleIDTokenKey)
       }
       
       static func getAppleIDToken() -> String? {
           return UserDefaults.standard.string(forKey: appleIDTokenKey)
       }
    // Function to set user email ID
    static func setUserEmail(email: String) {
        UserDefaults.standard.set(email, forKey: userEmailKey)
    }
    
    // Function to get user email ID
    static func getUserEmail() -> String? {
        return UserDefaults.standard.string(forKey: userEmailKey)
    }
    
    // Function to set user password
    static func setUserPassword(password: String) {
        UserDefaults.standard.set(password, forKey: userPassword)
    }
    
    // Function to get user password
    static func getUserPassword() -> String? {
        return UserDefaults.standard.string(forKey: userPassword)
    }
    
    
    // Function to set user Name
    static func setUserName(name: String) {
        UserDefaults.standard.set(name, forKey: userNameKey)
    }
    
    // Function to get user Name
    static func getUserName() -> String? {
        return UserDefaults.standard.string(forKey: userNameKey)
    }
    
    // Function to set if user Loggedin
    static func setIsUserLoggedIn(isLoggedIn: Bool) {
        UserDefaults.standard.set(isLoggedIn, forKey: isUserLoggedIn)
    }
    // Function to get if user Loggedin
    static func getIsUserLoggedIn() -> Bool? {
        return UserDefaults.standard.bool(forKey: isUserLoggedIn)
    }
    // Function to set FcmToken
    static func setFcmToken(token: String) {
        UserDefaults.standard.set(token, forKey: fcmToken)
    }
    // Function to get FcmToken
    static func getFcmToken() -> String? {
        return UserDefaults.standard.string(forKey: fcmToken)
    }
    
    // Function to set if user Loggedin
    static func setIsShowingAds(showingAds: Bool) {
        UserDefaults.standard.set(showingAds, forKey: isShowingAds)
    }
    // Function to get if user Loggedin
    static func getIsShowingAds() -> Bool? {
        return UserDefaults.standard.bool(forKey: isShowingAds)
    }
    
    // Function to set user remember me preference
    static func setIsRememberMeChecked(isChecked: Bool) {
        UserDefaults.standard.set(isChecked, forKey: rememberMe)
    }
    // Function to get user remember me preference
    static func getIsRememberMeChecked() -> Bool? {
        return UserDefaults.standard.bool(forKey: rememberMe)
    }
    
    // Function to set user remember me preference
    static func setIsNotificationAllowed(isChecked: Bool) {
        UserDefaults.standard.set(isChecked, forKey: notification)
    }
    // Function to get user remember me preference
    static func getIsNotificationAllowed() -> Bool? {
        return UserDefaults.standard.bool(forKey: notification)
    }
    
    static func setLanguages(langCode: [String]) {
        UserDefaults.standard.set(langCode, forKey: applyLanguages)
    }
    
    static func getLanguages()->[String]? {
        return UserDefaults.standard.array(forKey: applyLanguages) as? [String] 
    }
}

struct UserDefaultsUtil {
    private static let constants = IAPConstant.self
    private static let userDefaults = UserDefaults.standard
    static var subscriptionExpireDate: Date? {
        get {
            return userDefaults.value(forKey: IAPConstant.kExpiresDate) as? Date
        }
        set(newValue) {
            userDefaults.set(newValue, forKey: IAPConstant.kExpiresDate)
            userDefaults.synchronize()
        }
    }
    
    static var subscriptionPurchaseDate: Date? {
        get {
            return userDefaults.value(forKey: IAPConstant.kPurchaseDate) as? Date
        }
        set(newValue) {
            userDefaults.set(newValue, forKey: IAPConstant.kPurchaseDate)
            userDefaults.synchronize()
        }
    }
    
    static var subscriptionProductId: String? {
        get {
            return userDefaults.value(forKey: IAPConstant.kProductId) as? String
        }
        set(newValue) {
            userDefaults.set(newValue, forKey: IAPConstant.kProductId)
            userDefaults.synchronize()
        }
    }
    
    static var isSubscriptionActive: Bool? {
        get {
            return userDefaults.bool(forKey: IAPConstant.kIsSubscriptionActive)
        }
        set(newValue) {
            userDefaults.set(newValue, forKey: IAPConstant.kIsSubscriptionActive)
            userDefaults.synchronize()
        }
    }
    
    static var originalTransactionId: String? {
        get {
            return userDefaults.string(forKey: IAPConstant.kOriginalTransactionId)
        }
        set(newValue) {
            userDefaults.set(newValue, forKey: IAPConstant.kOriginalTransactionId)
            userDefaults.synchronize()
        }
    }
    
    static var transactionId: String? {
        get {
            return userDefaults.string(forKey: IAPConstant.kTransactionId)
        }
        set(newValue) {
            userDefaults.set(newValue, forKey: IAPConstant.kTransactionId)
            userDefaults.synchronize()
        }
    }
    
    static var lifeTimeTransactionId: String? {
        get {
            return userDefaults.string(forKey: IAPConstant.kLifeTimeTransactionId)
        }
        set(newValue) {
            userDefaults.set(newValue, forKey: IAPConstant.kLifeTimeTransactionId)
            userDefaults.synchronize()
        }
    }
    
    static var reStoreTransactionId: String? {
        get {
            return userDefaults.string(forKey: IAPConstant.kReStoreTransactionId)
        }
        set(newValue) {
            userDefaults.set(newValue, forKey: IAPConstant.kReStoreTransactionId)
            userDefaults.synchronize()
        }
    }

    static var userSubscriptionInfo: [[String:Any]]? {
        get {
            return userDefaults.array(forKey: IAPConstant.kUserSubscriptionInfo) as? [[String:Any]]
        }
        set(newValue) {
            userDefaults.set(newValue, forKey: IAPConstant.kUserSubscriptionInfo)
            userDefaults.synchronize()
        }
    }
    
    

}
