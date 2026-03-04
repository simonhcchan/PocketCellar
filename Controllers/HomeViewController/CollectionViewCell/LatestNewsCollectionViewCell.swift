//
//  LatestNewsCollectionViewCell.swift
//  PocketCellar
//
//  Created by IE MacBook Pro 2014 on 04/04/24.
//

import UIKit

protocol LatestNewsCollectionViewCellDelegate: AnyObject {
    func readMoreButtonDidTap(at index: Int)
}

class LatestNewsCollectionViewCell: UICollectionViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var postByLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var readMoreButton: UIButton!
    
    var index: Int = 0
    weak var delegate: LatestNewsCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        readMoreButton.titleLabel?.attributedText = NSAttributedString(string: "Read more..".localized(), attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
    }
    
    @IBAction func readMoreButtonDidTapped(_ sender: UIButton) {
        print("readMore button tapped")
        delegate?.readMoreButtonDidTap(at: index)
    }
    
    public func setNewsValues(details: NewsModel) {
        imageView.image = details.imageUrl.toImage()
        let timeDifference = DateUtility.getTimeDifference(from: details.time)
        timeLabel.text = timeDifference
        descriptionLabel.text = details.description
        // descriptionLabel.text = "jninnomijni"
        titleLabel.text = details.heading
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
    }
    
    private func fonts(fontSize:CGFloat){
        self.postByLabel.font = UIFont.rubik(ofSize: fontSize - 2 , weight: .regular)
        self.timeLabel.font = UIFont.rubik(ofSize: fontSize - 2 , weight: .regular)
        self.titleLabel.font = UIFont.rubik(ofSize: fontSize + 2 , weight: .regular)
        self.descriptionLabel.font = UIFont.rubik(ofSize: fontSize, weight: .regular)
        
    }
}
