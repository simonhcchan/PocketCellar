//
//  SectionHeaderView.swift
//  PocketCellar
//
//  Created by IE MacBook Pro 2014 on 09/04/24.
//

import Foundation
import UIKit
import FirebaseFirestoreInternal

protocol SectionHeaderViewDelegate: AnyObject {
    
    func sectionHeaderView(_ view: UITableViewHeaderFooterView, didTapOnSeeAll button: UIButton, withSection section: Int)
}

class SectionHeaderView: UITableViewHeaderFooterView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var seeAllButton: UIButton!
    
    var section: Int = -1
    weak var delegate: SectionHeaderViewDelegate?
    
    @IBAction func seeAllButtonTapped(_ sender: UIButton) {
        delegate?.sectionHeaderView(self, didTapOnSeeAll: sender, withSection: section)
    }
    func configure(with title: String) {
        titleLabel.text = title
        titleLabel.textColor = UIColor(named: StringConstants.ColorConstant.blackColor)
        let fontType = CurrentFont(rawValue: kUserDefault.getAppFontType() ?? "Normal")
        switch fontType {
        case .normal:
          self.titleLabel.font = UIFont.rubik(ofSize: 18 , weight: .medium)
        case .large:
          self.titleLabel.font = UIFont.rubik(ofSize: 20 , weight: .medium)
        case .veryLarge:
          self.titleLabel.font = UIFont.rubik(ofSize: 22 , weight: .medium)
        case nil:
          break
        }
      }
}
