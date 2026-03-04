//
//  AddPostViewController.swift
//  PocketCellar
//
//  Created by IE15 on 13/03/24.
//

import UIKit
import IQDropDownTextField
import TOCropViewController


class AddPostViewController: UIViewController,UITextFieldDelegate, IQDropDownTextFieldDelegate{
    
    @IBOutlet private var nextButton: UIButton!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var MarkerLabel: UILabel!
    @IBOutlet private var originLabel: UILabel!
    @IBOutlet private var shopFromLabel: UILabel!
    @IBOutlet private var ageLabel: UILabel!
    
    @IBOutlet private var liquorLabel: UILabel!
    @IBOutlet private var closeButton: UIButton!
    @IBOutlet private var bottleImage: UIImageView!
    
    
    @IBOutlet private var albumLabel: UILabel!
    @IBOutlet private var albumButton: UIButton!
    @IBOutlet private var albumImage: UIImageView!
    @IBOutlet private var cameraLabel: UILabel!
    @IBOutlet private var cameraImage: UIImageView!
    @IBOutlet private var cameraButton: UIButton!
    @IBOutlet private var nameTextField: UITextField!
    @IBOutlet private var makerTextField: UITextField!
    @IBOutlet private var originTextField: UITextField!
    @IBOutlet private var shopNameTextField: UITextField!
    
    @IBOutlet private var dashBordView: UIView!
    @IBOutlet private var selectedImage: UIImageView!
    @IBOutlet private var ageTextField: IQDropDownTextField!
    @IBOutlet private var ageView: UIView!
    @IBOutlet weak var ageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var ageViewTopConstraint: NSLayoutConstraint!
    private var textCheck: String?
    private let imagePickerController = UIImagePickerController()
    public var postDetails:AlcoholDetailsModel?
    private var fontSize: CGFloat = 34
   // private let ageArray = Array((1958...2024).map { String($0) }.reversed())
    private let ageArray: [String] = {
        var array = ["0"]
        array.append(contentsOf: (1958...2025).map { String($0) }.reversed())
        return array
    }()
    private let ageArray1 = (0...50).map { String($0) }
    private var labelImage:String?
    @IBOutlet private var barView: UIView!
    public var selectedCategory = ""
    public var selectedSubCategory = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        ageTextField.delegate = self
        closeButton.isHidden = true
        navigationTitle()
        setUpLocalization()
        configureTextFieldWithLeftPadding(nameTextField, padding: 10)
        configureTextFieldWithLeftPadding(makerTextField, padding: 10)
        configureTextFieldWithLeftPadding(originTextField, padding: 10)
        configureTextFieldWithLeftPadding(shopNameTextField, padding: 10)
        configureTextFieldWithLeftPadding(ageTextField, padding: 10)
        
        selectedImage.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        barView.addGestureRecognizer(tapGesture)
        updateDropDownTextColor()
        if let postDetails = postDetails {
            selectedCategory = postDetails.category ?? ""
            selectedSubCategory = postDetails.type ?? ""
            valuesSetup(postDetails: postDetails)
        }
        if selectedCategory == "Wine" {
            ageTextField.itemList = ageArray
        } else if selectedCategory == "Beer" {
            ageView.isHidden = true
            ageViewHeightConstraint.constant = 0
            ageViewTopConstraint.constant = 0
        }
        else{
            ageTextField.itemList = ageArray1
        }
        
        if let postDetails = postDetails {
            valuesSetup(postDetails: postDetails)}
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateDropDownTextColor()
    }
    
    func updateDropDownTextColor() {
        if traitCollection.userInterfaceStyle == .dark {
            ageTextField.dropDownTextColor = .white
        } else {
            ageTextField.dropDownTextColor = .black
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        setUpNavigationBar()
        setupFont()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setUpNavigationBar(with: .white)
    }
    
    @IBAction func closeButtonAction(_ sender: Any) {
        selectedImage.image = nil
        liquorLabel.isHidden = false
        cameraImage.isHidden = false
        cameraLabel.isHidden = false
        albumImage.isHidden = false
        albumLabel.isHidden = false
        bottleImage.isHidden = false
        closeButton.isHidden = true
        barView.backgroundColor = UIColor(named: StringConstants.ColorConstant.bGgreen)
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        var errorMessage = StringConstants.AllertMessage.errorMessageFillNameOriginShopFromAge.localized()
        if selectedCategory == "Beer" {
            errorMessage = StringConstants.AllertMessage.errorMessageFillNameOrigin.localized()
        }
        
        guard let name = nameTextField.text, !name.isEmpty,let marker = makerTextField.text, !marker.isEmpty,let origin = originTextField.text, !origin.isEmpty else {
            alertMassage(title: StringConstants.AllertMessage.alert.localized(), message: errorMessage)
            return
        }
        
        if selectedCategory != "Beer" {
            guard let age = ageTextField.selectedItem, !age.isEmpty else {
                alertMassage(title: StringConstants.AllertMessage.alert.localized(), message: errorMessage)
                return }
        }
        
        guard  selectedImage.image != nil else {
            let errorMessage = StringConstants.AllertMessage.errorMessageForImagePicker.localized()
            alertMassage(title: StringConstants.AllertMessage.alert.localized(), message: errorMessage)
            return
        }
        
        let storyboard = UIStoryboard(name: StoryboardName.common.rawValue, bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "AddPostNextViewController") as? AddPostNextViewController {
            viewController.postDetails["image"] = selectedImage.image?.toJpegString(compressionQuality: 0.4)
            viewController.postDetails["name"] = nameTextField.text
            viewController.postDetails["maker"] = makerTextField.text
            viewController.postDetails["origin"] = originTextField.text
            viewController.postDetails["shopFrom"] = shopNameTextField.text == "" ? "NA" : shopNameTextField.text
            viewController.postDetails["age"] = selectedCategory == "Beer" ? "0" : ageTextField.selectedItem
            viewController.postDetails["alcoholCategory"] = selectedCategory
            viewController.postDetails["alcoholSubCategory"] = selectedSubCategory
            viewController.postDetail = postDetails
            navigationController?.pushViewController(viewController, animated: true) }
    }
    
    func configureTextFieldWithLeftPadding(_ textField: UITextField, padding: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
    }
    
    private func navigationTitle() {
        let fontSize: CGFloat = 20
        let titleTextAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.rubik(ofSize: fontSize, weight: .regular)
        ]
        navigationController?.navigationBar.titleTextAttributes = titleTextAttributes
        self.title = StringConstants.Category.addLiquorIntoYourCellar.localized()
        
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        backButton.setImage(UIImage(named: StringConstants.ImageConstant.backButton), for: .normal)
        backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    @objc func backAction () {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cameraButtonAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: StoryboardName.common.rawValue, bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "CustomCameraViewController") as? CustomCameraViewController {
            viewController.delegate = self
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    @IBAction func galleryButtonAction(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
}

extension AddPostViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            if let image = info[.originalImage] as? UIImage {
                self.presentCropViewController(with: image)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func presentCropViewController(with image: UIImage) {
        let cropViewController = TOCropViewController(image: image)
        cropViewController.delegate = self
        self.present(cropViewController, animated: true, completion: nil)
    }
    
    
    @objc func imageTapped() {
        guard let image = selectedImage.image else {
            return
        }
        if let imageVC = storyboard?.instantiateViewController(withIdentifier: "ImageViewController") as? ImageViewController {
            imageVC.modalPresentationStyle = .overFullScreen
            imageVC.selectedImage = image
            present(imageVC, animated: true, completion: nil)
        }
    }
    
    func presentImagePickerController() {
        if let popoverPresentationController = imagePickerController.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverPresentationController.permittedArrowDirections = []
        }
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    private func alertMassage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: StringConstants.AllertMessage.ok.localized(), style: .cancel, handler: { _ in
            // print("OK Tapped")
        }))
        self.present(alertController, animated: true)
    }
}

extension UIView {
    @discardableResult
    func addLineDashedStroke(pattern: [NSNumber]?, radius: CGFloat, color: CGColor) -> CALayer {
        let borderLayer = CAShapeLayer()
        borderLayer.strokeColor = color
        borderLayer.lineDashPattern = pattern
        borderLayer.frame = bounds
        borderLayer.fillColor = nil
        borderLayer.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: radius, height: radius)).cgPath
        layer.addSublayer(borderLayer)
        return borderLayer
    }
}

extension AddPostViewController {
    
    func setupFont() {
        let fontType = CurrentFont(rawValue: kUserDefault.getAppFontType() ?? "Normal")
        switch fontType {
        case .normal:
            setupFont(size: 15)
            
        case .large:
            setupFont(size: 17)
            
        case .veryLarge:
            setupFont(size: 19)
            
        case nil:
            break
        }
    }
    
    func setupFont(size:CGFloat) {
        self.nameLabel.font = UIFont.rubik(ofSize: size , weight: .regular)
        self.MarkerLabel.font = UIFont.rubik(ofSize: size , weight: .regular)
        self.originLabel.font = UIFont.rubik(ofSize: size , weight: .regular)
        self.shopFromLabel.font = UIFont.rubik(ofSize: size , weight: .regular)
        self.ageLabel.font = UIFont.rubik(ofSize: size , weight: .regular)
        
        self.nameTextField.font = UIFont.rubik(ofSize: size + 1 , weight: .regular)
        self.makerTextField.font = UIFont.rubik(ofSize: size + 1 , weight: .regular)
        self.originTextField.font = UIFont.rubik(ofSize: size + 1 , weight: .regular)
        self.shopNameTextField.font = UIFont.rubik(ofSize: size + 1 , weight: .regular)
        self.ageTextField.font = UIFont.rubik(ofSize: size + 1 , weight: .regular)
        self.liquorLabel.font = UIFont.rubik(ofSize: size + 1, weight: .medium)
        
        self.cameraLabel.font = UIFont.rubik(ofSize: size -  3, weight: .medium)
        self.albumLabel.font = UIFont.rubik(ofSize: size - 3 , weight: .medium)
    }
    
    func setUpLocalization() {
        self.nameLabel.text = "Name".localized()
        self.MarkerLabel.text = "Maker".localized()
        self.originLabel.text = "Origin".localized()
        self.shopFromLabel.text = "Shop From".localized()
        self.ageLabel.text = "Age(In year)".localized()
        
        self.nameTextField.placeholder = "Name of Your Liquor".localized()
        self.makerTextField.placeholder = "WineMaker / Brewery / Distillery of Your Liquor".localized()
        self.originTextField.placeholder = "country / Region".localized()
        self.shopNameTextField.placeholder = "Where You Purchase?".localized()
        self.ageTextField.placeholder = "Age".localized()
        self.nextButton.setTitle("Next".localized(), for: .normal)
        
        self.liquorLabel.text = "Photo of Your Liquor label".localized()
        self.cameraLabel.text = "By Camera".localized()
        self.albumLabel.text = "Upload From Album".localized()
    }
    
    public func valuesSetup(postDetails: AlcoholDetailsModel) {
        if let postName = postDetails.name {
            self.nameTextField.text = postDetails.name
            self.makerTextField.text = postDetails.maker
            self.originTextField.text = postDetails.origin
            self.shopNameTextField.text = postDetails.shopFrom
            self.ageTextField.selectedItem = "\(postDetails.age ?? 0)"
            self.selectedImage.image = postDetails.image?.toImage()
            liquorLabel.isHidden = true
            cameraImage.isHidden = true
            cameraLabel.isHidden = true
            albumImage.isHidden = true
            albumLabel.isHidden = true
            bottleImage.isHidden = true
            closeButton.isHidden = false
            dashBordView.backgroundColor = .clear
        }
    }
}

extension AddPostViewController: TOCropViewControllerDelegate {
    func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true) {
            self.selectedImage.image = image
            self.liquorLabel.isHidden = true
            self.cameraImage.isHidden = true
            self.cameraLabel.isHidden = true
            self.albumImage.isHidden = true
            self.albumLabel.isHidden = true
            self.bottleImage.isHidden = true
            self.closeButton.isHidden = false
            self.dashBordView.backgroundColor = .clear
        }
    }
    
    func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true, completion: nil)
    }
}

extension AddPostViewController:CustomCameraViewControllerDelegate {
    func PhotoSelected(image: UIImage) {
        selectedImage.image = image
        self.selectedImage.image = image
        self.liquorLabel.isHidden = true
        self.cameraImage.isHidden = true
        self.cameraLabel.isHidden = true
        self.albumImage.isHidden = true
        self.albumLabel.isHidden = true
        self.bottleImage.isHidden = true
        self.closeButton.isHidden = false
        self.dashBordView.backgroundColor = .clear
    }
}
