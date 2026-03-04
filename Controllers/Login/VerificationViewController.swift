//
//  VerificationViewController.swift
//  PocketCellar
//
//  Created by IE12 on 22/03/24.
//

import UIKit
import FirebaseAuth

class VerificationViewController: UIViewController {
    
    @IBOutlet private var verificationHeaderLabel: UILabel!
    @IBOutlet private var verificationSubTitleLabel: UILabel!
    @IBOutlet private var goBackLabel: UILabel!
    @IBOutlet private var verificationButton: UIButton!
    @IBOutlet private var RefreshButton: UIButton!
    @IBOutlet private var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        signInButton.setTitle("Sign in".localized(), for: .normal)
        signInButton.titleLabel?.font = UIFont.rubik(ofSize: 15, weight: .regular)
        let attributedStringSignUp = NSAttributedString(string: "Sign in".localized(), attributes: [
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
        ])
        signInButton.setAttributedTitle(attributedStringSignUp, for: .normal)
        
        Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
            if let error = error {
                print("Error sending verification email: \(error.localizedDescription)")
                self.alertMassage(title:StringConstants.AllertMessage.error.localized(), message: "\(error.localizedDescription)")
            } 
        })
        goBackLabel.text = "Go back to".localized()
        RefreshButton.setTitle("Refresh".localized(), for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpLocalization()
        setupFont()
    }
    
    @IBAction func refreshButtonAction(_ sender: Any) {
        // Check if the user's email is verified
        if let user = Auth.auth().currentUser {
            user.reload { [weak self] (error) in
                if let error = error {
                    print("Error reloading user: \(error.localizedDescription)")
                    self?.alertMassage(title:StringConstants.AllertMessage.error.localized(), message: "\(error.localizedDescription)")
                    return
                }
                if user.isEmailVerified {
                    // Email is verified, navigate to the home screen
                    UserDefaults.standard.set(true, forKey: UserDefaultsManager.getUserEmail() ?? "")
                    self?.navigateToHomeTabBarController()
                } else {
                    self?.alertMassage(title: StringConstants.AllertMessage.emailNotVerified.localized(), message: StringConstants.AllertMessage.pleaseVerifiedEmail.localized())
                }
            }
        }
    }
    
    @IBAction func verificationButtonAction(_ sender: Any) {
        // Send verification email when the button is tapped
        Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
            if let error = error {
                print("Error sending verification email: \(error.localizedDescription)")
                self.alertMassage(title:StringConstants.AllertMessage.error.localized(), message: "\(error.localizedDescription)")
            } 
        })
    }
    
    private func navigateToHomeTabBarController() {
        UserDefaultsManager.setIsUserLoggedIn(isLoggedIn: true)
        let storyboard = UIStoryboard(name: StoryboardName.common.rawValue, bundle: nil)
        if let tabController = storyboard.instantiateViewController(withIdentifier: "HomeTabBarController") as? HomeTabBarController {
            self.navigationController?.pushViewController(tabController, animated: true)
        }
    }
    
    private func alertMassage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: StringConstants.AllertMessage.ok.localized(), style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func signInAction(_ sender: Any) {
        goToLoginScreen()
    }
}

extension VerificationViewController {
    
    func setupFont() {
        let fontType = CurrentFont(rawValue: kUserDefault.getAppFontType() ?? "Normal")
        switch fontType {
        case .normal:
            self.verificationHeaderLabel.font = UIFont.rubik(ofSize: 28 , weight: .medium)
            self.verificationSubTitleLabel.font = UIFont.rubik(ofSize: 17 , weight: .regular)
            
        case .large:
            self.verificationHeaderLabel.font = UIFont.rubik(ofSize: 30 , weight: .medium)
            self.verificationSubTitleLabel.font = UIFont.rubik(ofSize: 19 , weight: .regular)
            
        case .veryLarge:
            self.verificationHeaderLabel.font = UIFont.rubik(ofSize: 32 , weight: .medium)
            self.verificationSubTitleLabel.font = UIFont.rubik(ofSize: 21 , weight: .regular)
            
        case nil:
            break
        }
    }
    
    private func setUpLocalization() {
        let email = UserDefaultsManager.getUserEmail()
        self.verificationHeaderLabel.text = "Verify your email address".localized()
        self.verificationSubTitleLabel.text = "\("A verification email has been sent to your email".localized()) \(email!)"
        self.verificationButton.setTitle("Resend Verification Email".localized(), for: .normal)
    }
    
    private func goToLoginScreen() {
        let storyboard = UIStoryboard(name: StoryboardName.main.rawValue, bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        let navigationController = UINavigationController(rootViewController: loginViewController)
        navigationController.setNavigationBarHidden(true, animated:true)
        UIApplication.shared.windows.first?.rootViewController = navigationController
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
}
