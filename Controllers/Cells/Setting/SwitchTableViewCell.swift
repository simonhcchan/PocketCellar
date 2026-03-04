//
//  SwitchTableViewCell.swift
//  PocketCellar
//
//  Created by IE15 on 14/03/24.
//
import UIKit
import FirebaseMessaging

class SwitchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageIcon: UIImageView!
    @IBOutlet weak var TextLabel: UILabel!
    
    @IBOutlet weak var OnOffSwitch: UISwitch!
    @IBOutlet weak var sepraterView: UIView!
    var isDarkMode:Bool = true
    override func awakeFromNib() {
        super.awakeFromNib()
        if isDarkMode {
            let appThemeColor = kUserDefault.getAppTheme()
            if appThemeColor {
                OnOffSwitch.isOn = true
            }
            else{
                OnOffSwitch.isOn = false
            }
        }
        else{
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                DispatchQueue.main.async {
                    self.OnOffSwitch.isOn = settings.authorizationStatus == .authorized
                }
            }
            let isOn = UserDefaults.standard.bool(forKey: "FCMEnabled")
            OnOffSwitch.isOn = isOn
            if OnOffSwitch.isOn {
                UIApplication.shared.registerForRemoteNotifications()
            } else {
                UIApplication.shared.unregisterForRemoteNotifications()
            }
        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func togleButtonAction(_ sender: Any) {
        if isDarkMode {
            UIApplication.shared.windows.forEach { window in
                if OnOffSwitch.isOn{
                    window.overrideUserInterfaceStyle = .dark
                    kUserDefault.setAppTheme(value: true)
                } else {
                    window.overrideUserInterfaceStyle = .light
                    kUserDefault.setAppTheme(value: false)
                }
            }
        } else {
            //             action for notification
            //                        if OnOffSwitch.isOn {
            //                            requestNotificationAuthorization()
            //                            UserDefaultsManager.setIsNotificationAllowed(isChecked: true)
            //                        } else {
            //                            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            //                            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            //                           // UNUserNotificationCenter.current().requestAuthorization(options: []) { _, _ in }
            //                            UserDefaultsManager.setIsNotificationAllowed(isChecked: false)
            //                        }
            //
            if OnOffSwitch.isOn {
                // If switch is turned on, request permission again
//                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
//                    if granted {
//                        DispatchQueue.main.async {
//                            UIApplication.shared.registerForRemoteNotifications()
//                        }
//                    } else {
                        print("Handle denial of permission")
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
//                    }
//                }
            } else {
                // If switch is turned off, unregister for remote notifications
//                UIApplication.shared.unregisterForRemoteNotifications()
//                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
//                    if granted {
//                        DispatchQueue.main.async {
//                            UIApplication.shared.registerForRemoteNotifications()
//                        }
//                    } else {
                        print("Handle denial of permission")
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
//                    }
//                }
            }
        }
    }
    
    func setupFont() {
        let fontType = CurrentFont(rawValue: kUserDefault.getAppFontType() ?? "Normal")
        switch fontType {
        case .normal:
            self.TextLabel.font = UIFont.rubik(ofSize: 15 , weight: .regular)
        case .large:
            self.TextLabel.font = UIFont.rubik(ofSize: 17 , weight: .regular)
        case .veryLarge:
            self.TextLabel.font = UIFont.rubik(ofSize: 19 , weight: .regular)
        case nil:
            break
        }
        
    }
            
    private func requestNotificationAuthorization() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
            if let error = error {
                // Handle error
                print("Error requesting notification authorization: \(error.localizedDescription)")
            } else if granted {
                // User granted authorization
                UserDefaultsManager.setIsNotificationAllowed(isChecked: true)
                print("Notification authorization granted")
            } else {
                // User denied authorization
                UserDefaultsManager.setIsNotificationAllowed(isChecked: false)
                print("Notification authorization denied")
            }
        }
    }
    
}

