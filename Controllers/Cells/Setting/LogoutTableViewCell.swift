//
//  LogoutTableViewCell.swift
//  PocketCellar
//
//  Created by IE15 on 19/03/24.
//

import UIKit

class LogoutTableViewCell: UITableViewCell {

    @IBOutlet weak var logoutLabel: UILabel!

    @IBOutlet weak var imageIcon: UIImageView!
    
    @IBOutlet weak var sepraterView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setupFont() {

        let fontType = CurrentFont(rawValue: kUserDefault.getAppFontType() ?? "Normal")
        switch fontType {
        case .normal:
            self.logoutLabel.font = UIFont.rubik(ofSize: 15 , weight: .regular)
        case .large:
            self.logoutLabel.font = UIFont.rubik(ofSize: 17 , weight: .regular)
        case .veryLarge:
            self.logoutLabel.font = UIFont.rubik(ofSize: 19 , weight: .regular)
        case nil:
            break
        }

    }
}
