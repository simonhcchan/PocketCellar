//
//  ProfileEditViewController.swift
//  PocketCellar
//
//  Created by IE15 on 24/04/24.
//

import UIKit
import IQDropDownTextField

protocol ProfileEditDelegate: AnyObject {
    func didUpdateProfile()
}

class ProfileEditViewController: UIViewController, IQDropDownTextFieldDelegate {
    
    @IBOutlet weak var HeaderLabel: UILabel!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
  
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var genderTextField: IQDropDownTextField!
    @IBOutlet weak var ageTextField: IQDropDownTextField!
    @IBOutlet weak var favouriteAlcoholTextField: UITextField!
    
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    weak var delegate: ProfileEditDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.isHidden = true
        genderTextField.delegate = self
        ageTextField.delegate = self
        genderTextField.itemList = ["Male".localized(), "Female".localized(), "Other".localized()]
        ageTextField.itemList = ["18-24","25-30","31-40","41-50","51-60","60+"]
        userData()
        setUpLocalization()
        setupFont()
        fetchAllUserTokens()
    }

    @IBAction func updateButtonAction(_ sender: Any) {
        guard let userFirstName = firstNameTextField.text,
              let userLastName = lastNameTextField.text else {
            return
        }
        
        if userFirstName.isEmpty {
            alertMassage(title: StringConstants.AllertMessage.name.localized(), massage: StringConstants.AllertMessage.pleaseEnterYourFirstName.localized())
            return
        }
        if userLastName.isEmpty{
            alertMassage(title: StringConstants.AllertMessage.name.localized(), massage:  StringConstants.AllertMessage.pleaseEnterYourLastName.localized())
            return
        }
        
        guard let selectedGender = genderTextField.selectedItem, !selectedGender.isEmpty else {
            let errorMessage = StringConstants.AllertMessage.pleaseSelectGender.localized()
            alertMassage(title: StringConstants.AllertMessage.selection.localized(), massage: errorMessage)
            return
        }
        guard let selectedAge = ageTextField.selectedItem, !selectedAge.isEmpty else {
            let errorMessage = StringConstants.AllertMessage.pleaseSelectRange.localized()
            alertMassage(title: StringConstants.AllertMessage.selection.localized(), massage: errorMessage)
            return
        }
        
        guard let selectedAlcohol = favouriteAlcoholTextField.text, !selectedAlcohol.isEmpty else {
            let errorMessage = StringConstants.AllertMessage.pleaseSelectFavouriteAlcohol.localized()
            alertMassage(title: StringConstants.AllertMessage.message.localized(), massage: errorMessage)
            return
        }
        
        self.activityIndicator.isHidden = false
        let updatedUserData: [String: Any] = [
            "userFirstName": firstNameTextField.text ?? "",
            "userLastName": lastNameTextField.text ?? "",
            "age": ageTextField.selectedItem ?? "",
            "gender": genderTextField.selectedItem ?? "",
            "alcohol": favouriteAlcoholTextField.text ?? ""
        ]
        guard let email = UserDefaultsManager.getUserEmail() else {
            return
        }
         print(email)
        AddDataInFireBase.shared.updateUserDetails(forEmail: email, withData: updatedUserData) { error in
            if let error = error {
                print("Error updating user details: \(error.localizedDescription)")
            } else {
             
                let userName = self.firstNameTextField.text! + " " + self.lastNameTextField.text!
                UserDefaultsManager.setUserName(name: userName)
                self.delegate?.didUpdateProfile()
                self.activityIndicator.isHidden = true
                self.dismiss(animated: true)
                print("User details updated successfully!")
            }
        }
        
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    private func userData(){
        guard let email = UserDefaultsManager.getUserEmail() else {
            return
        }
        userEmailLabel.text = email
        FetchDataFromFireBase.shared.fetchUserData(forUserID: email) { result in
            switch result {
            case .success(let userData):
                if let userData = userData {
                    self.firstNameTextField.text = userData["userFirstName"] as? String
                    self.lastNameTextField.text = userData["userLastName"] as? String
                    self.ageTextField.selectedItem = userData["age"] as? String
                    self.favouriteAlcoholTextField.text = userData["alcohol"] as? String
                    self.genderTextField.selectedItem = userData["gender"] as? String
                } else {
                    print("User document not found")
                }
            case .failure(let error):
                print("Error fetching user data: \(error.localizedDescription)")
            }
        }
    }

    private func fetchAllUserTokens() {
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
                    title: "Testing",
                    body: "This is a test notification"
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

    func setUpLocalization() {
        self.HeaderLabel.text = "Update Profile".localized()
        self.firstNameTextField.placeholder = "First Name".localized()
        self.lastNameTextField.placeholder = "Last Name".localized()
        self.genderTextField.placeholder = "Gender".localized()
        
        self.ageTextField.placeholder = "Age Range".localized()
        self.favouriteAlcoholTextField.placeholder = "favourite alcohol".localized()
      
        self.updateButton.setTitle("Update".localized(), for: .normal)
        self.cancelButton.setTitle("Cancel".localized(), for: .normal)
    }
}

extension ProfileEditViewController {
    func alertMassage(title: String?, massage: String?) {
        let alertController = UIAlertController(title: title, message: massage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: StringConstants.AllertMessage.ok.localized(), style: .cancel, handler: { _ in }))
        self.present(alertController, animated: true)
    }
    
    func setupFont() {
        let fontType = CurrentFont(rawValue: kUserDefault.getAppFontType() ?? "Normal")
        switch fontType {
        case .normal:
            self.HeaderLabel.font = UIFont.rubik(ofSize: 32 , weight: .medium)
         
        case .large:
            self.HeaderLabel.font = UIFont.rubik(ofSize: 34 , weight: .medium)
           
        case .veryLarge:
            self.HeaderLabel.font = UIFont.rubik(ofSize: 36 , weight: .medium)
    
        case nil:
            self.HeaderLabel.font = UIFont.rubik(ofSize: 32 , weight: .medium)

        }
    }
}
