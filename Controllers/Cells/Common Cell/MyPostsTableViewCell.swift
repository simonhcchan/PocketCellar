//
//  myPostsTableViewCell.swift
//  PocketCellar
//
//  Created by IE15 on 14/03/24.
//

import UIKit
protocol MyPostsTableViewCellDelegate: AnyObject {
    func didTapOnImage(image:String)
    func deleteOrShareButtonTapped(at indexPath: IndexPath,documentID: String,sender: UIButton)
    func shareButtonTapped(at indexPath: IndexPath,documentID: String,sender: UIButton)
    func editButtonTapped(postDetails: AlcoholDetailsModel)
    func showToast(message: String)
}

class MyPostsTableViewCell: UITableViewCell {
    public var delegate: MyPostsTableViewCellDelegate?
    static var identifier = "MyPostsTableViewCell"
    public var postDetails: AlcoholDetailsModel?
    var image = ""
    public var indexPath: IndexPath?
    public var documentId: String?
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var alcoholImage: UIImageView!
    @IBOutlet private var category: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var issueType: UILabel!
    @IBOutlet private var type: UILabel!
    @IBOutlet private var name: UILabel!
    @IBOutlet private var maker: UILabel!
    @IBOutlet private var origin: UILabel!
    @IBOutlet private var shopFrom: UILabel!
    @IBOutlet private var age: UILabel!
    @IBOutlet private var price: UILabel!
    @IBOutlet private var purchaseDate: UILabel!
    @IBOutlet private var doYouRecommended: UILabel!
    @IBOutlet private var yourRemark: UILabel!
    @IBOutlet private var youReview: UILabel!
    
    @IBOutlet private var firstStarImageView: UIImageView!
    @IBOutlet private var secondStarImageView: UIImageView!
    @IBOutlet private var thirdStarImageView: UIImageView!
    @IBOutlet private var fourthStarImageView: UIImageView!
    @IBOutlet private var fifthStarImageView: UIImageView!
    
    @IBOutlet weak var yourRemarkType: UILabel!
    @IBOutlet weak var beerImage: UIImageView!
    @IBOutlet weak var nameType: UILabel!
    @IBOutlet weak var yourReviewType: UILabel!
   
    @IBOutlet weak var recommendedType: UILabel!
    @IBOutlet weak var labelType: UILabel!
    @IBOutlet weak var makerType: UILabel!
    
    @IBOutlet weak var shopFromType: UILabel!
    @IBOutlet weak var datePurchaseType: UILabel!
    @IBOutlet weak var originType: UILabel!
    
    @IBOutlet weak var yourRemarkStack: UIStackView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        beerImage.addGestureRecognizer(tapGesture)
        beerImage.isUserInteractionEnabled = true
        addLongPressGestureRecognizer(to: maker)
        addLongPressGestureRecognizer(to: name)
        addLongPressGestureRecognizer(to: type)
        addLongPressGestureRecognizer(to: origin)
        addLongPressGestureRecognizer(to: shopFrom)
        addLongPressGestureRecognizer(to: age)
        addLongPressGestureRecognizer(to: price)
        addLongPressGestureRecognizer(to: purchaseDate)
        addLongPressGestureRecognizer(to: doYouRecommended)
        addLongPressGestureRecognizer(to: yourRemarkType)
        addLongPressGestureRecognizer(to: yourReviewType)
        addLongPressGestureRecognizer(to: category)
        self.layoutIfNeeded()
    }
    @IBAction func deleteButtonAction(_ sender: Any) {
        delegate?.deleteOrShareButtonTapped(at: indexPath ?? IndexPath(), documentID: documentId ?? "", sender: sender as! UIButton)
    }
    
    @IBAction func editButtonAction(_ sender: Any) {
        delegate?.editButtonTapped(postDetails:postDetails!)
    }
    
    @IBAction func shareButtonAction(_ sender: Any) {
        delegate?.shareButtonTapped(at: indexPath ?? IndexPath(), documentID: documentId ?? "", sender: sender as! UIButton)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc func imageTapped() {
        delegate?.didTapOnImage(image: image)
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
    
    public func setValues(postDetails: AlcoholDetailsModel, at indexPath: IndexPath) {
        self.postDetails = postDetails
        alcoholImage.image = postDetails.image?.toImage()
        image = postDetails.image ?? ""
        category.text = postDetails.category?.localized()
        type.text = postDetails.type?.localized()
        name.text = postDetails.name!
        maker.text = postDetails.maker!
        origin.text = postDetails.origin
        shopFrom.text = postDetails.shopFrom
        age.text = "\(postDetails.age ?? 0) \("Year".localized())"
        if let currency = postDetails.currency{
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.groupingSeparator = ","
            numberFormatter.groupingSize = 3
            if let formattedString = numberFormatter.string(from: NSNumber(value: postDetails.price ?? 0)) {
        price.text = "\(currency)\(formattedString)"} }
        purchaseDate.text = postDetails.purchaseDate
        doYouRecommended.text = "\(postDetails.doYouRecommended ?? false ? "Yes" : "No")".localized()
        yourRemarkType.text = postDetails.yourRemark
        yourReviewType.text = postDetails.yourReview
        updateStarRating(ratting: postDetails.yourRating ?? 0)
        if let time = postDetails.timeStamp {
            timeLabel.text =  DateUtility.getTimeDifference(from: time.dateValue())
        }
        self.indexPath = indexPath
        self.documentId = postDetails.documentId
    }
    
    func setupFont() {
        let fontType = CurrentFont(rawValue: kUserDefault.getAppFontType() ?? "Normal")
        switch fontType {
        case .normal:
            setFont(size: 15)
        case .large:
            setFont(size: 17)
        case .veryLarge:
            setFont(size: 19)
        case nil:
            break
        }
    }
    
    private func setFont(size: CGFloat){
        self.nameType.font = UIFont.rubik(ofSize: size , weight: .regular)
        self.name.font = UIFont.rubik(ofSize: size , weight: .regular)
        self.maker.font = UIFont.rubik(ofSize: size , weight: .regular)
        self.category.font = UIFont.rubik(ofSize: size , weight: .regular)
        self.type.font = UIFont.rubik(ofSize: size, weight: .regular)
        self.origin.font = UIFont.rubik(ofSize: size , weight: .regular)
        self.shopFrom.font = UIFont.rubik(ofSize: size , weight: .regular)
        self.age.font = UIFont.rubik(ofSize: size , weight: .regular)
        self.price.font = UIFont.rubik(ofSize: size , weight: .regular)
        self.purchaseDate.font = UIFont.rubik(ofSize: size , weight: .regular)
        self.doYouRecommended.font = UIFont.rubik(ofSize: size , weight: .regular)
        self.yourRemark.font = UIFont.rubik(ofSize: size , weight: .regular)
        self.youReview.font = UIFont.rubik(ofSize: size , weight: .regular)
        self.labelType.font = UIFont.rubik(ofSize: size , weight: .regular)
        self.makerType.font = UIFont.rubik(ofSize: size , weight: .regular)
        self.originType.font = UIFont.rubik(ofSize: size , weight: .regular)
        self.shopFromType.font = UIFont.rubik(ofSize: size , weight: .regular)
        self.datePurchaseType.font = UIFont.rubik(ofSize: size , weight: .regular)
        self.recommendedType.font = UIFont.rubik(ofSize: size , weight: .regular)
        self.yourRemarkType.font = UIFont.rubik(ofSize: size , weight: .regular)
        self.yourReviewType.font = UIFont.rubik(ofSize: size , weight: .regular)
        self.ageLabel.font = UIFont.rubik(ofSize: size , weight: .regular)
        self.priceLabel.font = UIFont.rubik(ofSize: size , weight: .regular)
        self.categoryLabel.font = UIFont.rubik(ofSize: size , weight: .regular)
        self.issueType.font = UIFont.rubik(ofSize: size , weight: .regular)
    }
    
    func setUpLocalization() {
        self.nameType.text = "Name".localized()
        self.maker.text = "Maker".localized()
        self.type.text = "Type".localized()
        self.origin.text = "Origin".localized()
        self.shopFrom.text = "Shop From".localized()
        self.purchaseDate.text = "Purchase Date".localized()
        self.yourRemark.text = "Your Remark :".localized()
        self.youReview.text = "Your Review :".localized()
        self.labelType.text = "Sub Category:".localized()
        self.makerType.text = "Maker".localized()
        self.originType.text = "Origin".localized()
        self.shopFromType.text = "Shop From".localized()
        self.datePurchaseType.text = "Purchase Date".localized()
        self.recommendedType.text = "Do You Recommend?".localized()
        self.ageLabel.text = "Age: ".localized()
        self.priceLabel.text = "Price: ".localized()
        self.categoryLabel.text = "Category:".localized()
    }
    
    func addLongPressGestureRecognizer(to label: UILabel) {
            let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(labelLongPressed(_:)))
            label.isUserInteractionEnabled = true
            label.addGestureRecognizer(longPressRecognizer)
        }
    
        @objc func labelLongPressed(_ sender: UILongPressGestureRecognizer) {
            if sender.state == .began {
                guard let label = sender.view as? UILabel else { return }
                // Show the copy menu when the long press begins
                label.becomeFirstResponder()
                let menuController = UIMenuController.shared
                if !menuController.isMenuVisible {
                    menuController.showMenu(from: self, rect: label.frame)
                }
                
                // Copy the label's text to the pasteboard
                let pasteboard = UIPasteboard.general
                pasteboard.string = label.text
                // self.showToast(message: "Text copied.")
                delegate?.showToast(message: "Text copied.")
            }
        }
}



//import UIKit
//
//class BannerView: UIView {
//    static let height: CGFloat = 60
//    
//    init(frame: CGRect, message: String, fromTop: Bool) {
//        super.init(frame: frame)
//        
//        backgroundColor = UIColor.black.withAlphaComponent(0.8)
//        
//        let label = UILabel(frame: CGRect(x: 16, y: 0, width: frame.width - 32, height: frame.height))
//        label.textColor = UIColor.white
//        label.textAlignment = .center
//        label.text = message
//        addSubview(label)
//        
//        if fromTop {
//            self.frame.origin.y = -BannerView.height
//        } else {
//            self.frame.origin.y = frame.height
//        }
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    func show() {
//        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
//            self.frame.origin.y = 0
//        }, completion: { _ in
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                self.hide()
//            }
//        })
//    }
//    
//    func hide() {
//        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
//            if self.frame.origin.y < 0 {
//                self.frame.origin.y = -BannerView.height
//            } else {
//                self.frame.origin.y = self.superview!.frame.height
//            }
//        }, completion: { _ in
//            self.removeFromSuperview()
//        })
//    }
//}
