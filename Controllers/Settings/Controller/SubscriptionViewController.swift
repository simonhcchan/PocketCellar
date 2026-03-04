//
//  SubcriptionViewController.swift
//  PocketCellar
//
//  Created by IE15 on 10/06/24.
//

import UIKit
import FirebaseDatabase
import Firebase
import StoreKit
import WebKit

class SubscriptionViewController: UIViewController {
    
    @IBOutlet weak var purchaseSubscriptionLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var RestoreLabel: UILabel!
    
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var termsAndConditions: UIButton!
    @IBOutlet weak var privacyPolicy: UIButton!
    
    @IBOutlet weak var subscriptionAngleImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var restoreAngleImageView: UIImageView!
    
    @IBOutlet weak var restoreActivityIndicator: UIActivityIndicatorView!
    var expiryDate : String = ""
    var purchaseDate: String = ""
    var originalTransactionId: String = ""
    
    private var currentFont: CurrentFont = .normal
    private let purchaseIdentifierYearly = "com.pocketcellar.yearly"
    private var selectedFont: String = "Normal"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
        setUpNavigationBar()
        navigationTitle()
        self.hidesBottomBarWhenPushed = true
        setupFont()
        setLocalization()
        IAPHelper.shared.delegate = self
        IAPHelper.shared.getProducts()
        NotificationCenter.default.addObserver(self, selector: #selector(purchaseSuccess(_:)), name: NSNotification.Name(rawValue: "PurchaseSuccess"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(purchaseFailed(_:)), name: NSNotification.Name(rawValue: "PurchaseFailed"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(restoreSuccess), name: NSNotification.Name(rawValue: "PurchaseRestored"), object: nil)
    }
    
    @IBAction func purchaseButtonAction(_ sender: Any) {
        IAPHelper.shared.purchase(product: "com.pocketcellar.yearly")
        subscriptionAngleImageView.isHidden = true
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
    }
    
    @IBAction func reStore(_ sender: Any) {
        print("restore tapped")
        restoreAngleImageView.isHidden = true
        restoreActivityIndicator.startAnimating()
        restoreActivityIndicator.isHidden = false
        IAPHelper.shared.restorePurchase()
    }
    
    @IBAction func termsAndConditions(_ sender: Any) {
        //        let storyboard = UIStoryboard(name: StoryboardName.main.rawValue, bundle: nil)
        //        guard let controller = storyboard.instantiateViewController(withIdentifier: "PrivacyPolicyViewController") as? PrivacyPolicyViewController else{
        //            return }
        //
        //            controller.pdf = "Terms&Conditions_29April2024"
        //            controller.headerTitle = "Terms and Conditions".localized()
        //        controller.hidesBottomBarWhenPushed = true
        //        self.navigationController?.pushViewController(controller, animated: true)
        let privacyPolicyURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
        let webViewVC = UIViewController()
        let webView = WKWebView(frame: webViewVC.view.frame)
        webView.load(URLRequest(url: privacyPolicyURL))
        webViewVC.view.addSubview(webView)
        self.present(webViewVC, animated: true, completion: nil)
    }
    
    @IBAction func privacyPolicy(_ sender: Any) {
        //        let storyboard = UIStoryboard(name: StoryboardName.main.rawValue, bundle: nil)
        //        guard let controller = storyboard.instantiateViewController(withIdentifier: "PrivacyPolicyViewController") as? PrivacyPolicyViewController else{
        //            return }
        //
        //            controller.pdf = "PrivacyPolicy_29April2024"
        //            controller.headerTitle = "Privacy Policy".localized()
        //
        //        self.navigationController?.pushViewController(controller, animated: true)
        let privacyPolicyURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
        let webViewVC = UIViewController()
        let webView = WKWebView(frame: webViewVC.view.frame)
        webView.load(URLRequest(url: privacyPolicyURL))
        webViewVC.view.addSubview(webView)
        self.present(webViewVC, animated: true, completion: nil)
    }
    func setLocalization() {
        self.purchaseSubscriptionLabel.text = "Purchase Subscription".localized()
        self.yearLabel.text = "$0.99/" + "Year".localized()
        self.RestoreLabel.text = "Restore".localized()
        termsAndConditions.setTitle("Terms and Conditions".localized(), for: .normal)
        privacyPolicy.setTitle("Privacy Policy".localized(), for: .normal)
        noteLabel.text = """
          1. Enjoy an ad-free experience for just $0.99 a year! With our subscription, you'll never be interrupted by pesky ads while using our app.
          2. Subscribe now to unlock a seamless and uninterrupted experience.
          3. Cancel anytime.
          """.localized()
    }
    func setupFont() {
        let fontType = CurrentFont(rawValue: kUserDefault.getAppFontType() ?? "Normal")
        switch fontType {
        case .normal:
            self.purchaseSubscriptionLabel.font = UIFont.rubik(ofSize: 15 , weight: .regular)
            self.yearLabel.font = UIFont.rubik(ofSize: 15 , weight: .regular)
            self.RestoreLabel.font = UIFont.rubik(ofSize: 15 , weight: .regular)
            noteLabel.font = UIFont.rubik(ofSize: 12 , weight: .regular)
            termsAndConditions.titleLabel?.font = UIFont(name: "rubik-regular", size: 13)
            privacyPolicy.titleLabel?.font = UIFont(name: "rubik-regular", size: 13)
        case .large:
            self.purchaseSubscriptionLabel.font = UIFont.rubik(ofSize: 17 , weight: .regular)
            self.yearLabel.font = UIFont.rubik(ofSize: 17 , weight: .regular)
            self.RestoreLabel.font = UIFont.rubik(ofSize: 17 , weight: .regular)
            noteLabel.font = UIFont.rubik(ofSize: 14 , weight: .regular)
            termsAndConditions.titleLabel?.font = UIFont(name: "rubik-regular", size: 15)
            privacyPolicy.titleLabel?.font = UIFont(name: "rubik-regular", size: 15)
        case .veryLarge:
            self.purchaseSubscriptionLabel.font = UIFont.rubik(ofSize: 19 , weight: .regular)
            self.yearLabel.font = UIFont.rubik(ofSize: 19 , weight: .regular)
            self.RestoreLabel.font = UIFont.rubik(ofSize: 19 , weight: .regular)
            noteLabel.font = UIFont.rubik(ofSize: 16 , weight: .regular)
            termsAndConditions.titleLabel?.font = UIFont(name: "rubik-regular", size: 17)
            privacyPolicy.titleLabel?.font = UIFont(name: "rubik-regular", size: 17)
        case nil:
            break
        }
    }
    
    private func navigationTitle() {
        self.title = "Subscription".localized()
        let titleTextAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.rubik(ofSize: 20, weight: .regular)
        ]
        navigationController?.navigationBar.titleTextAttributes = titleTextAttributes
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        backButton.setImage(UIImage(named: StringConstants.ImageConstant.backButton), for: .normal)
        backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    @objc func backAction () {
        navigationController?.popViewController(animated: true)
    }
}
extension SubscriptionViewController : GetProductsPrice  {
    
    func didReceivedProducts(products: [SKProduct]) {
        for product in products {
            // showSpinner = true
            print("Product Title: \(product.localizedTitle)")
            print(product.price)
            print(product.priceLocale)
            print(product.productIdentifier)
            setPriceLabel(product: product)
        }
    }
    
    func setPriceLabel(product: SKProduct) {
        let formatter = NumberFormatter()
        formatter.locale = product.priceLocale
        formatter.numberStyle = .currency
        if let formattedAmount = formatter.string(from: product.price as NSNumber) {
            let currency = String(formattedAmount)
            let price = String(describing: product.price)
            let currecncyType = currency.prefix(1)
            DispatchQueue.main.async {
                if product.productIdentifier == "com.pocketcellar.yearly" {
                    // showSpinner = false
                    let text = "\(String(currecncyType))\(price)"
                    //self.basicAmount = text
                }
            }
        }
    }
}

extension SubscriptionViewController  {
    
    @objc func purchaseFailed(_ notification: NSNotification) {
        print(" purchase failed ")
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        subscriptionAngleImageView.isHidden = false
        if let error = notification.object as? NSError {
            if error.code != SKError.paymentCancelled.rawValue {
                print(error.localizedDescription)
                //    DTMUIHelper.showAlertWithAction(alertTitle: "Error", messageBody: error.localizedDescription, controller: self)
            }
        }
    }

    @objc func restoreSuccess() {
        print(" restore purchase success ")
        //  SKPaymentQueue.default().finishTransaction(transaction)
        restoreActivityIndicator.isHidden = true
        restoreAngleImageView.isHidden = false
        showAlert(title: "Restore Successful", message: "Your purchases have been restored.")
    }
    
    
    @objc func purchaseSuccess(_ notification: NSNotification) {
        //  print(" purchase success ")
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        subscriptionAngleImageView.isHidden = false
        if let productInfo = notification.userInfo?["product"] as? SKPaymentTransaction {
            let productId = ("\(productInfo.payment.productIdentifier)")
            let transactionId = ("\(String(describing: productInfo.transactionIdentifier))")
            // let originalTransactionId = ("\(String(describing: productInfo.original?.transactionIdentifier))")
            if let originalTransactionId = productInfo.original?.transactionIdentifier {
                let transactionId = "\(originalTransactionId)"
                self.originalTransactionId = transactionId
            }
            
            let purchaseStatus = ("\(productInfo.transactionState.status())")
            if let unwrappedDate = productInfo.transactionDate {
                let transactionDate = "\(unwrappedDate)"
                self.purchaseDate = "\(transactionDate)"
                print(transactionDate) // Output: "2023-07-05 10:05:56 +0000"
            }
            
            if let expiry =   UserDefaults.standard.value(forKey: UserDefaultsKeys.expiryDate) {
                print(expiry)
                expiryDate = "\(expiry)"
            }
            print("User purchased product id:-> \(productInfo.payment.productIdentifier)")
            print("Transaction Identifier:-> \(String(describing: productInfo.transactionIdentifier))")
            print("Original Transaction Identifier:-> \(String(describing: productInfo.original?.transactionIdentifier))")
            print("Transaction Date:-> \(productInfo.transactionDate as Any)")
            print("Purchase Status:-> \(productInfo.transactionState.status())")
            print("expiry Date :-> \(UserDefaults.standard.value(forKey: UserDefaultsKeys.expiryDate))")
            
            if productInfo.transactionState.status() == "restored" {
                switch productInfo.payment.productIdentifier {
                case purchaseIdentifierYearly:
                    print(productInfo.original?.transactionIdentifier as Any)
                    UserDefaultsUtil.reStoreTransactionId = productInfo.original?.transactionIdentifier
                    break
                    
                default:
                    break
                }
                
            } else if  productInfo.transactionState.status() == "purchased" {
                switch productInfo.payment.productIdentifier {
                case purchaseIdentifierYearly:
                    print(productInfo.original?.transactionIdentifier as Any)
                    saveSubscriptionDetails(productId: productId, transactionId: transactionId, transactionDate: purchaseDate, status: purchaseStatus, expiryDate: expiryDate, originalTransactionId: originalTransactionId) { success in
                        if success {
                            print("Saved successfully")
                            UserDefaultsManager.setIsShowingAds(showingAds: false)
                            UserDefaults.standard.set(true, forKey: "isUserSubscribed")
                        }
                    }
                    
                    break
                    
                default:
                    break
                }
            }
            else {
                print("The else case")
            }
            // showSpinner = false
        }
    }
}


extension SubscriptionViewController {
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
    
    
    func convertToDate(dateString: String, format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: dateString)
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
}


