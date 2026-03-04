//
//  SettingViewTableViewCell.swift
//  PocketCellar
//
//  Created by IE15 on 15/03/24.
//

import UIKit

class SettingViewTableViewCell: UITableViewCell {

    static let identifier = "SettingViewTableViewCell"
    
    @IBOutlet weak var sizeShowLabel: UILabel!
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var custemTextLabel: UILabel!
    @IBOutlet weak var imageIcon: UIImageView!
    @IBOutlet weak var rightchevronImage: UIImageView!
    @IBOutlet weak var sepraterView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
       // sizeShowLabel.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    func setupFont() {

        let fontType = CurrentFont(rawValue: kUserDefault.getAppFontType() ?? "Normal")
        switch fontType {
        case .normal:
            self.custemTextLabel.font = UIFont.rubik(ofSize: 15 , weight: .regular)
            self.sizeShowLabel.font = UIFont.rubik(ofSize: 14 , weight: .regular)
        case .large:
            self.custemTextLabel.font = UIFont.rubik(ofSize: 17 , weight: .regular)
            self.sizeShowLabel.font = UIFont.rubik(ofSize: 16 , weight: .regular)

        case .veryLarge:
            self.custemTextLabel.font = UIFont.rubik(ofSize: 19 , weight: .regular)
            self.sizeShowLabel.font = UIFont.rubik(ofSize: 18 , weight: .regular)
        case nil:
            break
        }
    }
}
