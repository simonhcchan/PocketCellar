//
//  SettingVC.swift
//  YourWineLabel
//
//  Created by IE14 on 11/03/24.
//


import UIKit
import FirebaseDatabase
import Firebase
import StoreKit
import WebKit

enum CurrentFont: String {
    case normal = "Normal"
    case large = "large"
    case veryLarge = "VeryLarge"
}

class SettingVC: UIViewController {
    
    
    @IBOutlet private var settingLabel: UILabel!
    @IBOutlet private var tableView: UITableView!
    
    var expiryDate : String = ""
    var purchaseDate: String = ""
    var originalTransactionId: String = ""
    
    private let sections: [(title: String, items: [String])] = [
        (title: "", items: [""]),
        (title: "", items: ["Language", "Notification", "Dark Mode", "Font"]),
        (title: "", items: ["Go Rating", "Feedback", "Contact Us"]),
        (title: "", items: ["Purchase Yearly Subacription"]),
        (title: "", items: ["Logout","Delete"])
    ]
    private var userName: String = "Hello User"
    private var currentFont: CurrentFont = .normal
    private let purchaseIdentifierYearly = "com.pocketcellar.yearly"
    private var selectedFont: String = "Normal"
    typealias AlertActionHandler = (UIAlertAction) -> Void
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTable), name: NSNotification.Name("ReloadTableNotification"), object: nil)
        
        
        setupLanguage()
        setUpForCells()
        configureTableView()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.hidesBottomBarWhenPushed = false
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func setUpForCells() {
        let nib = UINib(nibName: "SwitchTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "SwitchTableViewCell")
        let uiNib = UINib(nibName: SettingViewTableViewCell.identifier, bundle: nil)
        tableView.register(uiNib, forCellReuseIdentifier: SettingViewTableViewCell.identifier)
        let nibS = UINib(nibName: "ProfileTableViewCell", bundle: nil)
        tableView.register(nibS, forCellReuseIdentifier: "ProfileTableViewCell")
        let nibL = UINib(nibName: "LogoutTableViewCell", bundle: nil)
        tableView.register(nibL, forCellReuseIdentifier: "LogoutTableViewCell")
        let nibSu = UINib(nibName: "SubScripitonTableViewCell", bundle: nil)
        tableView.register(nibSu, forCellReuseIdentifier: "SubScripitonTableViewCell")
        let privacyPolicy = UINib(nibName: "PrivacyPolicyTableViewCell", bundle: nil)
        tableView.register(privacyPolicy, forCellReuseIdentifier: "PrivacyPolicyTableViewCell")
        
    }
    
    private func configureTableView() {
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @objc func reloadTable() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                    UserDefaultsManager.setIsNotificationAllowed(isChecked: true)
                }
            } else {
                print("Handle denial of permission")
                UIApplication.shared.unregisterForRemoteNotifications()
                UserDefaultsManager.setIsNotificationAllowed(isChecked: false)
                
                
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func openPrivacyPolicy(url: String) {
        let privacyPolicyURL = URL(string: url)!
        let webViewVC = UIViewController()
        let webView = WKWebView(frame: webViewVC.view.frame)
        webView.load(URLRequest(url: privacyPolicyURL))
        webViewVC.view.addSubview(webView)
        self.present(webViewVC, animated: true, completion: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("ReloadTableNotification"), object: nil)
    }
    
}

extension SettingVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTableViewCell",for: indexPath) as! ProfileTableViewCell
            if let userName = UserDefaultsManager.getUserName(),userName != "" {
                self.userName = userName
            }
            cell.userNameLabel.text = userName.localized()
            cell.setupFont()
            
            return cell
        } else if indexPath.section == 1 && (indexPath.row == 1 || indexPath.row == 2)  {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchTableViewCell",for: indexPath) as! SwitchTableViewCell
            if indexPath.row == 1 {
                cell.imageIcon.image = UIImage(named: StringConstants.ImageConstant.notification)
                if let toggleState = UserDefaultsManager.getIsNotificationAllowed() {
                    if toggleState == true {
                        cell.OnOffSwitch.isOn = true
                    } else {
                        cell.OnOffSwitch.isOn = false
                    }
                }
                cell.isDarkMode = false
            } else {
                cell.isDarkMode = true
                cell.imageIcon.image = UIImage(named: StringConstants.ImageConstant.moon)
            }
            cell.TextLabel.text = sections[indexPath.section].items[indexPath.row].localized()
            
            cell.setupFont()
            return cell
        } else if indexPath.section == 1 && (indexPath.row == 0 || indexPath.row == 3)  {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingViewTableViewCell",for: indexPath) as! SettingViewTableViewCell
            cell.innerView.layer.cornerRadius = 8
            if indexPath.row == 0 {
                cell.imageIcon.image = UIImage(named: StringConstants.ImageConstant.internet)
                cell.sizeShowLabel.isHidden = true
                cell.innerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            } else {
                if let font = kUserDefault.getAppFontType() {
                    if font == CurrentFont.large.rawValue {
                        selectedFont = "Large"
                    } else if font == CurrentFont.veryLarge.rawValue {
                        selectedFont = "VeryLarge"
                    } else {
                        selectedFont = "Normal"
                    }
                }
                cell.imageIcon.image = UIImage(named: StringConstants.ImageConstant.font)
                cell.innerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                cell.sepraterView.isHidden = true
                cell.sizeShowLabel.text = selectedFont.localized()
                cell.sizeShowLabel.isHidden = false
            }
            cell.custemTextLabel.text = sections[indexPath.section].items[indexPath.row].localized()
            // cell.sizeShowLabel.isHidden = false
            
            cell.setupFont()
            return cell
        } else if indexPath.section == 2  {
            let cell = tableView.dequeueReusableCell(withIdentifier:  SettingViewTableViewCell.identifier,for: indexPath) as! SettingViewTableViewCell
            cell.innerView.layer.cornerRadius = 8
            if indexPath.row == 0 {
                cell.imageIcon.image = UIImage(named: StringConstants.ImageConstant.favorite)
                cell.innerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                cell.sizeShowLabel.isHidden = true
            } else if indexPath.row == 1 {
                cell.imageIcon.image = UIImage(named: StringConstants.ImageConstant.speech_bubble)
            } else {
                cell.imageIcon.image = UIImage(named: StringConstants.ImageConstant.phone_book)
                cell.innerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                cell.sepraterView.isHidden = true
            }
            
            cell.custemTextLabel.text = sections[indexPath.section].items[indexPath.row].localized()
            cell.sizeShowLabel.isHidden = true
            
            cell.setupFont()
            return cell
        }  else if indexPath.section == 3{
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: SubScripitonTableViewCell.identifier, for: indexPath) as! SubScripitonTableViewCell
                cell.custemTextLabel.text = "Subscription".localized()
                cell.setupFont()
                
                return cell
            } else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: PrivacyPolicyTableViewCell.identifier, for: indexPath) as! PrivacyPolicyTableViewCell
                cell.delegate = self
                cell.setupFont()
                
                let privacyPolicyTitle = NSAttributedString(string: "Privacy Policy".localized(), attributes: [
                    .underlineStyle: NSUnderlineStyle.single.rawValue
                ])
                cell.PrivacyPolicyButton.setAttributedTitle(privacyPolicyTitle, for: .normal)
                
                //                        cell.PrivacyPolicyButton.setTitle("Privacy Policy".localized(), for: .normal)
                cell.andLabel.text = "&"
                
                let termsAndConditionsTitle = NSAttributedString(string: "Terms and Conditions".localized(), attributes: [
                    .underlineStyle: NSUnderlineStyle.single.rawValue
                ])
                cell.termsAndConditionButton.setAttributedTitle(termsAndConditionsTitle, for: .normal)
                
                return cell
            }
        }
        else if indexPath.section == 4 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier:  "LogoutTableViewCell",for: indexPath) as! LogoutTableViewCell
                cell.logoutLabel.text = "Logout".localized()
                cell.setupFont()
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier:  "LogoutTableViewCell",for: indexPath) as! LogoutTableViewCell
                cell.logoutLabel.text = "Delete".localized()
                cell.logoutLabel.textColor = UIColor.red
                cell.imageIcon?.image = UIImage(named: "delete")
                cell.sepraterView.isHidden = true
                cell.setupFont()
                return cell
            }
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:  SettingViewTableViewCell.identifier,for: indexPath) as! SettingViewTableViewCell
            
            cell.custemTextLabel.text = sections[indexPath.section].items[indexPath.row].localized()
            cell.sizeShowLabel.isHidden = false
            cell.setupFont()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
}

extension SettingVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            let storyboard = UIStoryboard(name: StoryboardName.common.rawValue, bundle: nil)
            if let viewController = storyboard.instantiateViewController(withIdentifier: "ProfileEditViewController") as? ProfileEditViewController {
                viewController.delegate = self
                present(viewController, animated: true, completion: nil)
            }
            break
        case 1:
            if indexPath.row == 0 {
                self.showLanguages()
            } else if indexPath.row == 3 {
                showFontSizeActionSheet()
            }
            break
        case 2:
            if indexPath.row == 0 {
                self.showRating()
            } else if indexPath.row == 1 {
                self.ShowFeedBack()
            }else if indexPath.row == 2 {
                self.showContactUs()
            }
            break
            // Handle  Go Rating, Feedback, Contact Us
            break
        case 3:
            let storyboard = UIStoryboard(name: StoryboardName.common.rawValue, bundle: nil)
            if let viewController = storyboard.instantiateViewController(withIdentifier: "SubscriptionViewController") as? SubscriptionViewController {
                viewController.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(viewController, animated: true) }
            break
        case 4:
            if indexPath.row == 0 {
                let buttonTitle =  StringConstants.AllertMessage.log_out.localized()
                let title = StringConstants.AllertMessage.logout.localized()
                let message =  StringConstants.AllertMessage.logoutMessage.localized()
                showAlert(
                    title: title,
                    message: message,
                    destructiveButtonTitle: buttonTitle,
                    destructiveButtonAction: { _ in
                        UserDefaultsManager.setIsUserLoggedIn(isLoggedIn: false)
                        UserDefaults.standard.removeObject(forKey: "UserEmail")
                        UserDefaults.standard.removeObject(forKey: "UserName")
                        UserDefaults.standard.removeObject(forKey: "userPassword")
                        self.goToLoginScreen()
                    }
                )
            } else {
                let buttonTitle = "Delete".localized()
                let title = "Delete".localized()
                let message =  "Are you sure you want to delete your account?".localized()
                showAlert(
                    title: title,
                    message: message,
                    destructiveButtonTitle: buttonTitle,
                    destructiveButtonAction: { _ in
                        self.deleteAccount()
                    }
                )
            }
            
        default:
            break
        }
    }
    
    func showRating(){
//        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
//            if #available(iOS 14.0, *) {
//                SKStoreReviewController.requestReview(in: scene)
//            } else {
//            }
//        }
        if let url = URL(string: "itms-apps://itunes.apple.com/app/id6497877589") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func showContactUs(){
        
        let storyboard = UIStoryboard(name: StoryboardName.common.rawValue, bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "ContactUsViewController") as? ContactUsViewController {
            viewController.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(viewController, animated: true) }
        
    }
    
    func ShowFeedBack(){
        if let url = URL(string: "itms-apps://itunes.apple.com/app/id6497877589?action=write-review") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    private func alertMassage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okActionButton = UIAlertAction(title: StringConstants.AllertMessage.ok.localized(), style: .default, handler: nil)
        alertController.addAction(okActionButton)
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func deleteAccount() {
        guard let user = Auth.auth().currentUser else { return }
        
        UserDefaultsManager.setIsUserLoggedIn(isLoggedIn: false)
        UserDefaultsManager.setIsRememberMeChecked(isChecked: false)
        
        if let providerID = user.providerData.first?.providerID {
            switch providerID {
            case EmailAuthProviderID:
                deleteUser()
            case GoogleAuthProviderID:
                deleteUser()
                print("GoogleAuthProviderID")
            case FacebookAuthProviderID:
                deleteUser()
                print("FacebookAuthProviderID")
            case "apple.com":
                deleteUser()
            default:
                break
            }
        } else {
            print("No provider ID found")
        }
    }
    
    func deleteUser() {
        let user = Auth.auth().currentUser
        user?.delete { error in
            if let error = error {
                print("Error deleting user: \(error.localizedDescription)")
                self.alertMassage(title: "Error", message: "\(error.localizedDescription)")
            } else {
                print("User deleted successfully.")
                let email = UserDefaultsManager.getUserEmail() ?? ""
                FetchDataFromFireBase.shared.deleteUser(UserEmail: email) { error in
                    print(error)
                }
                UserDefaults.standard.removeObject(forKey: "UserEmail")
                UserDefaults.standard.removeObject(forKey: "UserName")
                UserDefaults.standard.removeObject(forKey: "userPassword")
                UserDefaultsManager.setIsUserLoggedIn(isLoggedIn: false)
                UserDefaultsManager.setIsRememberMeChecked(isChecked: false)
                self.goToLoginScreen()
            }
        }
    }
    
    
    
    private func goToLoginScreen() {
        let storyboard = UIStoryboard(name: StoryboardName.main.rawValue, bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        let navigationController = UINavigationController(rootViewController: loginViewController)
        navigationController.setNavigationBarHidden(true, animated:true)
        UIApplication.shared.windows.first?.rootViewController = navigationController
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
    
    private func showFontSizeActionSheet() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let normalAction = UIAlertAction(title: "Normal".localized(), style: .default) { _ in
            self.currentFont = .normal
            self.setupFont()
            kUserDefault.setAppFontType(value: CurrentFont.normal.rawValue)
        }
        alertController.addAction(normalAction)
        
        
        let largeAction = UIAlertAction(title: "Large".localized(), style: .default) { _ in
            self.currentFont = .large
            self.setupFont()
            kUserDefault.setAppFontType(value: CurrentFont.large.rawValue)
        }
        alertController.addAction(largeAction)
        
        
        let veryLargeAction = UIAlertAction(title: "Very Large".localized(), style: .default) { _ in
            self.currentFont = .veryLarge
            self.setupFont()
            kUserDefault.setAppFontType(value: CurrentFont.veryLarge.rawValue)
        }
        
        alertController.addAction(veryLargeAction)
        let cancelAction = UIAlertAction(title: StringConstants.AllertMessage.cancel.localized(), style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func showLanguages() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let english = UIAlertAction(title: "English", style: .default) { _ in
            self.changeLanguage(to: ["en"])
            self.setupLanguage()
            self.setupForTabBar()
        }
        alertController.addAction(english)
        
        let french = UIAlertAction(title: "Française", style: .default) { _ in
            self.changeLanguage(to: ["fr"])
            self.setupLanguage()
            self.setupForTabBar()
        }
        alertController.addAction(french)
        
        let traditional = UIAlertAction(title: "繁體中文", style: .default) { _ in
            self.changeLanguage(to: ["zh-Hant"])
            self.setupLanguage()
            self.setupForTabBar()
        }
        alertController.addAction(traditional)
        
        let simplified = UIAlertAction(title: "简体中文", style: .default) { _ in
            self.changeLanguage(to: ["zh-Hans"])
            self.setupLanguage()
            self.setupForTabBar()
        }
        alertController.addAction(simplified)
        let japanese = UIAlertAction(title: "日本語", style: .default) { _ in
            self.changeLanguage(to: ["ja"])
            self.setupLanguage()
            self.setupForTabBar()
        }
        alertController.addAction(japanese)
        let korean = UIAlertAction(title: "한국어".localized(), style: .default) { _ in
            self.changeLanguage(to: ["ko"])
            self.setupLanguage()
            self.setupForTabBar()
        }
        alertController.addAction(korean)
        
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func changeLanguage(to languageCode: [String]) {
        UserDefaultsManager.setLanguages(langCode: languageCode)
        UserDefaults.standard.synchronize()
    }
    
}

extension SettingVC {
    func setupFont() {
        let fontType = CurrentFont(rawValue: kUserDefault.getAppFontType() ?? "Normal")
        switch fontType {
        case .normal:
            self.settingLabel.font = UIFont.rubik(ofSize: 34 , weight: .medium)
            selectedFont = "Normal".localized()
        case .large:
            self.settingLabel.font = UIFont.rubik(ofSize: 36 , weight: .medium)
            selectedFont = "Large".localized()
        case .veryLarge:
            self.settingLabel.font = UIFont.rubik(ofSize: 38 , weight: .medium)
            selectedFont = "VeryLarge".localized()
        case nil:
            self.settingLabel.font = UIFont.rubik(ofSize: 34 , weight: .medium)
            selectedFont = "Normal".localized()
        }
        tableView.reloadData()
    }
    
    func setupLanguage(){
        tableView.reloadData()
        setupFont()
        settingLabel.text = "Settings".localized()
        
    }
    
    func setupForTabBar(){
        if let tabBarController = self.tabBarController as? HomeTabBarController {
            tabBarController.setTabBarTitles()
        }
    }
}


//extension SettingVC : GetProductsPrice  {
//
//    func didReceivedProducts(products: [SKProduct]) {
//        for product in products {
//            // showSpinner = true
//            print("Product Title: \(product.localizedTitle)")
//            print(product.price)
//            print(product.priceLocale)
//            print(product.productIdentifier)
//            setPriceLabel(product: product)
//        }
//    }
//
//    func setPriceLabel(product: SKProduct) {
//        let formatter = NumberFormatter()
//        formatter.locale = product.priceLocale
//        formatter.numberStyle = .currency
//        if let formattedAmount = formatter.string(from: product.price as NSNumber) {
//            let currency = String(formattedAmount)
//            let price = String(describing: product.price)
//            let currecncyType = currency.prefix(1)
//            DispatchQueue.main.async {
//                if product.productIdentifier == "com.pocketcellar.yearly" {
//                    // showSpinner = false
//                    let text = "\(String(currecncyType))\(price)"
//                    //self.basicAmount = text
//                }
//            }
//        }
//    }
//}
//
//extension SettingVC  {
//
//    @objc func purchaseFailed(_ notification: NSNotification) {
//        print(" purchase failed ")
//        //        SVProgressHUD.dismiss()
//        //  activityIndicator.stopAnimating()
//
//        if let error = notification.object as? NSError {
//            if error.code != SKError.paymentCancelled.rawValue {
//                print(error.localizedDescription)
//                //                DTMUIHelper.showAlertWithAction(alertTitle: "Error", messageBody: error.localizedDescription, controller: self)
//            }
//        }
//    }
//
//    @objc func restoreSuccess() {
//        print(" restore purchase success ")
//        // SVProgressHUD.dismiss()
//    }
//
//
//    @objc func purchaseSuccess(_ notification: NSNotification) {
//        //  print(" purchase success ")
//        if let productInfo = notification.userInfo?["product"] as? SKPaymentTransaction {
//            let productId = ("\(productInfo.payment.productIdentifier)")
//            let transactionId = ("\(String(describing: productInfo.transactionIdentifier))")
//            // let originalTransactionId = ("\(String(describing: productInfo.original?.transactionIdentifier))")
//            if let originalTransactionId = productInfo.original?.transactionIdentifier {
//                let transactionId = "\(originalTransactionId)"
//                self.originalTransactionId = transactionId
//            }
//
//            let purchaseStatus = ("\(productInfo.transactionState.status())")
//            if let unwrappedDate = productInfo.transactionDate {
//                let transactionDate = "\(unwrappedDate)"
//                self.purchaseDate = "\(transactionDate)"
//                print(transactionDate) // Output: "2023-07-05 10:05:56 +0000"
//            }
//
//            if let expiry =   UserDefaults.standard.value(forKey: UserDefaultsKeys.expiryDate) {
//                print(expiry)
//                expiryDate = "\(expiry)"
//            }
//            print("User purchased product id:-> \(productInfo.payment.productIdentifier)")
//            print("Transaction Identifier:-> \(String(describing: productInfo.transactionIdentifier))")
//            print("Original Transaction Identifier:-> \(String(describing: productInfo.original?.transactionIdentifier))")
//            print("Transaction Date:-> \(productInfo.transactionDate as Any)")
//            print("Purchase Status:-> \(productInfo.transactionState.status())")
//            print("expiry Date :-> \(UserDefaults.standard.value(forKey: UserDefaultsKeys.expiryDate))")
//
//            if productInfo.transactionState.status() == "restored" {
//                switch productInfo.payment.productIdentifier {
//                case purchaseIdentifierYearly:
//                    print(productInfo.original?.transactionIdentifier as Any)
//                    UserDefaultsUtil.reStoreTransactionId = productInfo.original?.transactionIdentifier
//                    break
//
//                default:
//                    break
//                }
//
//            } else if  productInfo.transactionState.status() == "purchased" {
//                switch productInfo.payment.productIdentifier {
//                case purchaseIdentifierYearly:
//                    print(productInfo.original?.transactionIdentifier as Any)
//                    saveSubscriptionDetails(productId: productId, transactionId: transactionId, transactionDate: purchaseDate, status: purchaseStatus, expiryDate: expiryDate, originalTransactionId: originalTransactionId) { success in
//                        if success {
//                            print("Saved successfully")
//                            UserDefaultsManager.setIsShowingAds(showingAds: false)
//                            UserDefaults.standard.set(true, forKey: "isUserSubscribed")
//                        }
//                    }
//
//                    break
//
//                default:
//                    break
//                }
//            }
//            else {
//                print("The else case")
//            }
//            // showSpinner = false
//        }
//    }
//}
//
//
//extension SettingVC {
//    func checkIfExpired(expiryDate: Date?) -> Bool {
//        if let expiryDate = expiryDate {
//            let currentDateAsString = getTodayDateString() // Get today's date as a String
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss +0000"
//            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
//            if let currentDate = dateFormatter.date(from: currentDateAsString) {
//                return expiryDate < currentDate // Compare two Date objects
//            }
//        }
//        return false // Return false if not expired or if expiryDate is nil
//    }
//
//    func getTodayDateString() -> String {
//        let currentDate = Date()
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss +0000"
//        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
//
//        return dateFormatter.string(from: currentDate)
//    }
//
//
//    func convertToDate(dateString: String, format: String) -> Date? {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = format
//        return dateFormatter.date(from: dateString)
//    }
//
//    func saveSubscriptionDetails(productId: String, transactionId: String, transactionDate: String, status: String, expiryDate: String, originalTransactionId: String, completion: @escaping (Bool) -> Void  ) {
//        guard let userid = UserDefaultsManager.getUserEmail() else { return }
//        DispatchQueue.main.async {
//            let documentRef = Firestore.firestore().collection("users")
//                .document(userid).collection("subscriptionDetail").document("currentSubscription")
//            documentRef.getDocument { (document, error) in
//                if let document = document, document.exists {
//                    if let expiry = document.data()?["ExpiryDate"] as? String {
//                        let expiry = self.convertToDate(dateString: expiry, format: "yyyy-MM-dd HH:mm:ss +0000")
//                        if self.checkIfExpired(expiryDate: expiry) {
//                            documentRef.updateData(["productId": productId,
//                                                    "transactionId": transactionId,
//                                                    "originalTransactionId": originalTransactionId,
//                                                    "Transaction Date": transactionDate,
//                                                    "status": status,
//                                                    "ExpiryDate": expiryDate ]) { error in
//                                if let error = error {
//                                    completion(false)
//                                    print("Error updating document: \(error)")
//                                } else {
//                                    print("Document updated successfully.")
//                                    completion(true)
//                                }
//                            }
//                        } else {
//                            completion(false)
//                            print("subscription is not expired yet")
//                            return
//                        }
//                    } else {
//                        completion(false)
//                        print("error while fetchinh expiry date")
//                    }
//                } else {
//                    Firestore.firestore().collection("users").document(userid).collection("subscriptionDetail").document("currentSubscription").setData([
//                        "productId": productId,
//                        "transactionId": transactionId,
//                        "Transaction Date": transactionDate,
//                        "originalTransactionId": originalTransactionId,
//                        "status": status,
//                        "ExpiryDate": expiryDate
//                    ]) { err in
//                        if let err = err {
//                            completion(false)
//                            print("Error writing document: \(err)")
//                        } else {
//                            completion(true)
//                            print("Document successfully written!")
//                        }
//                    }
//                }
//            }
//        }
//    }
//}

extension SettingVC : ProfileEditDelegate {
    func didUpdateProfile() {
        tableView.reloadData()
    }
}

extension SettingVC : PrivacyPolicyTableViewCellDelegate {
    func didTapTermsOrPrivacyButton(title: String, url: String) {
        openPrivacyPolicy(url: url)
    }
    
    
}


extension SettingVC {
    func showAlert(title: String, message: String, cancelButtonTitle: String = StringConstants.AllertMessage.cancel.localized(), destructiveButtonTitle: String, destructiveButtonAction: @escaping AlertActionHandler) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Add Cancel button
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        // Add Destructive button
        let destructiveAction = UIAlertAction(title: destructiveButtonTitle, style: .default, handler: destructiveButtonAction)
        destructiveAction.setValue(UIColor.red, forKey: "titleTextColor")
        alertController.addAction(destructiveAction)
        
        // Present the alert
        self.present(alertController, animated: true)
    }
}
