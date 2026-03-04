//
//  FilterViewController.swift
//  PocketCellar
//
//  Created by IE15 on 16/03/24.
//

import UIKit

class FilterViewController: UIViewController {
    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var secondImageView: UIImageView!
    @IBOutlet weak var thirdImageView: UIImageView!
    @IBOutlet weak var fourthImageView: UIImageView!
    var index:Int?
    var didSelectAction: ((String) -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        checkOut(index: index ?? -1)
    }
    
    @IBAction func date(_ sender: Any) {
        didSelectAction?("date")
        checkOut(index: 0)
        dismiss(animated: true, completion: nil)
    }
    @IBAction func price(_ sender: Any) {
        didSelectAction?("price")
        checkOut(index: 1)
         dismiss(animated: true, completion: nil)
    }
    @IBAction func ratting(_ sender: Any) {
        didSelectAction?("ratting")
        checkOut(index: 2)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func category(_ sender: Any) {
        didSelectAction?("Category")
        checkOut(index: 3)
       dismiss(animated: true, completion: nil)
    }
    
    func checkOut(index:Int){
        let images = [firstImageView,secondImageView,thirdImageView,fourthImageView]
        for ind in 0...3 {
            if ind == index {
                images[ind]?.image = UIImage(named: "check")
            } else {
                images[ind]?.image = UIImage(named: "Chec")
            }
        }
    }
}
