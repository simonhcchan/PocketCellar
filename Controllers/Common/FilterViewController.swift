//
//  FilterViewController.swift
//  PocketCellar
//
//  Created by IE15 on 26/04/24.
//


import UIKit
import IQDropDownTextField
import RangeSeekSlider

protocol FilterViewControllerDelegate: AnyObject {
    func applyFilter(alcoholDetails: [AlcoholDetailsModel],filter:FilterParameters?)
}

class FilterViewController: UIViewController, Datapass,UITextFieldDelegate {

    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var dollerLabel: UILabel!
    @IBOutlet weak var dateSlider: RangeSeekSlider!
    @IBOutlet weak var categoryTextField: IQDropDownTextField!
    @IBOutlet weak var reviewSlider: RattingView!
    @IBOutlet weak var subCategoryButton: IQDropDownTextField!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var subCategoryTextField: IQDropDownTextField!
    @IBOutlet weak var minTextField: UITextField!
    @IBOutlet weak var maxTextField: UITextField!
    
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var maxLabel: UILabel!
    @IBOutlet weak var maxDollerLabel: UILabel!
    //@IBOutlet weak var minYearLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var subCategoryLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
   // @IBOutlet weak var maxYearLabel: UILabel!
    @IBOutlet weak var resetAll: UIButton!
    @IBOutlet weak var ApplyButton: UIButton!
    @IBOutlet weak var dateRangPicker: RangeSeekSlider!
    @IBOutlet weak var minYearLabel: UITextField!
    @IBOutlet weak var maxYearLabel: UITextField!
    @IBOutlet weak var downChevronForCategory: UIImageView!
    @IBOutlet weak var downChevronForSubCategory: UIImageView!
    @IBOutlet weak var activityIndicatorForCategory: UIActivityIndicatorView!
    @IBOutlet weak var activityIndicatorForSubCategory: UIActivityIndicatorView!
    var delegate: FilterViewControllerDelegate?
    var ratting = 0
    var minAge:Int = 0
    var maxAge:Int = 2025
    var email:String?
    var year: String = "Year"
    var filterDetails:FilterParameters?
    var alcoholCategoryArray:[AlcoholGroup] = []
    var alcoholSubCategoryArray:[AlcoholSubGroup] = []
    var selectedSubCategory:String?
    var selectedCategory:String?
    private var categoryArray:[String] = []
    private var subCategoryArray:[String] = []
    private var categoryArrayLocalized:[String] = []
    private var subCategoryArrayLocalized:[String] = []

    var setMinValue = 0
    var setMaXValue = 2025
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLocalization()
        minTextField.text = "0"
        maxTextField.text = "9,999,999"
        self.activityIndicatorForSubCategory.isHidden = true
        self.downChevronForCategory.isHidden = true
        categoryTextField.delegate = self
        reviewSlider.selectedRating = -1
        dateSlider.minValue = 0
        dateSlider.maxValue = 2025
        maxTextField.delegate = self
        minTextField.delegate = self
        minYearLabel.text  = "0" //"0 \(year.localized())"
        maxYearLabel.text  = "2025" //"2024 \(year.localized())"
        dateSlider.selectedMinValue = CGFloat(0)
        dateSlider.selectedMaxValue = CGFloat(2025)
        dateRangPicker.delegate = self
        dateSlider.hideLabels = true
        reviewSlider.delegate = self
        minTextField.borderStyle = .none
        maxTextField.borderStyle = .none
        updateDropDownTextColor()
        dateSlider.tintColor =  UIColor(named: StringConstants.ColorConstant.primaryColor)
        reviewSlider.tintColor =  UIColor(named: StringConstants.ColorConstant.primaryColor)
        configureTextFieldWithLeftPadding(categoryTextField, padding: 24)
        configureTextFieldWithLeftPadding(subCategoryTextField, padding: 24)
        
        FetchDataFromFireBase.shared.fetchCategoryOFAlcohols { alcohols in
            self.alcoholCategoryArray = alcohols
            self.alcoholCategoryArray.sort { $0.sequence < $1.sequence }
            self.categoryArray = self.alcoholCategoryArray.map { $0.name }
            self.categoryArrayLocalized = self.alcoholCategoryArray.map { $0.name.localized() }
            self.categoryTextField.itemList =  self.categoryArrayLocalized
            self.categoryTextField.selectedItem  = self.filterDetails?.category
            self.activityIndicatorForCategory.isHidden = true
            self.downChevronForCategory.isHidden = false
            
            if let row = self.categoryArrayLocalized.firstIndex(of: self.categoryTextField.selectedItem ?? "") {
                if row >= 0 && row < self.categoryArray.count {
                    let desiredString = self.categoryArray[row]
                    self.selectedCategory = desiredString
                    self.subCategory(text:desiredString)
                }
            }
            
        }
        
        
        filterBasedOn()
        categoryTextField.dropDownTextColor = .white
        minYearLabel.delegate = self
        maxYearLabel.delegate = self

    }


    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateDropDownTextColor()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        setUpNavigationBar()
        setupFont()
    }
    
    func updateDropDownTextColor() {
        if traitCollection.userInterfaceStyle == .dark {
            categoryTextField.dropDownTextColor = .white
            subCategoryTextField.dropDownTextColor = .white
        } else{
            categoryTextField.dropDownTextColor = .black
            subCategoryTextField.dropDownTextColor = .black
        }
    }
    
    
    @IBAction func resetALL(_ sender: Any) {
        if let email = email {
            FetchDataFromFireBase.shared.fetchUserPosts(forEmail: email, completion: { alcohols in
                self.delegate?.applyFilter(alcoholDetails: alcohols, filter: nil)
            }) } else {
                FetchDataFromFireBase.shared.fetchAllPosts { alcohols in
                    self.delegate?.applyFilter(alcoholDetails: alcohols, filter: nil)
                }
            }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func applyButtonAction(_ sender: Any) {

        var min = 0
        var max = 9999999
        if let maxText = maxTextField.text ,let minText = minTextField.text{
            // Remove commas
            let formattedMaxText = maxText.replacingOccurrences(of: ",", with: "")
            let formattedMinText = minText.replacingOccurrences(of: ",", with: "")
            if let maxInt = Int(formattedMaxText),let minInt = Int(formattedMinText) {
                min = minInt
                max = maxInt
            } else {
                print("Invalid integer value")
            }
        }
        let maxPrice = maxTextField.text?.replacingOccurrences(of: ",", with: "") ?? "9999999"
        let minPrice = minTextField.text?.replacingOccurrences(of: ",", with: "") ?? "0"
        let filterParams = FilterParameters(email: nil,
                                            category: categoryTextField.selectedItem,
                                            type: subCategoryTextField.selectedItem,
                                            minAge: minAge,
                                            maxAge: maxAge,
                                            minPrice: Int(minPrice),
                                            maxPrice: Int(maxPrice),
                                            yourRating: ratting)
        if let row = categoryArrayLocalized.firstIndex(of: categoryTextField.selectedItem ?? "") {
            if row >= 0 && row < categoryArray.count {
                let desiredString = categoryArray[row]
                selectedCategory = desiredString
            }
        } else {
            selectedCategory = nil
        }
        
        if let row = subCategoryArrayLocalized.firstIndex(of: subCategoryTextField.selectedItem ?? "") {
            if row >= 0 && row < subCategoryArray.count {
                let desiredString = subCategoryArray[row]
                selectedSubCategory = desiredString
            }
        } else {
            selectedSubCategory = nil
        }
        dismiss(animated: true) {

            DispatchQueue.main.async {

                if let allCellarVC = self.delegate as? AllCellar {
                           allCellarVC.showLoader()
                       }
                if let myCellarVC = self.delegate as? MyCellar {
                    myCellarVC.showLoader()
                       }
                FetchDataFromFireBase.shared.fetchDataBasedOnFilter(forEmail: self.email, category: self.selectedCategory, type: self.selectedSubCategory, minAge: self.minAge,maxAge: self.maxAge, minPrice:Int(min), maxPrice: Int(max) , yourRating: self.ratting) { alcohols in
                    self.delegate?.applyFilter(alcoholDetails: alcohols, filter: filterParams)
                }
            }}

       // dismiss(animated: true, completion: nil)
    }
    @IBAction func closeButtonAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func catogoryButtonAction(_ sender: Any) {
    }
    
    @IBAction func subCategoryAction(_ sender: Any) {
    }
    
    func dataPassing(ratting: Int) {
        self.ratting = ratting
        print("ratting = ", ratting)
    }
    func configureTextFieldWithLeftPadding(_ textField: UITextField, padding: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
    }
    private func filterBasedOn(){
        if let filter = filterDetails {
            minTextField.text = String(filter.minPrice ?? 0)
            maxTextField.text = String(filter.maxPrice ?? 9999999)
            if let category = filter.category{
                categoryTextField.selectedItem = category
            }
            if let type = filter.type {
                subCategoryTextField.selectedItem = type
            }
            if let filterRating = filter.yourRating {
                reviewSlider.selectedRating = filterRating - 1
                ratting = filterRating
            }
            if let minAge = filter.minAge , let maxAge = filter.maxAge {
                dateSlider.selectedMaxValue = CGFloat(maxAge)
                dateSlider.selectedMinValue = CGFloat(minAge)
                
                minYearLabel.text  = "\(Int(minAge))"
                maxYearLabel.text  = "\(Int(maxAge))"
            }
            print(filter)
        }
    }
}

extension FilterViewController: RangeSeekSliderDelegate {
    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        print ("SEEKBAR DID CHANGED")
        minAge = Int(minValue)
        minYearLabel.text  = "\(Int(minValue))" //"\(Int(minValue)) \(year.localized())"
        maxYearLabel.text  = "\(Int(maxValue))"
        maxAge = Int(maxValue)
    }
}

extension FilterViewController: IQDropDownTextFieldDelegate {
    func textField(_ textField: IQDropDownTextField, didSelectItem item: String?, row: Int) {
        if textField == categoryTextField {
            self.filterDetails?.type = nil
            self.subCategoryTextField.selectedItem = nil
            self.subCategoryTextField.itemList = nil
            if row >= 0 && row < categoryArray.count {
                let desiredString = categoryArray[row]
                selectedCategory = desiredString
                subCategory(text: desiredString)
            }
        }
    }
    
    func subCategory(text:String) {
        self.activityIndicatorForSubCategory.isHidden = false
        self.downChevronForSubCategory.isHidden = true
        if text == "Other" {
            self.activityIndicatorForSubCategory.isHidden = true
            self.downChevronForSubCategory.isHidden = false
            self.subCategoryTextField.itemList = nil
        }
        else if text != "" {
            FetchDataFromFireBase.shared.fetchSubCategoryOFAlcohols(name: text){ alcohols in
                self.alcoholSubCategoryArray = alcohols
                self.alcoholSubCategoryArray.sort { $0.sequence < $1.sequence }
                self.subCategoryArray = self.alcoholSubCategoryArray.map { $0.name }
                self.subCategoryArrayLocalized = self.alcoholSubCategoryArray.map { $0.name.localized() }
                self.subCategoryTextField.itemList = self.subCategoryArrayLocalized
                self.subCategoryTextField.selectedItem = self.filterDetails?.type
                
                self.activityIndicatorForSubCategory.isHidden = true
                self.downChevronForSubCategory.isHidden = false
            }
        } else {
            self.activityIndicatorForSubCategory.isHidden = true
            self.downChevronForSubCategory.isHidden = false
        }
        dateSlider.isUserInteractionEnabled = true
        if text == "Beer" {
            dateSlider.isUserInteractionEnabled = false
            minYearLabel.text  = "0"
            maxYearLabel.text  = "0"
            dateSlider.minValue = 0
            dateSlider.maxValue = 0
            dateSlider.selectedMinValue = CGFloat(0)
            dateSlider.selectedMaxValue = CGFloat(0)
            setMinValue = 0
            setMaXValue = 0
        } else if text == "Wine" {
            dateSlider.minValue = 1926
            dateSlider.maxValue = 2025
            dateSlider.selectedMinValue = CGFloat(1926)
            dateSlider.selectedMaxValue = CGFloat(2025)
            minYearLabel.text  = "1926"
            maxYearLabel.text  = "2025"
            setMinValue = 1926
            setMaXValue = 2025
        } else {
            dateSlider.minValue = 0
            dateSlider.maxValue = 50
            dateSlider.selectedMinValue = CGFloat(0)
            dateSlider.selectedMaxValue = CGFloat(50)
            minYearLabel.text  = "0"
            maxYearLabel.text  = "50"
            setMinValue = 0
            setMaXValue = 50
        }
    }
}
extension FilterViewController {
    
    func setupFont() {
        let fontType = CurrentFont(rawValue: kUserDefault.getAppFontType() ?? "Normal")
        
        switch fontType {
        case .normal:
            setupFont(size: 17)
            
        case .large:
            setupFont(size: 19)
            
        case .veryLarge:
            setupFont(size: 21)
            
        case nil:
            break
        }
    }
    
    func setupFont(size:CGFloat) {
        self.filterLabel.font = UIFont.rubik(ofSize: size + 7 , weight: .medium)
        self.categoryLabel.font = UIFont.rubik(ofSize: size - 2 , weight: .regular)
        self.categoryTextField.font = UIFont.rubik(ofSize: size - 1 , weight: .regular)
        self.subCategoryLabel.font = UIFont.rubik(ofSize: size - 2 , weight: .regular)
        self.subCategoryTextField.font = UIFont.rubik(ofSize: size - 1 , weight: .regular)
        self.dateLabel.font = UIFont.rubik(ofSize: size - 2 , weight: .regular)
        self.priceLabel.font = UIFont.rubik(ofSize: size - 2 , weight: .regular)
        self.minLabel.font = UIFont.rubik(ofSize: size - 4 , weight: .regular)
        self.maxLabel.font = UIFont.rubik(ofSize: size - 4 , weight: .regular)
        self.dollerLabel.font = UIFont.rubik(ofSize: size , weight: .regular)
        self.maxDollerLabel.font = UIFont.rubik(ofSize: size , weight: .regular)
        self.minTextField.font = UIFont.rubik(ofSize: size - 3, weight: .regular)
        self.maxTextField.font = UIFont.rubik(ofSize: size - 3 , weight: .regular)
        self.ratingLabel.font = UIFont.rubik(ofSize: size - 2 , weight: .regular)
    }
    
    func setUpLocalization() {
        self.filterLabel.text = "Filter".localized()
        self.categoryLabel.text = "Category".localized()
        self.subCategoryLabel.text = "Sub Category".localized()
        self.dateLabel.text = "Date".localized()
        self.priceLabel.text = "Price Range".localized()
        self.minLabel.text = "Min".localized()
        self.maxLabel.text = "Max".localized()
        self.ratingLabel.text = "Rating".localized()
        self.categoryTextField.placeholder = "Category".localized()
        self.subCategoryTextField.placeholder = "Sub Category".localized()
        self.resetAll.setTitle("Reset All".localized(), for: .normal)
        self.ApplyButton.setTitle("Apply".localized(), for: .normal)
    }
    
}
extension FilterViewController {


//    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//        print("THE VALUES IS 4--\(textField.text ?? "00") --\(minYearLabel.text ?? "99")--")
//        return true
//    }

    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        print("THE VALUES IS 6--\(textField.text ?? "00") --\(minYearLabel.text ?? "99")--")
        if textField == minYearLabel ||  textField == maxYearLabel{
            let minVal = minYearLabel.text ?? "0"
            let maxVal = maxYearLabel.text ?? "2025"
            dateSlider.minValue = CGFloat(setMinValue)
            dateSlider.maxValue = CGFloat(setMaXValue)
            dateSlider.selectedMinValue = CGFloat(Int(minVal) ?? 0)
            dateSlider.selectedMaxValue = CGFloat(Int(maxVal) ?? 2025)
            minAge = Int(minVal) ?? setMinValue
            maxAge = Int(maxVal) ?? setMaXValue
            dateRangPicker.delegate = self

        }
    }
    func textFieldDidChangeSelection(_ textField: UITextField) {
        print("THE VALUES IS 7--\(textField.text ?? "00") --\(minYearLabel.text ?? "99")--")
        if textField == minYearLabel ||  textField == maxYearLabel{
            let minVal = minYearLabel.text ?? "0"
            let maxVal = maxYearLabel.text ?? "2025"
            dateSlider.minValue = CGFloat(setMinValue)
            dateSlider.maxValue = CGFloat(setMaXValue)
            dateSlider.selectedMinValue = CGFloat(Int(minVal) ?? 0)
            dateSlider.selectedMaxValue = CGFloat(Int(maxVal) ?? 2025)
            minAge = Int(minVal) ?? setMinValue
            maxAge = Int(maxVal) ?? setMaXValue
            dateRangPicker.delegate = self

        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let currentText = (textField.text ?? "") as NSString
        let updatedText = currentText.replacingCharacters(in: range, with: string)
        
        let formattedText = updatedText.replacingOccurrences(of: ",", with: "")
        
        guard let intValue = Int(formattedText), !formattedText.isEmpty else {
            textField.text = "0"
            return false
        }
        
        if intValue > 9999999 {
            return false
        }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        textField.text = numberFormatter.string(from: NSNumber(value: intValue))
        
        return false
    }
}
