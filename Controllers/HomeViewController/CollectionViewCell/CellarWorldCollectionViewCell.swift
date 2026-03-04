//
//  CellarWorldCollectionViewCell.swift
//  PocketCellar
//
//  Created by IE MacBook Pro 2014 on 06/04/24.
//

import UIKit

class CellarWorldCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var subCategoryLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var makerLabel: UILabel!
    @IBOutlet weak var originLabel: UILabel!
    
    @IBOutlet weak var titlesStack: UIStackView!
    @IBOutlet weak var agetTitleLabel: UILabel!
    @IBOutlet weak var priceTitleLabel: UILabel!
    @IBOutlet weak var subCategoryTitleLabel: UILabel!
    @IBOutlet weak var categoryTitleLabel: UILabel!
    @IBOutlet weak var makerTitleLabel: UILabel!
    @IBOutlet weak var originTitleLabel: UILabel!
    
    @IBOutlet weak var firstStarImageView: UIImageView!
    @IBOutlet weak var secondStarImageView: UIImageView!
    @IBOutlet weak var thirdStarImageView: UIImageView!
    @IBOutlet weak var fourthStarImageView: UIImageView!
    @IBOutlet weak var fifthStarImageView: UIImageView!
    @IBOutlet weak var tapButton: UIButton!

    @IBOutlet weak var stackWidth: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization cod
        self.layoutIfNeeded()
    }
    
    
    
    public func setValues(postDetails:AlcoholDetailsModel) {
        imageView.image = postDetails.image?.toImage()
        categoryLabel.text = postDetails.category?.localized()
        subCategoryLabel.text = postDetails.type?.localized()
        nameLabel.text = postDetails.name!
        makerLabel.text = postDetails.maker
        originLabel.text = postDetails.origin
        ageLabel.text = "\(postDetails.age ?? 0) \("Year".localized())"
            if let currency = postDetails.currency{
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .decimal
                numberFormatter.groupingSeparator = ","
                numberFormatter.groupingSize = 3
            if let formattedString = numberFormatter.string(from: NSNumber(value: postDetails.price ?? 0)) {
                priceLabel.text = "\(currency)\(formattedString)" } }
        updateStarRating(ratting: postDetails.yourRating ?? 0)
        
    }
    
    public func setUpLocaliction(){
        priceTitleLabel.text = "Price: ".localized()
        agetTitleLabel.text = "Age: ".localized()
        categoryTitleLabel.text = "Category".localized()
        makerTitleLabel.text = "Maker".localized()
        originTitleLabel.text = "Origin".localized()
        subCategoryTitleLabel.text = "Sub Category".localized()
    }
    private func labelWidth(){
        if let font = kUserDefault.getAppFontType() {
            if let currentFont = CurrentFont(rawValue: font) {
                switch currentFont {
                    case .large:
                        stackWidth.constant = 127
                    case .veryLarge:
                        stackWidth.constant = 140
                    default:
                        stackWidth.constant = 115
                }
            }
        } else {
            stackWidth.constant = 110
        }
    }
    private func updateStarRating(ratting: Int) {
        let starImageViews = [firstStarImageView, secondStarImageView, thirdStarImageView, fourthStarImageView, fifthStarImageView]
        for (index, starImageView) in starImageViews.enumerated() {
            if index < ratting {
                starImageView?.image = UIImage(named: StringConstants.ImageConstant.starFilled)
            } else {
                starImageView?.image = UIImage(named: StringConstants.ImageConstant.starUnfilled)
            }
        }
    }
    
    public func fontSetUp(){
        let fontType = CurrentFont(rawValue: kUserDefault.getAppFontType() ?? "Normal")
        switch fontType {
        case .normal:
            fonts(fontSize: 15)
        case .large:
            fonts(fontSize: 17)
        case .veryLarge:
            fonts(fontSize: 19)
        case .none:
            fonts(fontSize: 15)
        }
        labelWidth()
    }
    
    private func fonts(fontSize: CGFloat) {
        nameLabel.font = UIFont.rubik(ofSize: fontSize + 5, weight: .regular)
        ageLabel.font = UIFont.rubik(ofSize: fontSize - 3, weight: .regular)
        priceLabel.font = UIFont.rubik(ofSize: fontSize - 3, weight: .regular)
        subCategoryLabel.font = UIFont.rubik(ofSize: fontSize, weight: .regular)
        categoryLabel.font = UIFont.rubik(ofSize: fontSize, weight: .regular)
        makerLabel.font = UIFont.rubik(ofSize: fontSize, weight: .regular)
        originLabel.font = UIFont.rubik(ofSize: fontSize, weight: .regular)
        
        agetTitleLabel.font = UIFont.rubik(ofSize: fontSize - 3, weight: .regular)
        priceTitleLabel.font = UIFont.rubik(ofSize: fontSize - 3, weight: .regular)
        subCategoryTitleLabel.font = UIFont.rubik(ofSize: fontSize, weight: .regular)
        categoryTitleLabel.font = UIFont.rubik(ofSize: fontSize, weight: .regular)
        makerTitleLabel.font = UIFont.rubik(ofSize: fontSize, weight: .regular)
        originTitleLabel.font = UIFont.rubik(ofSize: fontSize, weight: .regular)
    }
    
}
