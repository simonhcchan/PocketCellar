//
//  LoginViewController.swift
//  PocketCellar
//
//  Created by IE15 on 13/03/24.
//


import LocalAuthentication
import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices
import SwiftUI
import FacebookLogin
import FacebookCore
import FirebaseFirestoreInternal

class LoginViewController: UIViewController {
    
    @IBOutlet private var signInwithLabel: UILabel!
    @IBOutlet private var donthaveLabel: UILabel!
    @IBOutlet private var emailTextField: UITextField!
    @IBOutlet private var passwordTextField: UITextField!
    @IBOutlet private var showHideIconChangePasswordButton: UIButton!
    @IBOutlet private var checkBoxButton: UIButton!
    @IBOutlet private var signInButton: UIButton!
    @IBOutlet private var signUpButton: UIButton!
    @IBOutlet private var forgetButton: UIButton!
    @IBOutlet private var popOverView: UIView!
    
    @IBOutlet private var visualEffectView: UIVisualEffectView!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var tableVIew: UITableView!
    
    @IBOutlet private var rememberMeLabel: UILabel!
    @IBOutlet private var welcomeLabel: UILabel!
    @IBOutlet private var heightForTableView: NSLayoutConstraint!
    @IBOutlet private var darkModeSwitch: UISwitch!
    
    @IBOutlet private var popOverHeadingLabel: UILabel!
    @IBOutlet private var darkModeLabel: UILabel!
    
    @IBOutlet private var okButton: UIButton!
    @IBOutlet private var popOverNoteLabel: UILabel!
    @IBOutlet private var languageSelectIonButton: UIButton!
    
    fileprivate var currentNonce: String?
    private let Languages =  ["English","Française", "繁體中文","简体中文","日本語", "한국어"]
    private var selectedLang:String = ""
    private var appleSignInCompletion: ((Bool) -> Void)?
    private var error: NSError?
    private var selectedIndexPath: IndexPath?
    static var email:String = ""
    private var isShow = true
    private var isChecked = UserDefaultsManager.getIsRememberMeChecked() ?? false
    public var issocail : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableVIew.delegate = self
        tableVIew.dataSource = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        welcomeLabel.tag = 1
        activityIndicator.stopAnimating()
        
        configureTextFieldWithLeftPadding(emailTextField, padding: 0)
        configureTextFieldWithLeftPadding(passwordTextField, padding: 0)
        signInButton.layer.cornerRadius = 8
        navigationItem.hidesBackButton = true
        
        self.forgetButton.titleLabel?.text = StringConstants.Login.password
        forgetButton.titleLabel?.font = UIFont.rubik(ofSize: 15, weight: .regular)
        setUpLocalization()
        self.heightForTableView.constant = 0
        
        let showPopover = UserDefaults.standard.bool(forKey: "PopOver")
        if showPopover {
            popOverView.isHidden = true
            visualEffectView.isHidden = true
        } else {
            UserDefaults.standard.set(true, forKey: "PopOver")
        }
        
//        if let isRemembered =  UserDefaultsManager.getIsRememberMeChecked() {
//            if isRemembered {
//                emailTextField.text = UserDefaultsManager.getUserEmail()
//                passwordTextField.text = UserDefaultsManager.getUserPassword()
//                let image = UIImage(named: StringConstants.ImageConstant.checkedIcon)
//                checkBoxButton.setImage(image, for: .normal)
//            }
//            else {
//                emailTextField.text = ""
//                passwordTextField.text = ""
//                let image = UIImage(named: StringConstants.ImageConstant.uncheckedIcon)
//                checkBoxButton.setImage(image, for: .normal)
//            }
//        }
        
//        #if targetEnvironment(simulator)
//                emailTextField.text = "Kundan.sisodiya@infoenum.com"
//                passwordTextField.text = "Kundan@123"
//        #else
//                emailTextField.text = ""
//                passwordTextField.text = ""
//        #endif
//        
        self.heightForTableView.constant = CGFloat(40 * self.Languages.count + 10)
        self.tableVIew.layoutIfNeeded()
        self.tableVIew.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupFont()
        navigationController?.setNavigationBarHidden(true, animated: false)
        if let isRemembered =  UserDefaultsManager.getIsRememberMeChecked() {
            if isRemembered {
                emailTextField.text = UserDefaultsManager.getUserEmail()
                passwordTextField.text = UserDefaultsManager.getUserPassword()
                let image = UIImage(named: StringConstants.ImageConstant.checkedIcon)
                checkBoxButton.setImage(image, for: .normal)
            }
            else {
                emailTextField.text = ""
                passwordTextField.text = ""
                let image = UIImage(named: StringConstants.ImageConstant.uncheckedIcon)
                checkBoxButton.setImage(image, for: .normal)
            }
        }
        
    }
    
    func configureTextFieldWithLeftPadding(_ textField: UITextField, padding: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
    }
    
    @IBAction private func checkBoxAction(_ sender: Any) {
        isChecked = !isChecked
        print(isChecked)
        if isChecked {
            let image = UIImage(named: StringConstants.ImageConstant.checkedIcon)
            checkBoxButton.setImage(image, for: .normal)
        } else {
            let image = UIImage(named: StringConstants.ImageConstant.uncheckedIcon)
            checkBoxButton.setImage(image, for: .normal)
        }
        UserDefaultsManager.setIsRememberMeChecked(isChecked: isChecked)
    
    }
    
    @IBAction private func showHidePasswordAction(_ sender: Any) {
        if isShow {
            let image2 = UIImage(named: StringConstants.ImageConstant.visibleIcon)
            showHideIconChangePasswordButton.setImage(image2, for: .normal)
            isShow = false
        } else {
            let image2 = UIImage(named: StringConstants.ImageConstant.inVisibleIcon)
            showHideIconChangePasswordButton.setImage(image2, for: .normal)
            isShow = true
        }
        passwordTextField.isSecureTextEntry = isShow
    }
    
    @IBAction func googleSignInAction(_ sender: UIButton) {
        googleSignIn()
    }
    
    @IBAction func appleSignInAction(_ sender: UIButton) {
        handleSignInWithApple()
    }
    
    @IBAction func facebookLoginAction(_ sender: UIButton) {
        //signUpWithFacebook()
    }
    
    @IBAction private func signInAction(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty else {
            let errorMessage = StringConstants.AllertMessage.pleaseEnterYourEmail.localized()
            alertMassage(title: StringConstants.AllertMessage.email.localized(), message: errorMessage)
            return
        }
        
        guard let email = emailTextField.text, isValidEmail(email) else {
            let errorMessage = StringConstants.AllertMessage.pleaseEnterCorrectEmail.localized()
            alertMassage(title: StringConstants.AllertMessage.invalidEmail.localized(), message: errorMessage)
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            let errorMessage = StringConstants.AllertMessage.pleaseEnterYourPassword.localized()
            alertMassage(title: StringConstants.AllertMessage.password.localized(), message: errorMessage)
            return
        }
        
        guard let password = passwordTextField.text else {
            let errorMessage = StringConstants.AllertMessage.PasswordShouldBeBetween.localized()
            alertMassage(title: StringConstants.AllertMessage.invalidPassword.localized(), message: errorMessage)
            return
        }
        
        signIn(withEmail: email, password: password) { result in
            switch result {
            case .success:
                //  print("User signed in successfully!")
                UserDefaultsManager.setUserEmail(email: email.lowercased())
                UserDefaultsManager.setUserPassword(password: self.passwordTextField.text ?? "")
                let gotoHomeTab = UserDefaults.standard.bool(forKey: UserDefaultsManager.getUserEmail() ?? "")
                if gotoHomeTab {
                    self.navigateToHomeTabBarController()
                    self.activityIndicator.stopAnimating()
                } else {
                    self.verifiedUser()
                    self.activityIndicator.stopAnimating()
                }
            case .failure(let error):
                self.alertMassage(title: StringConstants.AllertMessage.loginFail.localized(), message: StringConstants.AllertMessage.loginFailMessage.localized())
                print("Error signing in: \(error.localizedDescription)")
                
            }
        }
    }
    
    private func verifiedUser(){
        if let user = Auth.auth().currentUser {
            user.reload { [weak self] (error) in
                if let error = error {
                    print("Error reloading user: \(error.localizedDescription)")
                    return
                }
                //                UserDefaultsManager.setUserEmail(email:  self?.emailTextField.text ?? "")
                
                if user.isEmailVerified {
                    // Email is verified, navigate to the home screen
                    UserDefaults.standard.set(true, forKey: UserDefaultsManager.getUserEmail() ?? "")
                    self?.navigateToHomeTabBarController()
                } else {
                    self?.navigateToVerificationController()
                }
            }
        }
    }
    
    @IBAction private func forgotPasswordAction(_ sender: Any) {
        let vc = ForgetPasswordViewController.instantiate(from: .main)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction private func signUpButtonAction(_ sender: Any) {
        let vc = SignUpViewController.instantiate(from: .main)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction private func okButtonAction(_ sender: Any) {
        if selectedLang.isEmpty || selectedLang == "" {
            alertMassage(title: StringConstants.AllertMessage.chooseLanguage.localized(), message: StringConstants.AllertMessage.chooseLanguageMessage.localized())
            return
        }
        visualEffectView.isHidden = true
        popOverView.isHidden = true
        UIApplication.shared.windows.forEach { window in
            if darkModeSwitch.isOn{
                window.overrideUserInterfaceStyle = .dark
                kUserDefault.setAppTheme(value: true)
            } else {
                window.overrideUserInterfaceStyle = .light
                kUserDefault.setAppTheme(value: false)
            }
        }
        setLanguage(selectedLang)
        refreshUI()
    }
    func setLanguage(_ selectedLanguage: String) {
        var languageCode: [String]
        
        switch selectedLanguage {
        case "English":
            languageCode = ["en"]
        case "Française":
            languageCode = ["fr"]
        case "繁體中文":
            languageCode = ["zh-Hant"]
        case "简体中文":
            languageCode = ["zh-Hans"]
        case "日本語":
            languageCode = ["ja"]
        case "한국어":
            languageCode = ["ko"]
        default:
            languageCode = ["en"]
        }
        UserDefaultsManager.setLanguages(langCode: languageCode)
        UserDefaults.standard.synchronize()
    }
    private func refreshUI(){
        setupFont()
        setUpLocalization()
    }
    
    private func navigateToHomeTabBarController() {
        UserDefaultsManager.setIsUserLoggedIn(isLoggedIn: true)
        let storyboard = UIStoryboard(name: StoryboardName.common.rawValue, bundle: nil)
        if let tabController = storyboard.instantiateViewController(withIdentifier: "HomeTabBarController") as? HomeTabBarController {
            self.navigationController?.pushViewController(tabController, animated: true)
        }
    }
    
    private func navigateToSignUpViewController() {
        // UserDefaultsManager.setIsUserLoggedIn(isLoggedIn: true)
        if let email = UserDefaultsManager.getUserEmail() , let name = UserDefaultsManager.getUserName() {
            let storyboard = UIStoryboard(name: StoryboardName.main.rawValue, bundle: nil)
            if let controller = storyboard.instantiateViewController(withIdentifier: "CreateAccountViewController") as? CreateAccountViewController {
                controller.userEmail = email
                controller.userFirstName = name
                controller.issocail = issocail
                controller.isPasswordTextfieldHidden = true
                self.navigationController?.pushViewController(controller, animated: true)
            }
        } 
//        else {
//            let storyboard = UIStoryboard(name: StoryboardName.main.rawValue, bundle: nil)
//            if let tabController = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController {
//                tabController.hidePasswordTextfield = true
//                self.navigationController?.pushViewController(tabController, animated: true)
//            }
//        }
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }
    
    @IBAction private func authenticateTapped(_ sender: Any) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself!"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                   localizedReason: reason) { [weak self] success, _ in
                DispatchQueue.main.async { [self] in
                    if success {
                        
                        let isCheck = UserDefaultsManager.getIsRememberMeChecked() ?? false
                        
                        if isCheck {
                            let image2 = UIImage(named: "Checked-removebg-preview")
                            self?.checkBoxButton.setImage(image2, for: .normal)
                            //                            self?.emailTextField.text = email
                            //                            self?.passwordTextField.text = password
                            self?.isChecked = true
                            UserDefaultsManager.setIsUserLoggedIn(isLoggedIn: true)
                        }
                    } else {
                        let title = StringConstants.AllertMessage.problem.localized()
                        let message = StringConstants.AllertMessage.yourIdentityNotMatch.localized()
                        self?.alertMassage(title: title, message: message)
                        return
                    }
                }
            }
        } else {
            // no biometry
        }
    }
}

extension LoginViewController {
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func alertMassage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: StringConstants.AllertMessage.ok.localized(), style: .cancel, handler: { _ in
            // print("OK Tapped")
        }))
        self.present(alertController, animated: true)
    }
    
    func checkDocumentExistence(collection: String, documentID: String) {
        let documentRef = Firestore.firestore().collection(collection).document(documentID)
        
        documentRef.getDocument { (documentSnapshot, error) in
            if let error = error {
                //print("Error checking document existence: \(error.localizedDescription)")
                self.alertMassage(title: StringConstants.AllertMessage.error.localized(), message: error.localizedDescription)
                self.activityIndicator.stopAnimating()
                return
            }
            
            if let document = documentSnapshot, document.exists
            {
                let gotoHomeTab = UserDefaults.standard.bool(forKey: UserDefaultsManager.getUserEmail() ?? "")
                if gotoHomeTab {
                    self.navigateToHomeTabBarController()
                    self.activityIndicator.stopAnimating()
                } else {
                    self.verifiedUser()
                    //self.navigateToVerificationController()
                    self.activityIndicator.stopAnimating()
                }
            } else {
                self.navigateToSignUpViewController()
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    private func navigateToVerificationController() {
        let storyboard = UIStoryboard(name: StoryboardName.main.rawValue, bundle: nil)
        if let tabController = storyboard.instantiateViewController(withIdentifier: "VerificationViewController") as? VerificationViewController {
            self.navigationController?.pushViewController(tabController, animated: true)
        }
    }
}

extension Notification.Name {
    static let userEmail = Notification.Name("UserEmail")
}


// MARK: Google Login
extension LoginViewController {
    
    func getRootViewController() -> UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }
        guard let root = screen.windows.first?.rootViewController else {
            return .init()
        }
        return root
    }
    
    
    func googleSignIn() {
        self.activityIndicator.startAnimating()
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: getRootViewController()) {  result, error in
            guard error == nil else {
                self.activityIndicator.stopAnimating()
                return
            }
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else {
                return
            }
            UserDefaultsManager.setGoogleIDToken(idToken: idToken)
            UserDefaultsManager.setGoogleAccessToken(accessToken: user.accessToken.tokenString)
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            Auth.auth().signIn(with: credential) { result, error in
                // At this point, our user is signed in
                guard error == nil else {
                    self.activityIndicator.stopAnimating()
                    return
                }
                if let user = Auth.auth().currentUser {
                    let gmailID = user.email?.lowercased()
                    let userName = user.displayName
                    print("Gmail ID: \(gmailID ?? "")")
                    print("User Name: \(userName ?? "")")
                    UserDefaultsManager.setUserEmail(email: gmailID ?? "")
                    UserDefaultsManager.setUserName(name:userName ?? "User" )
                    self.issocail = true
                    self.checkDocumentExistence(collection: "users", documentID: gmailID ?? "")
                } else {
                    self.activityIndicator.stopAnimating()
                }
            }
            print("SIGN IN")
        }
    }
}

// MARK: Apple Login
extension LoginViewController :  ASAuthorizationControllerDelegate , ASAuthorizationControllerPresentationContextProviding {
    
    func handleSignInWithApple() {
        self.activityIndicator.startAnimating()
        let nonce = String.randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = nonce.sha256
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows[0]
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
                self.activityIndicator.stopAnimating()
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                self.activityIndicator.stopAnimating()
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                self.activityIndicator.stopAnimating()
                return
            }
            UserDefaultsManager.setAppleIDToken(idToken: idTokenString)
            UserDefaultsManager.setAppleNonce(nonce: nonce)
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            Auth.auth().signIn(with: credential, completion: handleAuthResultCompletion)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple error: \(error)")
        self.error = error as NSError
        self.activityIndicator.stopAnimating()
    }
    
    func handleAuthResultCompletion(auth: AuthDataResult?, error: Error?) {
        DispatchQueue.main.async { [self] in
            if let user = Auth.auth().currentUser {
                let gmailID = user.email?.lowercased()
                let userName =  user.displayName
                print("Gmail ID: \(gmailID ?? "")")
                UserDefaultsManager.setUserEmail(email: gmailID ?? "")
                UserDefaultsManager.setUserName(name: userName ?? "User")
                self.issocail = true
                self.checkDocumentExistence(collection: "users", documentID: gmailID ?? "")
            }
            if let error = error {
                print(error.localizedDescription)
                self.activityIndicator.stopAnimating()
            }
        }
    }
}
// MARK: Email Login
extension LoginViewController {
    func signIn(withEmail email: String, password: String, completion: @escaping (Result<AuthDataResult?, Error>) -> Void) {
        self.activityIndicator.startAnimating()
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error as NSError? {
                print("Sign-in failed: \(error.localizedDescription)")
                completion(.failure(error))
                self.activityIndicator.stopAnimating()
                return
            }
            
            print("Sign-in successful")
            completion(.success(result))
            self.activityIndicator.stopAnimating()
        }
    }
}
// MARK: FacebookLogin
extension LoginViewController {
    
    func signUpWithFacebook() {
        self.activityIndicator.startAnimating()
        let loginManager = LoginManager()
        loginManager.logIn(permissions:  ["public_profile", "email"], from: nil) { result, error in
            if let error = error {
                print("Facebook login failed with error: \(error.localizedDescription)")
                self.alertMassage(title: StringConstants.AllertMessage.error.localized(), message: error.localizedDescription)
                self.activityIndicator.stopAnimating()
            } else if result?.isCancelled == true {
                print("Facebook login cancelled by user.")
                self.activityIndicator.stopAnimating()
            } else {
                guard let accessToken = AccessToken.current?.tokenString else {
                    print("Facebook access token not found.")
                    self.activityIndicator.stopAnimating()
                    return
                }
                UserDefaultsManager.setFacebookAccessToken(accessToken: accessToken)
                let credential = FacebookAuthProvider.credential(withAccessToken: accessToken)
                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        print("Firebase authentication failed with error: \(error.localizedDescription)")
                        self.alertMassage(title: StringConstants.AllertMessage.error.localized(), message: error.localizedDescription)
                        self.activityIndicator.stopAnimating()
                    } else {
                        print("Firebase authentication succeeded.")
                        if let user = Auth.auth().currentUser {
                            let gmailID = user.email?.lowercased()
                            print("Gmail ID: \(gmailID ?? "")")
                            UserDefaultsManager.setUserEmail(email: gmailID ?? "")
                            self.issocail = true
                            self.checkDocumentExistence(collection: "users", documentID: gmailID ?? "")
                        } else {
                            self.activityIndicator.stopAnimating()
                        }
                    }
                }
            }
        }
    }
}

extension LoginViewController {
    
    func setupFont() {
        let fontType = CurrentFont(rawValue: kUserDefault.getAppFontType() ?? "Normal")
        switch fontType {
        case .normal:
            setupFont(size: 16)
            
        case .large:
            setupFont(size: 18)
            
        case .veryLarge:
            setupFont(size: 20)
            
        case nil:
            break
        }
    }
    
    private func setupFont(size: CGFloat){
        self.welcomeLabel.font = UIFont.rubik(ofSize: size + 28 , weight: .medium)
        self.emailTextField.font = UIFont.rubik(ofSize: size, weight: .regular)
        self.passwordTextField.font = UIFont.rubik(ofSize: size, weight: .regular)
        self.rememberMeLabel.font = UIFont.rubik(ofSize: size, weight: .regular)
        self.signInwithLabel.font = UIFont.rubik(ofSize: size - 1, weight: .regular)
        self.donthaveLabel.font = UIFont.rubik(ofSize: size - 1, weight: .regular)
        
        
        forgetButton.setTitle("Forget Passowrd?".localized(), for: .normal)
        forgetButton.titleLabel?.font = UIFont(name: "rubik-regular", size: size - 1)
        let attributedString = NSAttributedString(string: "Forgot Password?".localized(), attributes: [
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
        ])
        forgetButton.setAttributedTitle(attributedString, for: .normal)
        
        signUpButton.setTitle("Sign up".localized(), for: .normal)
        signUpButton.titleLabel?.font = UIFont(name: "rubik-regular", size: size - 1)
        let attributedStringSignUp = NSAttributedString(string: "Sign up".localized(), attributes: [
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue ])
        signUpButton.setAttributedTitle(attributedStringSignUp, for: .normal)
    }
    
    private func setUpLocalization(){
        self.welcomeLabel.text = "Welcome Back!".localized()
        self.rememberMeLabel.text = "Remember Me".localized()
        self.emailTextField.placeholder = "Email ID".localized()
        self.passwordTextField.placeholder = "Password".localized()
        self.signInwithLabel.text = "Sign In With".localized()
        self.donthaveLabel.text = "Don't have an account?".localized()
        self.popOverHeadingLabel.text = "Please Choose For Your First Time Use".localized()
        self.popOverNoteLabel.text = "Note:you can still change your mind later in setting".localized()
        self.darkModeLabel.text = "Dark Mode".localized()
        self.signInButton.setTitle("Sign in".localized(), for: .normal)
        self.okButton.setTitle("Ok".localized(), for: .normal)
    }
}

extension LoginViewController:  UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Languages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectLanguageTableViewCell", for: indexPath) as! SelectLanguageTableViewCell
        cell.LanguageLabel.text = Languages[indexPath.row]
        cell.accessoryType = indexPath == selectedIndexPath ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedIndexPath = selectedIndexPath {
            tableView.cellForRow(at: selectedIndexPath)?.accessoryType = .none
        }
        
        // Select the new row
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        selectedIndexPath = indexPath
        selectedLang = Languages[indexPath.row]
    }
    
    private func hideTableView() {
        UIView.animate(withDuration: 0.5) {
            self.heightForTableView.constant = 0
        }
    }
}
