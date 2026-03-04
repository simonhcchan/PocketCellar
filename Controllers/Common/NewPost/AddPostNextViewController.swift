//
//  AddPostNextViewController.swift
//  PocketCellar
//
//  Created by IE15 on 20/03/24.
//

import UIKit
import IQDropDownTextField
import IQDropDownTextField.IQDropDownTextField_DateTime
import FirebaseFirestoreInternal

class AddPostNextViewController: UIViewController,UITextFieldDelegate,UITextViewDelegate {
    
    @IBOutlet private var PriceTextField: IQDropDownTextField!
    @IBOutlet private var remarkLabel: UILabel!
    @IBOutlet private var purchaseDateLabel: UILabel!
    @IBOutlet private var priceLabel: UILabel!
    @IBOutlet private var ratingLabel: UILabel!
    @IBOutlet private var recommenedLabel: UILabel!
    @IBOutlet private var reviewLabel: UILabel!
    
    @IBOutlet private var deleteDateButton: UIButton!
    @IBOutlet private var doYouRecommendedSwitch: UISwitch!
    
    @IBOutlet private var rattingView: RattingView!
    @IBOutlet private var reviewTextView: UITextView!
    
    @IBOutlet private var resetButtonLabel: UIButton!
    @IBOutlet private var remarkTextView: UITextView!
    @IBOutlet private var placeholderForRemark: UILabel!
    @IBOutlet private var placeholderForReview: UILabel!
    @IBOutlet private var barView: UIView!
    @IBOutlet private var dateTextField: UITextField!
    
    @IBOutlet private var saveButtonLabel: UIButton!
    @IBOutlet private var currencyTextField: UITextField!
    @IBOutlet private var activityIndicater: UIActivityIndicatorView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    var items = ["Refreshing", "Balanced", "hazy", "bitter", "Oaky", "Empyreumatic", "Burning", "Shar aftertaste", "Effervescent"]
    var selectedItems = Set<String>()
    
    private let todayDate = Date()
    private var selectedYear = 2025
    private let datePicker = UIPickerView()
    private let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    private let years = Array((1926..<2026).reversed()).map { "\($0)" }
    private var ratting = 0
    public var postDetails: [String: String] = [
        "alcoholCategory": "",
        "alcoholSubCategory": "",
        "image": "",
        "name": "",
        "maker":"",
        "origin": "",
        "shopFrom": "",
        "age": ""
    ]
    var yourReview = ""
    private var fontSize: CGFloat = 34
    public var postDetail:AlcoholDetailsModel?
    var selectedItem = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        navigationTitle()
        configureDropdown()
        activityIndicater.isHidden = true
        //rattingView.delegate = self
        currencyTextField.delegate = self
        rattingView.selectedRating = 2
        rattingView.delegate = self
        PriceTextField.delegate = self
        reviewTextView.delegate = self
        remarkTextView.delegate = self
        datePicker.delegate = self
        datePicker.dataSource = self
        dateTextField.inputView = datePicker
        placeHolder()
        barView.frame.size.width = UIScreen.main.bounds.width
        configureTextFieldWithLeftPadding(PriceTextField, padding: 10)
        configureTextFieldWithLeftPadding(dateTextField, padding: 10)
        configureTextFieldWithLeftPadding(currencyTextField, padding: 10)
        configureTextViewWithLeftPadding(remarkTextView, padding: 10)
        configureTextViewWithLeftPadding(reviewTextView, padding: 10)
        PriceTextField.itemList = ["USD $","GBP £","EUR €","HKD $", "JPY ¥", "CNY ¥"]
        updateDropDownTextColor()
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        dateTextField.inputAccessoryView = toolbar
        if let postDetail = postDetail{
            valueSetup(details: postDetail)
        }
    }
    
    @objc func doneButtonTapped() {
        dateTextField.resignFirstResponder()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // Update drop down text color when interface style changes
        updateDropDownTextColor()
    }
    
    func updateDropDownTextColor() {
        if traitCollection.userInterfaceStyle == .dark {
            PriceTextField.dropDownTextColor = .white
        } else {
            // Set to your default color for light mode
            PriceTextField.dropDownTextColor = .black
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        setUpNavigationBar()
        setupFont()
        setUpLocalization()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //   navigationController?.setNavigationBarHidden(true, animated: true)
        setUpNavigationBar(with: .white)
    }
    
    func placeHolder(){
        
        if reviewTextView.text.isEmpty {
            placeholderForReview.isHidden = false
        } else {
            placeholderForReview.isHidden = true
        }
        
        if remarkTextView.text.isEmpty {
            placeholderForRemark.isHidden = false
        } else {
            placeholderForRemark.isHidden = true
        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text ?? "") as NSString
        let updatedText = currentText.replacingCharacters(in: range, with: string)
        
        let formattedText = updatedText.replacingOccurrences(of: ",", with: "")
        
        guard let intValue = Int(formattedText), !formattedText.isEmpty else {
            textField.text = "0"
            return false
        }
        
        if intValue > 9999999 {
            return false
        }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        textField.text = numberFormatter.string(from: NSNumber(value: intValue))
        
        return false
    }
    
    @IBAction func SaveButtonAction(_ sender: Any) {
        
        guard let selectedText = PriceTextField.selectedItem, !selectedText.isEmpty else {
            let errorMessage = StringConstants.AllertMessage.selectPrice.localized()
            alertMassage(title: StringConstants.AllertMessage.selection.localized(), message: errorMessage)
            return
        }
        
        guard let selectedText = currencyTextField.text, !selectedText.isEmpty else {
            let errorMessage = StringConstants.AllertMessage.addPrice.localized()
            alertMassage(title: StringConstants.AllertMessage.selection.localized(), message: errorMessage)
            return
        }
        
        
        guard let selectedTextDate = dateTextField.text, !selectedTextDate.isEmpty else {
            let errorMessage = StringConstants.AllertMessage.selectDate.localized()
            alertMassage(title: StringConstants.AllertMessage.selection.localized(), message: errorMessage)
            return
        }
        
        guard let review = reviewTextView.text, !review.isEmpty else {
            let errorMessage = StringConstants.AllertMessage.giveYourReviewAndReview.localized()
            alertMassage(title: StringConstants.AllertMessage.selection.localized(), message: errorMessage)
            return
        }
        addOnDataBase()
    }
    
    private func addOnDataBase() {
        var remark = remarkTextView.text
        remark = remark == "" ? "NA" : remark
        activityIndicater.isHidden = false
        let email = UserDefaultsManager.getUserEmail()
        let numberString = currencyTextField.text
        let stringWithoutCommas = numberString?.replacingOccurrences(of: ",", with: "") ?? "0"

        var concatenatedText = ""

        for i in selectedItems {
            concatenatedText += i + ", "
        }

        yourReview = concatenatedText + reviewTextView.text
        AddDataInFireBase.shared.addNewPost(details: AlcoholDetailsModel(image: postDetails["image"], category: postDetails["alcoholCategory"], type: postDetails["alcoholSubCategory"], name: postDetails["name"], maker: postDetails["maker"], email: email, origin: postDetails["origin"], price: Int(stringWithoutCommas) ?? 100, currency: PriceTextField.selectedItem ?? "$" , age: Int(postDetails["age"]!) ?? 0, shopFrom: postDetails["shopFrom"], purchaseDate: dateTextField.text!, yourRating: ratting, doYouRecommended: doYouRecommendedSwitch.isOn, yourReview: yourReview, yourRemark: remark, timeStamp: postDetail?.timeStamp ?? Timestamp(date: Date()), documentId: postDetail?.documentId ?? nil), completion: { error in
            if let error = error {
                self.activityIndicater.isHidden = true
                self.alertMassage(title: "Error", message: "Error adding QA pairs: \(error.localizedDescription)")
            } else {
                self.SendNotificationToUsers()
//                if self.postDetail == nil {
//                    self.sendNotificationToTopic()
//                }
                self.activityIndicater.isHidden = true
                var message = StringConstants.AllertMessage.newCellarAddedSuccessfully.localized()
                if let _ = self.postDetail {
                    message = StringConstants.AllertMessage.newCellarUpdateSuccessfully.localized()
                }
                let alertController = UIAlertController(title: StringConstants.AllertMessage.done.localized(), message: message, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: StringConstants.AllertMessage.ok.localized(), style: .cancel, handler: { _ in
                    self.goToHomeScreen()
                }))
                self.present(alertController, animated: true)
            }
        })
    }

    private func SendNotificationToUsers() {
        guard let email = UserDefaultsManager.getUserEmail() else {
            return
        }

        FetchDataFromFireBase.shared.fetchAllUserTokens(excludingUserID: email) { result in
            switch result {
            case .success(let tokens):
                var allTokens: [String] = tokens
                print("Fetched FCM tokens for all users except current user: \(allTokens)")

                PushNotificationAPI.shared.sendPushNotification(
                    deviceTokens: allTokens,
                    title: "\(self.postDetails["alcoholSubCategory"] ?? "post") is added",
                    body: "\(self.postDetails["alcoholSubCategory"] ?? "post") is added please check the user reviews"
                ) { result in
                    switch result {
                    case .success:
                        print("Notification sent successfully!")
                    case .failure(let error):
                        print("Failed to send notification: \(error.localizedDescription)")
                    }
                }
            case .failure(let error):
                print("Error fetching tokens: \(error.localizedDescription)")
            }
        }
    }

    func isEmptyString() -> Bool {
        if let remark = remarkTextView.text,let review = reviewTextView.text {
            let trimmedRemark = remark.replacingOccurrences(of: " ", with: "")
            let trimmedReview = review.replacingOccurrences(of: " ", with: "")
            return trimmedRemark.count >= 5 && trimmedReview.count >= 5
        }
        return false
    }
    
    @IBAction func ResetButtonAction(_ sender: Any) {
        remarkTextView.text = ""
        reviewTextView.text = ""
        //  PriceTextField.text = ""
        placeholderForRemark.isHidden = false
        placeholderForReview.isHidden = false
    }
    
    @IBAction func deleteButtonAction(_ sender: Any) {
        dateTextField.text = ""
    }
    func configureDropdown() {
        dateTextField.delegate = self
    }
    
    private func navigationTitle() {
        let fontSize: CGFloat = 20
        let titleTextAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.rubik(ofSize: fontSize, weight: .regular)
        ]
        navigationController?.navigationBar.titleTextAttributes = titleTextAttributes
        self.title = StringConstants.Category.addLiquorIntoYourCellar.localized()
        
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        backButton.setImage(UIImage(named: StringConstants.ImageConstant.backButton), for: .normal)
        backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    @objc func backAction () {
        navigationController?.popViewController(animated: true)
    }
    
    func configureTextFieldWithLeftPadding(_ textField: UITextField, padding: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
    }
    
    func configureTextViewWithLeftPadding(_ textView: UITextView, padding: CGFloat) {
        let inset = UIEdgeInsets(top: 7, left: padding, bottom: 0, right: 0)
        textView.textContainerInset = inset
    }
    
    @IBAction func datePickerButtonAction(_ sender: Any) {
        let picker : UIDatePicker = UIDatePicker()
        
        picker.datePickerMode = UIDatePicker.Mode.date
        //  picker.maximumDate = Date()
        picker.addTarget(self, action: #selector(dueDateChanged(sender:)), for: UIControl.Event.valueChanged)
        let pickerSize : CGSize = picker.sizeThatFits(CGSize.zero)
        picker.frame = CGRect(x:0.0, y:250, width:pickerSize.width, height:460)
        
        self.view.addSubview(picker)
    }
    
    @objc func dueDateChanged(sender:UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .none
        //    btnMonth.setTitle(dateFormatter.string(from: sender.date), for: .normal)
    }
    
    private func alertMassage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: StringConstants.AllertMessage.ok.localized(), style: .cancel, handler: { _ in
            // print("OK Tapped")
        }))
        self.present(alertController, animated: true)
    }
    
    func goToHomeScreen() {
        let storyboard = UIStoryboard(name: StoryboardName.common.rawValue, bundle: nil)
        let homeTabBarController = storyboard.instantiateViewController(withIdentifier: "HomeTabBarController") as! HomeTabBarController
        let navigationController = UINavigationController(rootViewController: homeTabBarController)
        navigationController.setNavigationBarHidden(true, animated:true)
        UIApplication.shared.windows.first?.rootViewController = navigationController
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
    
}

extension AddPostNextViewController: Datapass,IQDropDownTextFieldDelegate{
    func dataPassing(ratting: Int) {
        self.ratting = ratting + 1
    }
}

extension AddPostNextViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2 // Month and year
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return months.count
        } else {
            return years.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return months[row].localized()
        } else {
            return years[row].localized()
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedMonthIndex = pickerView.selectedRow(inComponent: 0)
        let selectedYearIndex = pickerView.selectedRow(inComponent: 1)
        let selectedYear = years[selectedYearIndex]
        let selectedMonth = months[selectedMonthIndex]
        if let year = Int(selectedYear), year == Calendar.current.component(.year, from: Date()) {
            let currentMonthIndex = Calendar.current.component(.month, from: Date()) - 1
            if selectedMonthIndex > currentMonthIndex {
                pickerView.selectRow(currentMonthIndex, inComponent: 0, animated: true)
            }
        }
        dateTextField.text = "\(months[pickerView.selectedRow(inComponent: 0)].localized()) \(years[pickerView.selectedRow(inComponent: 1)])"
    }
    
}
extension AddPostNextViewController {
    
    func setupFont() {
        let fontType = CurrentFont(rawValue: kUserDefault.getAppFontType() ?? "Normal")
        switch fontType {
        case .normal:
            self.priceLabel.font = UIFont.rubik(ofSize: 15 , weight: .regular)
            self.purchaseDateLabel.font = UIFont.rubik(ofSize: 15 , weight: .regular)
            self.ratingLabel.font = UIFont.rubik(ofSize: 15 , weight: .regular)
            self.recommenedLabel.font = UIFont.rubik(ofSize: 15 , weight: .regular)
            self.reviewLabel.font = UIFont.rubik(ofSize: 15 , weight: .regular)
            // self.remarkLabel.font = UIFont.rubik(ofSize: 15 , weight: .regular)
            self.placeholderForRemark.font = UIFont.rubik(ofSize: 15 , weight: .regular)
            self.placeholderForReview.font = UIFont.rubik(ofSize: 15 , weight: .regular)
            
        case .large:
            self.priceLabel.font = UIFont.rubik(ofSize: 17 , weight: .regular)
            self.purchaseDateLabel.font = UIFont.rubik(ofSize: 17 , weight: .regular)
            self.ratingLabel.font = UIFont.rubik(ofSize: 17 , weight: .regular)
            self.recommenedLabel.font = UIFont.rubik(ofSize: 17 , weight: .regular)
            self.reviewLabel.font = UIFont.rubik(ofSize: 17 , weight: .regular)
            // self.remarkLabel.font = UIFont.rubik(ofSize: 17 , weight: .regular)
            self.placeholderForRemark.font = UIFont.rubik(ofSize: 17 , weight: .regular)
            self.placeholderForReview.font = UIFont.rubik(ofSize: 17 , weight: .regular)
            
        case .veryLarge:
            self.priceLabel.font = UIFont.rubik(ofSize: 19 , weight: .regular)
            self.purchaseDateLabel.font = UIFont.rubik(ofSize: 19 , weight: .regular)
            self.ratingLabel.font = UIFont.rubik(ofSize: 19 , weight: .regular)
            self.recommenedLabel.font = UIFont.rubik(ofSize: 19 , weight: .regular)
            self.reviewLabel.font = UIFont.rubik(ofSize: 19 , weight: .regular)
            //self.remarkLabel.font = UIFont.rubik(ofSize: 19 , weight: .regular)
            self.placeholderForRemark.font = UIFont.rubik(ofSize: 19 , weight: .regular)
            self.placeholderForReview.font = UIFont.rubik(ofSize: 19 , weight: .regular)
            
        case nil:
            break
        }
    }
    
    func setUpLocalization() {
        self.priceLabel.text = "Price".localized()
        self.purchaseDateLabel.text = "Purchase Date".localized()
        self.ratingLabel.text = "Rating".localized()
        self.recommenedLabel.text = "Do You Recommend?".localized()
        self.reviewLabel.text = "Review".localized()
        self.remarkLabel.text = "Remark".localized()
        self.currencyTextField.placeholder = "Price".localized()
        self.dateTextField.placeholder = "Selected Date".localized()
        self.resetButtonLabel.setTitle("Reset".localized(), for: .normal)
        self.saveButtonLabel.setTitle("Save".localized(), for: .normal)
        self.placeholderForRemark.text = "Type your Remark".localized()
        self.placeholderForReview.text = "Type your Review".localized()
    }
    
    func valueSetup(details:AlcoholDetailsModel){
        currencyTextField.text = "\(details.price ?? 0)"
        PriceTextField.selectedItem = details.currency
        dateTextField.text = details.purchaseDate
        doYouRecommendedSwitch.isOn = details.doYouRecommended!


        remarkTextView.text = details.yourRemark
        rattingView.selectedRating = details.yourRating! - 1

        let text = details.yourReview
        // Split the text by comma and trim any whitespace around each part
        let parts = text?.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        let array = Array(parts!.dropLast())
        let myselectedItems = Set(array)
        let textReview = parts?.last ?? ""

        print("Array:", array)
        print("TextReview:", textReview)
        selectedItems = myselectedItems
        reviewTextView.text = textReview


        placeHolder()
    }
    func splitText(_ text: String, numberOfAttributes: Int) -> (attributes: [String], review: String) {
        // Split the text by commas
        let components = text.components(separatedBy: ",")

        // Trim whitespace from each component
        let trimmedComponents = components.map { $0.trimmingCharacters(in: .whitespaces) }

        // Extract attributes
        let attributes = Array(trimmedComponents.prefix(numberOfAttributes))

        // Extract review text
        let review = trimmedComponents.dropFirst(numberOfAttributes).joined(separator: ", ")

        return (attributes, review)
    }

    func sendNotificationToTopic() {
        // Replace YOUR_SERVER_KEY with your Firebase Server Key
        let serverKey = "AAAA3x3Aysw:APA91bG1o4xVd4LbG7IP-PJ7kiwGkKbgS-KT9VWX1JJ61PyikVRBhrnlzDnr8aBrpvvzPs5jegIDQPnXjhUcXV2w57JSnHb8T-P0XPe4ZhXQQIU9Df3zoTZ8_pC8DPpv_8XOouXWVkHV"
        let topic = "/topics/newPost"
        
        guard let url = URL(string: "https://fcm.googleapis.com/fcm/send") else {
            print("Invalid URL")
            return
        }
        
        let headers: [String: String] = [
            "Authorization": "key=\(serverKey)",
            "Content-Type": "application/json"
        ]
        
        let body: [String: Any] = [
            "to": topic,
            "notification": [
                "title": "New Cellar",
                "body": "The New Cellar has been added"
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending notification: \(error.localizedDescription)")
            } else {
                print("Notification sent successfully")
            }
        }.resume()
    }
    
}
extension AddPostNextViewController : UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:
                                                        "ReviewcollectionViewCell", for: indexPath) as! ReviewcollectionViewCell
        
        cell.label.text = items[indexPath.item]
        cell.labelView.layer.cornerRadius = 8
        if selectedItems.contains(items[indexPath.item]) {

            cell.labelView.backgroundColor = UIColor(named: "PrimaryColor")
        }else{
            cell.labelView.backgroundColor = .lightGray
        }
        
        return cell
    }
    
    // MARK: - CollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        placeHolder()
        selectedItem = items[indexPath.item]
        
        
        if selectedItems.contains(selectedItem) {
            selectedItems.remove(selectedItem)
        } else {
            selectedItems.insert(selectedItem)
        }
        
        collectionView.reloadData()
       //updateTextView()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width   / 3 - 8) ,
                      height: (collectionView.frame.height  / 3  ))
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }


    // MARK: - TextViewDelegate
    
    func textViewDidChange(_ textView: UITextView) {
        placeHolder()
//        let typedText = textView.text.components(separatedBy: " ")
//        
//        for word in typedText {
//            if items.contains(word) && !selectedItems.contains(word) {
//                selectedItems.insert(word)
              // updateTextView()
//                break
//            }
//        }
    }
    
    // MARK: - Helper Methods
    
    func updateTextView() {
//        let text = reviewTextView.text
//
//        if ((text?.contains(selectedItem)) != nil) {
           // reviewTextView.text = \(selectedItems.joined(separator: ". "))\(text ?? "")"
//        }else{
//            //reviewTextView.text = "\(selectedItems.joined(separator: ". "))\(text ?? "")"
//        }

    }
    private func removeSelectedItems(from text: String) -> String {
        // Remove occurrences of each selected item from the text
        var updatedText = text
        for item in items {
            updatedText = updatedText.replacingOccurrences(of: "\(item). ", with: "")
        }
        return updatedText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

}

class ReviewcollectionViewCell : UICollectionViewCell{
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var labelView : UIView!



}
