//
//  FillViewController.swift
//  PocketCellar
//
//  Created by IE12 on 21/03/24.
//

import UIKit
import RangeSeekSlider
import IQDropDownTextField

class FillViewController: UIViewController, IQDropDownTextFieldDelegate {


    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var rangeSliderforPrice: RangeSeekSlider!
    @IBOutlet weak var rangeSliderforDate: RangeSeekSlider!
    @IBOutlet weak var catagorySelect: IQDropDownTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        catagorySelect.delegate = self
        rangeSliderforDate.hideLabels = true
        rangeSliderforPrice.hideLabels = true
        configureTextFieldWithLeftPadding(catagorySelect, padding: 24)
        rangeSliderforDate.tintColor =  UIColor(named: "PrimaryColor")
        rangeSliderforPrice.tintColor = UIColor(named: "PrimaryColor")
        catagorySelect.itemList = ["Beer", "Wine", "Japanese Alcohol","Sprit","Chinese Alcohol"]
    }
    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        DateLabel.text = "Min: \(Int(minValue)), Max: \(Int(maxValue))"
    }
    func configureTextFieldWithLeftPadding(_ textField: UITextField, padding: CGFloat) {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: textField.frame.height))
            textField.leftView = paddingView
            textField.leftViewMode = .always
    }
}

