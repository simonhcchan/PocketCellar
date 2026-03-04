//
//  CategoryViewController.swift
//  PocketCellar
//
//  Created by IE15 on 13/03/24.
//

import UIKit

class CategoryViewController: UIViewController {
    
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var barView: UIView!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    private var alcoholCategoryArray:[AlcoholGroup] = []
    private var selectedIndex = -1
    private let PlusButton = UIButton(type: .custom)
    private let sectionInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    private var fontSize: CGFloat = 34
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FetchDataFromFireBase.shared.fetchCategoryOFAlcohols { alcohols in
            self.alcoholCategoryArray = alcohols
            self.alcoholCategoryArray.sort { $0.sequence < $1.sequence }
            self.collectionView.reloadData()
            self.activityIndicator.isHidden =  true
        }
        
        navigationController?.navigationBar.tintColor = .black
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
        navigationTitle()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        setUpNavigationBar(with: .white)
    }
    
    private func CollectionViewHeader(){
        let titleLabel = UILabel()
        titleLabel.text = StringConstants.Category.selectCategory.localized()
        titleLabel.font = UIFont.rubik(ofSize: fontSize - 12, weight: .regular)
        titleLabel.textColor = UIColor(named: StringConstants.ColorConstant.blackColor)
        collectionView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: collectionView.topAnchor, constant: 25),
            titleLabel.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 25),
        ])
    }
    
    private func navigationTitle() {
        self.title = StringConstants.Category.addLiquorIntoYourCellar.localized()
        let titleTextAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.rubik(ofSize: fontSize, weight: .regular)
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

extension CategoryViewController:UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return alcoholCategoryArray.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StringConstants.Category.categoryCollectionViewCell, for: indexPath) as? CategoryCollectionViewCell else { return UICollectionViewCell() }
        let  alcohol = alcoholCategoryArray[indexPath.row]
        cell.categoryImage.image = alcohol.image.toImage()
        cell.categoryNameLabel.text = alcohol.name.localized()
        let fontType = CurrentFont(rawValue: kUserDefault.getAppFontType() ?? "Normal")
        switch fontType {
        case .normal:
            fontSize = 34
            cell.categoryNameLabel.font = UIFont.rubik(ofSize: 13 , weight: .regular)
        case .large:
            fontSize = 36
            cell.categoryNameLabel.font = UIFont.rubik(ofSize: 15 , weight: .regular)
        case .veryLarge:
            fontSize = 38
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
        if let viewController = storyboard.instantiateViewController(withIdentifier: StringConstants.Category.addPostViewController) as? AddPostViewController ,indexPath.row == 6 {
            let  alcohol = alcoholCategoryArray[indexPath.row]
            viewController.selectedCategory = alcohol.name
            viewController.selectedSubCategory = "NA"
            navigationController?.pushViewController(viewController, animated: true)
            return
        }
        
        if let viewController = storyboard.instantiateViewController(withIdentifier: StringConstants.Category.subViewController) as? SubViewController {
            let  alcohol = alcoholCategoryArray[indexPath.row]
            viewController.selectedAlcoholCategory = alcohol.name
            navigationController?.pushViewController(viewController, animated: true) }
    }
}

extension CategoryViewController: UICollectionViewDelegateFlowLayout{
    
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
        if alcoholCategoryArray.count % 2 == 1 && indexPath.row == alcoholCategoryArray.count - 1 {
            return CGSize(width: UIScreen.main.bounds.width - 80, height: 168)
        }
        return CGSize(width: 114, height: 168)
    }
}
