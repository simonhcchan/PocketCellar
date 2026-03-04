//
//  ContactUsViewController.swift
//  PocketCellar
//
//  Created by Ali hassan on 06/10/2024.
//

import UIKit

class ContactUsViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var contactTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
        setUpNavigationBar()
        navigationTitle()
        setTestView()
        // Do any additional setup after loading the view.
    }

    func setTestView(){
        // Define the text with the email and social media links
               let text = """
               Please share your comments for us to improve the app:

               By email: 
               cellarpocket@gmail.com

               In Facebook: https://www.facebook.com/profile.php?id=61557835102085

               In Instagram: https://www.instagram.com/cellarpocket/
               """


                let attributedString = NSMutableAttributedString(string: text)
                let font = UIFont.systemFont(ofSize: 16.0)
                let customColor = UIColor(named: "Textgreen") ?? UIColor.green 
               attributedString.addAttributes([.font: font, .foregroundColor: customColor], range: NSRange(location: 0, length: text.count))
               // Set attributes for Facebook link
               let facebookRange = (text as NSString).range(of: "https://www.facebook.com/profile.php?id=61557835102085")
               attributedString.addAttribute(.link, value: "https://www.facebook.com/profile.php?id=61557835102085", range: facebookRange)

               // Set attributes for Instagram link
               let instagramRange = (text as NSString).range(of: "https://www.instagram.com/cellarpocket/")
               attributedString.addAttribute(.link, value: "https://www.instagram.com/cellarpocket/", range: instagramRange)

               // Configure the UITextView
        contactTextView.attributedText = attributedString
        contactTextView.isEditable = false // Make sure it's not editable
        contactTextView.isScrollEnabled = false // Disable scrolling if you don't need it
        contactTextView.dataDetectorTypes = .link // Detect links
        contactTextView.linkTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "Textgreen") ?? UIColor.green, .font: UIFont.systemFont(ofSize: 16.0)] // Optional: customize link color

               // Set the delegate
        contactTextView.delegate = self
    }
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
            // Open the URL in the app if possible
            if UIApplication.shared.canOpenURL(URL) {
                UIApplication.shared.open(URL, options: [:], completionHandler: nil)
            }
            return false // Prevent the default behavior (opening the link in Safari)
        }


    private func navigationTitle() {
        self.title = "Contact Us".localized()
        let titleTextAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.rubik(ofSize: 20, weight: .regular)
        ]
        navigationController?.navigationBar.titleTextAttributes = titleTextAttributes
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        backButton.setImage(UIImage(named: StringConstants.ImageConstant.backButton), for: .normal)
        backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    @objc func backAction () {
        navigationController?.popViewController(animated: true)
    }
    
}
