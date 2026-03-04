//
//  ForgetPasswordViewController.swift
//  PocketCellar
//
//  Created by IE15 on 14/03/24.
//
import UIKit
import FirebaseAuth


class ForgetPasswordViewController: UIViewController {
    
    @IBOutlet private var userEmailTextField: UITextField!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var signInButton: UIButton!
    @IBOutlet private var nextPageButton: UIButton!
    @IBOutlet private var alreadyLabel: UILabel!
    @IBOutlet private var forgotLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.stopAnimating()
        userEmailTextField.delegate = self
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.tintColor = .black
        configureTextFieldWithLeftPadding(userEmailTextField, padding: 0)
        navigationTitle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupFont()
        setUpLocalization()
    }

    private func configureTextFieldWithLeftPadding(_ textField: UITextField, padding: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

    @IBAction func signButtonAction(_ sender: UIButton) {
        
       
        navigationController?.popViewController(animated: true)
    }

    func resetPassword(email: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(false, error.localizedDescription)
            } else {
                completion(true,StringConstants.AllertMessage.passwordResetEmailSent.localized())
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: StringConstants.AllertMessage.ok.localized(), style: .cancel, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func alertMassage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: StringConstants.AllertMessage.ok.localized(), style: .cancel, handler: { _ in
            // print("OK Tapped")
        }))
        self.present(alertController, animated: true)
    }

    @IBAction private func resetAction(_ sender: Any) {

        if let email = userEmailTextField.text ,email.isEmpty{
            let alertController = UIAlertController(title: StringConstants.AllertMessage.email.localized(),
                                                    message: StringConstants.AllertMessage.pleaseEnterYourEmail.localized(), preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: StringConstants.AllertMessage.ok.localized(), style: .cancel, handler: { _ in }))
            self.present(alertController, animated: true)
            return
        }

        if !isValidEmail(userEmailTextField.text ?? "") {
            let alertController = UIAlertController(title: StringConstants.AllertMessage.invalidEmail.localized(),
                                                    message: StringConstants.AllertMessage.pleaseEnterCorrectEmail.localized(), preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: StringConstants.AllertMessage.ok.localized(), style: .cancel, handler: { _ in }))
            self.present(alertController, animated: true)
            return
        }
        self.activityIndicator.startAnimating()
        
        resetPassword(email: userEmailTextField.text ?? "") { success, message in
            if success {
                print("Password reset email sent.")
                self.activityIndicator.stopAnimating()
                self.showAlert(title: StringConstants.AllertMessage.resetPassword.localized(), message: message ?? "")
            } else {
                print("Password reset failed.")
                self.activityIndicator.stopAnimating()
                self.showAlert(title: StringConstants.AllertMessage.resetPassword.localized().localized(), message: message ?? "")
            }
        }

    }
}

extension ForgetPasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        userEmailTextField.resignFirstResponder()
        return true
    }
}
extension ForgetPasswordViewController {

    func setupFont() {
        let fontType = CurrentFont(rawValue: kUserDefault.getAppFontType() ?? "Normal")
        
        switch fontType {
        case .normal:
            setUpFont(size: 16)

        case .large:
            setUpFont(size: 18)

        case .veryLarge:
            setUpFont(size: 20)
            
        case nil:
            break
        }
    }
    
    private func setUpFont(size: CGFloat) {
        self.forgotLabel.font = UIFont.rubik(ofSize: size + 18 , weight: .medium)
        self.userEmailTextField.font = UIFont.rubik(ofSize: size , weight: .regular)
        self.alreadyLabel.font = UIFont.rubik(ofSize: size - 1 , weight: .regular)


        signInButton.setTitle("Sign in".localized(), for: .normal)
        signInButton.titleLabel?.font = UIFont(name: "rubik-regular", size: size - 1)
        let attributedStringSignUp = NSAttributedString(string: "Sign in".localized(), attributes: [
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
        ])
        signInButton.setAttributedTitle(attributedStringSignUp, for: .normal)
    }
    
    private func setUpLocalization() {
        self.forgotLabel.text = "Forgot Password".localized()
        self.userEmailTextField.placeholder = "Email ID".localized()
        self.alreadyLabel.text = "Already have an account".localized()
        self.nextPageButton.setTitle("Continue".localized(), for: .normal)
    }
}

extension ForgetPasswordViewController {
    private func navigationTitle() {
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        backButton.setImage(UIImage(named: StringConstants.ImageConstant.backButton), for: .normal)
        backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    @objc func backAction () {
        navigationController?.popViewController(animated: true)
    }
}
