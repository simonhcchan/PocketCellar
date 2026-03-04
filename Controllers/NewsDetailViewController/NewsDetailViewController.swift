//
//  NewsDetailViewController.swift
//  PocketCellar
//
//  Created by IE MacBook Pro 2014 on 09/04/24.
//

import UIKit

class NewsDetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var postByLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dismissButton: UIButton!
    
    var newsDetails : NewsModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        if let newsDetails = newsDetails {
            setNewsValues(details: newsDetails)
        }
        postByLabel.text = "By admin".localized()
        // Do any additional setup after loading the view.
        addLongPressGestureRecognizer(to: titleLabel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupFont()
    }
    public func setNewsValues(details: NewsModel) {
        imageView.image = details.imageUrl.toImage()
        let timeDifference = DateUtility.getTimeDifference(from: details.time)
        timeLabel.text = timeDifference
        descriptionTextView.text = details.description
        titleLabel.text = details.heading
    }
    
    @IBAction func dismissButtonAction(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
}
extension NewsDetailViewController {

    func setupFont() {
        let fontType = CurrentFont(rawValue: kUserDefault.getAppFontType() ?? "Normal")

        switch fontType {
        case .normal:
            self.titleLabel.font = UIFont.rubik(ofSize: 22 , weight: .medium)
            self.timeLabel.font = UIFont.rubik(ofSize: 12 , weight: .medium)

            self.descriptionTextView.font = UIFont.rubik(ofSize: 17 , weight: .regular)
        case .large:
            self.titleLabel.font = UIFont.rubik(ofSize: 24 , weight: .medium)
            self.timeLabel.font = UIFont.rubik(ofSize: 14 , weight: .medium)
            self.descriptionTextView.font = UIFont.rubik(ofSize: 19 , weight: .regular)

        case .veryLarge:
            self.titleLabel.font = UIFont.rubik(ofSize: 26 , weight: .medium)
            self.timeLabel.font = UIFont.rubik(ofSize: 16 , weight: .medium)
            self.descriptionTextView.font = UIFont.rubik(ofSize: 21 , weight: .regular)
        case nil:
            break
        }
    }
}

extension NewsDetailViewController {
    
    func addLongPressGestureRecognizer(to label: UILabel) {
            let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(labelLongPressed(_:)))
            label.isUserInteractionEnabled = true
            label.addGestureRecognizer(longPressRecognizer)
        }
    
        @objc func labelLongPressed(_ sender: UILongPressGestureRecognizer) {
            if sender.state == .began {
                guard let label = sender.view as? UILabel else { return }
                label.becomeFirstResponder()
                let pasteboard = UIPasteboard.general
                pasteboard.string = label.text
                ToastManager.showToast(message: "Text copied.", onView: self.view)
                
            }
        }
}
