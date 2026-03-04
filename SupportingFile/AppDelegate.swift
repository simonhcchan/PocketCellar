//
//  AppDelegate.swift
//  PocketCellar
//
//  Created by IE14 on 12/03/24.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift
import FacebookLogin
import FacebookCore
import FirebaseMessaging
import GoogleMobileAds
import AppTrackingTransparency
import AdSupport
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.Message_ID"
    
    
    //    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions:       [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    //        registerGoogleADMob()
    //        return true
    //
    //    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        DispatchQueue.main.async {
            self.setupForTabBar()
            self.setAppThemeColor()
            self.initializeFirebase()
            self.setupNotificationAuthorization(application)
        }
        
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions:
                launchOptions
        )
        IQKeyboardManager.shared.enable = true
        registerForPushNotifications()
        self.registerGoogleADMob()
   //     ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }
    
    func registerForPushNotifications() {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
                print("Permission granted: \(granted)")
                guard granted else { return }
                self.getNotificationSettings()
            }
        }

        func getNotificationSettings() {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                print("Notification settings: \(settings)")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }

        // Called when APNs has assigned the device a unique token
        func application(_ application: UIApplication,
                         didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
            let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
            let token = tokenParts.joined()
            print("Device Token: \(token)")
           // UserDefaults.standard.set(token, forKey: "token")
            Messaging.messaging().apnsToken = deviceToken
        

        }

        func application(_ application: UIApplication,
                         didFailToRegisterForRemoteNotificationsWithError error: Error) {
            print("Failed to register: \(error)")
        }
    
    
    
    func application(application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {

                print("FCM registration token: \(token)")
            }
        }
    }
    
    private func initializeFirebase() {
            FirebaseApp.configure()
            Database.database().isPersistenceEnabled = true
            Messaging.messaging().delegate = self
        }
    
    private func setupNotificationAuthorization(_ application: UIApplication) {
           UNUserNotificationCenter.current().delegate = self
           let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
           UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
               if let error = error {
                   // Handle error
                   print("Error requesting notification authorization: \(error.localizedDescription)")
               } else if granted {
                   UserDefaultsManager.setIsNotificationAllowed(isChecked: true)
                   print("Notification authorization granted")
               } else {
                   // User denied authorization
                   UserDefaultsManager.setIsNotificationAllowed(isChecked: false)
                   print("Notification authorization denied")
               }
           }
           application.registerForRemoteNotifications()
       }
    
    
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
    }
    func setupForTabBar(){ let story = UIStoryboard(name: "Common", bundle: nil)
        let tabVC = story.instantiateViewController(withIdentifier: "HomeTabBarController") as! UITabBarController
        
        let names = [NSLocalizedString("Home", comment: "First Tab"), NSLocalizedString("Second", comment: "Second Tab"), NSLocalizedString("Third", comment: "Third Tab"), NSLocalizedString("Fourth", comment: "Fourth Tab")]
        var index = 0
        if let views = tabVC.viewControllers {
            for tab in views {
                tab.tabBarItem.title = names[index]
                index = index + 1
            }
        }
    }
    
    func registerGoogleADMob() {
        let group = DispatchGroup()
        
        group.enter()
        GADMobileAds.sharedInstance().start(completionHandler: { status in
            print("Google AdMob initialization status: \(status)")
            group.leave()
        })
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("App is about to enter the foreground")
        NotificationCenter.default.post(name: NSNotification.Name("ReloadTableNotification"), object: nil)
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("App entered the background")
    }
}

extension AppDelegate {
    
    func setAppThemeColor() {
        let appThemeColor = kUserDefault.getAppTheme()
        UIApplication.shared.windows.forEach { window in
            if appThemeColor{
                window.overrideUserInterfaceStyle = .dark
            } else{
                window.overrideUserInterfaceStyle = .light
            }
        }
    }
}


class LocalizableTabBarItem: UITabBarItem {
    @IBInspectable var localizedTitleKey: String? {
        didSet {
            if let key = localizedTitleKey {
                title = NSLocalizedString(key.localized(), comment: "")
            }
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)
                                -> Void) {
        let userInfo = notification.request.content.userInfo
        print(userInfo)
        completionHandler([[.alert, .sound]])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print(userInfo)
        completionHandler()
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult)
                     -> Void) {
        
        // TODO: Handle data of notification
        
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        print(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
}


extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        UserDefaults.standard.set(fcmToken, forKey: "token")
        print("Firebase registration token: \(String(describing: fcmToken))")
        if let token = fcmToken {
            UserDefaultsManager.setFcmToken(token: token)
            if UserDefaultsManager.getIsUserLoggedIn() ?? false {
                Messaging.messaging().subscribe(toTopic: "newPost") { error in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        print("Subscribed to weather topic")
                    }
                }
            }
        }
    }
}



