//
//  SignUpViewController.swift
//  PocketCellar
//
//  Created by IE15 on 14/03/24.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseFirestoreInternal

class SignUpViewController: UIViewController {
    
    @IBOutlet private var alreadyHaveAnLabel: UILabel!
    @IBOutlet private var createAccountLabel: UILabel!
    @IBOutlet private var userFirstNameTextField: UITextField!
    @IBOutlet private var userLastNameTextField: UITextField!
    @IBOutlet private var userEmailTextFiled: UITextField!
    @IBOutlet private var passwordTextField: UITextField!
    @IBOutlet private var showHideIconChangePasswordButton: UIButton!
    @IBOutlet weak var passwordTextFieldView: UIStackView!
    @IBOutlet private var signUpButton: UIButton!
    @IBOutlet private var signInButton: UIButton!
    
    private var isShowForPassword = true
    private var isShowForConfirmPassword = true
    private var isChecked = false
    var hidePasswordTextfield = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signInButton.titleLabel?.font = UIFont.rubik(ofSize: 15, weight: .regular)
        passwordTextFieldView.isHidden = hidePasswordTextfield
        
        setUpLocalization()
        
        if let email = UserDefaultsManager.getUserEmail(), hidePasswordTextfield {
            userEmailTextFiled.text = email
            userEmailTextFiled.isEnabled = false
        }
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor(named: StringConstants.ColorConstant.blackColor)
        ]
        
        let attributedString = NSMutableAttributedString(string:StringConstants.SignUp.termsOfServiceandPrivacyAndPolicy.localized(), attributes: attributes)
        let coloredAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.gray
        ]
        
        let range = (attributedString.string as NSString).range(of: StringConstants.SignUp.iHerebyAgreeToThe.localized())
        attributedString.addAttributes(coloredAttributes, range: range)
        
        configureAllTextFieldWithLeftPadding()
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        if let userName = userFirstNameTextField, let userEmail = userEmailTextFiled,
           let password = passwordTextField {
            password.delegate = self
            userName.delegate = self
            userEmail.delegate = self
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        setupFont()
        setUpNavigationBar()
        navigationTitle()
    }
    
    private func configureAllTextFieldWithLeftPadding(){
        configureTextFieldWithLeftPadding(userFirstNameTextField, padding: 0)
        configureTextFieldWithLeftPadding(userLastNameTextField, padding: 0)
        configureTextFieldWithLeftPadding(userEmailTextFiled, padding: 0)
        configureTextFieldWithLeftPadding(passwordTextField, padding: 0)
    }
    
    private func configureTextFieldWithLeftPadding(_ textField: UITextField, padding: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
    }
    
    @IBAction private func showHidePasswordAction(_ sender: Any) {
        if isShowForPassword {
            passwordTextField.isSecureTextEntry = false
            let image2 = UIImage(named: StringConstants.ImageConstant.visibleIcon)
            showHideIconChangePasswordButton.setImage(image2, for: .normal)
        } else {
            passwordTextField.isSecureTextEntry = true
            let image2 = UIImage(named: StringConstants.ImageConstant.inVisibleIcon)
            showHideIconChangePasswordButton.setImage(image2, for: .normal)
        }
        isShowForPassword = !isShowForPassword
    }
    
    @IBAction private func signUpAction(_ sender: Any) {
        
        guard let userFirstName = userFirstNameTextField.text,
              let userLastName = userLastNameTextField.text,
              let email = userEmailTextFiled.text,
              let password = passwordTextField.text else {
            return
        }
        
        if userFirstName.isEmpty{
            alertMassage(title: StringConstants.AllertMessage.name.localized(), massage: StringConstants.AllertMessage.pleaseEnterYourFirstName.localized())
        }
        if userLastName.isEmpty{
            alertMassage(title: StringConstants.AllertMessage.name.localized(), massage:  StringConstants.AllertMessage.pleaseEnterYourLastName.localized())
        }
        
        if email.isEmpty{
            alertMassage(title: StringConstants.AllertMessage.email.localized(), massage: StringConstants.AllertMessage.pleaseEnterYourEmail.localized())
        }
        if !isValidEmail(email) {
            alertMassage(title: StringConstants.AllertMessage.invalidEmail.localized(), massage: StringConstants.AllertMessage.pleaseEnterCorrectEmail.localized())
            return
        }
        
        if hidePasswordTextfield != true {
            if password.isEmpty{
                alertMassage(title: StringConstants.AllertMessage.password.localized(), massage: StringConstants.AllertMessage.pleaseEnterYourPassword.localized())
            }
            if !isValidPassword(myPassword: password) {
                let errorMessage = StringConstants.AllertMessage.errorMassageForPass.localized()
                alertMassage(title: StringConstants.AllertMessage.invalidPassword.localized(), massage: errorMessage)
                return
            }
        }
        
        FetchDataFromFireBase.shared.checkUserVerification(email: email.lowercased()) { isValid in
            if isValid {
                self.alertMassage(title: StringConstants.AllertMessage.loginFailed.localized(), massage: "The email address is already in use by another account.".localized())
            } else {
                let storyboard = UIStoryboard(name: StoryboardName.main.rawValue, bundle: nil)
                if let tabController = storyboard.instantiateViewController(withIdentifier: "CreateAccountViewController") as? CreateAccountViewController {
                    tabController.userFirstName = self.userFirstNameTextField.text ?? ""
                    tabController.userLastName = self.userLastNameTextField.text ?? ""
                    tabController.userEmail = self.userEmailTextFiled.text ?? ""
                    tabController.userPassword = self.passwordTextField.text ?? ""
                    tabController.isPasswordTextfieldHidden = self.hidePasswordTextfield
                    self.navigationController?.pushViewController(tabController, animated: true)
                }
            }
        }
    }
    
    @IBAction private func signInAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension SignUpViewController {
    
    func alertMassage(title: String?, massage: String?) {
        let alertController = UIAlertController(title: title, message: massage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: StringConstants.AllertMessage.ok.localized(), style: .cancel, handler: { _ in }))
        self.present(alertController, animated: true)
    }
    
    func isValidName(_ name: String) -> Bool {
        let nameRegEx = "^[A-Za-z][A-Za-z0-9_ ]{7,29}$"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", nameRegEx)
        return emailPred.evaluate(with: name)
    }
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func isValidPassword(myPassword: String) -> Bool {
        //        let passwordreg = ("(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z])(?=.*[@#$%^&*]).{8,}")
        //        let passwordtesting = NSPredicate(format: "SELF MATCHES %@", passwordreg)
        //        return passwordtesting.evaluate(with: myPassword)
        return myPassword.count >= 6
    }
}

extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        userFirstNameTextField.resignFirstResponder()
        userEmailTextFiled.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }
    
}

extension SignUpViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.x = 0.0
    }
    
}
extension SignUpViewController {
    
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
    
    private func setUpFont(size: CGFloat){
        self.createAccountLabel.font = UIFont.rubik(ofSize: size + 18 , weight: .medium)
        self.userFirstNameTextField.font = UIFont.rubik(ofSize: size, weight: .regular)
        self.userLastNameTextField.font = UIFont.rubik(ofSize: size, weight: .regular)
        self.passwordTextField.font = UIFont.rubik(ofSize: size, weight: .regular)
        self.userEmailTextFiled.font = UIFont.rubik(ofSize: size, weight: .regular)
        self.passwordTextField.font = UIFont.rubik(ofSize: size, weight: .regular)
        self.alreadyHaveAnLabel.font = UIFont.rubik(ofSize: size - 1, weight: .regular)
        
        signInButton.setTitle("Sign in".localized(), for: .normal)
        signInButton.titleLabel?.font = UIFont(name: "rubik-regular", size: size - 1)
        let attributedStringSignUp = NSAttributedString(string: "Sign in".localized(), attributes: [
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
        ])
        signInButton.setAttributedTitle(attributedStringSignUp, for: .normal)
    }
    
    private func setUpLocalization() {
        self.createAccountLabel.text = "Create an Account".localized()
        self.userFirstNameTextField.placeholder = "First Name".localized()
        self.userLastNameTextField.placeholder = "Last Name".localized()
        self.passwordTextField.placeholder = "Password".localized()
        self.userEmailTextFiled.placeholder = "Email ID".localized()
        self.alreadyHaveAnLabel.text = "Already have an account?".localized()
        self.signUpButton.setTitle("Continue".localized(), for: .normal)
    }
}

extension SignUpViewController {
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
