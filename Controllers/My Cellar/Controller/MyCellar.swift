//
//  ReviewVC.swift
//  YourWineLabel
//
//  Created by IE14 on 11/03/24.
//

import UIKit
import GoogleMobileAds
class MyCellar: UIViewController {
    
    @IBOutlet private var noPostsLabel: UILabel!
    @IBOutlet weak var myCellarLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var filterButton: UIButton!
    
    private var allPosts:[AlcoholDetailsModel]?
    private var searchedPosts:[AlcoholDetailsModel]?
    private var filteredPosts:[AlcoholDetailsModel]?
    var filterDetails:FilterParameters?
    var email = UserDefaultsManager.getUserEmail()
    var isBannerVisible = true
    var scrollToIndex: Int = 1
    let PlusButton = UIButton(type: .custom)
    private var currentFont: CurrentFont = .normal
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        navigationItem.hidesBackButton = false
        navigationController?.setNavigationBarHidden(true, animated: true)
        let nib = UINib(nibName: MyPostsTableViewCell.identifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: MyPostsTableViewCell.identifier)
        buttonSetup()
        if isBannerVisible {
            if UserDefaults.standard.bool(forKey: "isUserSubscribed") == false {
                setUpBannerView()
            }
            
        }
        FetchDataFromFireBase.shared.fetchUserPosts(forEmail: email ?? "") { alcohols in
            self.allPosts = alcohols
            self.searchedPosts = alcohols
            self.activityIndicator.isHidden = true
            self.tableView.reloadData()
            // crash on this
           // self.showIndexInTableView(index: self.scrollToIndex)
            if self.searchedPosts?.count == 0 {
                self.noPostsLabel.isHidden = false
            } else {
                self.noPostsLabel.isHidden = true
            }
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)  // Dismisses the keyboard for all text fields in the view
    }
    
    override func viewWillAppear(_ animated: Bool) {
        searchTextField.text = ""
        navigationController?.setNavigationBarHidden(true, animated: true)
        setUpLocalization()
        setupFont()
        filteredPosts = nil
        if filterDetails == nil {
            filterButton.tintColor = .white
        } else {
            filterButton.tintColor = .blue
        }
        if let scrollTo = UserDefaults.standard.object(forKey: "myCellarSelectedIndex") as? Int {
            self.scrollToIndex = scrollTo
        }
       // showIndexInTableView(index: scrollToIndex)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.searchedPosts = self.allPosts
        filterDetails = nil
        if self.searchedPosts?.count == 0 {
            self.noPostsLabel.isHidden = false
        } else {
            self.noPostsLabel.isHidden = true
        }
    }
    
    func setUpBannerView() {
        let banner: GADBannerView = {
            let banner = GADBannerView()
            //banner.adUnitID = "ca-app-pub-3940256099942544/9214589741" //testing
            banner.adUnitID = "ca-app-pub-9990987621012540/1916913095" //live
            banner.backgroundColor =  UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.8)
            banner.load(GADRequest())
            return banner
        }()
        
        banner.rootViewController = self
        view.addSubview(banner)
        banner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            banner.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
            banner.heightAnchor.constraint(equalToConstant: 50),
            banner.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            banner.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
        view.bringSubviewToFront(banner)
    }
    
    private func buttonSetup() {
        if let image = UIImage(named: StringConstants.ImageConstant.plus)?.withRenderingMode(.alwaysOriginal) {
            PlusButton.setImage(image, for: .normal)
        }
        PlusButton.contentMode = .scaleAspectFit
        PlusButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        PlusButton.translatesAutoresizingMaskIntoConstraints = false
        PlusButton.tintColor = .blue
        view.addSubview(PlusButton)
        NSLayoutConstraint.activate([
            PlusButton.widthAnchor.constraint(equalToConstant: 60),
            PlusButton.heightAnchor.constraint(equalToConstant: 60),
            PlusButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
            PlusButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ])
        view.bringSubviewToFront(PlusButton)
    }
    
    func showIndexInTableView(index: Int) {
        guard tableView.numberOfRows(inSection: 0) > 0 else {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let indexPath = IndexPath(row: index, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            UserDefaults.standard.setValue(0, forKey: "myCellarSelectedIndex")
        }
    }
    
    @objc func buttonTapped() {
        let storyboard = UIStoryboard(name: StoryboardName.common.rawValue, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "CategoryViewController")
        viewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func filterButtonAction(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: StoryboardName.main.rawValue, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "FilterViewController") as! FilterViewController
        searchTextField.text = ""
        if let allPosts = self.filteredPosts {
            searchedPosts = allPosts
        } else {
            guard let allPosts = self.allPosts else {
                return
            }
            searchedPosts = allPosts
        }
        if self.searchedPosts?.count == 0 {
            self.noPostsLabel.isHidden = false
        } else {
            self.noPostsLabel.isHidden = true
        }
        tableView.reloadData()
        viewController.delegate = self
        viewController.email = email
        viewController.filterDetails = filterDetails
        viewController.hidesBottomBarWhenPushed = true
        present(viewController, animated: true)
    }
    
    @IBAction func searchTextField(_ sender: Any) {
        if let char = searchTextField.text {
            let trimmedPrefix = char.trimmingCharacters(in: .whitespacesAndNewlines)
            if char.count == 0 || trimmedPrefix.count == 0 {
                if let allPosts = self.filteredPosts {
                    searchedPosts = allPosts
                } else {
                    guard let allPosts = self.allPosts else {
                        return
                    }
                    searchedPosts = allPosts
                }
                if self.searchedPosts?.count == 0 {
                    self.noPostsLabel.isHidden = false
                } else {
                    self.noPostsLabel.isHidden = true
                }
                tableView.reloadData()
                return
            }
            
            if let allPosts = self.filteredPosts {
                let filterAlcoholDetails = filterAlcoholDetails(alcoholDetails: allPosts, containing: trimmedPrefix)
                searchedPosts = filterAlcoholDetails
                
            } else {
                guard let allPosts = self.allPosts else {
                    return
                }
                let filterAlcoholDetails = filterAlcoholDetails(alcoholDetails: allPosts, containing: trimmedPrefix)
                searchedPosts = filterAlcoholDetails
            }
            if self.searchedPosts?.count == 0 {
                self.noPostsLabel.isHidden = false
            } else {
                self.noPostsLabel.isHidden = true
            }
            tableView.reloadData()
        }
    }
    
    @IBAction func crossButtonAction(_ sender: Any) {
        searchTextField.text = ""
        if let allPosts = self.filteredPosts {
            searchedPosts = allPosts
        } else {
            guard let allPosts = self.allPosts else {
                return
            }
            searchedPosts = allPosts
        }
        if self.searchedPosts?.count == 0 {
            self.noPostsLabel.isHidden = false
        } else {
            self.noPostsLabel.isHidden = true
        }
        tableView.reloadData()
    }
}

extension MyCellar: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedPosts?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MyPostsTableViewCell.identifier,for: indexPath) as! MyPostsTableViewCell
        cell.setupFont()
        cell.setUpLocalization()
        cell.delegate = self
        if let posts = searchedPosts {
            cell.setValues(postDetails: posts[indexPath.row], at: indexPath)
        }
        cell.layoutIfNeeded()
        self.hideLoader()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if isBannerVisible  {
            return 50
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}

extension MyCellar: FilterViewControllerDelegate {
    func applyFilter(alcoholDetails: [AlcoholDetailsModel], filter: FilterParameters?) {

        searchedPosts = alcoholDetails
        filteredPosts = alcoholDetails
        filterDetails = filter
        self.tableView.reloadData()
        if self.searchedPosts?.count == 0 {
            self.noPostsLabel.isHidden = false
        } else {
            self.noPostsLabel.isHidden = true
        }
        
        if filterDetails == nil {
            filterButton.tintColor = .white
        } else {
            filterButton.tintColor = .blue
        }
    }
}

extension MyCellar {
    func filterAlcoholDetails(alcoholDetails: [AlcoholDetailsModel], containing prefix: String) -> [AlcoholDetailsModel] {
        let filteredDetails = alcoholDetails.filter { detail in
            let lowercasePrefix = prefix.lowercased()
            let nameMatches = detail.name?.lowercased().contains(lowercasePrefix) ?? false
            let makerMatches = detail.maker?.lowercased().contains(lowercasePrefix) ?? false
            let originMatches = detail.origin?.lowercased().contains(lowercasePrefix) ?? false
            let shopFromMatches = detail.shopFrom?.lowercased().contains(lowercasePrefix) ?? false
            let reviewMatches = detail.yourReview?.lowercased().contains(lowercasePrefix) ?? false
            let remarkMatches = detail.yourRemark?.lowercased().contains(lowercasePrefix) ?? false
            return nameMatches || makerMatches || originMatches || shopFromMatches || reviewMatches || remarkMatches
        }
        return filteredDetails
    }
    
    private func setUpLocalization(){
        self.myCellarLabel.text = "My Cellar".localized()
        self.searchTextField.placeholder = "Search".localized()
        self.noPostsLabel.text = "No Cellar".localized()
    }
}

extension MyCellar {
    func setupFont() {
        let fontType = CurrentFont(rawValue: kUserDefault.getAppFontType() ?? "Normal")
        switch fontType {
        case .normal:
            self.myCellarLabel.font = UIFont.rubik(ofSize: 34 , weight: .medium)
        case .large:
            self.myCellarLabel.font = UIFont.rubik(ofSize: 36 , weight: .medium)
        case .veryLarge:
            self.myCellarLabel.font = UIFont.rubik(ofSize: 38 , weight: .medium)
        case nil:
            break
        }
        tableView.reloadData()
    }
}

extension MyCellar: MyPostsTableViewCellDelegate {
    func showToast(message: String) {
        ToastManager.showToast(message: message, onView: self.view)
    }
    
    func shareButtonTapped(at indexPath: IndexPath, documentID: String, sender: UIButton) {
        guard let post = allPosts?[indexPath.row] else {
            return
        }
        // Create text for sharing
        var sharingText = """
        I wanna share you this \(post.category!), sure you will find this great too!
        Category: \(post.category!)
        Sub category: \(post.type!)
        Name: \(post.name!)
        Maker: \(post.maker!)
        Origin: \(post.origin!)
        Shop from: \(post.shopFrom!)
        Price: \(post.currency!)\(post.price!)
        Purchase Date: \(post.purchaseDate!)
        Rating: \(String(repeating: "⭐️", count: post.yourRating!))
        Do you recommend?: \(post.doYouRecommended!)
        Review: \(post.yourReview!)
        """
        // Add Pocket Cellar link
        sharingText += "\n\nCheck out Pocket Cellar for more cellar reviews and recommendations: https://apps.apple.com/us/app/pocket-cellar/id6497877589"
        // Create activity view controller
        guard let imageData = post.image?.toImage() else {
            print("Failed to convert image to data")
            return
        }
        let activityViewController = UIActivityViewController(activityItems: [sharingText,imageData], applicationActivities: nil)
        activityViewController.setValue("Pocket Cellar", forKey: "subject")
        activityViewController.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact
        ]
        // Present the view controller
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        present(activityViewController, animated: true, completion: nil)
    }
    
    
    func deleteOrShareButtonTapped(at indexPath: IndexPath, documentID: String, sender: UIButton) {
        alertMassageForDelete(at: indexPath, documentID: documentID)
    }
    
    
    func didTapOnImage(image: String) {
        let storyboard = UIStoryboard(name: StoryboardName.common.rawValue, bundle: nil)
        if let imageViewController = storyboard.instantiateViewController(withIdentifier: "ImageViewController") as? ImageViewController {
            imageViewController.selectedImage = image.toImage()
            present(imageViewController, animated: true)
        }
    }
    
    private func alertMassageForDelete(at indexPath: IndexPath,documentID: String) {
        let massage = StringConstants.AllertMessage.deleteMessage.localized()
        let alertController = UIAlertController(title: StringConstants.AllertMessage.delete.localized(), message: massage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: StringConstants.AllertMessage.cancel.localized(), style: .cancel, handler: { _ in }))
        let deleteButton = UIAlertAction(title: StringConstants.AllertMessage.delete.localized(), style: .default, handler: { _ in
            if let searchedPosts = self.searchedPosts, searchedPosts.indices.contains(indexPath.row) {
                self.searchedPosts?.remove(at: indexPath.row)
            }
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            FetchDataFromFireBase.shared.deletePost(withDocumentID: documentID) { error in
                if let error = error {
                    print("Error deleting post: \(error.localizedDescription)")
                } else {
                    self.allPosts = self.searchedPosts
                    NotificationCenter.default.post(name: Notification.Name("MyCellarDeleted"), object: nil)
                }
            }
            self.updateIndexPathsOfVisibleCells()
            if self.searchedPosts?.isEmpty ?? true {
                self.noPostsLabel.isHidden = false
            }
        })
        deleteButton.setValue(UIColor.red, forKey: "titleTextColor")
        alertController.addAction(deleteButton)
        self.present(alertController, animated: true)
    }
    
    private func updateIndexPathsOfVisibleCells() {
        guard let visibleCells = tableView.visibleCells as? [MyPostsTableViewCell] else {
            return
        }
        
        for cell in visibleCells {
            if let currentIndexPath = tableView.indexPath(for: cell) {
                cell.indexPath = currentIndexPath
            }
        }
    }
    
    func editButtonTapped(postDetails: AlcoholDetailsModel) {
        navigateToEditPost(postDetails: postDetails)
    }
    
    private func navigateToEditPost(postDetails: AlcoholDetailsModel) {
        let storyboard = UIStoryboard(name: StoryboardName.common.rawValue, bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "AddPostViewController") as? AddPostViewController {
            controller.postDetails = postDetails
            controller.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}
