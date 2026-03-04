//
//  SplashViewController.swift
//  PocketCellar
//
//  Created by IE15 on 13/03/24.
//

import UIKit


class SplashViewController: UIViewController {
    
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        navigationController?.setNavigationBarHidden(true, animated: true)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerFired), userInfo: nil, repeats: false)
    }
    
    @objc func timerFired() {
        let gotoHomeTab = UserDefaults.standard.bool(forKey: UserDefaultsManager.getUserEmail() ?? "")
        
        if UserDefaultsManager.getIsUserLoggedIn() ?? false && gotoHomeTab  {
            let storyboard = UIStoryboard(name: StoryboardName.common.rawValue, bundle: nil)
            if let loginViewController = storyboard.instantiateViewController(withIdentifier: "HomeTabBarController") as? HomeTabBarController {
                navigationController?.pushViewController(loginViewController, animated: true)
            }
        } else {
            let storyboard = UIStoryboard(name: StoryboardName.main.rawValue, bundle: nil)
            if let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
                navigationController?.pushViewController(loginViewController, animated: true)
            }
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}
