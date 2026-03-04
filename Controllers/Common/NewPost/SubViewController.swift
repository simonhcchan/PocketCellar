//
//  SubViewController.swift
//  PocketCellar
//
//  Created by IE15 on 13/03/24.
//

import UIKit

class SubViewController: UIViewController {
    
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var barView: UIView!
    
    private var alcoholSubCategoryArray:[AlcoholSubGroup] = []
    private var selectedIndex = -1
    public var selectedAlcoholCategory: String = ""
    private var fontSize: CGFloat = 34
    private var textForCheck: String?
    private let PlusButton = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FetchDataFromFireBase.shared.fetchSubCategoryOFAlcohols(name: selectedAlcoholCategory){ alcohols in
            self.alcoholSubCategoryArray = alcohols
            self.alcoholSubCategoryArray.sort { $0.sequence < $1.sequence }
            print(self.selectedAlcoholCategory)
            self.activityIndicator.isHidden =  true
            self.collectionView.reloadData()
        }
        navigationController?.navigationBar.tintColor = .black
        navigationTitle()
        
        let nib = UINib(nibName: StringConstants.Category.categoryCollectionViewCell, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: StringConstants.Category.categoryCollectionViewCell)
        collectionView.delegate = self
        collectionView.dataSource = self
        CollectionViewHeader()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        setUpNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setUpNavigationBar(with: .white)
    }
    
    private func CollectionViewHeader(){
        let titleLabel = UILabel()
        titleLabel.text = StringConstants.Category.subCategory.localized()
        titleLabel.font = UIFont.rubik(ofSize: 22, weight: .regular)
        titleLabel.textColor = UIColor(named: StringConstants.ColorConstant.blackColor)
        collectionView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: collectionView.topAnchor, constant: 25),
            titleLabel.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor)       ,
            titleLabel.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 25),
        ])
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
}

extension SubViewController:UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return alcoholSubCategoryArray.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StringConstants.Category.categoryCollectionViewCell, for: indexPath) as? CategoryCollectionViewCell else { return UICollectionViewCell() }
        let alcohol = alcoholSubCategoryArray[indexPath.row]
        cell.categoryImage.image = alcohol.image.toImage()
        cell.categoryNameLabel.text = alcohol.name.localized()
        let fontType = CurrentFont(rawValue: kUserDefault.getAppFontType() ?? "Normal")
        switch fontType {
        case .normal:
            cell.categoryNameLabel.font = UIFont.rubik(ofSize: 13 , weight: .regular)
            
        case .large:
            cell.categoryNameLabel.font = UIFont.rubik(ofSize: 15 , weight: .regular)
            
        case .veryLarge:
            cell.categoryNameLabel.font = UIFont.rubik(ofSize: 17 , weight: .regular)
            
        case nil:
            break
        }
        if indexPath.row == selectedIndex {
            cell.categoryImage.layer.borderWidth = 3
            cell.categoryImage.layer.borderColor = UIColor(named: StringConstants.ColorConstant.primaryColor)?.cgColor
            cell.categoryImage.clipsToBounds = true
        } else {
            cell.categoryImage.layer.borderWidth = 0
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.section +  indexPath.row
        collectionView.reloadData()
        let storyboard = UIStoryboard(name: StoryboardName.common.rawValue, bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: StringConstants.Category.addPostViewController) as? AddPostViewController {
            viewController.selectedCategory = selectedAlcoholCategory
            viewController.selectedSubCategory = alcoholSubCategoryArray[indexPath.row].name
            navigationController?.pushViewController(viewController, animated: true) }
    }
}

extension SubViewController:UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 60, left: 40, bottom: 10, right: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 30
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if alcoholSubCategoryArray.count % 2 == 1 && indexPath.row == alcoholSubCategoryArray.count - 1 {
            return CGSize(width: UIScreen.main.bounds.width - 80, height: 168)
        }
        return CGSize(width: 114, height: 168)
    }
}
