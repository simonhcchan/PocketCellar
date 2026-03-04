//
//  PrivacyPolicyTableViewCell.swift
//  PocketCellar
//
//  Created by IE15 on 07/06/24.
//

import UIKit
import Nantes

protocol PrivacyPolicyTableViewCellDelegate: AnyObject {
    func didTapTermsOrPrivacyButton(title: String, url: String)
}


class PrivacyPolicyTableViewCell: UITableViewCell {
    static let identifier = "PrivacyPolicyTableViewCell"
    
    @IBOutlet weak var PrivacyPolicyButton: UIButton!
    @IBOutlet weak var andLabel: UILabel!
    @IBOutlet weak var termsAndConditionButton: UIButton!
    weak var delegate: PrivacyPolicyTableViewCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func privacyPolicyaction(_ sender: UIButton) {
        delegate?.didTapTermsOrPrivacyButton(title: "Privacy Policy", url: "https://firebasestorage.googleapis.com/v0/b/pocket-cellar-41a23.appspot.com/o/Documents%2FPrivacyPolicy_29April2024.pdf?alt=media&token=678bcfcc-e263-49eb-a0e7-b1c55fd1c42d")
    }
    
    @IBAction func termsAndConditionAction(_ sender: UIButton) {
        delegate?.didTapTermsOrPrivacyButton(title: "Terms and Conditions", url: "https://firebasestorage.googleapis.com/v0/b/pocket-cellar-41a23.appspot.com/o/Documents%2FTerms%26Conditions_29April2024.pdf?alt=media&token=8361ba82-8fa8-4126-b67c-5b3fc2edea92")
    }
    
    func setupFont() {
        let fontType = CurrentFont(rawValue: kUserDefault.getAppFontType() ?? "Normal")
        switch fontType {
        case .normal:
            self.andLabel.font = UIFont.rubik(ofSize: 15, weight: .regular)
            self.PrivacyPolicyButton.titleLabel?.font = UIFont.rubik(ofSize: 15, weight: .regular)
            self.termsAndConditionButton.titleLabel?.font = UIFont.rubik(ofSize: 15, weight: .regular)
        case .large:
            self.andLabel.font = UIFont.rubik(ofSize: 17, weight: .regular)
            self.PrivacyPolicyButton.titleLabel?.font = UIFont.rubik(ofSize: 17, weight: .regular)
            self.termsAndConditionButton.titleLabel?.font = UIFont.rubik(ofSize: 17, weight: .regular)
        case .veryLarge:
            self.andLabel.font = UIFont.rubik(ofSize: 19, weight: .regular)
            self.PrivacyPolicyButton.titleLabel?.font = UIFont.rubik(ofSize: 19, weight: .regular)
            self.termsAndConditionButton.titleLabel?.font = UIFont.rubik(ofSize: 19, weight: .regular)
        case nil:
            break
        }
    }
}



