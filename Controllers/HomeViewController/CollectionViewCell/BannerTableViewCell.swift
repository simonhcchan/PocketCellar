//
//  BannerTableViewCell.swift
//  PocketCellar
//
//  Created by IE15 on 16/04/24.
//

import UIKit
import GoogleMobileAds

class BannerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var bannerView: UIView!
    
    private lazy var banner: GADBannerView = {
        let banner = GADBannerView()
        banner.adUnitID = "ca-app-pub-8501671653071605/1974659335"
        banner.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.8)
        banner.load(GADRequest())
        return banner
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //banner.rootViewController = self
        banner.translatesAutoresizingMaskIntoConstraints = false
        bannerView.addSubview(banner)
        
        NSLayoutConstraint.activate([
            banner.topAnchor.constraint(equalTo: bannerView.topAnchor),
            banner.leadingAnchor.constraint(equalTo: bannerView.leadingAnchor),
            banner.trailingAnchor.constraint(equalTo: bannerView.trailingAnchor),
            banner.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor)
        ])
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
