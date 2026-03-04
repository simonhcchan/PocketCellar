//
//  ImageViewController.swift
//  PocketCellar
//
//  Created by IE12 on 28/03/24.
//

import UIKit

class ImageViewController: UIViewController {
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var backView: UIView!
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.backView.backgroundColor = .white
        imageView.image = selectedImage
        imageView.image = selectedImage ?? UIImage(named: "Beer")
    }
    
    @IBAction func hideButtonAction(_ sender: Any) {
        dismiss(animated: true)
    }
}
